/*
	PVars used in this script:
	BagID(int) - The BackPack SQLID
*/

#define BACKPACK_MDL_ID 371
#define MAX_BACKPACK_DESC 64
#define MAX_BACKPACKS 1000 //Max amount of backpacks around the map (1000) default
#define MAX_BACKPACKS_TIME 43200 //12 hours
#define MAX_LAPD_SPOTTIME 7200 //2 hours (7200 seconds)
#define MAX_LAPD_BP_SPOTS 14
#define BP_LAPD_INT 6
#define BP_LAPD_VW 2

new BackpackItems[][ESafeSingleItems] = {
	{"None","None",ESafeItemType:-1},
	{"Cash","Money",ESafeItemType_Money},
	{"Pot","Pot",ESafeItemType_Pot},
	{"Coke","Coke",ESafeItemType_Coke},
	{"Gun","Unused",ESafeItemType_Gun},
	{"Meth","Meth",ESafeItemType_Meth},
	{"Materials A","MatsA",ESafeItemType_MatsA},
	{"Materials B","MatsB",ESafeItemType_MatsB},
	{"Materials C","MatsC",ESafeItemType_MatsC},
	{"Special Item","SpecialItem",ESafeItemType_SpecialItem}
};

enum {
	EBackpackDialog_GiveTake = EBackpacks_Base + 1,
	EBackpackDialog_ModifySlot,
	EBackpackDialog_Take,
	EBackpackDialog_StoreChoose,
	EBackpackDialog_TakeAmount,
	EBackpackDialog_StoreAmount
}
enum EBackpackInfo  {
	EBackpackSQLID,
	EBackpackLastOwner,
	Float:EBackpackPickupX,
	Float:EBackpackPickupY,
	Float:EBackpackPickupZ,
	Float:EBackpackPickupRotX,
	Float:EBackpackPickupRotY,
	Float:EBackpackPickupRotZ,
	EBackpackPickupInt,
	EBackpackPickupVW,
	EBackpackDropTime,
	EBackpackName[MAX_BACKPACK_DESC],
	Text3D:EBackpackText,
	EBackPackObjID,	
};
new BackpackInfo[MAX_BACKPACKS][EBackpackInfo];

enum ELAPDBackpackSpots {
	Float:ELAPDSpotBPX,
	Float:ELAPDSpotBPY,
	Float:ELAPDSpotBPZ,
	Float:ELAPDSpotBPRotX,
	Float:ELAPDSpotBPRotY,
	Float:ELAPDSpotBPRotZ,
	ELAPDSpotBPVW,
	ELAPDSpotBPInt,
	ELAPDSpotBPTime,
	ESavedIndex,
};
new LAPDBackPackSpots[MAX_LAPD_BP_SPOTS][ELAPDBackpackSpots] = {
	{257.7799, 84.9246, 1002.4453, 0.0, 0.0, 90.0, 2, 6, 0, -1},
	{256.9650, 84.9238, 1002.4453, 0.0, 0.0, 90.0, 2, 6, 0, -1},
	{256.0956, 84.9230, 1002.4453, 0.0, 0.0, 90.0, 2, 6, 0, -1},
	{255.0645, 84.9219, 1002.4453, 0.0, 0.0, 90.0, 2, 6, 0, -1},
	{254.2534, 84.9212, 1002.4453, 0.0, 0.0, 90.0, 2, 6, 0, -1},
	{253.5501, 84.9205, 1002.4453, 0.0, 0.0, 90.0, 2, 6, 0, -1},
	{252.7786, 84.9197, 1002.4453, 0.0, 0.0, 90.0, 2, 6, 0, -1},
	{252.7531, 83.7334, 1002.4453, 0.0, 0.0, 90.0, 2, 6, 0, -1},
	{253.7243, 83.7343, 1002.4453, 0.0, 0.0, 90.0, 2, 6, 0, -1},
	{254.6096, 83.7352, 1002.4453, 0.0, 0.0, 90.0, 2, 6, 0, -1},
	{255.4244, 83.7359, 1002.4453, 0.0, 0.0, 90.0, 2, 6, 0, -1},
	{256.2193, 83.7367, 1002.4453, 0.0, 0.0, 90.0, 2, 6, 0, -1},
	{257.0948, 83.7376, 1002.4453, 0.0, 0.0, 90.0, 2, 6, 0, -1},
	{257.8980, 83.7383, 1002.4453, 0.0, 0.0, 90.0, 2, 6, 0, -1}
};

#define NUM_BACKPACK_SLOTS 7 //update in DB too
/* Needs to be on top, else we get a reparse warning.. */
ESafeItemType:bFindItemType(index) {
	if(index < 0 || index > sizeof(BackpackItems)) return ESafeItemType:-1;
	return BackpackItems[index][ESafeSType];
}
BGetItemName(ESafeItemType:item, dst[], dstlen) {
	for(new i=0;i<sizeof(BackpackItems);i++) {
		if(BackpackItems[i][ESafeSType] == item) {
			format(dst, dstlen, "%s",BackpackItems[i][ESafeSItemName]);
			return 1;
		}
	}
	return 0;
}

backpacksOnGameModeInit() {
	loadDroppedBackPacks();
}
loadDroppedBackPacks() {
	query[0] = 0;
	format(query, sizeof(query), "SELECT `id`, `lastowner`, `x`, `y`, `z`, `rotx`, `roty`, `rotz`, `int`, `vw`, Unix_Timestamp(`droptime`) FROM `backpacks` WHERE `dropped` = 1 AND `droptime` >= SYSDATE() - INTERVAL 1 DAY");
	mysql_function_query(g_mysql_handle, query, true, "OnLoadDroppedBackPacks", "");
}
forward OnLoadDroppedBackPacks();
public OnLoadDroppedBackPacks() {
	new rows, fields;
	new id_string[64], backpackdesc[64];
	cache_get_data(rows, fields);
	for(new i=0;i<rows;i++) {
	
		cache_get_row(i, 0, id_string);
		BackpackInfo[i][EBackpackSQLID] = strval(id_string);
		
		cache_get_row(i, 1, id_string); //lastowner
		BackpackInfo[i][EBackpackLastOwner] = strval(id_string);
		
		cache_get_row(i, 2, id_string);
		BackpackInfo[i][EBackpackPickupX] = floatstr(id_string);
		
		cache_get_row(i, 3, id_string);
		BackpackInfo[i][EBackpackPickupY] = floatstr(id_string);
		
		cache_get_row(i, 4, id_string);
		BackpackInfo[i][EBackpackPickupZ] = floatstr(id_string);
		
		cache_get_row(i, 5, id_string);
		BackpackInfo[i][EBackpackPickupRotX] = floatstr(id_string);
		
		cache_get_row(i, 6, id_string);
		BackpackInfo[i][EBackpackPickupRotY] = floatstr(id_string);
		
		cache_get_row(i, 7, id_string);
		BackpackInfo[i][EBackpackPickupRotZ] = floatstr(id_string);
		
		cache_get_row(i, 8, id_string);
		BackpackInfo[i][EBackpackPickupInt] = strval(id_string);
		
		cache_get_row(i, 9, id_string);
		BackpackInfo[i][EBackpackPickupVW] = strval(id_string);
		
		cache_get_row(i, 10, id_string);
		BackpackInfo[i][EBackpackDropTime] = strval(id_string);
		format(backpackdesc, sizeof(backpackdesc), "{%s}Item:[{%s}Backpack{%s}]",getColourString(X11_WHITE),getColourString(COLOR_BRIGHTRED),getColourString(X11_WHITE));
		BackpackInfo[i][EBackpackText] = CreateDynamic3DTextLabel(backpackdesc, 0x2BFF00AA, BackpackInfo[i][EBackpackPickupX], BackpackInfo[i][EBackpackPickupY], BackpackInfo[i][EBackpackPickupZ], 5.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, BackpackInfo[i][EBackpackPickupVW], BackpackInfo[i][EBackpackPickupInt]);
		BackpackInfo[i][EBackPackObjID] = CreateDynamicObject(BACKPACK_MDL_ID, BackpackInfo[i][EBackpackPickupX], BackpackInfo[i][EBackpackPickupY], BackpackInfo[i][EBackpackPickupZ], BackpackInfo[i][EBackpackPickupRotX], BackpackInfo[i][EBackpackPickupRotY], BackpackInfo[i][EBackpackPickupRotZ], BackpackInfo[i][EBackpackPickupVW], BackpackInfo[i][EBackpackPickupInt]);
		tryRemoveLAPDBackPack(i); //Re-writing the query is just pointless...
	}
	return 1;
}
tryRemoveLAPDBackPack(index) {
	if(BackpackInfo[index][EBackpackPickupInt] == BP_LAPD_INT && BackpackInfo[index][EBackpackPickupVW] == BP_LAPD_VW) {
		destroyBackPack(index);
		#if debug
		printf("Removed backpack from LAPD with id %d", index);
		#endif
	}
}
setPlayerHasBackPack(playerid, enabled) {
	new flags = GetPVarInt(playerid, "UserFlags");
	if(enabled) {
		flags |= EUFHasBackPack;
	} else {
		flags &= ~EUFHasBackPack;
	}
	SetPVarInt(playerid, "UserFlags", flags);
	return 1;
}
playerHasBackPack(playerid) {
	new flags = GetPVarInt(playerid, "UserFlags");
	if(~flags & EUFHasBackPack) { 
		return 0;
	}
	return 1;
}
findFreeLAPDBackPackSpot() {
	for(new i=0;i<sizeof(LAPDBackPackSpots);i++) {
		if(LAPDBackPackSpots[i][ELAPDSpotBPTime] == 0) {
			return i;
		}
	}
	return -1;
}
getOldBPLAPDSpot() {
	new time = gettime();
	for(new i=0;i<sizeof(LAPDBackPackSpots);i++) {
		if((time-LAPDBackPackSpots[i][ELAPDSpotBPTime]) >= MAX_LAPD_SPOTTIME) {
			if(LAPDBackPackSpots[i][ELAPDSpotBPTime] != 0) {
				return i;
			}
		}
	}
	return -1;
}
removeOldBPLAPDSpots() {
	new index;
	for(new i=0;i<sizeof(LAPDBackPackSpots);i++) {
		index = getOldBPLAPDSpot();
		if(index != -1) {
			destroyBackPack(LAPDBackPackSpots[index][ESavedIndex]);
			setLAPDBackPackSlot(index, 0);
			#if debug
			printf("Backpack with id %d destroyed...", index);
			#endif
		}
	}
}
setLAPDBackPackSlot(index, toggle, SQLIndex = -1) { //Function to toggle a spot 
	if(toggle) {
		LAPDBackPackSpots[index][ELAPDSpotBPTime] = gettime();	
		LAPDBackPackSpots[index][ESavedIndex] = SQLIndex;
	} else {
		LAPDBackPackSpots[index][ELAPDSpotBPTime] = 0;
		LAPDBackPackSpots[index][ESavedIndex] = -1;
	}
}
backpacksOnPlayerDeath(playerid) {
	trySendBackPackToLAPD(playerid);
}
trySendBackPackToLAPD(playerid) {
	if(playerHasBackPack(playerid)) {
		if(hasIllegalItemsInBackpack(playerid)) {
			new index = findFreeLAPDBackPackSpot();
			if(index != -1) {
				new Float:DropPosZ = LAPDBackPackSpots[index][ELAPDSpotBPZ] -= 0.8; //Backpack adjust
				new SQLIndex = OnBackPackDrop(playerid, LAPDBackPackSpots[index][ELAPDSpotBPX], LAPDBackPackSpots[index][ELAPDSpotBPY], DropPosZ, 0.0, 0.0, LAPDBackPackSpots[index][ELAPDSpotBPRotZ], LAPDBackPackSpots[index][ELAPDSpotBPInt], LAPDBackPackSpots[index][ELAPDSpotBPVW]);
				setLAPDBackPackSlot(index, 1, SQLIndex);
				SendClientMessage(playerid, X11_WHITE, "Since your backpack had illegal items in it, it's being sent to LAPD.");
			} else {
				stripIllBackpackItems(playerid);
				removeOldBPLAPDSpots();
				SendClientMessage(playerid, X11_WHITE, "Your backpack can't be sent to LAPD right now but all your illegal items have been taken away.");
			}
		}
	}
}
getIllegalItemNeedle() { //Preset needle, just to not repeat this all over this module
	return (1 << _:ESafeItemType_Pot) | (1 << _:ESafeItemType_Coke) | (1 << _:ESafeItemType_Gun) | (1 << _:ESafeItemType_Meth) | (1 << _:ESafeItemType_MatsA) | (1 << _:ESafeItemType_MatsB) | (1 << _:ESafeItemType_MatsC);
}
stripIllBackpackItems(playerid) { //Removes all the illegal items from a backpack
	new pvarname[64];
	new ELicenseFlags:lflags = ELicenseFlags:GetPVarInt(playerid, "LicenseFlags");
	for(new i=0;i<NUM_BACKPACK_SLOTS;i++) {
		new index;
		format(pvarname, sizeof(pvarname), "BItem%dType",i);
		index = GetPVarInt(playerid, pvarname);
		new ESafeItemType:type = bFindItemType(index);
		if ((1 << _:type) & getIllegalItemNeedle()) {
			if(_:type == _:ESafeItemType_Gun) {
				if(lflags & ELicense_Gun) { //If they have a gun license it's not illegal for them to own a weapon so for this specific check just continue looping...
					continue;
				}
			}
			format(pvarname, sizeof(pvarname), "BItem%dType",i);
			SetPVarInt(playerid, pvarname, 0);
			format(pvarname, sizeof(pvarname), "BItem%d",i);
			SetPVarInt(playerid, pvarname, 0);
		}
	}
	savePlayerBackpack(playerid);
}
hasIllegalItemsInBackpack(playerid) {
	new pvarname[64];
	new ELicenseFlags:lflags = ELicenseFlags:GetPVarInt(playerid, "LicenseFlags");
	for(new i=0;i<NUM_BACKPACK_SLOTS;i++) {
		new index;
		format(pvarname, sizeof(pvarname), "BItem%dType",i);
		index = GetPVarInt(playerid, pvarname);
		new ESafeItemType:type = bFindItemType(index);
		if ((1 << _:type) & getIllegalItemNeedle()) {
			if(_:type == _:ESafeItemType_Gun) {
				if(lflags & ELicense_Gun) { //If they have a gun license it's not illegal for them to own a weapon so for this specific check, return 0.
					return 0;
				}
			}
			return 1;
		}
	}
	return 0;
}
tryDropBackPack(playerid) {
	if(playerHasBackPack(playerid)) {
		new interior, vw, Float: X, Float: Y, Float: Z, Float: rotZ;
		interior = GetPlayerInterior(playerid);
		vw = GetPlayerVirtualWorld(playerid);
		GetPlayerPos(playerid, X, Y, Z);
		GetPlayerFacingAngle(playerid, rotZ);
		Z -= 0.8; //Backpack adjust
		OnBackPackDrop(playerid, X, Y, Z, 0.0, 0.0, rotZ, interior, vw);
	} else {
		SendClientMessage(playerid, X11_TOMATO_2, "You don't have a backpack!");
	}
}
forward OnBackPackDrop(playerid,Float:X,Float:Y,Float:Z,Float:rotX,Float:rotY,Float:rotZ,interior,vw);
public OnBackPackDrop(playerid,Float:X,Float:Y,Float:Z,Float:rotX,Float:rotY,Float:rotZ,interior,vw) {
	new index = findFreeBackPack();
	new data[128];
	query[0] = 0;
	if(index == -1) {
		ABroadcast(X11_RED,"Can't drop backpack right now. Backpack array is full. - Destroying some BackPacks..",EAdminFlags_BasicAdmin);
		destroyAllOldBackPacks();
		return 0;
	}
	BackpackInfo[index][EBackpackLastOwner]	= GetPVarInt(playerid, "CharID");
	BackpackInfo[index][EBackpackSQLID] = GetPVarInt(playerid, "BagID");
	BackpackInfo[index][EBackpackPickupX] = X;
	BackpackInfo[index][EBackpackPickupY] = Y;
	BackpackInfo[index][EBackpackPickupZ] = Z;
	BackpackInfo[index][EBackpackPickupRotX] = rotX;
	BackpackInfo[index][EBackpackPickupRotY] = rotY;
	BackpackInfo[index][EBackpackPickupRotZ] = rotZ;
	BackpackInfo[index][EBackpackPickupInt] = interior;
	BackpackInfo[index][EBackpackPickupVW] = vw;
	BackpackInfo[index][EBackpackDropTime] = gettime();
	
	format(data, sizeof(data), "{%s}Item:[{%s}Backpack{%s}]",getColourString(X11_WHITE),getColourString(COLOR_BRIGHTRED),getColourString(X11_WHITE));
	BackpackInfo[index][EBackpackText] = CreateDynamic3DTextLabel(data, 0x2BFF00AA, BackpackInfo[index][EBackpackPickupX], BackpackInfo[index][EBackpackPickupY], BackpackInfo[index][EBackpackPickupZ], 5.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, BackpackInfo[index][EBackpackPickupVW], BackpackInfo[index][EBackpackPickupInt]);
	BackpackInfo[index][EBackPackObjID] = CreateDynamicObject(BACKPACK_MDL_ID, BackpackInfo[index][EBackpackPickupX], BackpackInfo[index][EBackpackPickupY], BackpackInfo[index][EBackpackPickupZ], BackpackInfo[index][EBackpackPickupRotX], BackpackInfo[index][EBackpackPickupRotY], BackpackInfo[index][EBackpackPickupRotZ], BackpackInfo[index][EBackpackPickupVW], BackpackInfo[index][EBackpackPickupInt]);
	
	format(query, sizeof(query), "UPDATE `backpacks` SET `charid` = -1, `lastowner` = %d, `x` = %f, `y` = %f, `z` = %f, `rotx` = %f, `roty` = %f, `rotz` = %f, `int` = %d, `vw` = %d, `dropped` = 1 WHERE `id` = %d",BackpackInfo[index][EBackpackLastOwner], X, Y, Z, rotX, rotY, rotZ, interior, vw, BackpackInfo[index][EBackpackSQLID]);
	mysql_function_query(g_mysql_handle, query, true, "EmptyCallback", "");
	
	#if debug
	format(data,sizeof(data),"[AdmNotice]: BackpackInfo SQL ID: %d",BackpackInfo[index][EBackpackSQLID]);
	ABroadcast(X11_RED,data,EAdminFlags_BasicAdmin);
	#endif
	format(data, sizeof(data), "* %s drops %s backpack on the ground.",GetPlayerNameEx(playerid, ENameType_RPName), getPossiveAdjective(playerid));
	ProxMessage(30.0, playerid, data, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
					
	//Remove the backpack from the player
	setPlayerHasBackPack(playerid, 0); //It looks like it would make sense to put this inside deparentBackPack but what if we disconnect? Looks like trouble..
	deparentBackPack(playerid); //This removes the items as well
	return index; //Return the index for the backpack that was dropped
}
cantStoreItInBackPack(playerid, gunid) {
	new weaponNeedle = (1 << _:EWeaponType_AssaultRifle) | (1 << _:EWeaponType_Shotgun) | (1 << _:EWeaponType_Rifle) | (1 << _:EWeaponType_Heavy);
	new wClassType = getWeaponClassType(playerid, gunid);
	if ((1 << wClassType) & weaponNeedle) {
		return 1;
	}
	return 0;
}
findOldBackPacks() {
	new time = gettime();
	for(new i=0;i<sizeof(BackpackInfo);i++) {
		if(time-BackpackInfo[i][EBackpackDropTime] >= MAX_BACKPACKS_TIME) {
			return i;
		}
	}
	return -1;
}
manageOverallOldBackPacks() {
	removeOldBPLAPDSpots();
	destroyAllOldBackPacks();
}
destroyAllOldBackPacks() {
	new index;
	for(new i=0;i<sizeof(BackpackInfo);i++) {
		index = findOldBackPacks();
		if(index != -1) {
			destroyBackPack(index);
		}
	}
}
findFreeBackPack() {
	for(new i=0;i<sizeof(BackpackInfo);i++) {
		if(BackpackInfo[i][EBackpackSQLID] == 0) {
			return i;
		}
	}
	return -1;
}
deparentBackPack(playerid) {
	removeBackPackFromPlayer(playerid);
	deleteBackpackPVars(playerid);
}
BackpacksOnPlayerDisconnect(playerid, reason) {
	#pragma unused reason
	deparentBackPack(playerid);
}
YCMD:backpack(playerid, params[], help) {
	if(help) {
		SendClientMessage(playerid, X11_WHITE, "Access your Backpack");
		return 1;
	}
	new flags = GetPVarInt(playerid, "UserFlags");
	if(~flags & EUFHasBackPack) { 
		SendClientMessage(playerid, X11_TOMATO_2, "You don't have a backpack!");
		return 1;
	}
	if(isInPaintball(playerid)) {
		SendClientMessage(playerid, X11_TOMATO_2, "You can't do this right now!");
		return 1;
	}
	if(IsOnDuty(playerid)) {
		SendClientMessage(playerid, X11_TOMATO_2, "You can't do this on duty!");
		return 1;
	}
	showTypeBackpackMenu(playerid);
	return 1;
}
isAtBackpackLocation(playerid) {
	for(new i=0;i<sizeof(BackpackInfo);i++) {
		if(IsPlayerInRangeOfPoint(playerid, 5.0,BackpackInfo[i][EBackpackPickupX], BackpackInfo[i][EBackpackPickupY], BackpackInfo[i][EBackpackPickupZ])) {
			return 1;
		}
	}
	return 0;
}
showTypeBackpackMenu(playerid) {
	ShowPlayerDialog(playerid, EBackpackDialog_GiveTake, DIALOG_STYLE_MSGBOX, "{00BFFF}Backpack Menu","What would you like to do with your Backpack?", "Store", "Take");
}
BackpacksOnDialogResp(playerid, dialogid, response, listitem, inputtext[]) {
	new msg[128];
	new total;
	new pvarname[64];
	switch(dialogid) {
		case EBackpackDialog_GiveTake: {
			showBackpackTakeMenu(playerid,!response);
		}
		case EBackpackDialog_Take: {
			SetPVarInt(playerid, "BItemIndex", listitem);
			if(GetPVarInt(playerid, "BackpackTake") != 1) {
				if(response) {
					backpackStoreMenu(playerid);
					return 1;
				} 
				return 1;
			}
			if(response) {
				format(pvarname, sizeof(pvarname), "BItem%dType",listitem);
				new index = GetPVarInt(playerid, pvarname);
				format(pvarname, sizeof(pvarname), "BItem%d",listitem);
				total = GetPVarInt(playerid, pvarname);
				if(index == 0) {
					SendClientMessage(playerid, X11_TOMATO_2, "There's nothing in this slot!");
					return 1;
				} else if(index == 4) {
					new gun, ammo, slot;
					decodeWeapon(total, gun, ammo);
					slot = GetWeaponSlot(gun);
					new curgun, curammo;
					GetPlayerWeaponDataEx(playerid, slot, curgun, curammo);
					if(curgun != 0) {
						SendClientMessage(playerid, X11_TOMATO_2, "You are already holding a weapon in this slot!");
						return 1;
					}
					GivePlayerWeaponEx(playerid, gun, ammo);
					SetPVarInt(playerid, pvarname, 0);
					format(pvarname, sizeof(pvarname), "BItem%dType",listitem);	
					SetPVarInt(playerid, pvarname, 0);
					format(msg, sizeof(msg), "* %s takes something out %s Backpack.", GetPlayerNameEx(playerid, ENameType_RPName), getPossiveAdjective(playerid));
					ProxMessage(30.0, playerid, msg, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
					SendClientMessage(playerid, COLOR_LIGHTGREEN, "You have successfully taken this item from your Backpack");
					savePlayerBackpack(playerid);
					return 1;
				} else if(index == 9) { //special item
					if(HasSpecialItem(playerid)) {
						SendClientMessage(playerid, X11_TOMATO_2, "You are already holding a special item!");
						return 1;
					}
					GivePlayerItem(playerid, total);
					SetPVarInt(playerid, pvarname, 0);
					format(pvarname, sizeof(pvarname), "BItem%dType",listitem);	
					SetPVarInt(playerid, pvarname, 0);
					savePlayerBackpack(playerid);
					return 1;
				}
				BGetItemName(bFindItemType(index),pvarname, sizeof(pvarname));
				SetPVarInt(playerid, "BItemIndex", listitem);
				format(msg, sizeof(msg), "Enter how much %s you would like to remove\nYou currently have: %d in your Backpack and %d on hand.",pvarname,total,GetPVarInt(playerid, BackpackItems[index][ESafeSItemPVar]));
				ShowPlayerDialog(playerid, EBackpackDialog_TakeAmount, DIALOG_STYLE_INPUT, "{00BFFF}Backpack Menu",msg, "Take", "Cancel");
			}
		}
		case EBackpackDialog_TakeAmount: {
			if(response) {
				total = strval(inputtext);
				if(total <= 0) {
					SendClientMessage(playerid, X11_TOMATO_2, "Invalid Amount!");
					return 1;
				}
				new index = GetPVarInt(playerid, "BItemIndex");
				format(pvarname, sizeof(pvarname), "BItem%d",index);
				if(GetPVarInt(playerid, pvarname) < total) {
					SendClientMessage(playerid, X11_TOMATO_2, "You don't have enough!");
					return 1;
				} else {
					new Backpacktotal;
					format(pvarname, sizeof(pvarname), "BItem%d", index);
					Backpacktotal = GetPVarInt(playerid, pvarname);
					format(pvarname, sizeof(pvarname), "BItem%dType", index);
					new type = GetPVarInt(playerid, pvarname);
					if((Backpacktotal - total) < 1) {
						DeletePVar(playerid, pvarname);
						format(pvarname, sizeof(pvarname), "BItem%d", index);
						DeletePVar(playerid, pvarname);
					} else {
						format(pvarname, sizeof(pvarname), "BItem%d", index);
						SetPVarInt(playerid, pvarname, Backpacktotal - total);
					}
					new amount = GetPVarInt(playerid, BackpackItems[type][ESafeSItemPVar]);
					amount += total;
					SetPVarInt(playerid, BackpackItems[type][ESafeSItemPVar], amount);
					GiveMoneyEx(playerid, 0); //sync money
					format(msg, sizeof(msg), "* %s takes something out %s Backpack.", GetPlayerNameEx(playerid, ENameType_RPName), getPossiveAdjective(playerid));
					ProxMessage(30.0, playerid, msg, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
					SendClientMessage(playerid, COLOR_LIGHTGREEN, "You have successfully taken this item from your Backpack");
					savePlayerBackpack(playerid);
				}
			}
			DeletePVar(playerid, "BItemIndex");
		}
		case EBackpackDialog_StoreChoose: {
			if(!response) return 1;
			listitem++;
			format(pvarname, sizeof(pvarname), "BItem%dType",GetPVarInt(playerid, "BItemIndex"));
			SetPVarInt(playerid, "StorageSlot", listitem);
			new index = GetPVarInt(playerid, pvarname);
			if((listitem != index && index != 0) || BackpackItems[index][ESafeSType] == ESafeItemType_Gun || BackpackItems[index][ESafeSType] == ESafeItemType_SpecialItem) {
				SendClientMessage(playerid, X11_TOMATO_2, "You can't store this here!");
				return 1;
			}
			if(BackpackItems[listitem][ESafeSType] == ESafeItemType_Gun) {
				new gun, ammo, gslot;
				gslot = GetWeaponSlot(GetPlayerWeaponEx(playerid));
				GetPlayerWeaponDataEx(playerid, gslot ,gun, ammo);
				if(gun < 1) {
					SendClientMessage(playerid, X11_TOMATO_2, "You aren't carrying any weapon on that slot.");
					return 1;
				}
				if(cantStoreItInBackPack(playerid, gun)) {
					SendClientMessage(playerid, X11_TOMATO_2, "You can't store such weapon in the backpack.");
					return 1;
				}
				gslot = encodeWeapon(gun, ammo);
				new itemindex = GetPVarInt(playerid, "BItemIndex");
				format(pvarname, sizeof(pvarname), "BItem%d", itemindex);
				SetPVarInt(playerid, pvarname, gslot);
				format(pvarname, sizeof(pvarname), "BItem%dType", itemindex);
				SetPVarInt(playerid, pvarname, listitem);
				RemovePlayerWeapon(playerid, gun);
				format(msg, sizeof(msg), "* %s puts something into %s Backpack.", GetPlayerNameEx(playerid, ENameType_RPName), getPossiveAdjective(playerid));
				ProxMessage(30.0, playerid, msg, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
				SendClientMessage(playerid, COLOR_LIGHTGREEN, "You have successfully stored this item in your Backpack");
				savePlayerBackpack(playerid);
				return 1;
			} else if(BackpackItems[listitem][ESafeSType] == ESafeItemType_SpecialItem) {
				if(!HasSpecialItem(playerid)) {
					SendClientMessage(playerid, X11_TOMATO_2, "You are not carrying a special item.");
					return 1;
				}
				new itemindex = GetPVarInt(playerid, "BItemIndex");
				new item = GetPVarInt(playerid, "SpecialItem");
				format(pvarname, sizeof(pvarname), "BItem%dType", itemindex);
				SetPVarInt(playerid, pvarname, listitem);
				format(pvarname, sizeof(pvarname), "BItem%d",itemindex);
				SetPVarInt(playerid, pvarname, item);
				format(msg, sizeof(msg), "* %s puts something into %s Backpack.", GetPlayerNameEx(playerid, ENameType_RPName), getPossiveAdjective(playerid));
				ProxMessage(30.0, playerid, msg, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
				SendClientMessage(playerid, COLOR_LIGHTGREEN, "You have successfully stored this item in your Backpack");
				RemovePlayerItem(playerid);
				savePlayerBackpack(playerid);
				return 1;
			}
			BGetItemName(bFindItemType(listitem),pvarname, sizeof(pvarname));
			format(msg, sizeof(msg), "Enter how much %s you would like to store\nYou currently have: %d in your Backpack and %d on hand.",pvarname,total,GetPVarInt(playerid, BackpackItems[index][ESafeSItemPVar]));
			ShowPlayerDialog(playerid, EBackpackDialog_StoreAmount, DIALOG_STYLE_INPUT, "{00BFFF}Backpack Menu",msg, "Store", "Cancel");
		}
		case EBackpackDialog_StoreAmount: {
			total = strval(inputtext);
			if(total <= 0) {
				SendClientMessage(playerid, X11_TOMATO_2, "Invalid Amount!");
				return 1;
			}
			new slot = GetPVarInt(playerid, "StorageSlot");
			if(GetPVarInt(playerid, BackpackItems[slot][ESafeSItemPVar]) < total) {
				SendClientMessage(playerid, X11_TOMATO_2, "You don't have enough!");
				return 1;
			}
			new Backpacktotal;
			new index = GetPVarInt(playerid, "BItemIndex");
			format(pvarname, sizeof(pvarname), "BItem%d", index);
			Backpacktotal = GetPVarInt(playerid, pvarname);
			SetPVarInt(playerid, pvarname, Backpacktotal + total);
			format(pvarname, sizeof(pvarname), "BItem%dType", index);
			new curslot = GetPVarInt(playerid, pvarname);
			new localtotal = GetPVarInt(playerid, BackpackItems[slot][ESafeSItemPVar]);
			localtotal -= total;
			SetPVarInt(playerid, BackpackItems[slot][ESafeSItemPVar], localtotal);
			GiveMoneyEx(playerid, 0); //sync money
			SendClientMessage(playerid, COLOR_LIGHTGREEN, "You have successfully stored this item from your Backpack");
			if(curslot == 0) {
				SetPVarInt(playerid, pvarname, slot);
			}
			format(msg, sizeof(msg), "* %s puts something into %s Backpack.", GetPlayerNameEx(playerid, ENameType_RPName), getPossiveAdjective(playerid));
			ProxMessage(30.0, playerid, msg, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			DeletePVar(playerid, "StorageSlot");
			DeletePVar(playerid, "BItemIndex");
			savePlayerBackpack(playerid);
		}
	}
	return 1;
}
backpackStoreMenu(playerid) {
	dialogstr[0] = 0;
	tempstr[0] = 0;
	for(new i=1;i<sizeof(BackpackItems);i++) {
		format(tempstr, sizeof(tempstr), "%s\n",BackpackItems[i][ESafeSItemName]);
		strcat(dialogstr, tempstr, sizeof(dialogstr));
	}
	ShowPlayerDialog(playerid, EBackpackDialog_StoreChoose, DIALOG_STYLE_LIST, "{00BFFF}Backpack Menu",dialogstr, "Take", "Cancel");
}
showBackpackTakeMenu(playerid,take) {
	dialogstr[0] = 0;
	tempstr[0] = 0;
	new pvarname[64];
	for(new i=0;i<NUM_BACKPACK_SLOTS;i++) {
		new index,amount;
		format(pvarname, sizeof(pvarname), "BItem%dType",i);
		index = GetPVarInt(playerid, pvarname);
		format(pvarname, sizeof(pvarname), "BItem%d",i);
		amount = GetPVarInt(playerid, pvarname);
		if(index == 0) { //none
			strcat(dialogstr, "None\n", sizeof(dialogstr));
		} else {
			new ESafeItemType:type = bFindItemType(index);
			if(type == ESafeItemType_Gun) {
				new gun, ammo;
				decodeWeapon(amount, gun, ammo);
				GetWeaponNameEx(gun, pvarname, sizeof(pvarname));
				amount = ammo;
			} else {
				BGetItemName(type,pvarname, sizeof(pvarname));
			}
			if(type == ESafeItemType_SpecialItem) {
			format(tempstr, sizeof(tempstr), "%s - %s\n",pvarname,GetCarryingItemName(amount));
			} else {
				format(tempstr, sizeof(tempstr), "%s - %s\n",pvarname,getNumberString(amount));
			}
			strcat(dialogstr, tempstr, sizeof(dialogstr));
		}
	}
	SetPVarInt(playerid, "BackpackTake", take);
	ShowPlayerDialog(playerid, EBackpackDialog_Take, DIALOG_STYLE_LIST, "{00BFFF}Backpack Menu",dialogstr, "Take", "Cancel");
}
tryLoadBackpacks(playerid) {
	format(query, sizeof(query), "SELECT 1 FROM `backpacks` WHERE `charid` = %d AND `dropped` = 0",GetPVarInt(playerid, "CharID"));
	mysql_function_query(g_mysql_handle, query, true, "OnTryLoadBackpacks", "d",playerid);
}
insertPlayerBackpacks(playerid) {
	format(query, sizeof(query), "INSERT INTO `backpacks` SET `charid` = %d",GetPVarInt(playerid, "CharID"));
	mysql_function_query(g_mysql_handle, query, true, "EmptyCallback", "");
}
forward OnTryLoadBackpacks(playerid);
public OnTryLoadBackpacks(playerid) {
	new rows, fields;
	cache_get_data(rows, fields);
	if(rows > 0) {
		loadPlayerBackpacks(playerid);
	} else {
		setPlayerHasBackPack(playerid, 0); //Set the flag to off if they don't have any backpacks...
	}
}
savePlayerBackpack(playerid) {
	new pvarname[64],pvarname2[64];
	format(query, sizeof(query), "UPDATE `backpacks` SET ");
	for(new i=0;i<NUM_BACKPACK_SLOTS;i++) {
		format(pvarname, sizeof(pvarname), "BItem%dType",i);
		format(pvarname2, sizeof(pvarname2), "BItem%d",i);
		format(tempstr, sizeof(tempstr), "`bitem%dtype` = %d,`bitem%d` = %d,",i,GetPVarInt(playerid, pvarname), i, GetPVarInt(playerid, pvarname2));
		strcat(query, tempstr, sizeof(query));
	}
	query[strlen(query)-1] = 0;
	format(tempstr, sizeof(tempstr), " WHERE `id` = %d",GetPVarInt(playerid, "BagID"));
	strcat(query, tempstr, sizeof(query));
	mysql_function_query(g_mysql_handle, query, true, "EmptyCallback", "");
}
deleteBackpackPVars(playerid) {
	new pvarname[32];
	DeletePVar(playerid, "BagID");
	for(new i=0;i<NUM_BACKPACK_SLOTS;i++) {
		format(pvarname, sizeof(pvarname), "BItem%dType",i);
		DeletePVar(playerid, pvarname);
		format(pvarname, sizeof(pvarname), "BItem%d",i);
		DeletePVar(playerid, pvarname);
	}
}
loadPlayerBackpacks(playerid, backpacksqlid = -1) {
	query[0] = 0;
	tempstr[0] = 0;
	format(query, sizeof(query), "SELECT `id`,");
	for(new i=0;i<NUM_BACKPACK_SLOTS;i++) {
		format(tempstr, sizeof(tempstr), "`bitem%dtype`,`bitem%d`,",i, i);
		strcat(query, tempstr, sizeof(query));
	}
	query[strlen(query)-1] = 0;
	if(backpacksqlid != -1) {
		format(tempstr, sizeof(tempstr), " FROM `backpacks` WHERE `id` = %d",backpacksqlid);
	} else {
		format(tempstr, sizeof(tempstr), " FROM `backpacks` WHERE `charid` = %d AND `dropped` = 0",GetPVarInt(playerid, "CharID")); //It seems like it doesn't make sense to check this here but it actually does since this is used for the 24/7's as well
	}
	strcat(query, tempstr, sizeof(query));
	mysql_function_query(g_mysql_handle, query, true, "OnLoadPlayerBackpacks", "d", playerid);
}
forward OnLoadPlayerBackpacks(playerid);
public OnLoadPlayerBackpacks(playerid) { //This is also triggered when a player picks up a back pack
	new id_string[32];
	new pvarname[64];
	new x;	
	
	cache_get_row(0, 0, id_string); //Get the row 0 for the SQL ID
	SetPVarInt(playerid, "BagID", strval(id_string));
	
	for(new i=1;i<NUM_BACKPACK_SLOTS*2;i+=2) {
		format(pvarname, sizeof(pvarname), "BItem%dType",x);
		cache_get_row(0, i, id_string);
		//printf("PVarName: %s", pvarname);
		SetPVarInt(playerid, pvarname, strval(id_string));
		cache_get_row(0, i+1, id_string);
		format(pvarname, sizeof(pvarname), "BItem%d",x);
		SetPVarInt(playerid, pvarname, strval(id_string));
		//printf("PVarName: %s", pvarname);
		x++;
	}
	tryAttachBackPackToPlayer(playerid);
}
tryAttachBackPackToPlayer(playerid) {
	if(playerHasBackPack(playerid)) {
		SetPlayerAttachedObject(playerid, 8, BACKPACK_MDL_ID, BONE_SPINE, -0.1, -0.2, 0, 0, 90, 0, 1, 1, 1);
	} else {
		checkForBackPackPickup(playerid);
	}
}
/*
checkForBackPackSync(playerid) {
	if(GetPVarType(playerid, "BagID") == PLAYER_VARTYPE_NONE) { //If they haven't picked up a bag
		if(playerHasBackPack(playerid)) { //But they have the flag on
			setPlayerHasBackPack(playerid, 0); //set the flag off. Note: In rare cases desyncs occur so we can patch that here..
		}
	}
	return 1;
}
*/
checkForBackPackPickup(playerid) {
	if(GetPVarType(playerid, "BagID") != PLAYER_VARTYPE_NONE) { //He doesn't have a back pack but we know that he has one since he picked one up..
		removeBackPackFromMap(playerid); //Remove it from the map by using the SQLID
		SetPlayerAttachedObject(playerid, 8, BACKPACK_MDL_ID, BONE_SPINE, -0.1, -0.2, 0, 0, 90, 0, 1, 1, 1); //Attach the object
		setPlayerHasBackPack(playerid, 1); //Tell the script that they have a back pack now
	}
}
removeBackPackFromMap(playerid) {
	query[0] = 0;
	new index = findBackPackIDBySQLID(GetPVarInt(playerid, "BagID")); //This looks awkward but we currently have this here because the player JUST PICKED UP a bag
	if(index != -1) {
		destroyBackPack(index);
		format(query, sizeof(query), "UPDATE `backpacks` SET `charid` = %d, `dropped` = 0 WHERE `id` = %d",GetPVarInt(playerid, "CharID"), GetPVarInt(playerid, "BagID"));
		mysql_function_query(g_mysql_handle, query, true, "EmptyCallback", "");
	}
}
destroyBackPack(index) {
	BackpackInfo[index][EBackpackSQLID] = 0;
	BackpackInfo[index][EBackpackDropTime] = 0;
	DestroyDynamic3DTextLabel(BackpackInfo[index][EBackpackText]);
	DestroyDynamicObject(BackpackInfo[index][EBackPackObjID]);
	BackpackInfo[index][EBackpackText] = Text3D:0;
}
findBackPackIDBySQLID(sqlid) {
	for(new i=0;i<sizeof(BackpackInfo);i++) {
		if(BackpackInfo[i][EBackpackSQLID] == sqlid) {
			return i;
		}
	}
	return -1;
}
getClosestBackPack(playerid) {
	for(new i=0;i<sizeof(BackpackInfo);i++) {
		if(IsPlayerInRangeOfPoint(playerid, 5.0, BackpackInfo[i][EBackpackPickupX], BackpackInfo[i][EBackpackPickupY], BackpackInfo[i][EBackpackPickupZ])) {
			if(BackpackInfo[i][EBackpackSQLID] != 0) {
				return i;
			}
		}
	}
	return -1;
}
getClosestBackPackSQLID(playerid) {
	for(new i=0;i<sizeof(BackpackInfo);i++) {
		if(IsPlayerInRangeOfPoint(playerid, 5.0, BackpackInfo[i][EBackpackPickupX], BackpackInfo[i][EBackpackPickupY], BackpackInfo[i][EBackpackPickupZ])) {
			if(BackpackInfo[i][EBackpackSQLID] != 0) {
				return BackpackInfo[i][EBackpackSQLID];
			}
		}
	}
	return -1;
}
tryPickupBackPack(playerid) {
	new msg[128];
	if(playerHasBackPack(playerid)) {
		SendClientMessage(playerid, X11_TOMATO_2, "You're already carrying a backpack, you're only allowed to carry one at a time!");
		return 1;
	}
	if(isAtBackpackLocation(playerid)) {
		new sqlid = getClosestBackPackSQLID(playerid);
		if(sqlid != -1) {
			ApplyAnimation(playerid, "BOMBER","BOM_Plant_In",4.0,0,0,0,0,0);
			format(msg, sizeof(msg), "* %s picks up a backpack.", GetPlayerNameEx(playerid,ENameType_RPName));
			ProxMessage(25.0, playerid, msg, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			loadPlayerBackpacks(playerid, sqlid); //Let's load that backpack
		}
	} else {
		SendClientMessage(playerid, X11_TOMATO_2, "You're not near a backpack!");
	}
	return 1;
}
removeBackPackFromPlayer(playerid) {
	RemovePlayerAttachedObject(playerid, 8);
	toggleAccessorySlot(playerid, 8);
	return 1;
}
getPlayerBackpackWealth(playerid) {
	new value;
	new pvarname[64];
	for(new i=0;i<NUM_BACKPACK_SLOTS;i++) {
		new index,amount;
		format(pvarname, sizeof(pvarname), "BItem%dType",i);
		index = GetPVarInt(playerid, pvarname);
		format(pvarname, sizeof(pvarname), "BItem%d",i);
		amount = GetPVarInt(playerid, pvarname);
		new ESafeItemType:type = bFindItemType(index);
		if(type == ESafeItemType_Money) {
			value += amount;
		}
	}
	return value;
}
/* Commands */
YCMD:dropbackpack(playerid, params[], help) {
	if(help) {
		SendClientMessage(playerid, X11_WHITE, "Drops your back pack");
	}
	tryDropBackPack(playerid);
	return 1;
}
YCMD:pickupbackpack(playerid, params[], help) {
	if(help) {
		SendClientMessage(playerid, X11_WHITE, "Picks up your back pack");
	}
	tryPickupBackPack(playerid);
	return 1;
}
YCMD:checkbackpack(playerid, params[], help) {
	if(help) {
		SendClientMessage(playerid, X11_WHITE, "Displays the contents of a players Backpack");
		return 1;
	}
	new pvarname[64];
	new target;
	if(!sscanf(params, "k<playerLookup_acc>",target)) {
		if(!IsPlayerConnectEx(target)) {
			SendClientMessage(playerid, X11_TOMATO_2, "User not found");
			return 1;
		}
		format(query, sizeof(query), "******* %s's Backpack *******",GetPlayerNameEx(target, ENameType_CharName));
		SendClientMessage(playerid, X11_WHITE, query);
		for(new i=0;i<NUM_BACKPACK_SLOTS;i++) {
			new index,amount;
			format(pvarname, sizeof(pvarname), "BItem%dType",i);
			index = GetPVarInt(target, pvarname);
			format(pvarname, sizeof(pvarname), "BItem%d",i);
			amount = GetPVarInt(target, pvarname);
			if(index == 0) { //none
				format(query, sizeof(query), "%d. None",i+1);
			} else {
				new ESafeItemType:type = bFindItemType(index);
				if(type == ESafeItemType_Gun) {
					new gun, ammo;
					decodeWeapon(amount, gun, ammo);
					GetWeaponNameEx(gun, pvarname, sizeof(pvarname));
					amount = ammo;
				} else {
					BGetItemName(type,pvarname, sizeof(pvarname));
				}
				if(type != ESafeItemType_SpecialItem) {
					format(query, sizeof(query), "%d. %s - %s",i+1,pvarname,getNumberString(amount));
				} else {
					format(query, sizeof(query), "%d. %s - %s",i+1,pvarname,GetCarryingItemName(amount));
				}
			}
			SendClientMessage(playerid, COLOR_LIGHTBLUE, query);
		}
	} else {
		SendClientMessage(playerid, X11_WHITE, "USAGE: /checkbackpack [playerid/name]");
	}
	return 1;
}
YCMD:clearbackpack(playerid, params[], help) {
	if(help) {
		SendClientMessage(playerid, X11_WHITE, "Takes all the illegal items from a backpack");
	}
	if(!IsAnLEO(playerid)) {
		SendClientMessage(playerid, X11_TOMATO_2, "You aren't a cop!");
		return 1;
	}
	if(!IsOnDuty(playerid)) {
		SendClientMessage(playerid, X11_TOMATO_2, "You are not on duty!");
		return 1;
	}
	new target;
	new msg[128];
	if(!sscanf(params, "k<playerLookup_acc>", target)) {
		if(!IsPlayerConnectEx(target)) {
			SendClientMessage(playerid, X11_TOMATO_2, "User not found");
			return 1;
		}
		new Float:X,Float:Y,Float:Z;
		GetPlayerPos(target, X, Y, Z);
		if(!IsPlayerInRangeOfPoint(playerid, 2.5, X, Y, Z)) {
			SendClientMessage(playerid, X11_TOMATO_2, "You are too far away");
			return 1;
		}
		stripIllBackpackItems(target);
		SendClientMessage(playerid, X11_WHITE, "[OOC]: You've cleared the player's backpack");
		format(msg, sizeof(msg), "* %s reaches into %s's backpack and takes their suspicious belongings away.",GetPlayerNameEx(playerid, ENameType_RPName), GetPlayerNameEx(target, ENameType_RPName));
		ProxMessage(30.0, playerid, msg, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
		format(msg, sizeof(msg), "* Officer %s has cleared your backpack.",GetPlayerNameEx(playerid, ENameType_RPName));
		SendClientMessage(target, X11_WHITE, msg);
	} else {
		SendClientMessage(playerid, X11_WHITE, "USAGE: /clearbackpack [playerid/name]");
	}
	return 1;
}
//
