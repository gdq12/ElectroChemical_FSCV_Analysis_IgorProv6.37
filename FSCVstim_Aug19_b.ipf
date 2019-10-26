#pragma moduleName=FSCVstim
#include <Waves Average>

Menu "FSCV"
	"New Stimulation Folder", FSCVstim#NewStimFolder()
	"Stimulation Analysis", FSCVstim#call()
end 

static function NewStimFolder()
	NewDataFolder /O root:Stimulation
end	

static function call()
	DoWindow Stimulator
	if(V_Flag)
		DoWindow /F Stimulator
		return -1
	endif
	draw()
	init()
end

static function draw()
	NewPanel /K=2 /N=Stimulator /W=(55,45,1253,709) as "Stim Analysis"
	SetDrawLayer UserBack
	DrawText 9,332,"DA peaks normalized/baseline corrected:"
	Button SliceBut,pos={189,2},size={150,20},proc=FSCVstim#CalcOx,title="Graph Timecourse"
	Button CalcNormalBut,pos={253,312},size={175,20},proc=FSCVstim#NormBaseCalc,title="Graph Normalized data"
	Button ExitBut,pos={1114,635},size={75,20},proc=FSCVstim#Bye,title="Goodbye!"
	Button DiffCalcBut,pos={986,2},size={200,20},proc=FSCVstim#diffWaves,title="Subtract Background Current"
	Button RedimBut,pos={3,2},size={150,20},proc=FSCVstim#RedimWaves,title="Redimension Waves"
	Display/W=(6,23,1189,305)/HOST=# 
	RenameWindow #,StimTC
	SetActiveSubwindow ##
	Display/W=(6,335,1187,630)/HOST=# 
	RenameWindow #,NormTC
	SetActiveSubwindow ##
end 

static function init()	
	Button RedimBut, proc=FSCVstim#RedimWaves, win=Stimulator
	Button SliceBut, proc=FSCVstim#CalcOx, win=Stimulator
	Button DiffCalcBut, proc=FSCVstim#diffWaves, win=Stimulator 
	Button CalcNormalBut, proc=FSCVstim#NormBaseCalc, win=Stimulator
	Button ExitBut, proc=FSCVstim#Bye, win=Stimulator 
end

static function Bye(exit): ButtonControl
	string exit
	DoWindow /K Stimulator
end 	

static function RedimWaves(waves): ButtonControl
	string waves
	Redimension /N=700 root:Stimulation:CommVolt
	string theWaveList=WaveList("*CurrentIn",  ";", "DIMS:1")
	variable i=0
	string oddList= ""
	for(i=1;i<(ItemsinList(theWavelist, ";"))*2;i+=2)
		string NewName="Stim_"+ num2str(i)
		oddList=AddListItem(NewName, oddList, ";")
	endfor 
	string oddListSorted=SortList(oddList, ";", 16)
	for(i=0;i<ItemsinList(oddListSorted, ";");i+=1)
		Rename $StringFromList(i, theWaveList, ";"), $StringFromList(i, oddListSorted, ";")
	endfor
	string evenList=""
	for(i=2;i<(ItemsinList(theWaveList, ";"))*2+1;i+=2)
		string NewName1="Stim_"+ num2str(i)
		evenList=AddListItem(NewName1, evenList, ";")
	endfor
	string evenListSorted=SortList(evenList, ";", 16)
	for(i=0;i<ItemsinList(evenListSorted, ";");i+=1)
		Duplicate /O $StringFromList(i, oddListSorted, ";"), $StringFromList(i, evenListSorted, ";")
	endfor	
	for(i=0;i<ItemsinList(oddListSorted, ";");i+=1)
		Redimension /N=700 $StringFromList(i, oddListSorted)
	endfor 
	for(i=0;i<ItemsinList(evenListSorted, ";");i+=1)
		DeletePoints 0, 9999, $StringFromList(i, evenListSorted)
		Redimension /N=700 $StringFromList(i, evenListSorted) 
	endfor
end	

static function CalcOx(oxidation): ButtonControl
	string oxidation 
	string theWaveList1=WaveList("Stim*",  ";", "DIMS:1")
	string theWaveList=SortList(theWavelist1, ";", 16)	
	string theWaveName
	variable i=0
	variable q=ItemsInList(theWaveList, ";")
		
	make /D /O /N=(ItemsInList(theWaveList, ";")) StimTimecourse
	wave STIMtc=StimTimecourse
	
	for(i=0; i<q; i+=1)
		theWaveName=GetStrFromList(theWaveList, i, ";")
		STIMtc[i]=mean($theWaveName, pnt2x($theWaveName,213), pnt2x($theWaveName,264))
	endfor 
	
	AppendToGraph /W=Stimulator#STIMtc STIMtc
	Label /W=Stimulator#STIMtc left "Current (A)"
	Label /W=Stimulator#STIMtc bottom "Sweep Count"
end 	

static function diffWaves(diffwaves): ButtonControl
	string diffwaves
//calculate diffwaves
	//make baseline wave list
		string theWaveList1=WaveList("Stim*", ";", "DIMS:1") 
		string theWaveList=SortList(theWavelist1, ";", 16)	
		string theWaveNamebase 
		string baseLineList= ""
		variable q=0
		variable a=pcsr(A, "Stimulator#STIMtc") 
		variable b=pcsr(B, "Stimulator#STIMtc")
		for(q=a; q<b+1; q+=1)
			theWaveNamebase=StringFromList(q, theWaveList)
			baseLineList=AddListItem(theWaveNamebase, baseLineList, ";")
		endfor 
		fWaveAverage(baseLineList, "", 0,0, "baseline", "")
	//make the stimulus waves  list
		variable firstw=pcsr(C, "Stimulator#STIMtc")
		variable lastw=pcsr(D, "Stimulator#STIMtc")
		variable w=0	
		string stimWaveList1= ""
		for(w=firstw; w<lastw+1; w+=1)
			theWaveNameBase=StringFromList(w, theWaveList)
			stimWaveList1=AddListItem(theWaveNamebase, stimWaveList1, ";")
		endfor
		string stimWaveList=SortList(stimWaveList1, ";", 16)
	//make the diff name list
		string diffList1= ""
		for(w=firstw; w<lastw+1; w+=1)
			string name=StringFromList(w, theWaveList)+"_diff"
			diffList1=AddListItem(name, diffList1, ";")
		endfor
		string diffList=SortList(diffList1, ";", 16)
	//make diff waves	
		variable num=(ItemsInList(diffList, ";") 
		for(w=0; w<num; w+=1)
			wave stim=$StringFromList(w, stimWaveList)
			wave base=baseline
			MatrixOP /O /S $StringFromList(w, diffList)=stim-base
		endfor 
end		

static function NormBaseCalc(normWave): ButtonControl
	string normWave
//normalize wave 
	wave STIMtc=StimTimecourse
	variable AVG
	WaveStats /Q /C=3 STIMtc
	AVG=V_avg
	make /O /N=(numpnts(STIMtc)) Normtc
	variable i=0
	variable q=numpnts(STIMtc)
	for(i=0; i<q; i+=1)
		Normtc[i]=((STIMtc[i])/AVG)*100
	endfor	
//baseline Correction
	variable baseNorm
	WaveStats /Q /C=3 /R=[pcsr(A, "Stimulator#STIMtc"), pcsr(B,"Stimulator#Stimtc")] Normtc
	baseNorm=V_avg
	print baseNorm
	Duplicate /O Normtc, NormCorrected
	for(i=0; i<(numpnts(NormCorrected)); i+=1)
		NormCorrected[i]=(NormCorrected[i]-baseNorm)+100
	endfor	
	variable E=pcsr(E, "Stimulator#STIMtc")
	variable post=(pcsr(F, "Stimulator#STIMtc")-pcsr(E, "Stimulator#STIMtc"))
	DeletePoints 0, E, NormCorrected
	Redimension  /N=(post) NormCorrected 
	AppendToGraph /W=Stimulator#NormTC NormCorrected
	Label /W=Stimulator#NormTC left "% from baseline"
	Label /W=Stimulator#NormTC bottom "Sweep Count"
//to produce table and graph outside of GUI for exportation 	
	Display NormCorrected
	Label left "% from baseline"
	Label bottom "Sweep Count"
	Edit NormCorrected
end 	



	
	
	

