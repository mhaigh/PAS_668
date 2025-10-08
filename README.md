This repository contains an MITgcm configuration used for studying the Amundsen Sea, West Antarctica.
This configuration can be used to produce model output for the research paper  "Wind-driven coastal polynya variability drives decadal ice-shelf melt variability in the Amundsen Sea" by Michael Haigh, Paul R. Holland and Thomas Caton Harrison (Haigh et al., 2025).

This repository contains three directories, "input", "code_68r" and "scripts". 

The directory structure is as follows:
-input: This contains namelist files.
-code_68r: This contains edited MITgcm source code files. Edits to the shelfice package and exf (external forcing) package are essential for the pertution experiments in Haigh et al. (2025).
-scripts: users can launch model runs from this directory. Scripts copy necessary source files 

