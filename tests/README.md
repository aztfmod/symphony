# CAF Landing Zones Tests

In the `./tests` folder you can find [Terratest](https://github.com/gruntwork-io/terratest) test scripts for the following Landing Zones;

- Launchpad
- Foundation
- Shared Services
- Networking

> These tests are not **provision** or **destroy** resources on the _Azure Subscription_

## Prerequisites

Execute the following commands to have rover running on your environment;

```bash
# Clone the rover repo and cd into it
git clone https://github.com/aztfmod/rover
cd rover

# Create /tf folder at the root
mkdir -p /tf

# Copy the scripts folder into the /tf folder
cp -r scripts /tf/rover

# Give rover alias to /tf/rover/rover.sh file
alias rover=/tf/rover/rover.sh
```

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

To run the tests, execute the following command;

```bash
go test .
```
