This repository contains an MITgcm configuration used for studying the Amundsen Sea, West Antarctica.
This configuration can be used to produce the model output for the research paper  "Wind-driven coastal polynya variability drives decadal ice-shelf melt variability in the Amundsen Sea" by Michael Haigh, Paul R. Holland and Thomas Caton Harrison (Haigh et al., 2025).

This repository contains three directories, "input", "code_68r" and "scripts". Users must additionally create "run" and "build" directories. Users will require ERA5 data for forcing this MITgcm configuration.

The directory structure is as follows:
-input: This contains namelist files.
-code_68r: This contains edited MITgcm source code files. Edits to the shelfice package and exf (external forcing) package are essential for the pertution experiments in Haigh et al. (2025).
-scripts: users can launch model runs from this directory. Scripts copy into run the necessary source files from input and executables from build. This directoty also contains compile scripts.
-build: Compilation scripts in the scripts directory will build an MITgcm executable in this directory. 
-run: Executables, forcing files, namelists etc. are all to be copied into run for each execution of MITgcm.

Steps for running the model (note users will have to edit all paths for their system):
-Use compile.sh, compile_exf2winds.sh or compile_shelficeFeedback.sh (details below) to compile MITgcm (we use version 68r) into build directory. 
-Use prep_run_96.sh to copy all required files from build, input and elsewhere into the run directory. Alter options inside prep_run_96.sh to select which perturbation experiment to run. 
-Submit the simulation to the batch queue using sub_run.sh.

The three different compile scripts link to different directories inside code_68r and build three different executables. compile.sh is for the reference configuration. compile_exf2winds.sh is for the "WINDS" and "THERMO" configurations, which have specific treatments of the winds in the bulk formula heat and moisture fluxes. compile_shelficeFeedback.sh compiles the model configuration with ice-shelf melting feedbacks switched off.







