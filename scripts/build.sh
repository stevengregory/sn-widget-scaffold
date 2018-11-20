#!/usr/bin/env bash

source ./scripts/config.sh
source ./scripts/messages.sh

echo -e "${GREEN}${START_MSG}${RESET}"

function create_option_dir() {
  mkdir ${1}
  touch ${1}/${PREFIX}${WIDGET}.${2}
}

function fetch_github_user() {
  if [[ $(git config user.name) ]]; then
    echo $(git config user.name)
  else
    echo ${TEMP_CONTRIB}
  fi
}

declare -a args=($@)
declare -a widgetDir=()
for i in "${args[@]}"; do
  if [[ ${i} == "-a" ]]; then
    isAngularTemplate=true
  elif [[ ${i} == "-s" ]]; then
    isScriptInclude=true
  elif [[ ${i} == "-u" ]]; then
    isUIScript=true
  else
    widgetDir+=$(echo -${i} | tr '[:upper:]' '[:lower:]')
    readmeName+=$(tr '[:lower:]' '[:upper:]' <<< ${i:0:1})${i:1}' '
  fi
done
WIDGET=$(printf "%s" "${widgetDir[@]}" && echo "")

echo -e "${GREEN}${BRANCH_MSG}${RESET}"

git checkout -b feature/${PREFIX}${WIDGET} master

echo -e "${GREEN}${SCAFFOLD_MSG}${RESET}"

mkdir ${PREFIX}${WIDGET} && cd $_

curl ${README_GIST} > README.md
curl ${CONFIG_GIST} > config.json

echo -e "${GREEN}${UPDATE_MSG}${RESET}"
if [[ ${readmeName} == *-* ]]; then
  declare -a dashReadme=()
  RM=${readmeName}
  IFS='-' read -ra README <<< "$RM"
  for i in "${README[@]}"; do
    if [[ ${i} != "-a" && ${i} != "-s" && ${i} != "-u" ]]; then
      dashReadme+=$(tr '[:lower:]' '[:upper:]' <<< ${i:0:1})${i:1}' '
    fi
  done
  sed -i '' -e "s/${TEMP_NAME}/${dashReadme%??}/g" README.md
  sed -i '' -e "s/${TEMP_NAME}/${dashReadme%??}/g" config.json
else
  sed -i '' -e "s/${TEMP_NAME}/${readmeName%?}/g" README.md
  sed -i '' -e "s/${TEMP_NAME}/${dashReadme%??}/g" config.json
fi
sed -i '' -e "s/${TEMP_CONTRIB}/$(fetch_github_user)/g" config.json
sed -i '' -e "s/${TEMP_DIR}/${PREFIX}${WIDGET}/g" README.md

touch ${PREFIX}${WIDGET}.${UPDATE_SET}

if [[ ${isAngularTemplate} = true ]]; then
  create_option_dir ${ANGULAR_TEMPLATE_DIR} ${HTML}
fi

if [[ ${isScriptInclude} = true ]]; then
  create_option_dir ${SCRIPT_INCLUDE_DIR} ${SERVER}
fi

if [[ ${isUIScript} = true ]]; then
  create_option_dir ${UI_SCRIPT_DIR} ${CLIENT}
fi

mkdir ${WIDGET_DIR} && cd $_

echo "<div>" > ${PREFIX}${WIDGET}.${HTML}
echo "<!-- your widget template -->" >> ${PREFIX}${WIDGET}.${HTML}
echo "</div>" >> ${PREFIX}${WIDGET}.${HTML}
touch ${PREFIX}${WIDGET}.${CSS}

if [[ $1 == *-* ]]; then
  declare -a dashName=()
  IN=$1
  IFS='-' read -ra INPUT <<< "$IN"
  for i in "${INPUT[@]}"; do
    dashName+="$(tr '[:lower:]' '[:upper:]' <<< ${i:0:1})${i:1}"
  done
  controllerSuffix=$(printf "%s" "${dashName[@]}" && echo "")
else
  declare -a inputArgs=($@)
  declare -a spaceName=()
  for i in "${inputArgs[@]}"; do
    if [[ ${i} != "-a" && ${i} != "-s" && ${i} != "-u" ]]; then
      spaceName+="$(tr '[:lower:]' '[:upper:]' <<< ${i:0:1})${i:1}"
    fi
  done
  controllerSuffix=$(printf "%s" "${spaceName[@]}" && echo "")
fi

echo "function ${controllerSuffix}Controller() {" > ${PREFIX}${WIDGET}.${CLIENT}
echo "  var c = this;" >> ${PREFIX}${WIDGET}.${CLIENT}
echo "}" >> ${PREFIX}${WIDGET}.${CLIENT}
touch ${PREFIX}${WIDGET}.${OPTION_SCHEMA}
curl ${SERVER_GIST} > ${PREFIX}${WIDGET}.${SERVER}

echo -e "${GREEN}${DONE_MSG}${RESET}"