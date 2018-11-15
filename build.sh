source config.sh

echo "${GREEN}Getting started${RESET_COLOR}"

declare -a arr1=($@)
declare -a test2=()
for i in "${arr1[@]}"
do
  if [[ ${i} != "-a" ]]; then
    test2+=$(echo -${i} | tr '[:upper:]' '[:lower:]')
  else
    angularTemplate=true
  fi
done
WIDGET=$(printf "%s" "${test2[@]}" && echo "")

echo "${GREEN}Creating feature branch...${RESET_COLOR}"

git checkout -b feature/${PREFIX}${WIDGET}

echo "${GREEN}Starting widget scaffold...${RESET_COLOR}"

mkdir ${PREFIX}${WIDGET} && cd $_
touch README.md
touch ${PREFIX}${WIDGET}.${UPDATE_SET}

if [[ ${angularTemplate} = true ]]; then
  mkdir angular-template
  touch angular-template/${PREFIX}${WIDGET}.${HTML}
fi

mkdir widget && cd $_
touch ${PREFIX}${WIDGET}.${HTML}
touch ${PREFIX}${WIDGET}.${CSS}

if [[ $1 == *-* ]]; then
  declare -a wahoo=()
  IN=$1
  IFS='-' read -ra ADDR <<< "$IN"
  for i in "${ADDR[@]}"; do
    wahoo+="$(tr '[:lower:]' '[:upper:]' <<< ${i:0:1})${i:1}"
  done
  controllerSuffix=$(printf "%s" "${wahoo[@]}" && echo "")
else
  declare -a arr=($@)
  declare -a test=()
  for i in "${arr[@]}"
  do
    if [[ ${i} != "-a" ]]; then
      test+="$(tr '[:lower:]' '[:upper:]' <<< ${i:0:1})${i:1}"
    fi
  done
  controllerSuffix=$(printf "%s" "${test[@]}" && echo "")
fi

echo "function ${controllerSuffix}Controller() {" > ${PREFIX}${WIDGET}.${CLIENT}
echo "  var c = this;" >> pe${WIDGET}.${CLIENT}
echo "}" >> ${PREFIX}${WIDGET}.${CLIENT}
touch ${PREFIX}${WIDGET}.${OPTION_SCHEMA}
curl ${SERVER_GIST} > ${PREFIX}${WIDGET}.${SERVER}

echo "${GREEN}Done${RESET_COLOR}"