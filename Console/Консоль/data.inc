
	STYLBT equ WS_CHILD+BS_DEFPUSHBUTTON+WS_VISIBLE
	STYLED equ WS_CHILD+WS_VISIBLE+WS_BORDER+WS_TABSTOP
	STYLLB equ WS_CHILD+WS_VISIBLE
	
	ClassName	DB 'WinClass',0
	CLSBT 		DB 'BUTTON',0
	CLSED		DB 'EDIT',0
	CLSLB		DB 'STATIC',0

	AppName  		DB '���������',0
	
	TLB_L1			DB ' ������� ������:'
	HLB_L1			DD 0
	TED_Ed1			DB ' '
	HED_Ed1			DD 0
	TED_Ed2			DB ' '
	HED_Ed2			DD 0 
	TBT_BtConsole	DB '�������'
	HBT_BtConsole	DD 0 
	TBT_BtEdit		DB '����'
	HBT_BtEdit		DD 0
	TBT_BtMessage	DB '���������'
	HBT_BtMessage	DD 0