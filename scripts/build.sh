#!/usr/bin/env bash

source ./scripts/config.sh
source ./scripts/messages.sh

echo -e "${GREEN}${START_MSG}${RESET}"

create_option_dir() {
  mkdir ${1}
  touch ${1}/${PREFIX}${WIDGET}.${2}
}

fetch_github_user() {
  if [[ $(git config user.name) ]]; then
    echo $(git config user.name)
  else
    echo ${TEMP_CONTRIB}
  fi
}

flag_options() {
  case $1 in
  "-a")
    is_angular_template=true
    ;;
  "-s")
    is_script_include=true
    ;;
  "-u")
    is_ui_script=true
    ;;
  esac
}

declare -a args=($@)
declare -a widget_dir=()
for i in "${args[@]}"; do
  if [[ ${i} == "-a" || ${i} == "-s" || ${i} == "-u" ]]; then
    flag_options ${i}
  else
    widget_dir+=$(echo -${i} | tr '[:upper:]' '[:lower:]')
    widget_name+=$(tr '[:lower:]' '[:upper:]' <<< ${i:0:1})${i:1}' '
  fi
done
WIDGET=$(printf "%s" "${widget_dir[@]}" && echo "")

echo -e "${GREEN}${BRANCH_MSG}${RESET}"

git checkout -b feature/${PREFIX}${WIDGET} master

echo -e "${GREEN}${SCAFFOLD_MSG}${RESET}"

mkdir ${PREFIX}${WIDGET} && cd $_

curl ${README_GIST} > README.md
curl ${CONFIG_GIST} > config.json

echo -e "${GREEN}${UPDATE_MSG}${RESET}"
if [[ ${widget_name} == *-* ]]; then
  declare -a dash_readme=()
  RM=${widget_name}
  IFS='-' read -ra README <<< "$RM"
  for i in "${README[@]}"; do
    if [[ ${i} != "-a" && ${i} != "-s" && ${i} != "-u" ]]; then
      dash_readme+=$(tr '[:lower:]' '[:upper:]' <<< ${i:0:1})${i:1}' '
    fi
  done
  sed -i '' -e "s/${TEMP_NAME}/${dash_readme%??}/g" README.md
  sed -i '' -e "s/${TEMP_NAME}/${dash_readme%??}/g" config.json
else
  sed -i '' -e "s/${TEMP_NAME}/${widget_name%?}/g" README.md
  sed -i '' -e "s/${TEMP_NAME}/${dash_readme%??}/g" config.json
fi
sed -i '' -e "s/${TEMP_CONTRIB}/$(fetch_github_user)/g" config.json
sed -i '' -e "s/${TEMP_DIR}/${PREFIX}${WIDGET}/g" README.md

touch ${PREFIX}${WIDGET}.${UPDATE_SET}

if [[ ${is_angular_template} = true ]]; then
  create_option_dir ${ANGULAR_TEMPLATE_DIR} ${HTML}
fi

if [[ ${is_script_include} = true ]]; then
  create_option_dir ${SCRIPT_INCLUDE_DIR} ${SERVER}
fi

if [[ ${is_ui_script} = true ]]; then
  create_option_dir ${UI_SCRIPT_DIR} ${CLIENT}
fi

mkdir ${WIDGET_DIR} && cd $_

echo "<div>" > ${PREFIX}${WIDGET}.${HTML}
echo "<!-- your widget template -->" >> ${PREFIX}${WIDGET}.${HTML}
echo "</div>" >> ${PREFIX}${WIDGET}.${HTML}
touch ${PREFIX}${WIDGET}.${CSS}

if [[ $1 == *-* ]]; then
  declare -a dash_name=()
  IN=$1
  IFS='-' read -ra INPUT <<< "$IN"
  for i in "${INPUT[@]}"; do
    dash_name+="$(tr '[:lower:]' '[:upper:]' <<< ${i:0:1})${i:1}"
  done
  controller_suffix=$(printf "%s" "${dash_name[@]}" && echo "")
else
  declare -a input_args=($@)
  declare -a space_name=()
  for i in "${input_args[@]}"; do
    if [[ ${i} != "-a" && ${i} != "-s" && ${i} != "-u" ]]; then
      space_name+="$(tr '[:lower:]' '[:upper:]' <<< ${i:0:1})${i:1}"
    fi
  done
  controller_suffix=$(printf "%s" "${space_name[@]}" && echo "")
fi

echo "function ${controller_suffix}Controller() {" > ${PREFIX}${WIDGET}.${CLIENT}
echo "  var c = this;" >> ${PREFIX}${WIDGET}.${CLIENT}
echo "}" >> ${PREFIX}${WIDGET}.${CLIENT}
touch ${PREFIX}${WIDGET}.${OPTION_SCHEMA}
curl ${SERVER_GIST} > ${PREFIX}${WIDGET}.${SERVER}

echo -e "${GREEN}${DONE_MSG}${RESET}"