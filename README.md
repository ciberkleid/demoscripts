# demoscripts

## Setup:

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
    
    demoscripts/demos/**mydemo**.txt
    
    demoscripts/files/**mydemo**

## Execution

To execute a demo script, run the following commands:

    ```
    source setup.sh demos/mydemo.txt
    source demorunner.sh demos/mydemo.txt
    ```
   
   The script will create a temp directory to execute the demo script:
   
   demoscripts/temp/**mydemo**
   
   The script will also print the command to run to run your demo (and place it in your clipboard, so you can just paste it into the terminal window):
   
   `cd ${DEMO_TEMP}; source demorunner.sh ${DEMO_SCRIPT} 1; cd ${DEMO_HOME}`
   
   Note: To start your demo at an arbitrary line in your script, change the 1 to the appropriate line number.
    
-----

For more information on using demorunner.sh, type:

`demorunner.sh -h`