#!/usr/bin/env bash
#set -euo pipefail

declare me=`basename "$0"`

registration_token=`sudo gitlab-rails runner -e production "puts Gitlab::CurrentSettings.current_application_settings.runners_registration_token"`

echo $registration_token