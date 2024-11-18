
PROGRAM _INIT
	(* Insert code here *)
	 
END_PROGRAM

PROGRAM _CYCLIC
	(* Insert code here *)
	FileBrowseMV_0.FileDevices[0] 	:= 'USER';
	FileBrowseMV_0.NetworkConnectionOK	:= NetworkOK;
	FileBrowseMV_0.MpLink				:= ADR(gFileManagerUI);
	FileBrowseMV_0.USB_Detected			:= USB_OK;
	FileBrowseMV_0.ShowDialog			:= ShowDialog;
	FileBrowseMV_0();
	
END_PROGRAM

PROGRAM _EXIT
	(* Insert code here *)
	 
END_PROGRAM

