Overview
-----------------
This repository contains procedure files (".ipf") used to analyze fast-scan-cyclic voltammetry (FSCV) data recorded from a 
HEKA EPC8 amplifier with an LIH8+8 digitizer. Theoretically, the FSCVcal_Dec19.ipf can be used to analyze calibration voltammetry data from any digitizer as long as the data is imported into Igor Pro, voltage wave named "CommVolt", current waves named "Curr#", the current waves are in Amps and CommVolt wave is Volts.

Quick Notes
------------

1. These procedure files were written in IGOR pro v6.37 environment. Should they be used in any other version, they then may have to be altered to adjust to changes in the program version. 

2. These procedure files were originally written in 13" macbook pro early 2011 High Sierra, and build GUIs that are formatted based on the screen configurations of this system. If these procedure files are used in another pc system, the GUI dimensions will most probably be different but this should not affect the data in anyway. It will probably just skew how its visualized. 

3. Calibration technique that these codes are based is "accumulative pippetting" of Dopamine (DA) concentrations. For example, after 1 minute of background current recorded, 0.5µM DA is added to the aCSF bath from which the carbon fiber electrode was recording from 4x at 1-minute intervals. This results in 0.5/1/1.5/2µM DA concentrations for calibration. The setup of this code may not be best suited for perfusion method of DA calibration, but snippets of the code can be adjusted to get equal results.  

4. Due to specific pathchmaster program limitations, FSCVcleaner_Dec19.ipf was written to cleanup the data and increase analysis efficieny. More details described in cleaner markdown file.  

