#!/bin/bash

# Run official health check command
# https://docs.mulesoft.com/gateway/latest/flex-conn-readiness-liveness#configure-a-liveness-probe
docker exec flex-gateway flexctl probe --check=liveness
exit_code=$?

# Both commands succeeded
if [ $exit_code -eq 0 ]; then
  echo 'okay' >/usr/share/nginx/html/custom-health-check.html
else
  echo 'fail'
  rm -f /usr/share/nginx/html/custom-health-check.html
fi
