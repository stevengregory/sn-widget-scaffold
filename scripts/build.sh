#!/usr/bin/env bash

source ./scripts/config.sh
source ./scripts/messages.sh

branch_checkout() {
  echo -e "${GREEN}${BRANCH_MSG}${RESET}"
  local branch=feature/${PREFIX}${WIDGET}
  if [[ $(git branch --list ${branch}) ]]; then
    git checkout ${branch}
  else
    git checkout -b ${branch} origin/master
  fi
}

create_base_dir() {
  echo -e "${GREEN}${SCAFFOLD_MSG}${RESET}"
  make_core_dir ${PREFIX}${WIDGET}
  curl ${CONFIG_GIST} > config.json
  curl ${README_GIST} > README.md
  touch ${PREFIX}${WIDGET}.${UPDATE_SET}
}

create_option_dir() {
  mkdir ${1}
  touch ${1}/${PREFIX}${WIDGET}.${2}
}

create_widget_dir() {
  make_core_dir ${WIDGET_DIR}
  curl ${TEMPLATE_GIST} > ${PREFIX}${WIDGET}.${HTML}
  touch ${PREFIX}${WIDGET}.${CSS}
  curl ${CONTROLLER_GIST} > ${PREFIX}${WIDGET}.${CLIENT}
  replace_content ${CTRL_TEMP} ${controller_suffix} ${PREFIX}${WIDGET}.${CLIENT}
  curl ${SERVER_GIST} > ${PREFIX}${WIDGET}.${SERVER}
  touch ${PREFIX}${WIDGET}.${OPTION_SCHEMA}
  echo -e "${GREEN}${DONE_MSG}${RESET}"
}

fetch_github_user() {
  if [[ $(git config user.name) ]]; then
    echo $(git config user.name)
  else
    echo ${CONTRIB_TEMP}
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

format_data() {
  echo $(printf "%s" $1)
}

has_dashes() {
  if [[ ${args[0]} == *-* ]]; then
    name_has_dashes=true
  fi
}

main() {
  set_widget_name
  branch_checkout
  create_base_dir
  sub_base_content
  scaffold_option_dirs
  setup_controller_suffix
  create_widget_dir
}

make_core_dir() {
  if [ -d $1 ]; then
    cd $1
  else
    mkdir $1 && cd $1
  fi
}

make_space() {
  if [[ $1 ]]; then
    echo " "
  fi
}

make_uppercase() {
  echo $(tr '[:lower:]' '[:upper:]' <<< ${i:0:1})${i:1}"$(make_space $1)"
}

replace_content() {
  sed -i '' -e "s/${1}/${2}/g" ${3}
}

scaffold_option_dirs() {
  echo -e "${GREEN}${SUB_SCAFFOLD_MSG}${RESET}"
  if [[ ${is_angular_template} == true ]]; then
    create_option_dir ${ANGULAR_TEMPLATE_DIR} ${HTML}
  fi
  if [[ ${is_script_include} == true ]]; then
    create_option_dir ${SCRIPT_INCLUDE_DIR} ${SERVER}
  fi
  if [[ ${is_ui_script} == true ]]; then
    create_option_dir ${UI_SCRIPT_DIR} ${CLIENT}
  fi
}

setup_controller_suffix() {
  has_dashes
  if [[ ${name_has_dashes} == true ]]; then
    local dash_name=()
    local in=${args[0]}
    IFS='-' read -ra input <<< "$in"
    for i in "${input[@]}"; do
      dash_name+=$(make_uppercase)
    done
    controller_suffix=$(format_data ${dash_name[@]})
  else
    local space_name=()
    for i in "${args[@]}"; do
      if [[ ${i} != "-a" && ${i} != "-s" && ${i} != "-u" ]]; then
        space_name+=$(make_uppercase)
      fi
    done
    controller_suffix=$(format_data ${space_name[@]})
  fi
}

set_widget_name() {
  echo -e "${GREEN}${START_MSG}${RESET}"
  local widget_dir=()
  for i in "${args[@]}"; do
    if [[ ${i} == "-a" || ${i} == "-s" || ${i} == "-u" ]]; then
      flag_options ${i}
    else
      widget_dir+=$(echo -${i} | tr '[:upper:]' '[:lower:]')
      widget_name+=$(make_uppercase ${i})
    fi
  done
  WIDGET=$(format_data ${widget_dir[@]})
}

sub_base_content() {
  echo -e "${GREEN}${UPDATE_MSG}${RESET}"
  if [[ ${widget_name} == *-* ]]; then
    local dash_readme=()
    rm=${widget_name}
    IFS='-' read -ra content <<< "$rm"
    for i in "${content[@]}"; do
      if [[ ${i} != "-a" && ${i} != "-s" && ${i} != "-u" ]]; then
        dash_readme+=$(make_uppercase ${i})
      fi
    done
    replace_content "${NAME_TEMP}" "${dash_readme%??}" README.md
    replace_content "${NAME_TEMP}" "${dash_readme%??}" config.json
  else
    replace_content "${NAME_TEMP}" "${widget_name%?}" README.md
    replace_content "${NAME_TEMP}" "${dash_readme%??}" config.json
  fi
  replace_content "${CONTRIB_TEMP}" "$(fetch_github_user)" config.json
  replace_content "${DIR_TEMP}" "${PREFIX}${WIDGET}" README.md
}

args=($@)
main