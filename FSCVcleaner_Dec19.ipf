#pragma moduleName=FSCVcleaner

Menu "FSCV"
	"Cleanup data", FSCVcleaner#call()
end 	

static function call()
	DoWindow Cleaner
	if(V_flag)
		DoWindow /F Cleaner
		return -1
	endif
	draw()
	init()
end

static function draw()
	NewPanel /K=2 /N= Cleaner /W=(130,70,441,353) as "Data Cleaner"
	SetDrawLayer UserBack
	DrawText 5,26,"1) Clean up Voltage pulses:"
	DrawText 5,87,"2) Clean up Current pulses:"
	DrawText 5,180,"3) Current wave customization"
	Button VolClean,pos={84,38},size={150,20},proc=FSCVcleaner#Voltages,title="Organize V-waves"
	SetVariable valA,pos={12,101},size={126,19},title="first pulse:",fSize=12
	SetVariable valA,value= root:Calibration:firstW
	SetVariable valB,pos={148,101},size={150,19},title="last pulse:",fSize=12
	SetVariable valB,value= root:Calibration:lastW
	Button CurrClean,pos={70,134},size={175,20},proc=FSCVcleaner#Currents,title="delete Current Pulses"
	Button ExitBut,pos={201,243},size={100,20},proc=FSCVcleaner#Bye,title="GoodBye!"
	Button RedimBut,pos={54,195},size={200,20},proc=FSCVcleaner#Redim10Hz,title="Redimension current waves"
end 

static function init()
	Button VolClean, proc=FSCVcleaner#Voltages, win=Cleaner
	Button CurrClean, proc=FSCVcleaner#Currents, win=Cleaner
	Button ExitBut, proc=FSCVcleaner#Bye, win=Cleaner
	Button RedimBut, proc=FSCVcleaner#Redim10Hz, win=Cleaner
	Variable /G firstW=1
	Variable /G lastW=1
	SetVariable valA, win=Cleaner, value=firstW
	SetVariable valB, win=Cleaner, value=lastW
end 	

static function Voltages(waves): ButtonControl
	string waves
	variable i=0
	string theVoltageList1=WaveList("*VoltageIn", ";", "DIMS:1")
	for(i=0;i<1;i+=1)
		Rename $StringFromList(i, theVoltagelist1, ";"), CommVolt
	endfor	
	
	string theVoltageList=WaveList("*VoltageIn", ";", "DIMS:1")
	for(i=0; i<ItemsInList(theVoltageList); i+=1)
		KillWaves $StringFromList(i, theVoltageList, ";")
	endfor	
end 		

static function Currents(waves): ButtonControl
	string waves
	NVAR a=firstW
	NVAR b=lastW
	string theCurrentList=WaveList("*CurrentIn", ";", "DIMS:1")
	variable i=0
	for(i=a; i<b; i+=1)
		KillWaves $StringFromlist(i, theCurrentList, ";")
	endfor
end 		

static function Redim10Hz(waves): ButtonControl
	string waves
	Redimension /N=700 root:calibration:CommVolt
	string theWaveList=WaveList("*CurrentIn",  ";", "DIMS:1")
	variable i=0
	string oddList= ""
	for(i=1;i<(ItemsinList(theWavelist, ";"))*2;i+=2)
		string NewName="Curr_"+ num2str(i)
		oddList=AddListItem(NewName, oddList, ";")
	endfor 
	string oddListSorted=SortList(oddList, ";", 16)
	for(i=0;i<ItemsinList(oddListSorted, ";");i+=1)
		Rename $StringFromList(i, theWaveList, ";"), $StringFromList(i, oddListSorted, ";")
	endfor
	string evenList=""
	for(i=2;i<(ItemsinList(theWaveList, ";"))*2+1;i+=2)
		string NewName1="Curr_"+ num2str(i)
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

static function Bye(exit): ButtonControl
	string exit
	DoWindow /K Cleaner
end		