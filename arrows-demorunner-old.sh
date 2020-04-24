#!/bin/bash
#  demorunner.sh
#
#
#  Created by Maria Gabriella Brodi and Cora Iberkleid on 3/28/20.

COMMANDS_FILE="${1}"          # required
START_WITH_LINE_NUMBER="${2}" # optional
START_WITH_LINE_NUMBER="${START_WITH_LINE_NUMBER:-1}" # default to 1 if not provided

RESET_FONT="\033[0m"
BOLD="\033[1m"
YELLOW="\033[38;5;11m"
BLUE="\033[0;34m"
RED="\033[0;31m"
ECHO=off

# Set color
if [[ $DEMO_COLOR == "blue" ]]; then
  SET_FONT="${BLUE}${BOLD}"
else
  SET_FONT="${YELLOW}${BOLD}"
fi

usage_instructions() {
  printf "${RESET_FONT}"
  echo
  echo "Usage:"
  echo     "source ./demorunner.sh [commands-file]"
  echo     "source ./demorunner.sh [commands-file] [start-with-line-number]"
  echo
  echo "This script echoes and executes a list of commands that you provide in a \"commands file\". The file"
  echo "must exist for the demorunner script to run. Also, if a second argument is supplied, it must be an integer."
  echo
  echo "Use @_ECHO_ON & @_ECHO_OFF in the commands file to control whether or not commands are printed to the"
  echo "terminal before they are executed. If echo is turned off, commands are executed immediately. If echo is"
  echo "turned on, the script will wait for the user to hit Enter/Return before echoing each command, and again"
  echo "before executing the command. Commands are echoed slowly to the terminal to simulate live typing."
  echo
  echo "At the prompt, you may also type a custom command at any time. Once that is executed, hit Enter/Return at"
  echo "an empty prompt to continue with the next command from the commands file"
  echo
  echo "If you provide a number as a second input argument, the script will skip execution of any lines above that."
  echo "@_ECHO_ON & @_ECHO_OFF commands above the starting line will still be respected."
  echo
  echo "The default font color for echoed commands is yellow. You can change it to blue using:"
  echo "export DEMO_COLOR=blue"
  echo
}

# If the 'commands file' does not exist, print error and usage instructions
# If a 'start with line number' argument was provided and it is not a number, print error and usage instructions
ERROR=""
if [ $# -eq 0 ] || [[ ${1} =~ -h|--help ]]; then
  usage_instructions
  return
elif [ $# -gt 2 ]; then
  ERROR="Unexpected number of input arguments: expecting 1 or 2 (got $#)"
elif [ ! -f "${COMMANDS_FILE}" ]; then
  ERROR="File does not exist (${COMMANDS_FILE})"
elif { [ $# -eq 2 ] && ! [[ "${START_WITH_LINE_NUMBER}" =~ ^[0-9]+$ ]]; }; then
  ERROR="Second argument must be an integer (got ${START_WITH_LINE_NUMBER})"
fi
if [[ ${ERROR} != "" ]]; then
  printf "${RED}ERROR: ${ERROR}\n"
  usage_instructions
  return
else
  echo "Executing commands in file ${COMMANDS_FILE} starting at line ${START_WITH_LINE_NUMBER}"
fi

# Set terminal tab name to the file name minus the extension
printf "\e]1;%s\a" "${COMMANDS_FILE%.*}"

# Keep a history of user-executed commands
declare -a COMMAND_HISTORY=()

# Function to process additional user input at runtime
get_user_input() {
  temp_command=${1}
  # Temporarily keep temp_command in history (so that DOWN arrow can re-display it)
  COMMAND_HISTORY+=${temp_command}
  ((command_history_index=${#COMMAND_HISTORY[@]}))
  while IFS= read -rn1 next_char ; do
    # If user hit enter/return, exit the loop
    if [ "${next_char}" = "" ]; then
      break
    fi
    # Detect escape sequences, capture if user hit arrow key
    arrow=""
    if [ "${next_char}" = $'\E' ]; then # =$'\E' or =$'\x1b'
      read -rn1 next_char
      if [ "${next_char}" = $'[' ]; then
        read -rn1 next_char
        if [ "${next_char}" = 'A' ]; then
          arrow=up
        elif [ "${next_char}" = 'B' ]; then
          arrow=down
        elif [ "${next_char}" = 'C' ]; then
          arrow=right
        elif [ "${next_char}" = 'D' ]; then
          arrow=left
        else
          printf "${RED}ERROR: ARROW KEY DETECTED - DIRECTION UNKNOWN: ${next_char}${ERROR}\n" >>/dev/tty
        fi
      else
        printf "${RED}ERROR: ESCAPE KEY DETECTED FOLLOWED BY UNRECOGNIZED CHARACTER: ${next_char}${ERROR}\n" >>/dev/tty
      fi
      next_char=''
    fi
    # Handle case where user input is an arrow
    # UP: go to previous executed command
    # DOWN: go to next executed command
    # TODO Implement handling of LEFT/RIGHT (currently ignored/no-op)
    if [[ "${arrow}" != "" ]]; then
      # Delete the arrow character sequence from the terminal
      printf "\b \b\b \b\b \b\b \b\b \b\b \b\b \b" >>/dev/tty
    fi
    if [[ "${arrow}" =~ up|down ]]; then
      # Delete any other characters the user had already typed
      bunch_of_backspaces=""
      while [ ${#temp_command} -gt 0 ]; do
        bunch_of_backspaces="${bunch_of_backspaces}\b \b"
      done
      printf "${bunch_of_backspaces}" >>/dev/tty
      # Go to previous or next command in history, as appropriate
      if [[ "${arrow}" == "up" ]] && (( ${command_history_index} > 0 )); then
        ((command_history_index=command_history_index-1))
      elif [[ "${arrow}" == "down" ]] && (( ${command_history_index} < ${#COMMAND_HISTORY[@]}-1)); then
        ((command_history_index=command_history_index+1))
      fi
      temp_command=${COMMAND_HISTORY[${command_history_index}]}
      echo "temp_command is [${temp_command}] and length is ${#temp_command}" >>/dev/tty
      printf "${temp_command}" >>/dev/tty
    fi
    # If user hit backspace/delete, remove the last character
    if [ "${next_char}" = $'\177' ]; then
      # Delete chars printed to terminal by delete button
      printf "\b \b\b \b" >>/dev/tty
      # If temp_command is not empty, delete last char from temp_command and from terminal
      if [ ${#temp_command} -gt 0 ]; then
        printf "\b \b" >>/dev/tty
        temp_command=${temp_command%?} # remove the last char
      fi
      next_char=''
    fi
    # Append next_char to temp_command
    temp_command=${temp_command}${next_char}
    # Update last element of COMMAND_HISTORY
    COMMAND_HISTORY[${#COMMAND_HISTORY[@]}-1]=${temp_command}
  done
  # Remove temp command temporarily saved in history
  # Will be added back at time of execution
  unset 'COMMAND_HISTORY[${#COMMAND_HISTORY[@]}-1]'
  echo "${temp_command}"
}

# Make sure file ends with newline so last
# command is captured in array in next step
c=`tail -c 1 $1`
if [ "$c" != "" ]; then echo "" >> $1; fi

# read all the lines in an array
IFS=$'\n' read -d '' -r -a COMMAND_LINES < ${COMMANDS_FILE}

# Execute commands in array. Allow dynamic input as well.
((LINE_NUMBER=1))
for command in "${COMMAND_LINES[@]}"
do
  # Always check for desired state of ECHO setting
  # Skip empty lines and any lines before desired start line
  if [[ "${command}" == "@_ECHO_ON" ]]; then
    ECHO=on
    ((LINE_NUMBER=LINE_NUMBER+1))
    continue
  elif [[ "${command}" == "@_ECHO_OFF" ]]; then
    ECHO=off
    ((LINE_NUMBER=LINE_NUMBER+1))
    continue
  elif [[ "${command}" == "" ]] || [[ $LINE_NUMBER -lt $START_WITH_LINE_NUMBER ]]; then
    ((LINE_NUMBER=LINE_NUMBER+1))
    continue
  fi
  # If ECHO is off, just execute the command
  if [[ $ECHO == "off" ]]; then
    printf "${RESET_FONT}"
    # No need to adde non-echoed commands to COMMAND_HISTORY, just execute
    eval "${command}"
    ((LINE_NUMBER=LINE_NUMBER+1))
    continue
  fi
  # ECHO is on
  # Before echoing the next command, give the user an opportunity to type in one or more custom commands.
  # If they do, execute these first.
  # When the user simply clicks enter/return, echo the next command from the file.
  # The user can then click enter/return once again to execute the command from the file.
  while ( : ); do
    printf "\n${SET_FONT}\$ "
    custom_command=$(get_user_input "")
    # If user entered a custom command, execute it
    if [[ "${custom_command}" != "" ]]; then
      printf "${RESET_FONT}"
      COMMAND_HISTORY+=("${command}")
      eval "${custom_command}"
    else
      break
    fi
  done

  # Magic: delete the last line (should just contain the prompt)
  cols=$(tput cols)
  IFS=';' read -sdR -p $'\E[6n' ROW COL; ((current_line=${ROW#*[}))
  ((current_line=current_line-2))
  tput cup ${current_line} 2
  # END Magic

  # Process command from file
  printf "${SET_FONT}${command}" | pv -qL 10
  # Wait for user to hit return/enter before executing. Allow user to delete and change the command as well.
  command=$(get_user_input "${command}")
  echo
  printf "${RESET_FONT}"
  COMMAND_HISTORY+=("${command}")
  eval "${command}"
  ((LINE_NUMBER=LINE_NUMBER+1))
done