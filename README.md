Overview
-----------------
This repository contains procedure files (".ipf") that Ive used to analyze fast-scan-cyclic voltammetry (FSCV) data recorded from a 
HEKA EPC8 amplifier with an LIH8+8 digitizer. Along with the ".ipf" files, there are accompanying documents (".doc" and ".pptx") to guide the user in adding these files to the program files and how the analysis should be run with these procedures. 

Quick Notes
------------

1. These procedure files were written in IGOR pro v6.37 environment. Should they be used in any other version, they then may have to be altered to adjust to changes in the program version. 

2. These analysis files were written on the premise that the FSCV protocols are -0.4V --> 1V --> -0.4V at a 400 V/s scan rate, execucted at 10Hz and the signal being digitized at 100kHz. If any of these parameters are changed during data acquisition, then the following line of code must be altered in the FSCVcal_Aug19.ipf and FSCVstim_Aug19_b.ipf under the function name:

  "static function CalcOx(oxidation): ButtonControl"

  tc[i]=mean($theWaveName, pnt2x($theWaveName,213), pnt2x($theWaveName,264))

This line calculates the mean current recorded between 450-650mV from the command voltage. If the recording parameters change (increase
stimulus range, scan rate or digitization rate) then the values 213 & 264 must be adjusted so the new values reflect the 450-650mV points on the current waves recorded with the new recording parameter. 

3. Because of patchmaster's software limitations, patchmaster had to be programmed to stimulate a command voltage twice in 1 sweep at 93ms apart so the command voltage could be sent at 10Hz in real time. To be able to analyze every pulse individually, the "redimension" command in the procedure files re-adjusts the current sweep so that the first pulse is labelled as an odd number wave while the second pulse is labelled as an even numbered wave. The command accounts for numerical sequential ordering of the wave names for consecutive analysis functions. 

4. For assuring background current stability and due to patchmaster software design, .dat files created during data acquisition are unnecessarily large and essentially have a lot of "junk" voltage and current sweeps. The FSCVcleaner_Aug19.ipf was created as a speedy way to delete the unnecessary voltage and current waves. So the analyzer should know which current sweep number to delete prior to using this. 
