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

There are two options for running the tests.

### Option 1 - rover

Run the rover test command:

```shell
rover test \
      -b <path to tests folder> \
      -env <environment name> \
      -level <level> \
      -tfstate <name of deployed state file> \
      -d
```

### Option 2 - Debugging or cli invocation of go test

- Download your state file from azure blob storage.
- Rename the file to terraform.tfstate and place it in a known location.
- create a .env file in the tests folder with the following structure

```shell
 STATE_FILE_PATH=<path to state file>
 ENVIRONMENT=<deployed caf environment>
 ARM_SUBSCRIPTION_ID=<subscription id>
```

Note: if running through rover, you don't have to set these as rover test exports the values.

When running through go test you must specifiy the build tag and ensure that the correct state file is loaded into STATE_FILE_PATH.

eg
`go test -tags level0 -v
`

You can only test one level at a time.