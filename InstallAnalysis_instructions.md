# Required Installations prior to analysis

1) Install Igor pro onto your desktop
2) Install the “patcher’s power tool” macro to import that data from the .dat file created by patchmaster during recordings.  
   (http://www3.mpibpc.mpg.de/groups/neher/index.php?page=aboutppt)
   
   *this step isn't needed if not analyzing .dat files, use another macro for data importation*
3) Add the following in house written procedure files into the “Igor Procedures” folder of your Igor Pro application folder: 
   - FSCVcal_Dec19.ipf
   - FSCVcleaner_Dec19.ipf
    
4) Quick note: in house written procedure files written with IGOR pro v6.37, therefore any other IGOR pro version used may require code adjustments

# Analyze calibration data 

1) verifications prior to analysis 
   - voltage wave should be named "CommVolt"
   - all current waves should follow format: "Curr#"
   - all current waves should be in Amps unit and CommVolt should be in V unit 
2) Import the voltage and all current waves into folder named "Calibration" 
3) Click on FSCV>Electrode Calibration
4) A window named “Calibrator” should appear (fig1) with the top left graph with a single voltammogram graphed onto it (fig,#1)

fig1: 

![image](https://user-images.githubusercontent.com/52377705/70870266-6301c200-1f91-11ea-9f27-30c4808e50f0.png)

5) go to Panel>Show Info to activate the cursors on the panel (fig2). Place cursors A/B around at the min and max points of the oxidation peak (~450-650mV). (this will be indicated by the X values (voltage) in the cursor portion of the panel)

fig2:

![image](https://user-images.githubusercontent.com/52377705/70869970-719aaa00-1f8e-11ea-94c6-5758297289e2.png)

6) Next the current time course must be visualized for specific wave selection for consecutive steps. Click on “Get Timecourse” button (fig1,#2), which calculates the average current of the values between A/B curser in the previous graph (fig1,#1) for every current wave in the "Calibration" folder. A timecourse wave with DA oxidation for the calibration time period will appear. 
7) Next, the specific waves for averaging and voltammogram creation must be selected.  
8) Place the corresponding cursors in the desired sections of the timecourse graph as follows (fid1,#3): (make sure the amount of current voltage pulses selected for each cursor pair is identical)
   - A/B=baseline
   - C/D=1st DA concentration
   - E/F=2nd DA concentration
   - G/H=3rd DA concentration
   - I/J=4th DA concentration
9) Once the cursors are placed in the desired sections of the timecourse graph, click on the “Calc Voltammograms” button (fig1,#4). This will calculate the average current pulse for each concentration, create background subtracted pulses and graph each one against the command voltage, which will then be visualized in the bottom left graph.
10) The maximum current produced at oxidation (~600-800mV) must next be calculated. Click on the left bottom panel in the “Calibrator” window so the info panel applies to it and place the A cursor to the left of the peak and the B cursor to the right of the peak (fig1,#5). 
11) In the black outlined box in the bottom right portion of the “Calibrator Window” enter the numerical DA concentration (in µM) in the boxes right under “Known concentration (uM):” text (fig1,#6). Click on the “Calc Calibration Curve” button right (fig1,#7) above the black outlined box and the calibration curve should appear in the panel right to the left of it. The sensitivity and the calculated error should also appear within the black outlined box
12) Outside the “Calibrator” window, duplicate voltammogram and calibration curve graphs should appear along with a table of DA concentration vs current amount. These graphs and table can be manipulated as desired for exportation. 
13) Once finished, "Goodbye" can be clicked (fig1,#8) to close the Calibrator panel

  




