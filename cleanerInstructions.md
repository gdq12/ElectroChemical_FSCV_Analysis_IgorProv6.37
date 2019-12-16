# Background: Voltammetry recording from Patchmaster(HEKA)

When Patchmaster is programmed to execute voltage pulses greater than 5Hz (1x per 200ms), the program experiences massive time delays in visualizing the resulting current pulses, due to how the data is being saved in real time. The time line of the oxidation peak for each current pulse must visualized in real time and typically voltage pulses should be executed at 8-10Hz, patchmaster .pgf files must be programmed slightly different to over come this time delay and maintain the desired pulsating frequency of the protocol. Here I attempt to provide a sufficient and clear explanation on how I circumvented this issue and the protocol I used to maintain analysis efficiency. 

# Protocol for 10Hz voltage execution in Patchmaster

Since patchmaster can only execute protocols at a maximum of 5Hz in real time, I programmed patchmaster to execute 200ms voltage pulses which includes 2 triangle voltammetry pulses (-0.4V --> 1V --> -0.4V) 93ms apart within each 200ms pulse (fig1). 

fig1



Because of patchmaster's software limitations, patchmaster had to be programmed to stimulate a command voltage twice in 1 sweep at 93ms apart so the command voltage could be sent at 10Hz in real time. To be able to analyze every pulse individually, the "redimension" command in the procedure files re-adjusts the current sweep so that the first pulse is labelled as an odd number wave while the second pulse is labelled as an even numbered wave. The command accounts for numerical sequential ordering of the wave names for consecutive analysis functions. 

For assuring background current stability and due to patchmaster software design, .dat files created during data acquisition are unnecessarily large and essentially have a lot of "junk" voltage and current sweeps. The FSCVcleaner_Aug19.ipf was created as a speedy way to delete the unnecessary voltage and current waves. So the analyzer should know which current sweep number to delete prior to using this. 
