FROM aztfmod/rover:0.13.6-2104.1611

RUN sudo apt-get update \
  && sudo apt-get install -y wget jq nano

# Install GO Lang for testing using Terratest
RUN sudo wget https://golang.org/dl/go1.16.linux-amd64.tar.gz \
  && sudo tar -C /usr/local -xzf go1.16.linux-amd64.tar.gz

# Install ArgoCD for CAF sample application use
RUN VERSION=$(curl --silent "https://api.github.com/repos/argoproj/argo-cd/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/') \
  && sudo curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/download/$VERSION/argocd-linux-amd64 \
  && sudo chmod +x /usr/local/bin/argocd
