# Usage example:
# source env.sh scripts/dockerfile-1.txt files/dockerfile
# source demorunner.sh scripts/dockerfile-1.txt

demo_script=""
demo_files=""

if [ ! -f "${1}" ]; then
  echo "File does not exist: [${1}]"
  kill -INT $$
else
  demo_script="${1}"
fi

if [ ! -d "${2}" ]; then
  echo "Directory does not exist: [${2}]"
  kill -INT $$
else
  demo_files="${2}"
fi

##### ENV VARS

# default color is yellow. Choices are yellow or blue
export DEMO_COLOR=blue
# Default delay is 10. To make it faster, increase the number
export DEMO_DELAY=15
export SAVED_DEMO_DELAY=${DEMO_DELAY}

# brew install coreutils (for greadlink)
demo_script_absolute_path=$(greadlink -f "${demo_script}")
demo_files_absolute_path=$(greadlink -f "${demo_files}")
demo_script_handle=$(echo $(basename "${demo_script}") | cut -d. -f1)

export DEMO_HOME=`pwd`
export DEMO_SCRIPT="${demo_script_absolute_path}"
export DEMO_FILES="${demo_files_absolute_path}"
export DEMO_TEMP="${DEMO_HOME}/temp/${demo_script_handle}"

echo
echo "### Setting env vars"
echo "DEMO_HOME=${DEMO_HOME}"
echo "DEMO_TEMP=${DEMO_TEMP}"
echo "DEMO_SCRIPT=${DEMO_SCRIPT}"
echo "DEMO_FILES=${DEMO_FILES}"
echo "DEMO_COLOR=${DEMO_COLOR}"
echo "DEMO_DELAY=${DEMO_DELAY}"
echo "SAVED_DEMO_DELAY=${SAVED_DEMO_DELAY}"
echo

##### TEMP DIR

if [ "$(ls -A ${DEMO_TEMP})" ]; then
  echo "Temp dir is not empty [${DEMO_TEMP}]"
  echo "Contents:"
  ls -la "${DEMO_TEMP}"
  echo
  read -p "Keep or remove? [KP|rm] : " action
  action="${action:-KP}"
  if [[ "${action}" =~ rm|RM|Rm|rM ]]; then
    echo "Removing temp directory ${DEMO_TEMP}"
    rm -rf "${DEMO_TEMP}"
  else
    echo "Using existing temp directory ${DEMO_TEMP}"
  fi
fi
if [ ! -d "${DEMO_TEMP}" ]; then
  echo "Creating temp directory ${DEMO_TEMP}"
  mkdir -p "${DEMO_TEMP}"
fi

##### ALIASES

# Stop running containers & prune images, containers, volumes, and networks (stopped,unused, and dangling)
alias dclean="docker ps -a -q | xargs -n1 docker stop; docker system prune -af"

# Rename Terminal tabs
tabname() { printf '\e]1;%s\a' $1; }

# BEGIN SECTION: Fancy cat and diff aliases
#brew install colordiff

# catt - like cat, but skip commented lines and empty lines
cattf() { grep -v -A1 '^[[:blank:]]*$' "${@}" | grep -v '^--$' | grep -vE '^\s*#'; }
alias catt=cattf

# cattd - like dif, but side-by-side and colored, and skip commented lines and empty lines
cattdf() { cattf ${1} > .___cattdf_temp_file_1; cattf ${2} > .___cattdf_temp_file_2; colordiff -yW"`tput cols`" .___cattdf_temp_file_1 .___cattdf_temp_file_2; rm .___cattdf_temp_file_1; rm .___cattdf_temp_file_2; }
alias cattd=cattdf

# catd - like dif, but side-by-side and colored
catdf() { colordiff -yW"`tput cols`" ${1} ${2}; }
alias catd=catdf
# END SECTION: Fancy cat and diff aliases

#####  GUIDANCE

command="cd \${DEMO_TEMP}; source demorunner.sh \${DEMO_SCRIPT} 1; cd \${DEMO_HOME}"
printf "${command}" | pbcopy
echo
echo "Execute the following command (it's in your clipboard!):"
echo "cd \${DEMO_TEMP}; source demorunner.sh \${DEMO_SCRIPT} 1; cd \${DEMO_HOME}"
echo
echo "Expanded form:"
echo "cd ${DEMO_TEMP}; source demorunner.sh ${DEMO_SCRIPT} 1; cd ${DEMO_HOME}"
echo