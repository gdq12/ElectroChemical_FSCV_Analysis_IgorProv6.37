Overview
-----------------
This repository contains procedure files (".ipf") that Ive used to analyze fast-scan-cyclic voltammetry (FSCV) data recorded from a 
HEKA EPC8 amplifier with an LIH8+8 digitizer. Theoretically, the FSCVcal_Dec19.ipf can be used to analyze calibration voltammetry data from any digitizer as long as the data is imported into Igor Pro, voltage wave named "CommVolt", current waves named "Curr#", the current waves are Amps unit and CommVolt wave is in Voltage unit.

Quick Notes
------------

1. These procedure files were written in IGOR pro v6.37 environment. Should they be used in any other version, they then may have to be altered to adjust to changes in the program version. 

2. Due to specific pathchmaster program limitations, FSCVcleaner_Dec19.ipf was written to cleanup the data and increase analysis efficieny. More details described in FSCVcleaner markdown file.  

