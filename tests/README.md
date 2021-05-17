# CAF Landing Zones Tests

In the `./tests` folder you can find [Terratest](https://github.com/gruntwork-io/terratest) test scripts for the following Landing Zones;

- Launchpad
- Foundation
- Shared Services
- Networking

## Prerequisites

- Clone the Rover repo

  ```bash
  git clone https://github.com/aztfmod/rover
   ```

- Open the repo in VSCode and reopen in a dev container.
- Clone the symphony repo to /tf/caf/symphony
  
  ```bash
  git clone git@github.com:aztfmod/symphony.git /tf/caf/symphony
  ```

- Create a local caf environment by running the file local.sh in the caf folder of this repo.

- Navigate to the tests folder of this repo. `cd tests`

## Expose the argocd service

- `az aks list --query "[?tags.landingzone].{name:name,resourceGroup:resourceGroup}" -o table `
  Note the cluster name and rg name

- `az aks get-credentials -n <name from above> -g <rg name from above>`
- In a seperate terminal window `kubectl port-forward svc/argo-argocd-server 9090:80 -n argocd`
  Keep this window alive to ensure the port forward to the cluster is up.
  
## Guideline to run the tests

Clone `symphony` repo on your computer (_prefferably onto a WSL instance_)

Run the following command in the `./tests` folder to download _go_ dependencies;

```bash
go get
```

In case of an issue, run the following command to make sure all the dependencies are still available;

```bash
go mod tidy
```

Ensure your bash env has gcc installed. If not then install with the following commands
```bash
sudo apt-get update
sudo apt-get upgrade
sudo apt install build-essential
```

To run the tests, execute the following command;

Invoke the tests via the provided bash script. `./run_tests.sh -e local-test -d`

run_tests.sh is invoked with -e to specificy the environment name. In this case we are using local-test because that is what is specified in local.sh
