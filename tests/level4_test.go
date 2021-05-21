// +build level4

package caf_tests

import (
	"bytes"
	"crypto/tls"
	"encoding/json"
	"fmt"
	"strings"
	"testing"

	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/stretchr/testify/assert"
	corev1 "k8s.io/api/core/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

var argoTestOptions = struct {
	argoServerService string
	argoSecretName    string
}{
	argoServerService: "argo-argocd-server",
	argoSecretName:    "argocd-initial-admin-secret",
}

func getKubectlOptions() *k8s.KubectlOptions {
	return k8s.NewKubectlOptions("", "", "argocd")
}

var argoCdExpectedServiceNames = []struct {
	testID      int
	serviceName string
	nameSpace   string
}{
	{
		testID:      1,
		serviceName: "argo-argocd-application-controller",
		nameSpace:   "argocd",
	},
	{
		testID:      2,
		serviceName: "argo-argocd-dex-server",
		nameSpace:   "argocd",
	},
	{
		testID:      3,
		serviceName: "argo-argocd-redis",
		nameSpace:   "argocd",
	},
	{
		testID:      4,
		serviceName: "argo-argocd-repo-server",
		nameSpace:   "argocd",
	},
	{
		testID:      5,
		serviceName: "argo-argocd-server",
		nameSpace:   "argocd",
	},
}

func TestArgoServiceNamesAreCorrect(t *testing.T) {
	t.Parallel()
	options := getKubectlOptions()
	for _, test := range argoCdExpectedServiceNames {
		testDisplay := fmt.Sprintf("%d - %s", test.testID, fmt.Sprintf("Verifying %s", test.serviceName))
		t.Run(testDisplay, func(t *testing.T) {
			service := k8s.GetService(t, options, test.serviceName)
			assert.Equal(t, test.serviceName, service.Name, "Incorrect k8s Service Name.")
			assert.Equal(t, test.nameSpace, service.Namespace, "Incorrect k8s Namespace.")
		})
	}
}

func TestArgoPodCountIsCorrect(t *testing.T) {
	//arrange
	t.Parallel()
	options := getKubectlOptions()
	listOptions := metav1.ListOptions{}

	//act
	pods := k8s.ListPods(t, options, listOptions)

	//assert
	assert.Equal(t, 5, len(pods), "Incorrect k8s pod count.")
}

func TestArgoReplicaSetCountIsCorrect(t *testing.T) {
	//arrange
	t.Parallel()
	options := getKubectlOptions()

	//act
	replicaSets := k8s.ListReplicaSets(t, options, metav1.ListOptions{})

	//assert
	assert.Equal(t, 5, len(replicaSets), "Incorrect k8s replica set count.")
}

func TestArgoCDLocalPortForwardWorks(t *testing.T) {
	t.Parallel()
	options := getKubectlOptions()

	tunnel := k8s.NewTunnel(options, k8s.ResourceTypeService, argoTestOptions.argoServerService, 0, 8080)
	defer tunnel.Close()
	tunnel.ForwardPort(t)

	tlsConfig := tls.Config{}
	tlsConfig.InsecureSkipVerify = true

	http_helper.HttpGetWithCustomValidation(
		t,
		fmt.Sprintf("http://%s", tunnel.Endpoint()),
		&tlsConfig,
		verifyArgoCdLoginPage,
	)
}

func verifyArgoCdLoginPage(statusCode int, body string) bool {
	if statusCode != 200 {
		return false
	}
	return strings.Contains(body, "Argo CD") && strings.Contains(body, "Argo CD CLI")
}

func TestArgoCDInitialAdminSecretExists(t *testing.T) {
	//arrange
	t.Parallel()
	options := getKubectlOptions()

	//act
	secret := k8s.GetSecret(t, options, argoTestOptions.argoSecretName)

	//assert
	assert.Equal(t, argoTestOptions.argoSecretName, secret.Name, "Initial Secret Not found")
}

func TestArgoCDInitialAdminSecretIsNotBlank(t *testing.T) {
	//arrange
	t.Parallel()
	options := getKubectlOptions()

	//act
	secret := k8s.GetSecret(t, options, argoTestOptions.argoSecretName)
	password := getPassword(secret)

	//assert
	assert.NotEqual(t, "", password, "Initial Secret is blank")
}

func TestArgoCDApiAuth(t *testing.T) {
	//arrange
	t.Parallel()
	options := getKubectlOptions()

	//act
	secret := k8s.GetSecret(t, options, argoTestOptions.argoSecretName)
	password := getPassword(secret)

	tunnel := k8s.NewTunnel(options, k8s.ResourceTypeService, argoTestOptions.argoServerService, 0, 8080)
	defer tunnel.Close()
	tunnel.ForwardPort(t)

	tlsConfig := tls.Config{}
	tlsConfig.InsecureSkipVerify = true

	token := getArgoToken(t, tunnel, password, tlsConfig)
	applications := getArgoApplications(t, tunnel, token, tlsConfig)

	//assert
	assert.NotEmpty(t, applications.Metadata.ResourceVersion, "Cannot fetch applications from authenticated api.")
}

func getArgoApplications(t *testing.T, tunnel *k8s.Tunnel, token string, tlsConfig tls.Config) ArgoApplicationsResponse {
	headers := map[string]string{"Authorization": fmt.Sprintf("Bearer %s", token)}
	url := fmt.Sprintf("http://%s/api/v1/applications", tunnel.Endpoint())
	_, response := http_helper.HTTPDo(t, "GET", url, nil, headers, &tlsConfig)
	var applications ArgoApplicationsResponse
	json.Unmarshal([]byte(response), &applications)
	return applications
}
func getArgoToken(t *testing.T, tunnel *k8s.Tunnel, password string, tlsConfig tls.Config) string {
	auth := fmt.Sprintf("{\"username\":\"%s\",\"password\":\"%s\"}", "admin", password)
	body := bytes.NewReader([]byte(auth))
	url := fmt.Sprintf("http://%s/api/v1/session", tunnel.Endpoint())
	_, response := http_helper.HTTPDo(t, "POST", url, body, nil, &tlsConfig)
	var tokenResponse ArgoTokenResponse
	json.Unmarshal([]byte(response), &tokenResponse)
	return tokenResponse.Token
}
func getPassword(secret *corev1.Secret) string {
	for key, value := range secret.Data {
		if key == "password" {
			return fmt.Sprintf("%s", value)
		}
	}
	return ""
}

type ArgoTokenResponse struct {
	Token string
}

type ArgoApplicationsResponse struct {
	Metadata struct {
		ResourceVersion string `json:"resourceVersion"`
	} `json:"metadata"`
	Items interface{} `json:"items"`
}
