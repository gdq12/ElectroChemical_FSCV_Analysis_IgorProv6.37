# Background: Voltammetry recording with Patchmaster(HEKA)

When Patchmaster is programmed to execute voltage pulses greater than 5Hz (1x per 200ms), the program experiences massive time delays in visualizing the resulting current pulses, due to how the data is being saved in real time. The time line of the oxidation peak for each current pulse must be visualized in real time and typically voltage pulses should be executed at 8-10Hz. Therefore, patchmaster .pgf files must be programmed slightly different to over come this time delay and maintain the desired pulsating frequency of the protocol. Here I attempt to provide a sufficient and clear explanation on how I circumvented this issue and the protocol I used to maintain analysis efficiency. 

# Protocol for 10Hz voltage execution in Patchmaster

Since patchmaster can only execute protocols at a maximum of 5Hz in real time, I programmed patchmaster to execute 200ms voltage pulses which includes 2 triangle 7ms voltammetry pulses (-0.4V --> 1V --> -0.4V) 93ms apart within each 200ms pulse (fig1). With this protocol, patchmaster recorded current pulses in the same fashion (fig2)

fig1

![image](https://user-images.githubusercontent.com/52377705/70886590-155e7700-1fdc-11ea-8207-1878cb2e6a86.png)

**protocol specifics:** voltage pulse: -0.4V --> 1V --> -0.4V, scan rate: 400 V/s, Frequency: 5Hz (in reality 10Hz after redimensioning), digitized at 100kHz, time length: 200ms

fig2

![image](https://user-images.githubusercontent.com/52377705/70886929-fa403700-1fdc-11ea-9d85-ce0d7e6004c2.png)

*resulting current pulses*

This method overcomes recording in realtime issue, but it makes analysis more difficult. The FSCVcleaner_Dec19.ipf file was there for created to overcome this issue. 

# Brief overview of FSCVcleaner_Dec10.ipf

General outline of what code does 
- Cleans up excess voltage pulse waves
- deletes unucessary current pulses 
- redimensions remaining voltage wave and current waves 

Outline on using FSCVcleaner_Dec19.ipf:
1) Copy the .ipf folder into Igor_procedures folder either prior to initializing Igor Pro or load the procedure file after starting the program 
2) Once in the desired folder and have uploaded that data into Igor pro, go to FSCV>Cleanup Data
3) A panel named "Data Cleaner" should appear (fig3)

fig3

![image](https://user-images.githubusercontent.com/52377705/70895450-45fbdc00-1fef-11ea-854d-e0f36fd430de.png)

4) click on "Organize V-waves". This will delete all but one voltage wave and rename it "CommVolt"
5) The next step is to remove any excessive or "junk" current wave pulses that were unecessarily recorded to keep the current signal stable during recording. Once you have in mind the set of waves that not needed for analysis, input the first and last wave number into the numerical boxes next to "first pulse:" and "last pulse:", respectively. This should delete all the current pulses that you indicated. 
6) Finally, since there are 2 current/voltage pulses with each wave, these pulses must be extracted into new individual waves and labelled as even and odd "Curr#" appropriately. Click "Redimension current waves" to do this. 
7) Once this process is complete, one can examine the waves to verify that they are in the right dimension, they contain one pulse and they are labelled correctly. 
8) Click on "Goodbye!" to close the window and continue with the normal calibration analysis. 

Some notes:
- this procedure file was built to clean up data with the specificities indicated in fig1. (each pulse being 700 points long)
- should this procedure file be used for data not acquired with the same protocol (e.g. extended command pulse, different digitization rate, different scan rate), then the code should be altered to adapt to the change. 
