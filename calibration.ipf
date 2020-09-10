#pragma moduleName=FSCVcal
#include <Waves Average>

Menu "FSCV"
	"Electrode Calibration", FSCVcal#call()
end 	

//build GUI call(), draw() and init()
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
		//10th current randomly chosen for cursor orientation, no specific significance 
	Label /W=Calibrator#OxDef  VertCrossing   "Current (nA)"
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
	Variable /G con1da=1
	Variable /G con2da=1
	Variable /G con3da=1
	Variable /G con4da=1
		//must make results of SetVariables into global variables so can be used by Calibration function 
	SetVariable con1Var, win=Calibrator, value=con1da
	SetVariable con2Var, win=Calibrator, value=con2da
	SetVariable con3Var, win=Calibrator, value=con3da
	SetVariable con4Var, win=Calibrator, value=con4da
end 


static function CalcOx(oxidation): ButtonControl
	string oxidation 
//Create string list of all current waves in working directory and arrange names in list in numerical order
	string theWaveList1=WaveList("Curr*",  ";", "DIMS:1")
	string theWaveList=SortList(theWavelist1, ";", 16)	
//create timecourse template wave
	make /D /O /N=(ItemsInList(theWaveList, ";")) Timec
	wave tc=Timec
//set min and max current value of DA oxidation from background voltammogram 
	variable a=pcsr(A, "Calibrator#OxDef")
	variable b=pcsr(B, "Calibrator#OxDef")
//calculate the mean current (from cursors) of each current wave, save the calculated mean, and insert value into timecourse wave 
	string theWaveName
	variable i=0
	variable q=ItemsInList(theWaveList, ";")
		//set the number of repeats in for loop
	for(i=0; i<q; i+=1)
		theWaveName=GetStrFromList(theWaveList, i, ";")
		tc[i]=mean($theWaveName, pnt2x($theWaveName,a), pnt2x($theWaveName,b))
	endfor 
//graph new timecourse wave in specific GUI graph	
	AppendToGraph /W=Calibrator#Timecourse tc
	Label /W=Calibrator#Timecourse left "Current (A)"
	Label /W=Calibrator#Timecourse bottom "Sweep Count"
end 	

static function Voltammograms(voltgraphs): ButtonControl
	string voltgraphs
//Create string list of all current waves in working directory and arrange names in list in numerical order
	string theWaveList1=WaveList("Curr*",  ";", "DIMS:1")
	string theWaveList=SortList(theWavelist1, ";", 16)	
//create baseline wave for background subtracted DA current waves
	string theWaveNamebase
	string baseLineList= ""  
	variable q=0
	variable a=pcsr(A, "Calibrator#Timecourse")
	variable b=pcsr(B, "Calibrator#Timecourse")+1 
		//set first and last wave for wave average calculation based on timecourse wave
	for(q=a; q<b; q+=1)
		theWaveNamebase=StringFromList(q, theWaveList)	
		baseLineList=AddListItem(theWaveNamebase, baseLineList, "; ")
	endfor
		//creates string list of baseline current waves names 
	fWaveAverage(baseLineList, "", 0, 0, "baseline", "") 
		//save average baseline current wave as baseline
//first DA concentration average wave 
	string theWaveNameDA1
	string DA1LineList= ""
	variable c=pcsr(C, "Calibrator#Timecourse")
	variable d=pcsr(D, "Calibrator#Timecourse")+1
	for(q=c; q<d; q+=1)
		theWaveNameDA1=StringFromList(q, theWaveList)	
		DA1LineList=AddListItem(theWaveNameDA1, DA1LineList, "; ")
	endfor
	fWaveAverage(DA1LineList, "", 0, 0, "DA1", "") 
		//save average DA current wave as DA1
//for second DA concentration average wave 
	string theWaveNameDA2
	string DA2LineList= ""
	variable e=pcsr(E, "Calibrator#Timecourse")
	variable f=pcsr(F, "Calibrator#Timecourse")+1
	for(q=e; q<f; q+=1)
		theWaveNameDA2=StringFromList(q, theWaveList)	
		DA2LineList=AddListItem(theWaveNameDA2, DA2LineList, "; ")
	endfor
	fWaveAverage(DA2LineList, "", 0, 0, "DA2", "") 
		//save average DA current wave as DA2
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
		//save average DA current wave as DA3
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
	//save average DA current wave as DA4
//to create background subtracted DA current waves 
	//create template waves for subtraction
	Duplicate /O /S baseline 'diff1'
	Duplicate /O /S baseline 'diff2'
	Duplicate /O /S baseline 'diff3'
	Duplicate /O /S baseline 'diff4'
	wave DA1=DA1
	wave DA2=DA2
	wave DA3=DA3
	wave DA4=DA4	
	wave baseline=baseline
	diff1=DA1-baseline
	diff2=DA2-baseline
	diff3=DA3-baseline
	diff4=DA4-baseline
//Graph background subtracted DA waves against CommVolt			
	AppendtoGraph /W=Calibrator#Voltammogram /L=VertCrossing/B=HorizCrossing diff1,diff2,diff3,diff4 vs CommVolt
	ModifyGraph /W=Calibrator#Voltammogram rgb(diff1)=(0,0,0),rgb(diff3)=(0,0,65535),rgb(diff4)=(0,65535,0)
	Label /W=Calibrator#Voltammogram  VertCrossing   "Current (nA)"
	Label /W=Calibrator#Voltammogram HorizCrossing "Voltage (V)"
	//produce voltammogram graph outside of GUI for exporting 
	Display /L=VertCrossing/B=HorizCrossing diff1,diff2,diff3,diff4 vs CommVolt	
	ModifyGraph rgb(diff1)=(0,0,0),rgb(diff3)=(0,0,65535),rgb(diff4)=(0,65535,0)
	Label  VertCrossing   "Current (nA)"
	Label HorizCrossing "Voltage (V)"

end 

//for if want to recalculate background subtracted DA current waves and want to regraph new voltammograms
static function ClearVoltGraph(clear): ButtonControl
	string clear 
	RemoveFromGraph /W=Calibrator#Voltammogram diff1,diff2,diff3,diff4		
end 

static function Calibration(calculator): ButtonControl
	string calculator 
//calculate height of oxidation peak for each background subtracted DA wave
	make /O  /N=4 CurrentValue
		//create template wave so can save calculated peak heights that will be calculated by WaveStats 
	wave cw=CurrentValue
	WaveStats/Q /C=12 /R=[pcsr(A, "Calibrator#Voltammogram"),pcsr(B,"Calibrator#Voltammogram")] diff1
	cw[0]=V_Max //V_Max extracted before its is over written by the execution of WaveStats function 
	WaveStats/Q /C=12 /R=[pcsr(A, "Calibrator#Voltammogram"),pcsr(B,"Calibrator#Voltammogram")] diff2
	cw[1]=V_Max
	WaveStats/Q /C=12 /R=[pcsr(A, "Calibrator#Voltammogram"),pcsr(B,"Calibrator#Voltammogram")] diff3
	cw[2]=V_Max
	WaveStats/Q /C=12 /R=[pcsr(A, "Calibrator#Voltammogram"),pcsr(B,"Calibrator#Voltammogram")] diff4
	cw[3]=V_Max
//create DA concentration wave
	NVAR con1da=con1da
	NVAR con2da=con2da
	NVAR con3da=con3da
	NVAR con4da=con4da
	make /O  /N=4 DAuMvalue
	wave da=DAuMvalue
	da[0]=con1da
	da[1]=con2da
	da[2]=con3da
	da[3]=con4da
//Graph DA oxidation peaks values vs DA concentration
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
//Calculates SEM(error)
	variable SD=sqrt(variance(cw))
	variable SEM=(SD/sqrt(numpnts(cw)))*10^9 
	string Error=num2str(SEM) 
	TitleBox SEMcalc, win=Calibrator, title=Error, fcolor=(0,0,0)
	print "Error: ", Error
		//to print out value into notebook for copy/paste into external programs 
end 	

//to exit out of GUI when finish with analysis
static function Bye(exit): ButtonControl
	string exit 
	DoWindow /K Calibrator
		
end 	
	




	



