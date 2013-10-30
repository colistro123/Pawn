/*
	PVARS Used By This Script
	MovingTag(int) - 1 to edit/move the tag, 2 to delete
	PVarAdminWallStatus(int) - 1 to Go to a tag and 2 to delete
	WallTagColorIndex(int) - Stores the color index for the tags
*/
/* Defines */
#define MAX_WALLTAGS 1000
#define MAX_WALLTAG_TITLE 24
#define WALLTAG_FONT_SIZE 24
#define WALLTAG_MATERIAL_SIZE 80
#define WALLTAG_STREAM_DIST 60.0
/* End of Defines */
/* Forwards */
forward OnLoadWallTags();
forward wallTagCreate(playerid);
forward wallTagEdit(playerid);
forward wallTagDelete(playerid);
forward showWallTagMenu(playerid);
forward onWallTagCreate(playerid, text[]);
forward displayAllTagsForAdmin(playerid);
forward setupWallTag(Float:X, Float:Y, Float:Z, Float:RotX, Float:RotY, Float:RotZ, int, vw, owner, text[], color, playerid);
forward onChooseTagColor(playerid, index);
forward chooseTagColor(playerid);
forward OnDeleteDeadWalltags();

/* End of Forwards */
enum {
	EWallTags_Menu = EWallTag_Base + 1,
	EWallTags_TagDescription,
	EWallTags_TagDelete,
	EWallTags_TagEdit,
	EWallTags_TagLocations,
	EWallTags_ChooseTagColor,
};

enum pWallTagInfo {
	pWallTagTitle[MAX_WALLTAG_TITLE],
	pWallTagSprayer[MAX_PLAYER_NAME+1],
	pWallTagSprayerSQLID,
	pWallTagSQLID,
	pFamOwnerSQLID,
	pWallTagTime,//time in seconds when it was sprayed
	pWallTagColor, //Text Color 
	Float:pWallTagX,
	Float:pWallTagY, 
	Float:pWallTagZ,
	Float:pWallTagRotX,
	Float:pWallTagRotY, 
	Float:pWallTagRotZ,
	pWallTagInt,
	pWallTagVW,
	pWallTagObjectID,
};
new WallTagInfo[MAX_WALLTAGS][pWallTagInfo];

enum {
	WallTagType_Create,
	WallTagType_Edit,
	WallTagType_Delete,
}

enum E_WallTagMenu {
	E_DialogOptionText[128],
	E_WallTagType,
	E_DoWallTagCallBack[128],
	EFamilyPermissions:E_ItemPerms,
}

new WallTagMenu[][E_WallTagMenu] = {
	{"Create A Tag", WallTagType_Create, "chooseTagColor", EFamilyPerms_CanTag},
	{"Edit A Tag", WallTagType_Edit, "wallTagEdit", EFamilyPerms_CanEditWallTags},
	{"Delete A Tag", WallTagType_Delete, "wallTagDelete", EFamilyPerms_CanDeleteWallTags}
};					 


/* General Functions */
wallTagsOnGameModeInit() {
	loadWallTags();
}
loadWallTags() {
	query[0] = 0;
	format(query, sizeof(query), "SELECT `w`.`id`,`w`.`owner`,`w`.`text`,`w`.`color`,`w`.`x`,`w`.`y`,`w`.`z`,`w`.`rotx`,`w`.`roty`,`w`.`rotz`,`w`.`int`,`w`.`vw`,`c`.`username`,`c`.`id` FROM `walltags` `w` LEFT JOIN `characters` `c` ON `c`.`id` = `w`.`sprayer`");
	mysql_function_query(g_mysql_handle, query, true, "OnLoadWallTags", "");
	
	mysql_function_query(g_mysql_handle,"select wt.id id from families f right join walltags wt on f.id = wt.owner where f.name is null", true, "OnDeleteDeadWalltags", "");
}
public OnDeleteDeadWalltags() {
	new id_string[32];
	new rows, fields;
	cache_get_data(rows, fields);
	for(new i=0;i<rows;i++) {
		cache_get_row(i, 0, id_string);
		format(query, sizeof(query), "DELETE FROM walltags where id = %d",strval(id_string));
		mysql_function_query(g_mysql_handle, query, true, "EmptyCallback", "");
	}
}
deleteFamilyWallTags(family) {
	for(new i=0;i<sizeof(WallTagInfo);i++) {
		if(WallTagInfo[i][pFamOwnerSQLID] == family) {
			DeleteTag(WallTagInfo[i][pWallTagSQLID]);
		}
	}
}
public OnLoadWallTags() {
	new rows, fields;
	new colorid;
	new id_string[64];
	cache_get_data(rows, fields);
	for(new i=0;i<rows;i++) {
		if(WallTagInfo[i][pWallTagSQLID] != 0) continue; //This won't be used for reloading walltags, but w/e
		cache_get_row(i, 0, id_string);
		WallTagInfo[i][pWallTagSQLID] = strval(id_string);
		
		cache_get_row(i, 1, id_string);
		WallTagInfo[i][pFamOwnerSQLID] = strval(id_string);
		
		cache_get_row(i, 2, WallTagInfo[i][pWallTagTitle]);
		
		cache_get_row(i, 3, id_string);
		WallTagInfo[i][pWallTagColor] = strval(id_string);
		
		cache_get_row(i, 4, id_string);
		WallTagInfo[i][pWallTagX] = floatstr(id_string);
		
		cache_get_row(i, 5, id_string);
		WallTagInfo[i][pWallTagY] = floatstr(id_string);
		
		cache_get_row(i, 6, id_string);
		WallTagInfo[i][pWallTagZ] = floatstr(id_string);
		
		cache_get_row(i, 7, id_string);
		WallTagInfo[i][pWallTagRotX] = floatstr(id_string);
		
		cache_get_row(i, 8, id_string);
		WallTagInfo[i][pWallTagRotY] = floatstr(id_string);
		
		cache_get_row(i, 9, id_string);
		WallTagInfo[i][pWallTagRotZ] = floatstr(id_string);
		
		cache_get_row(i, 10, id_string);
		WallTagInfo[i][pWallTagInt] = strval(id_string);
		
		cache_get_row(i, 11, id_string);
		WallTagInfo[i][pWallTagVW] = strval(id_string);
		
		cache_get_row(i, 12, WallTagInfo[i][pWallTagSprayer]);
		
		cache_get_row(i, 13, id_string);
		WallTagInfo[i][pWallTagSprayerSQLID] = strval(id_string);
		
		colorid = WallTagColour(WallTagInfo[i][pWallTagColor]);
		//printf("%x", colorid);
		WallTagInfo[i][pWallTagObjectID] = CreateDynamicObject(19353, WallTagInfo[i][pWallTagX],WallTagInfo[i][pWallTagY],WallTagInfo[i][pWallTagZ], WallTagInfo[i][pWallTagRotX], WallTagInfo[i][pWallTagRotY], WallTagInfo[i][pWallTagRotZ], WallTagInfo[i][pWallTagVW], WallTagInfo[i][pWallTagInt], -1, WALLTAG_STREAM_DIST);
		SetDynamicObjectMaterial(WallTagInfo[i][pWallTagObjectID], 0, 19353, "none", "none",colorid);
		
		SetDynamicObjectMaterialText(WallTagInfo[i][pWallTagObjectID], 0, WallTagInfo[i][pWallTagTitle], WALLTAG_MATERIAL_SIZE, "Arial", WALLTAG_FONT_SIZE, 1, colorid, 0x00000000, 1);
		#if debug
		printf("Loaded Wall Tag: SQLID: %d, ObjectID: %d, Color(INT) %d, %f, %f, %f, %f, %f, %f, %d, %d, %d, %s, color: %x",WallTagInfo[i][pWallTagSQLID], WallTagInfo[i][pWallTagObjectID], WallTagInfo[i][pWallTagColor], WallTagInfo[i][pWallTagX], WallTagInfo[i][pWallTagY], WallTagInfo[i][pWallTagZ], 
		WallTagInfo[i][pWallTagRotX], WallTagInfo[i][pWallTagRotY], WallTagInfo[i][pWallTagRotZ], WallTagInfo[i][pWallTagInt], WallTagInfo[i][pWallTagVW], WallTagInfo[i][pFamOwnerSQLID], WallTagInfo[i][pWallTagTitle], colorid);
		#endif
	}
	return 1;
}
WallTagColour(index) {
	return RGBA_To_ARBG(FamilyColours[index]);
}
public wallTagEdit(playerid) {
	SetPVarInt(playerid, "MovingTag", 1);
	SelectObject(playerid);
	return 1;
}
public wallTagDelete(playerid) {
	SetPVarInt(playerid, "MovingTag", 2);
	SelectObject(playerid);
	return 1;
}
public chooseTagColor(playerid) {
	dialogstr[0] = 0;
	new temptxt[256];
	for(new i=1;i<sizeof(FamilyColours);i++) {
		format(temptxt, sizeof(temptxt), "{%s}Sample %d\n",getColourString(FamilyColours[i]),i);
		strcat(dialogstr,temptxt,sizeof(dialogstr));
	}
	ShowPlayerDialog(playerid, EWallTags_ChooseTagColor, DIALOG_STYLE_LIST, "{00BFFF}Choose a Tag Colour",dialogstr, "Ok", "Cancel");
}
public onChooseTagColor(playerid, index) {
	SendClientMessage(playerid, COLOR_LIGHTGREEN, "[INFO]: You've chosen a tag color!");
	SetPVarInt(playerid, "WallTagColorIndex", index+1);
	wallTagCreate(playerid);
	return 1;
}
public wallTagCreate(playerid) {
	ShowPlayerDialog(playerid, EWallTags_TagDescription, DIALOG_STYLE_INPUT, "Enter A Title:","{FFFFFF}Tag Message\n{FF0000}Note:{FFFFFF} Admins are able to see what you do tag, so make sure it's tagged properly.","Spray It", "Cancel");
	return 1;
}
public onWallTagCreate(playerid, text[]) {
	if(strlen(text) < 1 || strlen(text) >= MAX_WALLTAG_TITLE) {
		SendClientMessage(playerid, X11_TOMATO_2, "The text you're trying to enter is either too short or too long!");
		wallTagCreate(playerid);
		return 1;
	}
	new sqlfamilyid = GetPVarInt(playerid,"Family");
	new Float:X,Float:Y,Float:Z,Float:RotZ,VW,Interior;
	GetPlayerPos(playerid, X, Y, Z);
	GetPlayerFacingAngle(playerid, RotZ);
	Interior = GetPlayerInterior(playerid);
	VW = GetPlayerVirtualWorld(playerid);
	new color = GetPVarInt(playerid, "WallTagColorIndex");
	CreateTag(sqlfamilyid, X, Y, Z, 0,0,RotZ+90.0, Interior, VW, text, color, playerid);
	SetTimerEx("UpdatePlayerObjectsAtPos",1000, false, "d", playerid);
	movePlayerBack(playerid, 2.0);
	wallTagEdit(playerid);
	SendClientMessage(playerid, COLOR_LIGHTGREEN, "[INFO]: Select the object to edit it.");
	return 1;
}
public showWallTagMenu(playerid) {
	dialogstr[0] = 0;
	tempstr[0] = 0;
	for(new i=0;i<sizeof(WallTagMenu);i++) {
		format(tempstr,sizeof(tempstr),"%s\n",WallTagMenu[i][E_DialogOptionText]);
		strcat(dialogstr,tempstr,sizeof(dialogstr));
	}
	ShowPlayerDialog(playerid, EWallTags_Menu, DIALOG_STYLE_LIST, "Wall Tag Menu",dialogstr,"Ok", "Cancel");
}
public displayAllTagsForAdmin(playerid) {
	dialogstr[0] = 0;
	tempstr[0] = 0;
	for(new i=0;i<sizeof(WallTagInfo);i++) {
		if(WallTagInfo[i][pWallTagObjectID] != 0) {
			format(tempstr,sizeof(tempstr),"%s\n",WallTagInfo[i][pWallTagTitle]);
			strcat(dialogstr,tempstr,sizeof(dialogstr));
		}
	}
	ShowPlayerDialog(playerid, EWallTags_TagLocations, DIALOG_STYLE_LIST, "Wall Tags",dialogstr,"Ok", "Cancel");
}
getWallTagSQLIDByDialogIndex(index) {
	new sqlid;
	for(new i=0;i<sizeof(WallTagInfo);i++) {
		if(WallTagInfo[i][pWallTagSQLID] == 0) {
			#if debug
			printf("index++: %d", index);
			#endif
			index++;
			continue;
		}
		if(WallTagInfo[i][pWallTagSQLID] != 0) {
			if(WallTagInfo[index][pWallTagSQLID] == WallTagInfo[i][pWallTagSQLID]) {
				sqlid = WallTagInfo[i][pWallTagSQLID];
				#if debug
				printf("WallTag SQLID: %d Index: %d",sqlid, index);
				#endif
				return sqlid;
			}
		}
	}
	return -1;
}
getWallTagIDByDialogIndex(index) {
	new objid;
	for(new i=0;i<sizeof(WallTagInfo);i++) {
		if(WallTagInfo[i][pWallTagSQLID] == 0) {
			#if debug
			printf("index++: %d", index);
			#endif
			index++;
			continue;
		}
		if(WallTagInfo[i][pWallTagSQLID] != 0) {
			if(WallTagInfo[index][pWallTagSQLID] == WallTagInfo[i][pWallTagSQLID]) {
				objid = findWallTagObjIDBySQLID(WallTagInfo[i][pWallTagSQLID]);
				#if debug
				printf("WallTag objid: %d Index: %d",objid, index);
				#endif
				return objid;
			}
		}
	}
	return -1;
}
WallTagOnDialogResp(playerid, dialogid, response, listitem, inputtext[]) {
	wallTagHandleDialog(playerid, dialogid, response, listitem, inputtext);
	return 1;
}
wallTagHandleDialog(playerid, dialogid, response, listitem, inputtext[]) {
	#pragma unused inputtext
	switch(dialogid) {
		case EWallTags_Menu: {
			if(!response) {
				SendClientMessage(playerid, X11_LIGHTBLUE, "* You closed the tag menu.");
				return 1;
			}
			preListItemWallTagCheck(playerid, listitem);
		}
		case EWallTags_TagDescription: {
			if(!response) {
				showWallTagMenu(playerid);
				return 1;
			}
			onWallTagCreate(playerid, inputtext);
		}
		case EWallTags_TagLocations: {
			if(!response) {
				SendClientMessage(playerid, X11_LIGHTBLUE, "* You closed the menu.");
				return 1;
			}
			onWallTagDeleteOrGoto(playerid, listitem);
		}
		case EWallTags_ChooseTagColor: {
			if(!response) {
				SendClientMessage(playerid, X11_LIGHTBLUE, "* You closed the menu.");
				return 1;
			}
			onChooseTagColor(playerid, listitem);
		}
	}
	return 1;
}
preListItemWallTagCheck(playerid, index) {
	new rank = GetPVarInt(playerid, "Rank")-1;
	new family = FindFamilyBySQLID(GetPVarInt(playerid, "Family"));
	if(family != -1) {
		new EFamilyPermissions:rankperms = EFamilyPermissions:Families[family][EFamilyRankPerms][rank];
		if(~rankperms & WallTagMenu[index][E_ItemPerms]) {
			showWallTagMenu(playerid);
			SendClientMessage(playerid, X11_TOMATO_2, "You do not have permissions for this");
			return 1;
		}
	}
	CallLocalFunction(WallTagMenu[index][E_DoWallTagCallBack],"d", playerid);
	return 1;
}
onWallTagDeleteOrGoto(playerid, index) {
	new getTagAdminStatus = GetPVarInt(playerid, "PVarAdminWallStatus");
	DeletePVar(playerid, "PVarAdminWallStatus");
	new msg[128];
	new fid = FindFamilyBySQLID(WallTagInfo[index][pFamOwnerSQLID]);
	if(getTagAdminStatus == 1) { //Just TP
		new walltagid = getWallTagIDByDialogIndex(index);
		format(msg, sizeof(msg), "You have been teleported to this tag, the family owner of this tag is: %s", GetFamilyName(fid));
		SetPlayerPos(playerid, WallTagInfo[walltagid][pWallTagX], WallTagInfo[walltagid][pWallTagY], WallTagInfo[walltagid][pWallTagZ]+1.5);
		SendClientMessage(playerid, X11_WHITE, msg);
	} else if(getTagAdminStatus == 2) { //Delete
		new deletesqlid = getWallTagSQLIDByDialogIndex(index);
		DeleteTag(deletesqlid);
		format(msg, sizeof(msg), "AdmWarn: %s has deleted a tag owned by %s.", GetPlayerNameEx(playerid, ENameType_AccountName), GetFamilyName(fid));
		ABroadcast(X11_YELLOW, msg, EAdminFlags_AdminManage);
	}
	return 1;
}
public setupWallTag(Float:X, Float:Y, Float:Z, Float:RotX, Float:RotY, Float:RotZ, int, vw, owner, text[], color, playerid) {
	new index;
	if(strlen(text) < 1) {
		return 1;
	}
	index = findFreeWallTagSlot();
	if(index == -1) {
		#if debug
		printf("Max reached, couldn't find a new object slot");
		#endif
		return 1;
	}
	new sqlid = mysql_insert_id();
	WallTagInfo[index][pWallTagSQLID] = sqlid;
	WallTagInfo[index][pWallTagX] = X;
	WallTagInfo[index][pWallTagY] = Y;
	WallTagInfo[index][pWallTagZ] = Z;
	WallTagInfo[index][pWallTagRotX] = RotX;
	WallTagInfo[index][pWallTagRotY] = RotY;
	WallTagInfo[index][pWallTagRotZ] = RotZ;
	WallTagInfo[index][pWallTagVW] = vw;
	WallTagInfo[index][pWallTagInt] = int;
	WallTagInfo[index][pFamOwnerSQLID] = owner;
	WallTagInfo[index][pWallTagSprayerSQLID] = GetPVarInt(playerid, "CharID");
	format(WallTagInfo[index][pWallTagSprayer], MAX_PLAYER_NAME, "%s", GetPlayerNameEx(playerid, ENameType_CharName));
	format(WallTagInfo[index][pWallTagTitle], MAX_WALLTAG_TITLE, "%s", text);
	WallTagInfo[index][pWallTagObjectID] = CreateDynamicObject(19353, X,Y,Z, RotX, RotY, RotZ, vw, int, -1, WALLTAG_STREAM_DIST);
	/*
	SetDynamicObjectMaterial(WallTagInfo[index][pWallTagObjectID], 0, 19353, "none", "none", 0xFFFFFFFF);
	SetDynamicObjectMaterialText(WallTagInfo[index][pWallTagObjectID], 0, text, WALLTAG_MATERIAL_SIZE, "Verdana", WALLTAG_FONT_SIZE, 1, 0xFFFFFFFF, 0, 1);
	*/
	SetDynamicObjectMaterial(WallTagInfo[index][pWallTagObjectID], 0, 19353, "none", "none", WallTagColour(color));
	SetDynamicObjectMaterialText(WallTagInfo[index][pWallTagObjectID], 0, text, WALLTAG_MATERIAL_SIZE, "Arial", WALLTAG_FONT_SIZE, 1, WallTagColour(color), 0x00000000, 1);
	#if debug
	printf("Added Wall Tag (setupWallTag): SQLID: %d, ObjectID: %d, %f, %f, %f, %f, %f, %f, %d, %d, %d, %s",WallTagInfo[index][pWallTagSQLID], WallTagInfo[index][pWallTagObjectID], WallTagInfo[index][pWallTagX], WallTagInfo[index][pWallTagY], WallTagInfo[index][pWallTagZ], 
	WallTagInfo[index][pWallTagRotX], WallTagInfo[index][pWallTagRotY], WallTagInfo[index][pWallTagRotZ], WallTagInfo[index][pWallTagInt], WallTagInfo[index][pWallTagVW], WallTagInfo[index][pFamOwnerSQLID], WallTagInfo[index][pWallTagTitle]);
	#endif
	return 1;
}
walltagsOnPlayerEditObject(playerid, objectid, response, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz) {
	query[0] = 0;//[128];
	if(response != EDIT_RESPONSE_FINAL) {
		return 0;
	}
	new sqlid = findWallTagSQLIDByObjID(objectid);
	new index = findWallTagByObjID(objectid);
	if(index != -1) {
		WallTagInfo[index][pWallTagX] = x;
		WallTagInfo[index][pWallTagY] = y;
		WallTagInfo[index][pWallTagZ] = z;
		WallTagInfo[index][pWallTagRotX] = rx;
		WallTagInfo[index][pWallTagRotY] = ry;
		WallTagInfo[index][pWallTagRotZ] = rz;
		SendClientMessage(playerid, X11_TOMATO_2, "Tag position saved!");
		format(query, sizeof(query), "UPDATE `walltags` SET `X` = %f, `Y` = %f, `Z` = %f, `rotx` = %f, `roty` = %f, `rotz` = %f WHERE `id` = %d",x,y,z,rx,ry,rz,sqlid);
		SetDynamicObjectPos(objectid, x, y, z);
		SetDynamicObjectRot(objectid, rx, ry, rz);
		mysql_function_query(g_mysql_handle, query, true, "EmptyCallback","");
	}
	return 1;
}
DisplayTagInfo(playerid, index) {
	new msg[128];
	new family =  FindFamilyBySQLID(WallTagInfo[index][pFamOwnerSQLID]);
	format(msg, sizeof(msg), "* Tag Object ID: %d SQLID: %d",WallTagInfo[index][pWallTagObjectID],WallTagInfo[index][pWallTagSQLID]);
	SendClientMessage(playerid, X11_YELLOW, msg);
	format(msg, sizeof(msg), "* Tag Family: %s",GetFamilyName(family));
	SendClientMessage(playerid, X11_YELLOW, msg);
	format(msg, sizeof(msg), "* Tag Sprayer: %s[%d]",WallTagInfo[index][pWallTagSprayer],WallTagInfo[index][pWallTagSprayerSQLID]);
	SendClientMessage(playerid, X11_YELLOW, msg);
	DeletePVar(playerid, "WallTagInfo");
	CancelEdit(playerid);
}
YCMD:walltaginfo(playerid, params[], help) {
	if(help) {
		SendClientMessage(playerid, X11_WHITE, "Displays info on a tag");
		return 1;
	}
	SelectObject(playerid);
	SetPVarInt(playerid, "WallTagInfo", 1);
	SendClientMessage(playerid, X11_LIGHTBLUE, "Select the tag you wish to see information on");
	return 1;
}
walltagsOnPlayerSelectObject(playerid, objectid, modelid, Float:x, Float:y, Float:z) {
	#pragma unused x
	#pragma unused y
	#pragma unused z
	#pragma unused modelid
	new family = -1;
	new movingtag = GetPVarInt(playerid, "MovingTag");
	DeletePVar(playerid, "MovingTag");
	new index = findWallTagByObjID(objectid);
	new sqlid = findWallTagSQLIDByObjID(objectid);
	if(GetPVarInt(playerid, "WallTagInfo") == 1) {
		if(index != -1) {
			DisplayTagInfo(playerid, index);
		}
	}
	if(index != -1) {
		new rank = GetPVarInt(playerid, "Rank")-1;
		family = FindFamilyBySQLID(GetPVarInt(playerid, "Family"));
		if(family != -1) {
			new EFamilyPermissions:rankperms = EFamilyPermissions:Families[family][EFamilyRankPerms][rank];
			if(~rankperms & EFamilyPerms_CanDeleteWallTags) {
				SendClientMessage(playerid, X11_TOMATO_2, "You do not have permissions for this");
				return 1;
			}
		}
		if(movingtag == 1) {
			EditDynamicObject(playerid, objectid);
		} else if(movingtag == 2) {
			DeleteTag(sqlid);
			SendClientMessage(playerid, X11_YELLOW, "Tag Deleted!");
			CancelEdit(playerid);
		}
	}
	return 0;	
}
findWallTagByObjID(objectid) {
	for(new i = 0; i < sizeof(WallTagInfo); i++) {
		if(WallTagInfo[i][pWallTagObjectID] == objectid) {
			#if debug
			printf("findWallTagByObjID(%d)",i);
			#endif
			return i;
		}
	}
	return -1;
}
findWallTagObjIDBySQLID(sqlid) {
	for(new i=0;i<sizeof(WallTagInfo);i++) {
		if(WallTagInfo[i][pWallTagSQLID] == sqlid) {
			#if debug
			printf("findWallTagObjIDBySQLID(%d)",i);
			#endif
			return i;
		}
	}
	return -1;
}
findWallTagSQLIDByObjID(objid) {
	for(new i=0;i<sizeof(WallTagInfo);i++) {
		if(WallTagInfo[i][pWallTagObjectID] == objid) {
			#if debug
			printf("findWallTagSQLIDByObjID(%d)",WallTagInfo[i][pWallTagSQLID]);
			#endif
			return WallTagInfo[i][pWallTagSQLID];
		}
	}
	return -1;
}
stock CreateTag(owner, Float:X, Float:Y, Float:Z, Float:RotX,Float:RotY,Float:RotZ, int, vw, text[], color, playerid) {
	new index = findFreeWallTagSlot();
	if(index == -1) {
		//Max reached! Don't add
		#if debug
		printf("Max reached, couldn't find a new object slot");
		#endif
		return 1;
	}
	query[0] = 0;
	mysql_real_escape_string(text,text);
	new sqlplayerid = GetPVarInt(playerid, "CharID");
	format(query, sizeof(query), "INSERT INTO `walltags` (`owner`,`text`,`color`,`x`,`y`,`z`,`rotx`,`roty`,`rotz`,`int`,`vw`,`sprayer`) VALUES (%d,'%s',%d,%f,%f,%f,%f,%f,%f,%d,%d,%d)",owner, text, color, X, Y, Z, RotX, RotY, RotZ, int, vw, sqlplayerid);
	mysql_function_query(g_mysql_handle, query, true, "setupWallTag", "ffffffdddsdd", X,Y,Z,RotX,RotY,RotZ, int, vw, owner, text, color, playerid);
	return 1;
}
stock DeleteTag(sqlid) {
	query[0] = 0;//[256];
	if(sqlid == -1) {
		#if debug
		printf("Error, cannot delete this.");
		#endif
		return 1;
	}
	format(query, sizeof(query), "DELETE FROM `walltags` WHERE `id` = %d",sqlid);
	mysql_function_query(g_mysql_handle, query, true, "EmptyCallback", "");
	DestroyTag(sqlid);
	return 1;
}
DestroyTag(sqlid) { //By SQLID
	for(new i=0;i<sizeof(WallTagInfo);i++) {
		if(WallTagInfo[i][pWallTagSQLID] == sqlid) {
			DestroyDynamicObject(WallTagInfo[i][pWallTagObjectID]);
			WallTagInfo[i][pWallTagObjectID] = 0;
			WallTagInfo[i][pWallTagSQLID] = 0;
		}
	}
	return 1;
}
findFreeWallTagSlot() {
	for(new i=0;i<sizeof(WallTagInfo);i++) {
		if(WallTagInfo[i][pWallTagSQLID] == 0) {
			return i;
		}
	}
	return -1;
}
deleteAllTags() {
	for(new i=0;i<sizeof(WallTagInfo);i++) {
		if(WallTagInfo[i][pWallTagSQLID] != 0) {
			DeleteTag(WallTagInfo[i][pWallTagSQLID]);
		}
	}
	return -1;
}
/* Commands */
YCMD:tagwall(playerid, params[], help) {
	if(help) {
		SendClientMessage(playerid, X11_WHITE, "Used for tagging on a wall");
		return 1;
	}
	if(GetPVarInt(playerid, "Family") == 0) {
		SendClientMessage(playerid, X11_TOMATO_2, "You must be in a family");
		return 1;
	}
	if(!hasSprayCanOnHand(playerid)) {
		SendClientMessage(playerid, X11_TOMATO_2, "You at least need a spray can to tag something on a wall.");
		return 1;
	}
	new rank = GetPVarInt(playerid, "Rank")-1;
	new family = FindFamilyBySQLID(GetPVarInt(playerid, "Family"));
	new EFamilyPermissions:rankperms = EFamilyPermissions:Families[family][EFamilyRankPerms][rank];
	if(~rankperms & EFamilyPerms_CanTag) {
		SendClientMessage(playerid, X11_TOMATO_2, "You do not have permissions for this");
		return 1;
	}
	showWallTagMenu(playerid);
	return 1;
}
YCMD:gototag(playerid, params[], help) {
	if(help) {
		SendClientMessage(playerid, X11_WHITE, "Used to go to a tag");
		return 1;
	}
	SetPVarInt(playerid, "PVarAdminWallStatus", 1);
	displayAllTagsForAdmin(playerid);
	return 1;
}
YCMD:deletetag(playerid, params[], help) {
	if(help) {
		SendClientMessage(playerid, X11_WHITE, "Used to delete a tag");
		return 1;
	}
	SetPVarInt(playerid, "PVarAdminWallStatus", 2);
	displayAllTagsForAdmin(playerid);
	return 1;
}
YCMD:deletealltags(playerid, params[], help) {
	if(help) {
		SendClientMessage(playerid, X11_WHITE, "Used to delete all tags");
		return 1;
	}
	deleteAllTags();
	new msg[128];
	format(msg, sizeof(msg), "AdmWarn: %s has deleted all tags.", GetPlayerNameEx(playerid, ENameType_AccountName));
	ABroadcast(X11_YELLOW, msg, EAdminFlags_AdminManage);
	return 1;
}
