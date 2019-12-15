#pragma moduleName=FSCVcal
#include <Waves Average>

Menu "FSCV"
	"New Calibration Folder", FSCVcal#NewFolder()
	"Electrode Calibration", FSCVcal#call()
end 	

//after creating the Calibration subfolder, make sure red arrow in data browser is set to this folder 
//load all files using LoadPM to this subfolder 
//can cleanup the folder by deleting all but 1 voltageIn wave
//using Macros --> PPT Macros --> rename multiple wave, rename all current waves with format "Cal_#" (neccessary for following codes)

static function NewFolder()
	NewDataFolder /O root:Calibration
end 	

static function call()
	DoWindow Calibrator
	if(V_Flag)
		DoWindow /F Calibrator
		return -1
	endif
	draw()
	init()
end		

static function draw()
	NewPanel /K=2 /N=Calibrator /W=(75,45,1268,699) as "Calibrator"
	SetDrawLayer UserBack
	DrawText 8,355,"Concentration Voltammogram:"
	DrawText 552,356,"Calibration Curve:"
	DrawText 933,424,"Known Concentrations (uM):"
	DrawText 937,473,"Sensitivity (nA/uM):"
	SetDrawEnv fillpat= 0
	DrawRect 928,401,1180,565
	DrawText 939,395,"***enter values before calibration***"
	DrawText 941,524,"Error: "
	DrawText 13,22,"Set cursors to Oxidation Peak:"
	Button TCbut,pos={286,4},size={125,20},proc=FSCVcal#CalcOx,title="Graph Timecourse"
	Button VoltGraphBut,pos={389,472},size={150,20},proc=FSCVcal#Voltammograms,title="Calc Voltammograms"
	Button ClearGraphBut,pos={386,552},size={150,20},proc=FSCVcal#ClearVoltGraph,title="Clear Voltammogram"
	Button SlopeCalBut,pos={967,355},size={160,20},proc=FSCVcal#Calibration,title="Calc Calibration Curve"
	Button ExitBut,pos={1108,614},size={75,20},proc=FSCVcal#Bye,title="GoodBye!"
	SetVariable con1Var,pos={932,431},size={60,15},title="#1"
	SetVariable con1Var,value= root:Calibration:con1da
	SetVariable con2Var,pos={992,431},size={60,15},title="#2"
	SetVariable con2Var,value= root:Calibration:con2da
	SetVariable con3Var,pos={1052,431},size={60,15},title="#3"
	SetVariable con3Var,value= root:Calibration:con3da
	SetVariable con4Var,pos={1112,431},size={60,15},title="#4"
	SetVariable con4Var,value= root:Calibration:con4da
	TitleBox SlopeCalc,pos={967,479},size={12,24},title=" "
	TitleBox SlopeCalc,labelBack=(65535,65535,65535),fSize=12,frame=2
	Button SlopeCalcBut,pos={1065,486},size={50,20},disable=1,proc=FSCVcal#Calibration
	TitleBox SEMcalc,pos={970,530},size={12,24},title=" "
	TitleBox SEMcalc,labelBack=(65535,65535,65535),fSize=12,frame=2
	Display/W=(4,29,280,335)/HOST=# 
	RenameWindow #,OxDef
	SetActiveSubwindow ##
	AppendtoGraph /W=Calibrator#OxDef /L=VertCrossing/B=HorizCrossing Curr10 vs CommVolt
	Label /W=Calibrator#OxDef  VertCrossing   "Current (µA)"
	Label /W=Calibrator#OxDef HorizCrossing "Voltage (V)"
	Display/W=(286,29,1185,337)/HOST=# 
	RenameWindow #,Timecourse
	SetActiveSubwindow ##
	Display/W=(6,362,378,649)/HOST=# 
	RenameWindow #,Voltammogram
	SetActiveSubwindow ##
	Display/W=(549,362,919,647)/HOST=# 
	RenameWindow #,CalibrationCalc
	SetActiveSubwindow ##
end

static function init()
	Button TCbut, proc=FSCVcal#CalcOx, win=Calibrator
	Button VoltGraphBut, proc=FSCVcal#Voltammograms, win=Calibrator
	Button ClearGraphBut, proc=FSCVcal#ClearVoltGraph, win=Calibrator
	Button SlopeCalcBut, proc=FSCVcal#Calibration, win=Calibrator
	Button ExitBut, proc=FSCVcal#Bye, win=Calibrator
	Variable /G root:Calibration:con1da=1
	Variable /G root:Calibration:con2da=1
	Variable /G root:Calibration:con3da=1
	Variable /G root:Calibration:con4da=1
		//must make results of SetVariables into global variables so can be used by Calibration function 
	SetVariable con1Var, win=Calibrator, value=root:Calibration:con1da
	SetVariable con2Var, win=Calibrator, value=root:Calibration:con2da
	SetVariable con3Var, win=Calibrator, value=root:Calibration:con3da
	SetVariable con4Var, win=Calibrator, value=root:Calibration:con4da
end 


static function CalcOx(oxidation): ButtonControl
	string oxidation //need for the button effect, not play a role in this function 
	string theWaveList1=WaveList("Curr*",  ";", "DIMS:1")
		//to gather all the names of the current waves in folder and place into string 
	string theWaveList=SortList(theWavelist1, ";", 16)	
	string theWaveName
	variable i=0
		//this is the loop code to follow
	variable q=ItemsInList(theWaveList, ";")
		//this counts the number of current waves that are in the folder and sets this value for "q"
	
	make /D /O /N=(ItemsInList(theWaveList, ";")) Timec
	wave tc=Timec
		//this commences to create the wave that will be used to plot the time course making it as long as the number of current waves in the folder 
	
	variable a=pcsr(A, "Calibrator#OxDef")
	variable b=pcsr(B, "Calibrator#OxDef")
		//min and max current points in each background current will be used for mean current timecourse graph
	
	for(i=0; i<q; i+=1)
		theWaveName=GetStrFromList(theWaveList, i, ";")
		tc[i]=mean($theWaveName, pnt2x($theWaveName,a), pnt2x($theWaveName,b))
	endfor 
		//this loop extracts the name of the current wave from the string list, calculates the mean current between the specified points, 
		//then places the value in a cell in the "Timecourse" wave that was just created 
		//the values are placed into cells of this "wave" in sequential order because the forloop defined the min and max points by "i" and "q"
		//which then also determines the point number of the timecourse wave via "[i]"	
	
	AppendToGraph /W=Calibrator#Timecourse tc
		//to graph the new timecourse wave to the specific window in the GUI, path of place of window must be specified in /W=
	Label /W=Calibrator#Timecourse left "Current (A)"
	Label /W=Calibrator#Timecourse bottom "Sweep Count"
end 	

static function Voltammograms(voltgraphs): ButtonControl
	string voltgraphs //for button function, no significant value in this function 
	string theWaveList1=WaveList("Curr*",  ";", "DIMS:1")
	string theWaveList=SortList(theWavelist1, ";", 16)	
//for baseline wave
	string theWaveNamebase
	string baseLineList= "" //no space between the quotation marks or else wont be properly recognized as list wave in fWaveAverage function 
	variable q=0
	variable a=pcsr(A, "Calibrator#Timecourse")
	variable b=pcsr(B, "Calibrator#Timecourse")+1 //wrote like this because when examined list string, the desired waves were recalled 
		//variables a and b set to cursor position so the for loop can recall the wave names from start to finish based in the cursor position in the timecourse wave
		//predict for cursor function dont need a ocal reference of Timecourse wave 
	for(q=a; q<b; q+=1)
		theWaveNamebase=StringFromList(q, theWaveList)	
		baseLineList=AddListItem(theWaveNamebase, baseLineList, "; ")
	endfor
		//the for loop forms the list string backwards, so wave from last cursor first and wave from first cursor last 
		//this backward sequential organization of wave names doesnt effect diffwave results 
	fWaveAverage(baseLineList, "", 0, 0, "baseline", "") 
		//"if" issues with fWaveAverage in compilation --> deactivate in procedure file first via // then compile wave average.ipf (search for it) 
		//fWaveAverage is a wave metrics function and can search for its helpfile and procedure file for more details on its functionality 
//for first DA concentration wave 
	string theWaveNameDA1
	string DA1LineList= ""
	variable c=pcsr(C, "Calibrator#Timecourse")
	variable d=pcsr(D, "Calibrator#Timecourse")+1
	for(q=c; q<d; q+=1)
		theWaveNameDA1=StringFromList(q, theWaveList)	
		DA1LineList=AddListItem(theWaveNameDA1, DA1LineList, "; ")
	endfor
	fWaveAverage(DA1LineList, "", 0, 0, "DA1", "") 
//for second DA concentration wave 
	string theWaveNameDA2
	string DA2LineList= ""
	variable e=pcsr(E, "Calibrator#Timecourse")
	variable f=pcsr(F, "Calibrator#Timecourse")+1
	for(q=e; q<f; q+=1)
		theWaveNameDA2=StringFromList(q, theWaveList)	
		DA2LineList=AddListItem(theWaveNameDA2, DA2LineList, "; ")
	endfor
	fWaveAverage(DA2LineList, "", 0, 0, "DA2", "") 
//for third DA concentration wave
	string theWaveNameDA3
	string DA3LineList= ""
	variable g=pcsr(G, "Calibrator#Timecourse")
	variable h=pcsr(H, "Calibrator#Timecourse")+1
	for(q=g; q<h; q+=1)
		theWaveNameDA3=StringFromList(q, theWaveList)	
		DA3LineList=AddListItem(theWaveNameDA3, DA3LineList, "; ")
	endfor
	fWaveAverage(DA3LineList, "", 0, 0, "DA3", "") 
//for fourth DA concetration wave
	string theWaveNameDA4
	string DA4LineList= ""
	variable i=pcsr(I, "Calibrator#Timecourse")
	variable j=pcsr(J, "Calibrator#Timecourse")+1
	for(q=i; q<j; q+=1)
		theWaveNameDA4=StringFromList(q, theWaveList)	
		DA4LineList=AddListItem(theWaveNameDA4, DA4LineList, "; ")
	endfor
	fWaveAverage(DA4LineList, "", 0, 0, "DA4", "") 
//to calculate voltammograms 
	Duplicate /O /S baseline 'diff1'
	Duplicate /O /S baseline 'diff2'
	Duplicate /O /S baseline 'diff3'
	Duplicate /O /S baseline 'diff4'
	wave baseline=baseline
	wave DA1=DA1
	wave DA2=DA2
	wave DA3=DA3
	wave DA4=DA4	
	wave base=baseline
	diff1=DA1-base
	diff2=DA2-base
	diff3=DA3-base
	diff4=DA4-base
		//makes the actual difference wave
		//cant use MatrixOP because then if not use all cursors the code will malfunction and not work, will have to manually silence particular lines each time 
	
	AppendtoGraph /W=Calibrator#Voltammogram /L=VertCrossing/B=HorizCrossing diff1,diff2,diff3,diff4 vs CommVolt
	ModifyGraph /W=Calibrator#Voltammogram rgb(diff1)=(0,0,0),rgb(diff3)=(0,0,65535),rgb(diff4)=(0,65535,0)
		//adds the waves to the correct subwindow in GUI
	Label /W=Calibrator#Voltammogram  VertCrossing   "Current (nA)"
	Label /W=Calibrator#Voltammogram HorizCrossing "Voltage (V)"
//produce voltammogram graph outside of GUI for exporting 
	Display /L=VertCrossing/B=HorizCrossing diff1,diff2,diff3,diff4 vs CommVolt	
	ModifyGraph rgb(diff1)=(0,0,0),rgb(diff3)=(0,0,65535),rgb(diff4)=(0,65535,0)
	Label  VertCrossing   "Current (nA)"
	Label HorizCrossing "Voltage (V)"

end 

static function ClearVoltGraph(clear): ButtonControl
	string clear 
	RemoveFromGraph /W=Calibrator#Voltammogram diff1,diff2,diff3,diff4
		//this is if want to recalculate the diffwaves, then must remove the waves already made so no conflict in cursor function in the calibration function 
end 

static function Calibration(calculator): ButtonControl
	string calculator //not meaningful in this function, just for button functionality 
//calculate peaks for yvalues 
	make /O  /N=4 CurrentValue
	wave cw=CurrentValue
	WaveStats/Q /C=12 /R=[pcsr(A, "Calibrator#Voltammogram"),pcsr(B,"Calibrator#Voltammogram")] diff1
	cw[0]=V_Max //V_Max extracted before its is over written by the execution of WaveStats function 
	WaveStats/Q /C=12 /R=[pcsr(A, "Calibrator#Voltammogram"),pcsr(B,"Calibrator#Voltammogram")] diff2
	cw[1]=V_Max
	WaveStats/Q /C=12 /R=[pcsr(A, "Calibrator#Voltammogram"),pcsr(B,"Calibrator#Voltammogram")] diff3
	cw[2]=V_Max
	WaveStats/Q /C=12 /R=[pcsr(A, "Calibrator#Voltammogram"),pcsr(B,"Calibrator#Voltammogram")] diff4
	cw[3]=V_Max
//input DAuM for xvalues 
	NVAR con1da=root:Calibration:con1da
	NVAR con2da=root:Calibration:con2da
	NVAR con3da=root:Calibration:con3da
	NVAR con4da=root:Calibration:con4da
	make /O  /N=4 DAuMvalue
	wave da=DAuMvalue
	da[0]=con1da
	da[1]=con2da
	da[2]=con3da
	da[3]=con4da
//Graph nA peaks vs uM DA
	AppendtoGraph/W=Calibrator#CalibrationCalc CurrentValue vs DAuMvalue
	ModifyGraph /W=Calibrator#CalibrationCalc mode=2,lsize=5
	Label /W=Calibrator#CalibrationCalc left "Current (nA)"
	Label /W=Calibrator#CalibrationCalc bottom "DA concentration (uM)"
//produce graph outside of GUI for exportation 
	Display CurrentValue vs DAuMvalue
	ModifyGraph mode=2,lsize=5
	Label left "Current (nA)"
	Label bottom "DA concentration (uM)"
	CurveFit/M=2/W=0 line, CurrentValue/X=DAuMvalue/D
//Calculate sensitivity 
	StatsLinearRegression /PAIR DAuMvalue, CurrentValue
	Duplicate /O /U W_StatsLinearRegression, Stats
		//must duplicate W_StatsLinearRegression wave to extract the b value 
	variable Sensitivity 
	sensitivity=(Stats[0][2])*10^9
		//extracts the slope value 
	string SensSlope
	SensSlope=num2str(sensitivity)
		//converts value to string so can be read by TitleBox function 
	TitleBox SlopeCalc, win=Calibrator, title=SensSlope, fcolor=(0,0,0)
	printf "Sensitivity: %s nA/uM\r", SensSlope
		//so can be printed into the notebook for copy and paste to other files like word or excel
	Edit DAuMValue, CurrentValue	
//Calculates SEM
	variable SD=sqrt(variance(cw))
	variable SEM=(SD/sqrt(numpnts(cw)))*10^9 
	string Error=num2str(SEM) 
	TitleBox SEMcalc, win=Calibrator, title=Error, fcolor=(0,0,0)
	print "Error: ", Error
end 	

static function Bye(exit): ButtonControl
	string exit //for button functionality 
	DoWindow /K Calibrator
		//to close out of GUI with ease since x on panel was disabled by /K=2 in draw function 
end 	
	



