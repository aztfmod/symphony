# Run each command manually and in order to deploy the relevant level/component
# Launchpad deployment only necessary when using Gitlab Pipelines for Platform and App deployments

export CAF_DIR=$(pwd)
export caf_environment=demo

# Local launchpad deployment

rover -lz $CAF_DIR/caf_modules/landingzones/caf_launchpad \
  -launchpad \
  -var-folder $CAF_DIR/config_launchpad/level0/launchpad \
  -parallelism 30 \
  -level level0 \
  -env ${caf_environment} \
  -a apply

# Local platform deployments

rover -lz $CAF_DIR/caf_modules/landingzones/caf_solution \
  -tfstate caf_foundations.tfstate \
  -var-folder $CAF_DIR/config_platform/level1/foundations \
  -parallelism 30 \
  -level level1 \
  -env ${caf_environment} \
  -a apply

rover -lz $CAF_DIR/caf_modules/landingzones/caf_solution \
  -tfstate caf_shared_services.tfstate \
  -var-folder $CAF_DIR/config_platform/level2/shared_services \
  -parallelism 30 \
  -level level2 \
  -env ${caf_environment} \
  -a apply

rover -lz $CAF_DIR/caf_modules/landingzones/caf_solution \
  -tfstate networking_hub.tfstate \
  -var-folder $CAF_DIR/config_platform/level2/networking/hub \
  -parallelism 30 \
  -level level2 \
  -env ${caf_environment} \
  -a apply

# Local app deployments

rover -lz $CAF_DIR/caf_modules/landingzones/caf_solution \
  -tfstate landing_zone_aks.tfstate \
  -var-folder $CAF_DIR/config_app_argocd/level3/aks \
  -parallelism 30 \
  -level level3 \
  -env ${caf_environment} \
  -a apply

export appname="argocd"

rover -lz $CAF_DIR/caf_modules_argocd/landingzones/aks_applications \
  -tfstate argocd1.tfstate \
  -var-folder $CAF_DIR/config_app_argocd/level4/argocd \
  -var tags={application=\"${appname}\"} \
  -level level4 \
  -env ${caf_environment} \
  -a apply
