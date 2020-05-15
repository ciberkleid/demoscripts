#### Setting up environment
source config/env.sh "$@"

#### Calling demorunner
echo -e "\nExecuting demorunner.sh...\n"
cd "${DEMO_TEMP}"
source demorunner.sh "${DEMO_SCRIPT}" 1
cd "${DEMO_HOME}"
