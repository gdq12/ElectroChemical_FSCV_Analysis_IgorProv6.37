# Required Installations prior to analysis

1) Install Igor pro onto your desktop
2) Install the “patcher’s power tool” macro to import that data from the .dat file created by patchmaster during recordings.  
   (http://www3.mpibpc.mpg.de/groups/neher/index.php?page=aboutppt)
3) Add the following in house written procedure files into the “Igor Procedures” folder of your Igor Pro application folder: 
    -FSCVcal_Dec19.ipf
    -FSCVcleaner_Dec19.ipf
4) Quick note: in house written procedure files written with IGOR pro v6.37, therefore any other IGOR pro version used may require code adjustments

# Analyze calibration data 

1) verifications prior to analysis 
   - voltage wave should be named "CommVolt"
   - all current waves should follow format: "Curr#"
   - all current waves should be in Amps unit and CommVolt should be in V unit 
2) Import the voltage and all current waves into folder named "Calibration" 
3) Click on FSCV>Electrode Calibration
4) A window named “Calibrator” should appear (fig1) with the top left graph with a single voltammogram graphed onto it (#1)
5) go to Panel>Show Info to activate the cursors on the panel (fig2). Place cursors A/B around at the min and max points of the oxidation peak (~450-650mV)


k.	The current waves must then be redimensioned by clicking on the “Redimension Waves” button (#1) on the top left hand corner of the window. Depending on the amount of waves in the folder will determine how fast or slow this process is 
l.	All the current waves should be re-dimensioned and renamed in the data folder (fig1a)
m.	Next the current time course must be visualized for specific wave selection for consecutive steps. To do this, click on “Get Timecourse” button (#2). This can be slightly delayed by the amount of waves present, but eventually the timecourse wave (average current at oxidation vs sweep count) should appear (fig2)
n.	Next, the specific waves for averaging and voltammogram creation must be selected. This can be done by first going to Panel>show info. A thin rectangular panel will appear at the bottom of the “Calibrator” window (fig2, #3a). 
o.	Place the corresponding cursors in the desired sections of the timecourse graph as follows (#3): (make sure the amount of current voltage pulses selected for each cursor pair is identical)
i.	A/B=baseline
ii.	C/D=1st DA concentration
iii.	E/F=2nd DA concentration
iv.	G/H=3rd DA concentration
v.	I/J=4th DA concentration
p.	Once the cursors are placed in the desired sections of the timecourse graph, click on the “Calc Voltammograms” button (#4). This will calculate the average current pulse for each concentration, create background subtracted pulses and graph each one against the command voltage (fig2)
q.	The maximum current produced at oxidation (~600mV) must next be calculated. Click on the left bottom panel in the “Calibrator” window so the info panel applies to it and place the A cursor to the left of the peak and the B cursor to the right of the peak (#5). 
r.	In the black outlined box in the bottom right portion of the “Calibrator Window” enter the numerical DA concentration (in µM) in the boxes right under “Known concentration (uM):” text (#6). Click on the “Calc Calibration Curve” button right (#7) above the black outlined box and the calibration curve should appear in the panel right to the left of it. The sensitivity and the calculated error should also appear within the black outlined box
s.	Outside the “Calibrator” window, duplicate voltammogram and calibration curve graphs should appear along with a table of DA concentration vs current amount. These graphs and table can be manipulated as desired for exportation. 

  




