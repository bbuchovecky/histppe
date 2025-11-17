# perturbations for coupPPE

copied over from `/glade/u/home/bbuchovecky/projects/cpl_ppe_co2/hist/data/cesm2.1.5` on 10/27/25

directory structure:
```
├─ README.md
├─ nlmods
|  └─ ...
├─ paramfiles
|  └─ ...
└─ srcmods
   ├─ coupPPE_OAAT.csv       <- describes each ensemble member (ens name, parameter, minmax)
   ├─ orig                        <- original CESM2.1.5 source files
   |  ├─ cam                      <- original CAM source files
   |  └─ clm                      <- original CLM source files
   ├─ perturbed                   <- all modified source mods
   |  ├─ all                      <- modifed source files to use in all simulations to output specific diagnostics
   |  |  ├─ cam
   |  |  └─ clm
   |  ├─ coupPPE.0[0-9][1-9] <- CLM source mods for each member
   |  └─ ...
   └─ templates                   <- template CLM source mod files for perturbations, where '<parameter>' has been replaced with 'this_<parameter>'
      ├─ <parameter-name>
      ├─ <parameter-group-name>
      └─ ...
```