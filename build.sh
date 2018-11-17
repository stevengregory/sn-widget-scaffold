source config.sh

echo "${GREEN}Getting started${RESET_COLOR}"

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
  fi
done
WIDGET=$(printf "%s" "${widgetDir[@]}" && echo "")

echo "${GREEN}Creating feature branch...${RESET_COLOR}"

git checkout -b feature/${PREFIX}${WIDGET} master

echo "${GREEN}Starting widget scaffold...${RESET_COLOR}"

mkdir ${PREFIX}${WIDGET} && cd $_
touch README.md
touch ${PREFIX}${WIDGET}.${UPDATE_SET}

if [[ ${isAngularTemplate} = true ]]; then
  mkdir ${ANGULAR_TEMPLATE_DIR}
  touch ${ANGULAR_TEMPLATE_DIR}/${PREFIX}${WIDGET}.${HTML}
fi

if [[ ${isScriptInclude} = true ]]; then
  mkdir ${SCRIPT_INCLUDE_DIR}
  touch ${SCRIPT_INCLUDE_DIR}/${PREFIX}${WIDGET}.${SERVER}
fi

if [[ ${isUIScript} = true ]]; then
  mkdir ${UI_SCRIPT_DIR}
  touch ${UI_SCRIPT_DIR}/${PREFIX}${WIDGET}.${CLIENT}
fi

mkdir ${WIDGET_DIR} && cd $_
touch ${PREFIX}${WIDGET}.${HTML}
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

echo "${GREEN}Done${RESET_COLOR}"