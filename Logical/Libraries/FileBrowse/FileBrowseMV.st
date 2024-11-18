
(* Controls compound widget to interact with mpFileUI to display a file browser. *)
FUNCTION_BLOCK FileBrowseMV
	UIconnect.DeviceList.DeviceNames[0]	:= FileDevices[0];
	UIconnect.DeviceList.DeviceNames[1]	:= FileDevices[1];
	UIconnect.DeviceList.DeviceNames[2]	:= FileDevices[2];
	
	MpFileManagerUI_FB.MpLink 		:= MpLink;
	MpFileManagerUI_FB.Enable		:= TRUE;
	MpFileManagerUI_FB.ErrorReset;
	MpFileManagerUI_FB.UIConnect	:= ADR(UIconnect);
	MpFileManagerUI_FB.UISetup		:= UIsetup;
	//Timer delay on refresh. FB needs to run an indeterminate amount of cycles before a refresh
	IF TON_Refresh.Q THEN
		UIconnect.File.Refresh	:= TRUE;
		WaitForRefresh		:= FALSE;
		Index				:= 0;
		TotalIndex			:= 0;
	END_IF
	
	IF EDGEPOS(ShowDialog) THEN
		UIconnect.File.Refresh			:= TRUE;
	END_IF
	
	//Go to local if connection lost
	IF ToggleNetwork AND NOT(NetworkConnectionOK) THEN
		ToggleLocal	:= TRUE;
	ELSIF ToggleUSB AND NOT(USB_Detected) THEN
		ToggleLocal	:= TRUE;
	END_IF
	//Refresh when changing devices
	IF PreviousDevice <> UIconnect.DeviceList.SelectedIndex THEN
		WaitForRefresh					:= TRUE;
		PreviousDevice					:= UIconnect.DeviceList.SelectedIndex;
	END_IF
	ShowFolderBackBtn	:= (EnteredFolderCnt > 0);
	// Only runs while  selection dialog is open
	IF ShowDialog THEN
		//Count number of total pages
		MaxPages 					:= UDINT_TO_USINT((UIconnect.File.PathInfo.FileCount + UIconnect.File.PathInfo.FolderCount) / UIsetup.FileListSize);
		IF (UIconnect.File.PathInfo.FileCount + UIconnect.File.PathInfo.FolderCount) > (UIsetup.FileListSize * MaxPages) THEN
			MaxPages					:= MaxPages + 1;
		END_IF
		IF MaxPages < 1 THEN
			MaxPages	:= 1;
		END_IF
		
		//Resets all values when changing devices
		IF EDGEPOS(ToggleNetwork) THEN
			Index							:= 0;
			TotalIndex						:= 0;
			EnteredFolderCnt					:= 0;
			ToggleUSB						:= FALSE;
			ToggleLocal						:= FALSE;
			UIconnect.DeviceList.SelectedIndex 	:= 1;
		END_IF
		IF EDGEPOS(ToggleLocal) THEN
			Index							:= 0;
			TotalIndex						:= 0;
			EnteredFolderCnt					:= 0;
			ToggleUSB						:= FALSE;
			ToggleNetwork					:= FALSE;
			UIconnect.DeviceList.SelectedIndex 	:= 0;
		END_IF
		IF EDGEPOS(ToggleUSB) THEN
			Index							:= 0;
			TotalIndex						:= 0;
			EnteredFolderCnt					:= 0;
			ToggleLocal						:= FALSE;
			ToggleNetwork					:= FALSE;
			UIconnect.DeviceList.SelectedIndex 	:= 2;
		END_IF
		// Goes back to Local file device if USB connection is lost
		IF UIconnect.DeviceList.SelectedIndex = 2 AND NOT(USB_Detected) THEN
			ToggleLocal		:= TRUE;
		END_IF
		//Adjusts filter to not be exact
		IF FilterInput THEN
			brsstrcpy(ADR(UIconnect.File.Filter),ADR('*'));
			brsstrcat(ADR(UIconnect.File.Filter),ADR(Filter));
			brsstrcat(ADR(UIconnect.File.Filter),ADR('*'));
			WaitForRefresh		:= TRUE;
			FilterInput				:= FALSE;
		END_IF
		//Updates the  list
		brsmemset(ADR(DataProvider),0,SIZEOF(DataProvider));
		FOR i:= 0 TO UIsetup.FileListSize BY 1 DO
			IF brsstrcmp(ADR(UIconnect.File.List.Items[i].Name),ADR('')) <> STRINGCMP_NO_DIFF THEN
				brsmemset(ADR(DataProvider[i]),0,SIZEOF(DataProvider[i]));
				brsstrcat(ADR(DataProvider[i]),ADR('{"value":"'));
				brsitoa(i,ADR(TempStringArrayIndex));
				brsstrcat(ADR(DataProvider[i]),ADR(TempStringArrayIndex));
				brsstrcat(ADR(DataProvider[i]),ADR('","text":"'));
				brsstrcat(ADR(DataProvider[i]),ADR(UIconnect.File.List.Items[i].Name));
				brsstrcat(ADR(DataProvider[i]),ADR('"}'));
			END_IF
		END_FOR
		//Updates TotalIndex and makes sure correct  is selected when user touchs the list
		IF ListClicked THEN
			IF Index < PreviousIndex THEN
				TotalIndex	:= TotalIndex - (PreviousIndex - Index);
			ELSE
				TotalIndex	:= TotalIndex + (Index - PreviousIndex);
			END_IF
			UIconnect.File.List.Items[Index].IsSelected	:= TRUE;
			ListClicked	:= FALSE;
		END_IF
		// index calculations based on actions taken and current position within list
		IF UIconnect.File.List.StepUp THEN
			IF Index > 0 THEN
				Index		:= Index - 1;
			END_IF
			IF TotalIndex > 0 THEN
				TotalIndex	:= TotalIndex - 1;
			END_IF
		ELSIF UIconnect.File.List.StepDown THEN
			IF Index < (UIsetup.FileListSize - 1) AND Index < (UIconnect.File.PathInfo.FileCount + UIconnect.File.PathInfo.FolderCount - 1)  THEN
				Index		:= Index + 1;
			END_IF
			IF TotalIndex < (UIconnect.File.PathInfo.FileCount + UIconnect.File.PathInfo.FolderCount - 1) THEN
				TotalIndex	:= TotalIndex + 1;
			END_IF
		ELSIF UIconnect.File.List.PageUp THEN
			IF Index > 0 THEN
				TotalIndex	:= TotalIndex - Index;
				Index		:= 0;
			ELSIF CurrentPage > 1 THEN
				TotalIndex	:= TotalIndex - (UIsetup.FileListSize - 1);
			ELSE
				TotalIndex	:= 0;
			END_IF	
		ELSIF UIconnect.File.List.PageDown THEN
			IF Index < (UIsetup.FileListSize - 1) AND Index < (UIconnect.File.PathInfo.FileCount + UIconnect.File.PathInfo.FolderCount - 1)  THEN
				TotalIndex	:= TotalIndex + MIN(UDINT_TO_UINT((UIconnect.File.PathInfo.FileCount + UIconnect.File.PathInfo.FolderCount - 1)),(UIsetup.FileListSize - 1 - Index));
				Index		:= MIN(UDINT_TO_UINT((UIconnect.File.PathInfo.FileCount + UIconnect.File.PathInfo.FolderCount - 1)),(UIsetup.FileListSize - 1));
			ELSIF UIconnect.File.List.RangeStart > 0 THEN
				TotalIndex	:= MIN((TotalIndex + (UIsetup.FileListSize - 1)),(UIconnect.File.PathInfo.FileCount + UIconnect.File.PathInfo.FolderCount - 1));
			END_IF
		END_IF
		// Current  page
		IF TotalIndex > 0 THEN
			CurrentPage	:= UDINT_TO_USINT(TotalIndex / UIsetup.FileListSize) + 1;
		ELSE
			CurrentPage	:= 1;
		END_IF
		IF CurrentPage = 1 THEN
			// Weird timing issue sometimes causes TotalIndex to not update properly, this will hopefully minimize the chances of that happening
			TotalIndex		:= Index;
		END_IF
		PreviousIndex	:= Index;
	END_IF
	
	IF Open THEN
		IF UIconnect.File.List.Items[Index].IsFolder THEN
			UIconnect.File.EnterFolder	:= TRUE;
			WaitForRefresh			:= TRUE;
			EnteredFolderCnt			:= EnteredFolderCnt + 1;
		ELSE
			brsstrcpy(ADR(FilePath),ADR(''));
			// assemble in format that MpCnc wants (FileDev:Path/File)
			brsstrcpy(ADR(temp), ADR(UIconnect.DeviceList.DeviceNames[UIconnect.DeviceList.SelectedIndex]));
			brsstrcat(ADR(temp), ADR(':'));
			IF brsstrcmp(ADR(UIconnect.File.PathInfo.CurrentDir),ADR('')) <> STRINGCMP_NO_DIFF THEN 
				brsstrcat(ADR(temp), ADR(UIconnect.File.PathInfo.CurrentDir));
				brsstrcat(ADR(temp), ADR('/'));
				brsstrcpy(ADR(FilePath),ADR(UIconnect.File.PathInfo.CurrentDir));
				brsstrcat(ADR(FilePath), ADR('/'));
			END_IF
			brsstrcat(ADR(temp), ADR(UIconnect.File.List.Items[Index].Name));		
			brsstrcat(ADR(FilePath),ADR(UIconnect.File.List.Items[Index].Name));
			Close	:= TRUE;
		END_IF
		Open		:= FALSE;	
	END_IF
	
	//Allows user to move up a directory
	IF EnteredFolderCnt > 0 AND FolderUp THEN
		UIconnect.File.FolderUp 	:= TRUE;
		WaitForRefresh				:= TRUE;
		FolderUp					:= FALSE;
		EnteredFolderCnt			:= EnteredFolderCnt - 1;
	END_IF
	//Resets counts
	IF NOT(ShowDialog) AND NOT(Open)THEN
		TotalIndex				:= 0;
		Index					:= 0;
		WaitForRefresh			:= 0;
		brsstrcpy(ADR(Filter),ADR(''));
		CurrentPage				:= 1;
		Close					:= 0;
		brsstrcpy(ADR(UIconnect.File.Filter),ADR(''));
	END_IF
	TON_Refresh(IN := WaitForRefresh, PT := T#700ms);
	MpFileManagerUI_FB();
	
END_FUNCTION_BLOCK
