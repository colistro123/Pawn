/*
-------
	PVars Used By This Script:
	CraftWepID - Holds the weaponid the player is crafting
	CraftWepType - Holds the type of weapon the player is crafting (not really used at the moment)
-------
*/
enum ECraftFlags (<<= 1) {
	ECraftFlags_NotDoneYet,
	ECraftFlags_Done,
};
enum pCraftInfo
{
	pCraftSQLID,
	pOwnerSQLID,
	pOwner[MAX_PLAYER_NAME],
	pGunID,
	pOrderTime,//time in seconds when it was planted
	ECraftFlags:pCraftFlags,
};
enum {
	EGunFactory_CraftMenu = EGunFactory_Base + 1,
	EGunFactory_SelectGun,
	EGunFactory_RetireGun,
	EGunFactory_NameMenu,
	EGunFactory_ConfirmBox,
};
/* Defines */
#define MAX_FACWEAPONS 300
#define WEAPON_READY_TIME 18000 //5 hours
#define MAX_GUNFACTORY_NAME 64
/* End of Defines */
new WepCraftInfo[MAX_FACWEAPONS][pCraftInfo];

enum EGunFactoryIconInfo  {
	EGunFactoryName[MAX_GUNFACTORY_NAME],
	Float:EGunFactoryPickupX,
	Float:EGunFactoryPickupY,
	Float:EGunFactoryPickupZ,
	EGunFactoryPickupInt,
	EGunFactoryPickupVW,
	EGunFactoryPickupID,
	Text3D:EGunFactoryText,
};
new GunFactoryIcons[][EGunFactoryIconInfo] = { 
	{"Gun Factory (( /craftweapon ))",2247.0269,-2373.1807,13.5469, 0, 0, 0, Text3D:0}
};

enum {
	CraftType_Manufacture,
	CraftType_Retire,
}

enum E_CraftWepMenu {
	E_DialogOptionText[128],
	E_CraftType,
	E_CraftPrice,
	E_DoCraftWepCallBack[128],
}

new CraftWepMenu[][E_CraftWepMenu] = {
	{"Craft A Weapon", CraftType_Manufacture, 0, "manufactureWepMenu"},
	{"Retire A Crafted Weapon", CraftType_Retire, 0, "retireCraftWepMenu"}
};

gunFactoryOnGameModeInit() {
	loadGunFactoryIcons();
	loadWepCrafts();
}
loadGunFactoryIcons() {
	for(new i=0;i<sizeof(GunFactoryIcons);i++) {
		GunFactoryIcons[i][EGunFactoryText] = CreateDynamic3DTextLabel(GunFactoryIcons[i][EGunFactoryName], 0x2BFF00AA, GunFactoryIcons[i][EGunFactoryPickupX], GunFactoryIcons[i][EGunFactoryPickupY], GunFactoryIcons[i][EGunFactoryPickupZ]+1.0, 25.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, GunFactoryIcons[i][EGunFactoryPickupVW], GunFactoryIcons[i][EGunFactoryPickupInt]);
		GunFactoryIcons[i][EGunFactoryPickupID] =  CreateDynamicPickup(1239, 16,  GunFactoryIcons[i][EGunFactoryPickupX], GunFactoryIcons[i][EGunFactoryPickupY], GunFactoryIcons[i][EGunFactoryPickupZ], GunFactoryIcons[i][EGunFactoryPickupVW], GunFactoryIcons[i][EGunFactoryPickupInt]);
	}
}
loadWepCrafts() {
	mysql_function_query(g_mysql_handle, "SELECT `gunfactory`.`id`,`gunid`,`gunowner`,`flags`,Unix_Timestamp(`ordertime`) FROM `gunfactory` INNER JOIN `characters` ON `characters`.`id` = `gunfactory`.`gunowner`", true, "OnLoadWepCrafts", "");
	//"ON `characters`.`id` = `gunfactory`.`gunowner`" This is done so it only loads the guns if the users actually exist. Else it will display null when trying to display the gun owner since there's no relation to the other table / broken link.
}
forward OnLoadWepCrafts();
public OnLoadWepCrafts() {
	new rows, fields;
	new id_string[128];
	//new index;
	cache_get_data(rows, fields);
	for(new i=0;i<rows;i++) {

		//index = findFreeWepCraft();
		cache_get_row(i, 0, id_string);
		WepCraftInfo[i][pCraftSQLID] = strval(id_string);
		
		cache_get_row(i, 1, id_string);
		WepCraftInfo[i][pGunID] = strval(id_string);
		
		cache_get_row(i, 2, id_string);
		WepCraftInfo[i][pOwnerSQLID] = strval(id_string);
		
		cache_get_row(i, 3, id_string);
		WepCraftInfo[i][pCraftFlags] = ECraftFlags:strval(id_string);
		
		cache_get_row(i, 4, id_string);
		WepCraftInfo[i][pOrderTime] = strval(id_string);
		#if debug
		printf("Loaded SQLGunID: %d, WeaponID: %d, Owner: %d", WepCraftInfo[i][pCraftSQLID], WepCraftInfo[i][pGunID], WepCraftInfo[i][pOwnerSQLID]);
		#endif
	}
}
placeWepCraft(playerid, gunid) {
	format(query, sizeof(query), "INSERT INTO `gunfactory` (`gunid`,`gunowner`) VALUES (%d,%d)",gunid, GetPVarInt(playerid, "CharID"));
	mysql_function_query(g_mysql_handle, query, true, "OnPlaceWepCraft", "dd",playerid,gunid);
}

forward OnPlaceWepCraft(playerid, gunid);
public OnPlaceWepCraft(playerid, gunid) {
	new index = findFreeWepCraft();
	new id = mysql_insert_id();
	new msg[128];
	if(index == -1) {
		SendClientMessage(playerid, X11_TOMATO_2, "We've reached our production limit right now, please come back at a later time.");
		format(msg, sizeof(msg), "DELETE FROM `gunfactory` WHERE `id` = %d",id);
		mysql_function_query(g_mysql_handle, msg, false, "EmptyCallback", "");
		return -1;
	}
	WepCraftInfo[index][pCraftSQLID] = id;
	WepCraftInfo[index][pOrderTime] = gettime();
	WepCraftInfo[index][pCraftFlags] = ECraftFlags:0;
	format(WepCraftInfo[index][pOwner],MAX_PLAYER_NAME,"%s",GetPlayerNameEx(playerid, ENameType_CharName));
	WepCraftInfo[index][pOwnerSQLID] = GetPVarInt(playerid, "CharID");
	WepCraftInfo[index][pGunID] = gunid;
	if(EAdminFlags:GetPVarInt(playerid, "AdminFlags") & EAdminFlags_Scripter) {
		format(msg, sizeof(msg), "WepCraft ID: %d SQL ID: %d",index,id);
		SendClientMessage(playerid, COLOR_LIGHTGREEN, msg);
	}
	return 0;
}

findFreeWepCraft() {
	for(new i=0;i<sizeof(WepCraftInfo);i++) {
		if(WepCraftInfo[i][pOwnerSQLID] == 0) {
			return i;
		}
	}
	return -1;
}
forward DestroyWepCraft(craftid);
public DestroyWepCraft(craftid) {
	new msg[128];
	format(msg, sizeof(msg), "DELETE FROM `gunfactory` WHERE `id` = %d",WepCraftInfo[craftid][pCraftSQLID]);
	mysql_function_query(g_mysql_handle, msg, false, "EmptyCallback", "");
}
forward sqlUpdateCraft(craftid);
public sqlUpdateCraft(craftid) {
	format(query, sizeof(query), "UPDATE `gunfactory` SET `flags` = %d WHERE `id` = %d",_:WepCraftInfo[craftid][pCraftFlags],WepCraftInfo[craftid][pCraftSQLID]);
	mysql_function_query(g_mysql_handle, query, true, "EmptyCallback", "");
}
GunFactoryOnDialogResp(playerid, dialogid, response, listitem, inputtext[]) {
	#pragma unused response
	#pragma unused listitem
	#pragma unused inputtext
	gunFactoryHandleDialog(playerid, dialogid, response, listitem, inputtext);
	return 1;
}
gunFactoryHandleDialog(playerid, dialogid, response, listitem, inputtext[]) {
	#pragma unused inputtext
	switch(dialogid) {
		case EGunFactory_CraftMenu: {
			if(!response) {
				SendClientMessage(playerid, X11_LIGHTBLUE, "* You closed the craft menu.");
				return 1;
			}
			CallLocalFunction(CraftWepMenu[listitem][E_DoCraftWepCallBack],"d", playerid);
		}
		case EGunFactory_SelectGun: {
			if(!response) {
				showCraftMenu(playerid);
				return 1;
			}
			//startCraftProcess(playerid, GunJobPrices[listitem][EGunJobWeaponID], GunJobPrices[listitem][EWeaponType]);
			showConfirmMenu(playerid, listitem);
		}
		case EGunFactory_ConfirmBox: {
			if(!response) {
				showCraftMenu(playerid);
				SendClientMessage(playerid, COLOR_LIGHTBLUE, "You cancelled the crafting process!");
				return 1;
			}
			new CraftWepID = GetPVarInt(playerid, "CraftingGun");
			new CraftWepType = GetPVarInt(playerid, "CraftWepType");
			startCraftProcess(playerid, CraftWepID, CraftWepType);
		}
		case EGunFactory_RetireGun: {
			if(!response) {
				showCraftMenu(playerid);
				return 1;
			}
			preRetireProcess(playerid, listitem);
		}
	}
	return 1;
}
/* Commands */
YCMD:craftweapon(playerid, params[], help) {
	if(help) {
		SendClientMessage(playerid, X11_WHITE, "Allows you to craft a weapon");
		return 1;
	}
	new job = GetPVarInt(playerid, "Job");
	if(job != EJobType_Arms_Dealer) {
		SendClientMessage(playerid, X11_TOMATO_2,"You must be a Gun Dealer");
		return 1;
	}
	if(!isAtGunFactoryLocation(playerid)) {
		SendClientMessage(playerid, X11_TOMATO_2, "You are not at the gun factory!");
		return 1;
	}
	showCraftMenu(playerid);
	return 1;
}
/* Functions */
isAtGunFactoryLocation(playerid) {
	for(new i=0;i<sizeof(GunFactoryIcons);i++) {
		if(IsPlayerInRangeOfPoint(playerid, 5.0,GunFactoryIcons[i][EGunFactoryPickupX], GunFactoryIcons[i][EGunFactoryPickupY], GunFactoryIcons[i][EGunFactoryPickupZ])) {
			return 1;
		}
	}
	return 0;
}
preRetireProcess(playerid, index) {
	#if debug
	printf("preRetireProcess(%d, %d)", playerid, index);
	#endif 
	//new charid = GetPVarInt(playerid, "CharID");
	new sqlid;
	sqlid = getSQLIDByDialogIndex(playerid, index);
	if(sqlid != -1) {
		doRetireProcess(playerid, sqlid);
	}
}
getSQLIDByDialogIndex(playerid, index) {
	new sqlid;
	new charid = GetPVarInt(playerid, "CharID");
	for(new i=0;i<sizeof(WepCraftInfo);i++) {
		if(WepCraftInfo[index][pOwnerSQLID] != charid) {
			#if debug
			printf("index++: %d", index);
			#endif
			index++;
			continue;
		}
		if(WepCraftInfo[index][pCraftSQLID] == WepCraftInfo[i][pCraftSQLID]) {
			sqlid = WepCraftInfo[i][pCraftSQLID];
			#if debug
			printf("GunCraft SQLID: %d", sqlid);
			#endif
			return sqlid;
		}
	}
	return -1;
}
forward hasRequiredToCraftGun(playerid, WepID);
public hasRequiredToCraftGun(playerid, WepID) {
	if(canAffordGun(playerid, WepID) && hasGunLevel(playerid, WepID)) {
		return 1;
	}
	return 0;
}
forward showConfirmMenu(playerid, index);
public showConfirmMenu(playerid, index) {
	dialogstr[0] = 0;
	new msg[128];
	if(getCraftAmount(playerid) >= GetPVarInt(playerid, "MaxCraftGuns")) {
		format(msg, sizeof(msg), "You've reached the crafting limit. You can only craft %d guns at a time", GetPVarInt(playerid, "MaxCraftGuns"));
		SendClientMessage(playerid, X11_TOMATO_2, msg);
		return 1;
	}
	if(GunJobPrices[index][EGunJobWeaponID] != -1) {
		new weaponname[32];
		GetWeaponNameEx(GunJobPrices[index][EGunJobWeaponID], weaponname, sizeof(weaponname));
		//printf("Gun Name: %s", weaponname);
		format(dialogstr, sizeof(dialogstr), "You are about to craft a %s, this weapon requires you to have %d A Materials, %d B Materials and %d C Materials and to be at least a level %d gun dealer.\n{FF0000}Please note: {FFFFFF}Crafting this weapon will take %d hours.",
		weaponname, 
		GunJobPrices[index][EGunJobAMats], 
		GunJobPrices[index][EGunJobBMats], 
		GunJobPrices[index][EGunJobCMats],
		GunJobPrices[index][EGunJobLevel],
		UnixTimeToHours(WEAPON_READY_TIME)
		);
		SetPVarInt(playerid, "CraftingGun", GunJobPrices[index][EGunJobWeaponID]);
		//SetPVarInt(playerid, "CraftWepType", EWepType);
		ShowPlayerDialog(playerid, EGunFactory_ConfirmBox, DIALOG_STYLE_MSGBOX, "{00BFFF}Confirm:", dialogstr, "Yes", "No");
	}
	return 1;
}
forward startCraftProcess(playerid, WepID, EWepType);
public startCraftProcess(playerid, WepID, EWepType) {
	if(hasRequiredToCraftGun(playerid, WepID)) {
		doCraftProcess(playerid, WepID, EWepType);
		return 1;
	}
	SendClientMessage(playerid, X11_TOMATO_2, "You don't meet the requirements to build this weapon!");
	showCraftMenu(playerid);
	return 1;
}

forward doCraftProcess(playerid, WepID, EWepType);
public doCraftProcess(playerid, WepID, EWepType) {
	#pragma unused EWepType
	new msg[128];
	removeGunMaterials(playerid, WepID);
	placeWepCraft(playerid, WepID);
	format(msg, sizeof(msg), "Your order has been placed, come to pick up your weapon in %d hours.", UnixTimeToHours(WEAPON_READY_TIME));
	SendClientMessage(playerid, COLOR_LIGHTBLUE, msg);
	deleteCraftPVars(playerid);
	doGunResolution(playerid, WepID);
	return 1;
}
forward showCraftMenu(playerid);
public showCraftMenu(playerid) {
	dialogstr[0] = 0;
	tempstr[0] = 0;
	for(new i=0;i<sizeof(CraftWepMenu);i++) {
		format(tempstr,sizeof(tempstr),"%s\n",CraftWepMenu[i][E_DialogOptionText]);
		strcat(dialogstr,tempstr,sizeof(dialogstr));
	}
	ShowPlayerDialog(playerid, EGunFactory_CraftMenu, DIALOG_STYLE_LIST, "{00BFFF}Craft Menu",dialogstr,"Ok", "Cancel");
}
forward manufactureWepMenu(playerid);
public manufactureWepMenu(playerid) {
	dialogstr[0] = 0;
	tempstr[0] = 0;
	for(new i=0;i<sizeof(GunJobPrices);i++) {
		format(tempstr,sizeof(tempstr),"%s\n",GunJobPrices[i][EGunJobName]);
		strcat(dialogstr,tempstr,sizeof(dialogstr));
	}
	ShowPlayerDialog(playerid, EGunFactory_SelectGun, DIALOG_STYLE_LIST, "{00BFFF}Which weapon do you want to craft?",dialogstr,"Craft", "Cancel");
}
forward retireCraftWepMenu(playerid);
public retireCraftWepMenu(playerid) {
	dialogstr[0] = 0;
	tempstr[0] = 0;
	new time = gettime();
	new charid = GetPVarInt(playerid, "CharID");
	for(new i=0;i<sizeof(WepCraftInfo);i++) {
		if(WepCraftInfo[i][pOwnerSQLID] == charid) {
			if(WepCraftInfo[i][pCraftSQLID] != 0) {
				if(time-WepCraftInfo[i][pOrderTime] >= WEAPON_READY_TIME) {
					format(tempstr,sizeof(tempstr),"%s - {00FF00}Ready\n",GunName[WepCraftInfo[i][pGunID]]);
				} else {
					format(tempstr,sizeof(tempstr),"%s - {FF0000}Being Crafted\n",GunName[WepCraftInfo[i][pGunID]]);
				}
				strcat(dialogstr,tempstr,sizeof(dialogstr));
			}
		}
	}
	ShowPlayerDialog(playerid, EGunFactory_RetireGun, DIALOG_STYLE_LIST, "{00BFFF}Which weapon do you want to retire?",dialogstr,"Retire", "Cancel");
}
forward doRetireProcess(playerid, SQLID);
public doRetireProcess(playerid, SQLID) {
	new msg[128];
	new time = gettime();
	new charid = GetPVarInt(playerid, "CharID");
	#if debug
	printf("Sent Playerid: %d, SQLID: %d", playerid, SQLID);
	#endif
	for(new i=0;i<sizeof(WepCraftInfo);i++) {
		if(WepCraftInfo[i][pCraftSQLID] == SQLID) {
			if(WepCraftInfo[i][pOwnerSQLID] == charid) { //Extra silly check just in case
				if(time-WepCraftInfo[i][pOrderTime] >= WEAPON_READY_TIME) {
					GivePlayerWeaponEx(playerid, WepCraftInfo[i][pGunID], -1);
					format(msg, sizeof(msg), "You have received your %s.", GunName[WepCraftInfo[i][pGunID]]);
					SendClientMessage(playerid, COLOR_LIGHTBLUE, msg);
					destroyServerGunVars(i);
				} else {
					SendClientMessage(playerid, X11_TOMATO_2, "That weapon is not ready yet!");
				}
			}
		}
	}
	return 1;
}
getCraftAmount(playerid) {
	new charid = GetPVarInt(playerid, "CharID");
	new amount = 0;
	for(new i=0;i<sizeof(WepCraftInfo);i++) {
		if(WepCraftInfo[i][pCraftSQLID] != 0) {
			if(WepCraftInfo[i][pOwnerSQLID] == charid) {
				amount++;
			}
		}
	}
	return amount;
}
destroyServerGunVars(index) {
	DestroyWepCraft(index);
	WepCraftInfo[index][pGunID] = -1;
	WepCraftInfo[index][pCraftSQLID] = 0;
	WepCraftInfo[index][pOwnerSQLID] = 0;
}
deleteCraftPVars(playerid) {
	DeletePVar(playerid, "CraftingGun");
	DeletePVar(playerid, "CraftWepType");
}
/*
wepCraftOnPayday() {
	new time = gettime();
	for(new i=0;i<sizeof(WepCraftInfo);i++) {
		if(WepCraftInfo[i][pCraftSQLID] != 0) {
			if(time-WepCraftInfo[i][pOrderTime] >= HoursToUnixTime(5)) {
				sqlUpdateCraft(i);
			}
		}
	}
}
*/
