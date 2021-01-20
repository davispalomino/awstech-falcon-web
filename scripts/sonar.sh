#!/bin/bash

sonar=$1
token=$2

# capturando id de tarea
URLTASKID=$(cat ./app/.scannerwork/report-task.txt | grep ceTaskUrl | cut -c11-)

# esperando estatus de tarea
echo -e "\n\e[94m[INFO]\e[0m COMPROBACION DEL ESTADO DE SONARQUBE\n"
while [[ "$(curl --silent -X GET -u "${token}":'' "${URLTASKID}" | jq -r '.task.status')" != "SUCCESS" ]]; do sleep 1; done

# capturando id de analisis
ANALISISID=$(curl --silent -X GET -u "${token}":"" "${URLTASKID}" | jq -r '.task.analysisId')

# capturando estatus de proyecto
TYPE=$(curl --silent -X GET -u "${token}":""  "https://${sonar}/api/qualitygates/project_status?analysisId=${ANALISISID}" | jq -r '.projectStatus.status')

# capturando resultados
CONDITIONS=$(curl --silent -X GET -u "${token}":""  "https://${sonar}/api/qualitygates/project_status?analysisId=${ANALISISID}" | jq -r '.projectStatus.conditions')
if [ "${TYPE}" = "OK" ] ; then echo -e "\n\e[94m[INFO]\e[0m \e[30;48;5;82mSONARQUBE PASSED\e[0m"; echo -e $CONDITIONS | jq -jr '.[] |"\n[INFO] ", .metricKey, " : ", .status,"\n"'; else echo -e "\n\e[94m[INFO]\e[0m \e[101;39mSONARQUBE FAILED\e[0m"; echo -e $CONDITIONS | jq -jr '.[] |"\n[INFO] ", .metricKey, " : ", .status,"\n"'; exit 1; fi

# eliminando archivos temporales
rm -rf ${PWD}/app/build/sonar/ ${PWD}/app/.sonar
