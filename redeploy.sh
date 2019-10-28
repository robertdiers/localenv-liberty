#!/bin/bash

ENV=${1:-dev}
function prop {
    grep "${1}" ${ENV}.properties|cut -d'=' -f2
}

# stop servers
./stop.sh

# delete deployment
rm $(prop 'WLP_PATH')/usr/servers/$(prop 'SERVER_NAME')/dropins/$(prop 'DEPLOYMENT_NAME')

# place new one
cp ../$(prop 'DEPLOYMENT_PROJECT')/target/$(prop 'DEPLOYMENT_NAME') $(prop 'WLP_PATH')/usr/servers/$(prop 'SERVER_NAME')/dropins/$(prop 'DEPLOYMENT_NAME')

# start servers
./start.sh
