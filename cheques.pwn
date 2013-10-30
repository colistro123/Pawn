/*
-------
	PVars Used By This Script:
-------
*/
#define WELFARE_MONEY 1000

/* Forwards */
forward OnReceiveCheques(playerid);
forward tryToCashCheque(playerid, chequeid);
forward onCashCheque(playerid);
/* Enums */
enum {
	EChequeSystem_CashCheque = EChequeSystem_Base + 1,
	EChequeSystem_ShowMenu,
	EChequeSystem_DoNothing,
};
/* Functions */
sendPlayerCheques(playerid) {
	format(query, sizeof(query), "SELECT `id`, `jobid`, `amount` FROM `jobcheques` WHERE `charid` = %d && `cashed` != 1",GetPVarInt(playerid, "CharID"));
	mysql_function_query(g_mysql_handle, query, true, "OnReceiveCheques", "d",playerid);
}
public OnReceiveCheques(playerid) {
	new rows,fields;
	dialogstr[0] = 0;
	query[0] = 0;
	cache_get_data(rows,fields);
	format(query, sizeof(query), "**** Cheques for: %s ****\n",GetPlayerNameEx(playerid, ENameType_CharName));
	strcat(dialogstr,query,sizeof(dialogstr));
	if(rows < 1) {
		strcat(dialogstr,"No Cheques on record!",sizeof(dialogstr));
		ShowPlayerDialog(playerid, EChequeSystem_DoNothing, DIALOG_STYLE_MSGBOX, "{00BF00}Cheques:", dialogstr, "Close", "");
		return 1;
	} else {
		new chequeid, jobid, amount, field_data[32];
		for(new i=0;i<rows;i++) {
			cache_get_row(i,0,field_data);
			chequeid = strval(field_data);
			cache_get_row(i,1,field_data);
			jobid = strval(field_data);
			cache_get_row(i,2,field_data);
			amount = strval(field_data);
			format(query, sizeof(query), "Cheque ID: %d Purpose: %s, Amount: $%s, Beneficiary: %s\n",chequeid, returnChequeJobName(jobid),getNumberString(amount),GetPlayerNameEx(playerid, ENameType_CharName));
			strcat(dialogstr,query,sizeof(dialogstr));
		}
	}
	displayChequeInputID(playerid, DIALOG_STYLE_INPUT, "{00BF00}Enter The Cheque ID:", dialogstr, "Cash", "Cancel");
	return 0;
}
stock returnChequeJobName(jobid) {
	new string[64];
	if(jobid < 0 || jobid > sizeof(JobPickups)-1) {
		format(string, sizeof(string), "Welfare Cheque");
	} else {
		format(string, sizeof(string), JobPickups[jobid][EJobName]);
	}
	return string;
}
displayChequeInputID(playerid, inputstyle, title[], msg[], button1[], button2[]) {
	ShowPlayerDialog(playerid, EChequeSystem_CashCheque, inputstyle,title,msg,button1,button2);
}
ChequesOnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {
	#pragma unused response
	#pragma unused listitem
	#pragma unused inputtext
	chequesHandleDialog(playerid, dialogid, response, listitem, inputtext);
	return 1;
}
chequesHandleDialog(playerid, dialogid, response, listitem, inputtext[]) {
	#pragma unused inputtext
	#pragma unused listitem
	switch(dialogid) {
		case EChequeSystem_CashCheque: {
			if(!response) {
				SendClientMessage(playerid, X11_LIGHTBLUE, "* You closed the cheque menu.");
				showGovMenu(playerid);
				return 1;
			}
			processChequeID(playerid, strval(inputtext));
		}
		case EChequeSystem_DoNothing: {
			if(!response) {
				SendClientMessage(playerid, X11_LIGHTBLUE, "* You closed the cheque menu.");
				showGovMenu(playerid);
				return 1;
			}
		}
	}
	return 1;
}
processChequeID(playerid, chequeid) {
	query[0] = 0;//[128];
	format(query, sizeof(query),"SELECT 1 FROM `jobcheques` WHERE `id` = %d && cashed != 1",chequeid);
	mysql_function_query(g_mysql_handle, query, true, "tryToCashCheque", "dd", playerid, chequeid);
}
public tryToCashCheque(playerid, chequeid) {
	query[0] = 0;//[128];
	dialogstr[0] = 0;
	new rows, fields;
	cache_get_data(rows, fields);
	if(rows < 1) {
		ShowScriptMessage(playerid, "Couldn't ~r~find ~w~any ~r~cheques ~w~with that ID!", 5000);
		sendPlayerCheques(playerid);
	} else {
		format(query, sizeof(query), "SELECT `id`, `jobid`, `amount` FROM `jobcheques` WHERE `charid` = %d && `id` = %d",GetPVarInt(playerid, "CharID"),chequeid);
		mysql_function_query(g_mysql_handle, query, true, "onCashCheque", "d", playerid);
	}
}
public onCashCheque(playerid) {
	new rows,fields;
	dialogstr[0] = 0;
	query[0] = 0;
	cache_get_data(rows,fields);
	if(rows < 1) {
		return 1;
	}
	new chequeid, jobid, amount, field_data[32];
	for(new i=0;i<rows;i++) {
		cache_get_row(i,0,field_data);
		chequeid = strval(field_data);
		cache_get_row(i,1,field_data);
		jobid = strval(field_data);
		cache_get_row(i,2,field_data);
		amount = strval(field_data);
	}
	new bankamount = GetPVarInt(playerid, "Bank");
	SetPVarInt(playerid, "Bank", bankamount + amount);
	updateChequeState(chequeid, 1);
	ShowScriptMessage(playerid, "Your ~g~cheque ~w~has been ~g~cashed~w~!", 5000);
	sendPlayerCheques(playerid);
	return 0;
}
updateChequeState(chequeid, cashed) { //It's more than obvious to know that the cheque still exists on the DB if it was cashed before..
	format(query, sizeof(query),"UPDATE `jobcheques` SET `cashed` = %d WHERE `id` = %d",cashed,chequeid);
	mysql_function_query(g_mysql_handle, query, true, "EmptyCallback", "");	
}
/*
attemptToCreateCheque(playerid) {
	new msg[128];
	new account = GetPVarInt(playerid, "Bank");
	new check = GetPVarInt(playerid, "PayCheque");
	if(!hasLegalJob(playerid)) {
		account += check;
		format(msg, sizeof(msg), "* You earned $%s",getNumberString(check));
		SendClientMessage(playerid, COLOR_CUSTOMGOLD, msg);
		SetPVarInt(playerid, "Bank", account);
	} else {
		ShowScriptMessage(playerid, "You've received a ~g~cheque~w~, you can cash it any time at ~g~City Hall~w~!", 5000);
		createCheque(playerid, check);
	}
	DeletePVar(playerid, "PayCheque");
	return 1;
}
*/
attemptToCreateCheque(playerid) {
	new check = GetPVarInt(playerid, "PayCheque");
	new job = GetPVarInt(playerid, "Job");
	if(job < 0) {
		createCheque(playerid, WELFARE_MONEY + check);
		return 1;
	}
	if(hasLegalJob(playerid)) {
		createCheque(playerid, check);
	}
	DeletePVar(playerid, "PayCheque");
	return 1;
}
createCheque(playerid, amount) { //Use carefully, not to play around
	ShowScriptMessage(playerid, "You've received a ~g~cheque~w~, you can cash it any time at ~g~City Hall~w~!", 5000);
	format(query, sizeof(query),"INSERT INTO `jobcheques` (`charid`, `jobid`, `amount`, `cashed`) values (%d, %d, %d, 0)",GetPVarInt(playerid, "CharID"),GetPVarInt(playerid, "Job"),amount);
	mysql_function_query(g_mysql_handle, query, true, "EmptyCallback", "");	
}
