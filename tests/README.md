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

Invoke the tests via the provided bash script. `./run_tests.sh -e demo -d`

run_tests.sh is invoked with -e to specify the environment name. In this case we are using demo because that is what is specified in local.sh
