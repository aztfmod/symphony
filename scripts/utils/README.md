# Utility scripts

## Clone Repos

This script is used to facilitate the creation of Gitlab group/repos in the target server from:
- An existing GitLab instance, or
- A local folder

In addition to the PAT, please ensure you have added a SSH key to the GitLab instances you are working with to be able to access the repositories.

``` bash
# GitLab group w/repos to GitLab clone
./clone-repos.sh
  -g reference_app_caf \
  -sp <source-pat> -sd <source-fqdn> \
  -tp <target-pat> -td <target-fqdn> \
  -e <environment> \
  -d -o

# Folder group w/sub_folder repos to Gitlab clone
./clone-repos.sh
  -s /workspaces/symphony/caf \
  -tp <target-pat> -td <target-fqdn> \
  -e <environment> \
  -d  -o
```

## Remove resources

This script is used to remove an entire collection of resource groups that match the environment passed to the script.

```bash
# Remove demo environment
./remove-caf-resources.sh -e demo

# Confirm deletion y/n?

# Monitor deletion progress
watch -n 5 "az group list -o table | grep Deleting"

# Ctrl+D to exit watch
```
