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
	NewPanel /K=2 /N= Cleaner /W=(305,45,619,258) as "Data Cleaner"
	SetDrawLayer UserBack
	DrawText 5,26,"1) Clean up Voltage pulses:"
	DrawText 5,87,"2) Clean up Current pulses:"
	Button VolClean,pos={84,38},size={150,20},title="Organize V-waves"
	SetVariable valA,pos={12,101},size={126,19},title="first pulse:",fSize=12
	SetVariable valB,pos={148,101},size={150,19},title="last pulse:",fSize=12
	Button CurrClean,pos={70,134},size={175,20},title="delete Current Pulses"
	Button ExitBut,pos={199,181},size={100,20},title="GoodBye!"
end 

static function init()
	Button VolClean, proc=FSCVcleaner#Voltages, win=Cleaner
	Button CurrClean, proc=FSCVcleaner#Currents, win=Cleaner
	Button ExitBut, proc=FSCVcleaner#Bye, win=Cleaner
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

static function Bye(exit): ButtonControl
	string exit
	DoWindow /K Cleaner
end		