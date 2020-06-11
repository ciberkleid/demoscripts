# demoscripts

## Setup

1. Set up the demorunner utility

   ```
   git clone git@github.com:mgbrodi/demorunner.git
   cp demorunner/demorunner.sh /usr/bin/
   ```

2. Create your demo scripts and any supporting files

   ```
   git clone git@github.com:ciberkleid/demoscripts.git
   cd demoscripts
   ```

   Place scripts and supporting files in the corresponding subdirectories, as show in the example below:
   
   _demoscripts/demos/**mydemo**.txt_
   
   _demoscripts/files/**mydemo**_

## Execution

To run a demo script, execute the following command:

   ```
   source run.sh demos/mydemo.txt [files/mydemo] [-f] [-a]
   ```
   
   The run.sh script will create a temp directory to execute the demo script:
   
   _demoscripts/temp/**mydemo**_
   
   `run.sh` will create some env vars and aliases that might be handy in your demo scripts. For example:
   
   ```
   DEMO_HOME=<directory from which you are executing run.sh>
   DEMO_TEMP=<temp directory for execution of demo script>
   DEMO_FILES=<files directory you provided to run script>
   ```
   
   Look through `run.sh` for more.
   
   The optional `-f` flag instructs `run.sh` to delete and recreate the temp directory.
   
   The optional `-a` flag instructs `run.sh` to run demorunner automatically. Alternatively, use the following command to run demorunner separately:
   
   `cd ${DEMO_TEMP}; source demorunner.sh ${DEMO_SCRIPT} 1; cd ${DEMO_HOME}`
   
   As a convenience, `run.sh` will also place the demorunner command in in your clipboard, so you can just paste it into the terminal window.
   
   To start your demo at an arbitrary line in your script, change the 1 to the appropriate line number.
      
   

   
-----

For more information on using demorunner.sh, type:

`demorunner.sh -h`
