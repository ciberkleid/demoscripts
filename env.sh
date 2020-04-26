demo_script=""

if [ ! -f "${1}" ]; then
  echo "File does not exist: [${1}]"
  exit
else
  demo_script="${1}"
fi

##### ENV VARS

# brew install coreutils (for greadlink)
demo_script_absolute_path=$(greadlink -f "${demo_script}")
demo_script_dirname=$(echo "${demo_script_absolute_path}" | sed 's:/[^/]*$::')
demo_script_parent_dirname=$(echo "${demo_script_dirname}" | sed 's:/[^/]*$::')
demo_script_basename=$(basename "${demo_script}")
demo_script_nickname=$(echo "${demo_script_basename}" | cut -d. -f1)

export DEMO_HOME=`pwd`
export DEMO_TEMP="${DEMO_HOME}/temp/${demo_script_nickname}"
export DEMO_SCRIPT="${demo_script_dirname}/${demo_script_basename}"
export DEMO_FILES="${demo_script_parent_dirname}/files/${demo_script_nickname}"
export DEMO_COLOR=""

echo
echo  "### Setting env vars"
echo "DEMO_HOME=${DEMO_HOME}"
echo "DEMO_TEMP=${DEMO_TEMP}"
echo "DEMO_SCRIPT=${DEMO_SCRIPT}"
echo "DEMO_FILES=${DEMO_FILES}"
echo "DEMO_COLOR=${DEMO_COLOR}"
echo

##### TEMP DIR

if [ -d "${DEMO_TEMP}" ]; then
  read -p "Temp dir exits. Keep or remove? [KP|rm] : " action
  action=${action:-KP}
  if [[ "${action}" =~ rm|RM|Rm|rM ]]; then
    echo "Removing temp directory ${DEMO_TEMP}"
    rm -rf "${DEMO_TEMP}"
  else
    echo "Using existing temp directory ${DEMO_TEMP}"
  fi
fi
if [ -d "${DEMO_TEMP}" ]; then
  echo "Creating temp directory ${DEMO_TEMP}"
  mkdir -p "${DEMO_TEMP}"
fi


##### ALIASES

# Stop running containers & prune images, containers, volumes, and networks (stopped,unused, and dangling)
alias dclean="docker ps -a -q | xargs -n1 docker stop; docker system prune -af"

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
