#!/bin/bash

ENV=${1:-dev}
function prop {
    grep "${1}" ${ENV}.properties|cut -d'=' -f2
}

# start server
./$(prop 'WLP_PATH')/bin/server start $(prop 'SERVER_NAME')

# user hint
echo 'Server URL: http://localhost:8080/'
