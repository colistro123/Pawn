/* ------------ Purpose: Game TextDraws ------------  */

enum ETDType {
	EType_Normal,
	EType_VehGUI, //vehicle GUI
};
enum eTextDrawProps {
	TextDrawName[128],
	Float:TDScreenX,
	Float:TDScreenY,
	Float:TDLetterSizeX,
	Float:TDLetterSizeY,
	Float:PlayerTDTextSizeX,
	Float:PlayerTDTextSizeY,
	TDAlignment,
	TDColor,
	TDUseBox,
	TDBoxColor,
	TDSetShadow,
	TDSetOutline,
	TDBgColor,
	TDFont,
	TDSetProportional,
	TDCanBeHiddenByPlayer,
	ETDType:ETDrawType
};
new TextDrawProperties[][eTextDrawProps] = { //Here you can add the textdraw formats to manipulate them later, they load automatically
	{"uiHelpText", 529.000732, 157.629531, 0.150333, 0.849183,513.667419, 166.340988,2,-1,true,150,0,0,180,2,1,0,EType_Normal},
	{"FadeScreen", -20.000000, 2.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0, 0,true,0,0,0,0,0,1,0,EType_Normal},
	{"MapLocation", 8.666667, 436.918579, 0.183666, 0.836740, 999.666667, 30.000000, 1, -1,false,0,0,1,255,2,1,0,EType_Normal},
	{"WebsiteTD", 570.000000, 10.000000, 0.270000, 1.000000,-415.458435, 167.092651, 2, -1724710657,false,0,0,1,255,3,1,0,EType_Normal},
	//vehicle GUI - Can Be Hidden? No
	//Box
	{"vehGuiBOX", 623.666809, 320.492523, 0.000000, 9.270159, 451.666595, 0.000000, 1, 0,true,102,0,0,255,0,1,0,EType_VehGUI},
	//Fonts
	{"vehGuiName", 459.333251, 323.970184, 0.183666, 0.836740, 999.666667, 30.000000, 1, -1,true,0,0,1,255,1,1,0,EType_VehGUI},
	{"vehGuiFuel", 459.333251, 333.096252, 0.183666, 0.836740, 999.666667, 30.000000, 1, -1,true,0,0,1,255,1,1,0,EType_VehGUI},
	{"vehGuiMile", 459.333251, 342.222320, 0.183666, 0.836740, 999.666667, 30.000000, 1, -1,true,0,0,1,255,1,1,0,EType_VehGUI},
	{"vehGuiSpeed", 459.333251, 350.933288, 0.183666, 0.836740, 999.666667, 30.000000, 1, -1,true,0,0,1,255,1,1,0,EType_VehGUI},
	{"vehGuiCondition", 459.333251, 358.399963, 0.183666, 0.836740, 999.666667, 30.000000, 1, -1,true,0,0,1,255,1,1,0,EType_VehGUI},
	{"vehGuiEngState", 459.333251, 367.111053, 0.183666, 0.836740, 999.666667, 30.000000, 1, -1,true,0,0,1,255,1,1,0,EType_VehGUI},
	{"vehGuiLights", 459.333251, 376.651763, 0.183666, 0.836740, 999.666667, 30.000000, 1, -1,true,0,0,1,255,1,1,0,EType_VehGUI} // 152.000015,87.111129
	//End of vehicle GUI
};

new PlayerText:TextDrawID[MAX_TEXT_DRAWS][MAX_PLAYERS];

initializeTextDraws(playerid) { //Here we can initialize textdraws among other things
	showSiteTD(playerid, 1, 255, 0xFF0000FF, "~r~InglewoodRP.com"); //-1724710657
}
forward showSiteTD(playerid, show, bgcolor, fontcolor, const parsedstring[]); 
public showSiteTD(playerid, show, bgcolor, fontcolor, const parsedstring[]) {
	new websiteTD = GetPVarInt(playerid, "WebsiteTD");
	new stringParse[64];
	PlayerTextDrawHide(playerid, PlayerText:websiteTD); //Hide it first so it doesn't overlap
	if(show == 1) {
		format(stringParse,sizeof(stringParse),"%s",parsedstring);
		PlayerTextDrawSetString(playerid, PlayerText:GetPVarInt(playerid, "WebsiteTD"), stringParse);
		PlayerTextDrawBackgroundColor(playerid, PlayerText:websiteTD, bgcolor);
		PlayerTextDrawBoxColor(playerid, PlayerText:websiteTD, bgcolor);
		PlayerTextDrawColor(playerid, PlayerText:websiteTD, fontcolor);
		PlayerTextDrawShow(playerid, PlayerText:websiteTD);
	} else {
		PlayerTextDrawHide(playerid, PlayerText:websiteTD);
	}
}
forward colorScreen(playerid, show, color); 
public colorScreen(playerid, show, color) {
	new fadeID = GetPVarInt(playerid, "FadeScreen");
	PlayerTextDrawHide(playerid, PlayerText:fadeID); //Hide it first so it doesn't overlap
	if(show == 1) {
		PlayerTextDrawBackgroundColor(playerid, PlayerText:fadeID, color);
		PlayerTextDrawBoxColor(playerid, PlayerText:fadeID, color);
		PlayerTextDrawColor(playerid, PlayerText:fadeID, color);
		PlayerTextDrawShow(playerid, PlayerText:fadeID);
	} else {
		PlayerTextDrawHide(playerid, PlayerText:fadeID);
	}
}
ShowScriptMessage(playerid, parsedstring[], timeout = 5000) {
	hideHelpText(playerid);
	new string[128];
	format(string,sizeof(string),"%s",parsedstring);
	PlayerTextDrawSetString(playerid, PlayerText:GetPVarInt(playerid, "uiHelpTxt"), string);
	PlayerTextDrawShow(playerid, PlayerText:GetPVarInt(playerid, "uiHelpTxt"));
	SetTimerEx("hideHelpText", timeout, false, "d", playerid);
	textDrawInUse(playerid, 1);
	return 1;
}
forward hideHelpText(playerid);
public hideHelpText(playerid) {
	PlayerTextDrawHide(playerid, PlayerText:GetPVarInt(playerid, "uiHelpTxt"));
	return 1;
}
forward hideAllTextDrawsForPlayer(playerid);
public hideAllTextDrawsForPlayer(playerid) {
	for(new i=0; i < sizeof(TextDrawProperties); i++) {
		if(TextDrawProperties[i][TDCanBeHiddenByPlayer] == 1) {
			PlayerTextDrawHide(playerid, PlayerText:GetPVarInt(playerid, TextDrawProperties[i][TextDrawName]));
		}
	}
	textDrawInUse(playerid, 0);
}
forward destroyAllTextDrawsForPlayer(playerid);
public destroyAllTextDrawsForPlayer(playerid) {
	for(new i=0; i < sizeof(TextDrawProperties); i++) {
		PlayerTextDrawDestroy(playerid, PlayerText:GetPVarInt(playerid, TextDrawProperties[i][TextDrawName]));
		DeletePVar(playerid, TextDrawProperties[i][TextDrawName]);
	}
}
textDrawInUse(playerid, active) {
	if(active == 1) {
		SetPVarInt(playerid, "TextDrawInUse", active);
	} else {
		DeletePVar(playerid, "TextDrawInUse");
	}
	return 1;
}
isTextDrawInUse(playerid) {
	if(GetPVarType(playerid, "TextDrawInUse") != PLAYER_VARTYPE_NONE) {
		return 1;
	}
	return 0;
}
textdrawsOnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
	#pragma unused oldkeys
	if(isTextDrawInUse(playerid)) {
		if(newkeys & KEY_FIRE) {
			hideAllTextDrawsForPlayer(playerid);
		}
	}
	return 1;
}
/* Initialize TD's*/
textdrawsOnPlayerConnect(playerid) {
	for(new i=0; i < sizeof(TextDrawProperties); i++) {
		TextDrawID[i][playerid] = CreatePlayerTextDraw(playerid, TextDrawProperties[i][TDScreenX], TextDrawProperties[i][TDScreenY], "None");
		PlayerTextDrawLetterSize(playerid, TextDrawID[i][playerid], TextDrawProperties[i][TDLetterSizeX], TextDrawProperties[i][TDLetterSizeY]);
		PlayerTextDrawTextSize(playerid, TextDrawID[i][playerid], TextDrawProperties[i][PlayerTDTextSizeX], TextDrawProperties[i][PlayerTDTextSizeY]);
		PlayerTextDrawAlignment(playerid, TextDrawID[i][playerid], TextDrawProperties[i][TDAlignment]);
		PlayerTextDrawColor(playerid, TextDrawID[i][playerid], TextDrawProperties[i][TDColor]);
		PlayerTextDrawUseBox(playerid, TextDrawID[i][playerid], TextDrawProperties[i][TDUseBox]);
		PlayerTextDrawBoxColor(playerid, TextDrawID[i][playerid], TextDrawProperties[i][TDBoxColor]);
		PlayerTextDrawSetShadow(playerid, TextDrawID[i][playerid], TextDrawProperties[i][TDSetShadow]);
		PlayerTextDrawSetOutline(playerid, TextDrawID[i][playerid], TextDrawProperties[i][TDSetOutline]);
		PlayerTextDrawBackgroundColor(playerid, TextDrawID[i][playerid], TextDrawProperties[i][TDBgColor]);
		PlayerTextDrawFont(playerid, TextDrawID[i][playerid], TextDrawProperties[i][TDFont]);
		PlayerTextDrawSetProportional(playerid, TextDrawID[i][playerid], TextDrawProperties[i][TDSetProportional]);
		SetPVarInt(playerid, TextDrawProperties[i][TextDrawName], _:TextDrawID[i][playerid]);
	}
}
/* Remove all TD's on disconnect */
textdrawsOnTextDrawDisconnect(playerid, reason) {
	if(reason != 3) {
		destroyAllTextDrawsForPlayer(playerid);
	}
}
