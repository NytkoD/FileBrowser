
FUNCTION_BLOCK FileBrowseMV
	VAR_INPUT
		NetworkConnectionOK : BOOL; (*Allows selection of Network files (DevLink) if set up.*)
		FileDevices : ARRAY[0..2] OF STRING[40]; (*Files devices are listed in order, Local user partition, Network, USB*)
		MpLink : UDINT; (*Address of mappFileManagerUI*)
		USB_Detected : BOOL; (*Allows selection of USB files if setup*)
	END_VAR
	VAR_OUTPUT
		FilePath : STRING[200]; (*Path to chosen file*)
	END_VAR
	VAR_INPUT
		ShowDialog : BOOL; (*True when filebrowsing is occuring. This was tied to a pop up in mapp view.*)
	END_VAR
	VAR
		Index : UINT; (*Index of focused file in current directory*)
		CurrentPage : USINT; (*Page number withing directory*)
		Filter : STRING[40]; (*Text that is being looked for*)
		FilterInput : BOOL; (*Indication that filter has been applied*)
		DataProvider : ARRAY[0..49] OF STRING[100]; (*Output text to mappview to be displayed in listbox*)
		Open : BOOL; (*Command to select the currently focused file and update the FilePath*)
		MaxPages : USINT; (*Total number of pages based on number of files in current directory*)
		temp : STRING[200]; (*Temp string*)
		ToggleNetwork : BOOL; (*Toggle status of network button*)
		ToggleUSB : BOOL; (*Toggle status of USB button*)
		ToggleLocal : BOOL; (*Toggle status of Local button (User partition)*)
		TotalIndex : UDINT; (*Total number of file and folders found within current directory*)
		PreviousDevice : UINT; (*Last selected device*)
		EnteredFolderCnt : USINT; (*Keeps track of how many levels deep within a folder user has gone, used for folder back button visibility*)
		FolderUp : BOOL; (*Command to exit out of current folder, going up a level*)
		WaitForRefresh : BOOL; (*Flag for refreshing list*)
		TON_Refresh : TON; (*Timer for refreshing list*)
		Close : BOOL;
		ListClicked : BOOL; (*Indicates that user has clicked on the list *)
		PreviousIndex : UINT; (*Keep tracks of last focused index*)
		TempStringArrayIndex : UINT;
		i : UINT;
		ShowFolderBackBtn : BOOL; (*Visibility of folder back button*)
		MpFileManagerUI_FB : MpFileManagerUI;
		UIconnect : MpFileManagerUIConnectType;
		UIsetup : MpFileManagerUISetupType;
		zzEdge00000 : BOOL;
		zzEdge00001 : BOOL;
		zzEdge00002 : BOOL;
		zzEdge00003 : BOOL;
	END_VAR
END_FUNCTION_BLOCK
