#!/bin/bash

ENV=${1:-dev}
function prop {
    grep "${1}" ${ENV}.properties|cut -d'=' -f2
}

# define JAVA_HOME
JAVA_HOME=$PWD/$(prop 'JAVA_HOME')
echo $JAVA_HOME
PATH=$PATH:$JAVA_HOME/bin

# create server
./$(prop 'WLP_PATH')/bin/server create $(prop 'SERVER_NAME')

# set JAVA_HOME for the new server
echo 'set JAVA_HOME'
echo $'\n''JAVA_HOME='$JAVA_HOME >> $(prop 'WLP_PATH')/usr/servers/$(prop 'SERVER_NAME')/server.env

# replace javaee-8.0 feature with required ones
echo 'register features'
features=""
for i in $(echo $(prop 'LIBERTY_FEATURES') | sed "s/,/ /g")
do
    # create feature entry
    features=${features}'\n<feature>'${i}'<\/feature>'
done
sed -i -e "s/<feature>javaee-8.0<\/feature>/"${features}"/g" $(prop 'WLP_PATH')/usr/servers/$(prop 'SERVER_NAME')/server.xml

# replace ports
echo 'replace ports'
sed -i -e "s/9080/8080/g" $(prop 'WLP_PATH')/usr/servers/$(prop 'SERVER_NAME')/server.xml
sed -i -e "s/9443/8443/g" $(prop 'WLP_PATH')/usr/servers/$(prop 'SERVER_NAME')/server.xml

# copy libs
echo 'copy libs'
cp -r $(prop 'ADDITIONAL_LIBS') $(prop 'WLP_PATH')/usr/servers/$(prop 'SERVER_NAME')/$(prop 'ADDITIONAL_LIBS')

# register databases and so on specified in properties (app specific stuff here, Oracle example below)
echo 'register database'
sed -i -e "s/<\/server>/<!--\/server-->/g" $(prop 'WLP_PATH')/usr/servers/$(prop 'SERVER_NAME')/server.xml

echo $'\n''<dataSource id="DefaultDataSource" jndiName="jdbc/myappjdbc">' >> $(prop 'WLP_PATH')/usr/servers/$(prop 'SERVER_NAME')/server.xml
echo $'<jdbcDriver libraryRef="OracleLib"/>' >> $(prop 'WLP_PATH')/usr/servers/$(prop 'SERVER_NAME')/server.xml
echo $'<properties.oracle URL="'$(prop 'DATABASE_URL')'" user="'$(prop 'DATABASE_USER')'" password="'$(prop 'DATABASE_PASSWORD')'"/>' >> $(prop 'WLP_PATH')/usr/servers/$(prop 'SERVER_NAME')/server.xml
echo $'</dataSource>' >> $(prop 'WLP_PATH')/usr/servers/$(prop 'SERVER_NAME')/server.xml
echo $'\n''<library id="OracleLib">' >> $(prop 'WLP_PATH')/usr/servers/$(prop 'SERVER_NAME')/server.xml
echo $'<file name="'$(prop 'ADDITIONAL_LIBS')'/ojdbc7.jar"/>' >> $(prop 'WLP_PATH')/usr/servers/$(prop 'SERVER_NAME')/server.xml
echo $'</library>' >> $(prop 'WLP_PATH')/usr/servers/$(prop 'SERVER_NAME')/server.xml

echo $'\n\n''</server>' >> $(prop 'WLP_PATH')/usr/servers/$(prop 'SERVER_NAME')/server.xml

echo 'DONE!'