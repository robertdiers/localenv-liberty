#!/bin/bash

ENV=${1:-dev}
function prop {
    grep "${1}" ${ENV}.properties|cut -d'=' -f2
}

# start server
./$(prop 'WLP_PATH')/bin/server stop $(prop 'SERVER_NAME')
