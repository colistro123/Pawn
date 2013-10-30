/*
	PVARS Used By This Script
	VictimEvidence(int) - Stores the SQLID of the victims evidence (any kind) if the victim was shot from a close distance
	VictimEvidenceType(int) - The type of evidence being stored (EvidenceType)
	EvidenceType (int) - The type of evidence to pvar
	EvidenceOwner (int) - The evidence SQLID.
	EvidenceOwnerName (char) - The name of the original person who owns the DNA / Evidence
*/
/* Defines */
#define MAX_EVIDENCE 500
#define MAX_EVIDENCE_DESC 32
#define MAX_EVIDENCE_TIME 7200 //2 hours
#define EVIDENCE_STREAM_DIST 5.0
/* End of Defines */

enum EvidenceType {
	Evidence_FingerPrint,
	Evidence_FootPrint,
	Evidence_Blood,
	Evidence_Saliva,
	Evidence_Ammo,
	Evidence_Sweat,
	Evidence_Hair,
};
new EvidenceName[7][] = {
	{"Finger Print"},
	{"Blue Print"},
	{"Blood"},
	{"Saliva"},
	{"Bullets"},
	{"Sweat"},
	{"Hair"}
};
enum pEvidenceInfo {
	pEvidenceDesc[MAX_EVIDENCE_DESC],
	pEvidenceSQLID,
	pOwnerSQLID,
	pOwner[MAX_PLAYER_NAME],
	pEvidenceTime,//time in seconds when it was dropped
	EvidenceType:pEvidenceType,
	Float:EvidenceX,
	Float:EvidenceY, 
	Float:EvidenceZ,
	EvidenceInt,
	EvidenceVW,
	Amount,
	WeaponID,
	Text3D:EvidenceTextLabel,
};
new EvidenceInfo[MAX_EVIDENCE][pEvidenceInfo];

new Text3D:PEvidenceLabels[MAX_PLAYERS];

evidenceOnClothes(attackerid, sentvictimid, EvidenceType:EvidType) {
	new Float:X, Float:Y, Float:Z;
	GetPlayerPos(sentvictimid, X, Y, Z);
	if(IsPlayerInRangeOfPoint(attackerid, 5.0, X, Y, Z)) {
		setEvidencePVars(attackerid, sentvictimid, EvidType);
		setEvidence3dTextLabel(attackerid, EvidType);
	}
	return 1;
}
setEvidencePVars(attackerid, sentvictimid, EvidenceType:EvidType) {
	SetPVarInt(attackerid, "VictimEvidence", sentvictimid);
	SetPVarInt(attackerid, "VictimEvidenceType", _:EvidType);
	return 1;
}
deleteEvidencePVars(playerid) {
	DeletePVar(playerid, "VictimEvidence");
	DeletePVar(playerid, "VictimEvidenceType");
	new pvarstring[64];
	for(new i=0;i<MAX_EVIDENCE;i++) {
		format(pvarstring,sizeof(pvarstring),"EvidenceOwnerName%d",i);
		if(GetPVarType(playerid, pvarstring) != PLAYER_VARTYPE_NONE) {
			DeletePVar(playerid, pvarstring);
		}
		format(pvarstring,sizeof(pvarstring),"EvidenceType%d",i);
		if(GetPVarType(playerid, pvarstring) != PLAYER_VARTYPE_NONE) {
			DeletePVar(playerid, pvarstring);
		}
		format(pvarstring,sizeof(pvarstring),"EvidenceOwner%d",i);
		if(GetPVarType(playerid, pvarstring) != PLAYER_VARTYPE_NONE) {
			DeletePVar(playerid, pvarstring);
		}
		format(pvarstring,sizeof(pvarstring),"EvidenceGunID%d",i);
		if(GetPVarType(playerid, pvarstring) != PLAYER_VARTYPE_NONE) {
			DeletePVar(playerid, pvarstring);
		}
	}
	return 1;
}
setEvidence3dTextLabel(playerid, EvidenceType:EvidType) {
	destroyEvidence3dTextLabel(playerid);
	new msg[32];
	format(msg, sizeof(msg), "%s", getEvidenceNameByType(EvidType, 1, 0));
	PEvidenceLabels[playerid] = CreateDynamic3DTextLabel(msg,X11_WHITE, 0.0, 0.0, 0.0-0.5, NAMETAG_DRAW_DISTANCE,playerid,.testlos=1);
	return 1;
}
destroyEvidenceOnPlayer(playerid) {
	destroyEvidence3dTextLabel(playerid);
	deleteEvidencePVars(playerid);
	return 1;
}
destroyEvidence3dTextLabel(playerid) {
	if(PEvidenceLabels[playerid] != Text3D:0) {
		DestroyDynamic3DTextLabel(PEvidenceLabels[playerid]);
		PEvidenceLabels[playerid] = Text3D:0;
	}
	return 1;
}
dropEvidence(playerid, EvidenceType:EvidType, amount = 1, gunid = 0) {
	new index = findFreeEvidenceSlot();
	new msg[128];
	if(index == -1) {
		//Max reached! Don't add evidence, and remove the old one
		destroyAllOldEvidence();
		return 1;
	}
	new Float:X, Float:Y, Float:Z;
	new VW, Interior;
	GetPlayerPos(playerid, X, Y, Z);
	Interior = GetPlayerInterior(playerid);
	VW = GetPlayerVirtualWorld(playerid);
	//EvidenceInfo[index][pEvidenceSQLID] = id;
	EvidenceInfo[index][EvidenceX] = X;
	EvidenceInfo[index][EvidenceY] = Y;
	EvidenceInfo[index][EvidenceZ] = Z;
	EvidenceInfo[index][pEvidenceType] = EvidType;
	EvidenceInfo[index][pEvidenceTime] = gettime();
	EvidenceInfo[index][EvidenceInt] = Interior;
	EvidenceInfo[index][EvidenceVW] = VW;
	if(EvidType == Evidence_Ammo) {
		EvidenceInfo[index][Amount] = amount;	
		EvidenceInfo[index][WeaponID] = gunid;
	}
	//EvidenceInfo[index][pEvidenceFlags] = EFEvidenceFlags:0;
	format(EvidenceInfo[index][pOwner],MAX_PLAYER_NAME,"%s",GetPlayerNameEx(playerid, ENameType_RPName));
	EvidenceInfo[index][pOwnerSQLID] = GetPVarInt(playerid, "CharID");
	format(EvidenceInfo[index][pEvidenceDesc], MAX_EVIDENCE_DESC, "%s", getEvidenceNameByType(EvidType, amount, gunid));
	EvidenceInfo[index][EvidenceTextLabel] = CreateDynamic3DTextLabel(EvidenceInfo[index][pEvidenceDesc], 0x2BFF00AA, X, Y, Z-1.0, 5.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, EvidenceInfo[index][EvidenceVW],EvidenceInfo[index][EvidenceInt],-1,EVIDENCE_STREAM_DIST);
	if(EAdminFlags:GetPVarInt(playerid, "AdminFlags") & EAdminFlags_Scripter) {
		format(msg, sizeof(msg), "Evidence ID: %d",index);
		SendClientMessage(playerid, COLOR_LIGHTGREEN, msg);
	}
	return 1;
}
stock getEvidenceNameByType(EvidenceType:EvidType, amount = 1, gunid = 0) {
	new name[32];
	if(EvidType == Evidence_Ammo) {
		if(amount > 0) {
			format(name,sizeof(name),"{FFFFFF}%s shells (%d).",GunName[gunid],amount);
		} else {
			format(name,sizeof(name),"{FFFFFF}%s shells.",GunName[gunid]);
		}
	} else if(EvidType == Evidence_Blood) {
		format(name,sizeof(name),"{FF0000}Blood Stain");
	} else {
		format(name,sizeof(name),"{FFFFFF}%s", EvidenceName[_:EvidType]);
	}
	return name;
}
findFreeEvidenceSlot() {
	for(new i=0;i<sizeof(EvidenceInfo);i++) {
		if(EvidenceInfo[i][pOwnerSQLID] == 0) {
			return i;
		}
	}
	return -1;
}
findOldEvidence() {
	new time = gettime();
	for(new i=0;i<sizeof(EvidenceInfo);i++) {
		if(time-EvidenceInfo[i][pEvidenceTime] >= MAX_EVIDENCE_TIME) {
			return i;
		}
	}
	return -1;
}
destroyAllOldEvidence() {
	new index;
	for(new i=0;i<sizeof(EvidenceInfo);i++) {
		index = findOldEvidence();
		if(index != -1) {
			destroyEvidence(index);
		}
	}
}
destroyEvidence(index) {
	EvidenceInfo[index][pOwnerSQLID] = 0;
	EvidenceInfo[index][pEvidenceTime] = 0;
	//EvidenceInfo[index][pEvidenceSQLID] = 0;
	DestroyDynamic3DTextLabel(EvidenceInfo[index][EvidenceTextLabel]);
	EvidenceInfo[index][EvidenceTextLabel] = Text3D:0;
}
getClosestEvidenceID(playerid) {
	for(new i=0;i<sizeof(EvidenceInfo);i++) {
		if(IsPlayerInRangeOfPoint(playerid, 5.0, EvidenceInfo[i][EvidenceX], EvidenceInfo[i][EvidenceY], EvidenceInfo[i][EvidenceZ])) {
			if(EvidenceInfo[i][pOwnerSQLID] != 0) {
				return i;
			}
		}
	}
	return -1;
}
putEvidenceInBag(playerid, index) {
	new pvarindex = getEvidencePVarIndex(playerid);
	new indexformat[64];
	format(indexformat,sizeof(indexformat),"EvidenceType%d",pvarindex);
	SetPVarInt(playerid,indexformat,_:EvidenceInfo[index][pEvidenceType]); // save the string into a player variable
	format(indexformat,sizeof(indexformat),"EvidenceOwner%d",pvarindex);
	SetPVarInt(playerid,indexformat,EvidenceInfo[index][pOwnerSQLID]); // save the string into a player variable
	format(indexformat,sizeof(indexformat),"EvidenceOwnerName%d",pvarindex);
	SetPVarString(playerid,indexformat,EvidenceInfo[index][pOwner]); // save the string into a player variable this is the owner name
	format(indexformat,sizeof(indexformat),"EvidenceGunID%d",pvarindex);
	SetPVarInt(playerid,indexformat,EvidenceInfo[index][WeaponID]); // save the string into a player variable this is the weapon id
	SetPVarInt(playerid, "EvidenceIndex", pvarindex+1);
}
getEvidencePVarIndex(playerid) {
	if(GetPVarType(playerid, "EvidenceIndex") != PLAYER_VARTYPE_NONE) {
		new evidenceindex = GetPVarInt(playerid, "EvidenceIndex");
		return evidenceindex;
	}
	return 0;
}
showAllEvidence(playerid) {
	new textstring[128];
	new msg[128];
	new pvarstring[24];
	new pvarstringtype[24];
	new SEvidType, SGunID;
	SendClientMessage(playerid, COLOR_WHITE, "|__________________ Evidence __________________|");
	for(new i=0;i<MAX_EVIDENCE;i++) {
		format(pvarstring,sizeof(pvarstring),"EvidenceOwnerName%d",i);
		if(GetPVarType(playerid, pvarstring) != PLAYER_VARTYPE_NONE) {
			GetPVarString(playerid, pvarstring, msg, MAX_PLAYER_NAME);
			format(pvarstringtype,sizeof(pvarstringtype),"EvidenceType%d",i);
			SEvidType = GetPVarInt(playerid, pvarstringtype);
			format(pvarstringtype,sizeof(pvarstringtype),"EvidenceGunID%d",i);
			if(GetPVarType(playerid, pvarstringtype) != PLAYER_VARTYPE_NONE) {
				SGunID = GetPVarInt(playerid, pvarstringtype);
			} else {
				SGunID = 0;
			}
			format(textstring, sizeof(textstring), "Evidence Owner: %s Type: %s", msg, getEvidenceNameByType(EvidenceType:SEvidType, 0, SGunID));
			SendClientMessage(playerid, X11_WHITE, textstring);
		}
	}
	SendClientMessage(playerid, COLOR_WHITE, "|______________________________________________|");
	return 1;
}
checkEvidenceOnPlayer(playerid, targetid) {
	if(GetPVarType(targetid, "VictimEvidence") == PLAYER_VARTYPE_NONE) {
		SendClientMessage(playerid, X11_TOMATO_2, "There's no evidence on this person's clothes");
		return 1;
	}
	new msg[128];
	new victimsblood = GetPVarInt(targetid, "VictimEvidence");
	format(msg,sizeof(msg),"The blood on this cloth belongs to: %s",GetPlayerNameEx(victimsblood, ENameType_RPName));
	SendClientMessage(playerid, X11_WHITE, msg);
	destroyEvidenceOnPlayer(playerid);
	return 1;
}
evidenceOnPlayerDisconnect(playerid) {
	destroyEvidenceOnPlayer(playerid);
	return 1;
}
/* Commands */

YCMD:viewevidence(playerid, params[], help) {
	if(help) {
		SendClientMessage(playerid, X11_WHITE, "Allows you to examine the evidence you've picked up");
		return 1;
	}
	if(!IsAnLEO(playerid)) {
		SendClientMessage(playerid, X11_TOMATO_2, "You are not a LEO Officer!");
		return 1;
	}
	if(!IsAtDutySpot(playerid)) {
		SendClientMessage(playerid, X11_TOMATO_2, "You need to be at your duty spot to check the evidence!");
		return 1;
	}
	showAllEvidence(playerid);
	return 1;
}
YCMD:viewevidenceonplayer(playerid, params[], help) {
	if(help) {
		SendClientMessage(playerid, X11_WHITE, "Allows you to examine evidence on a player");
		return 1;
	}
	if(!IsAnLEO(playerid)) {
		SendClientMessage(playerid, X11_TOMATO_2, "You are not a LEO Officer!");
		return 1;
	}
	if(!IsAtDutySpot(playerid)) {
		SendClientMessage(playerid, X11_TOMATO_2, "You need to be at your duty spot to check the evidence on this person!");
		return 1;
	}
	new user;
	if(!sscanf(params, "k<playerLookup>", user)) {
		if(!IsPlayerConnectEx(user)) {
			SendClientMessage(playerid, X11_TOMATO_2, "User not found");
			return 1;
		}
		new Float:X, Float:Y, Float:Z;
		GetPlayerPos(user, X, Y, Z);
		if(!IsPlayerInRangeOfPoint(playerid, 2.5, X, Y, Z)) {
			SendClientMessage(playerid, X11_TOMATO_2, "You are too far away from this person!");
			return 1;
		}
		if(IsPlayerInAnyVehicle(user) && GetPlayerState(playerid) == PLAYER_STATE_ONFOOT) {
			SendClientMessage(playerid, X11_TOMATO_2, "This person is inside a vehicle, the person must be on foot!");
			return 1;
		}
		checkEvidenceOnPlayer(playerid, user);
	} else {
		SendClientMessage(playerid, X11_WHITE, "USAGE: /viewevidenceonplayer [playerid/name]");
	}
	return 1;
}
YCMD:pickevidence(playerid, params[], help) {
	if(help) {
		SendClientMessage(playerid, X11_WHITE, "Allows you to pick up evidence");
		return 1;
	}
	if(!IsAnLEO(playerid)) {
		SendClientMessage(playerid, X11_TOMATO_2, "You are not a LEO Officer!");
		return 1;
	}
	new index = getClosestEvidenceID(playerid);
	new msg[128];
	if(index != -1) {
		ApplyAnimation(playerid, "BOMBER","BOM_Plant_In",4.0,0,0,0,0,0);
		format(msg, sizeof(msg), "* %s picks up some evidence and carefully places it into a plastic bag.", GetPlayerNameEx(playerid,ENameType_RPName));
		ProxMessage(25.0, playerid, msg, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
		putEvidenceInBag(playerid, index);
		destroyEvidence(index);
		if(EAdminFlags:GetPVarInt(playerid, "AdminFlags") & EAdminFlags_Scripter) {
			format(msg, sizeof(msg), "Evidence ID: %d",index);
			SendClientMessage(playerid, COLOR_LIGHTGREEN, msg);
		}
	} else {
		SendClientMessage(playerid, X11_TOMATO_2, "You are not near any evidence!");
	}
	return 1;
}
YCMD:takeshower(playerid, params[], help) {
	if(help) {
		SendClientMessage(playerid, X11_WHITE, "Allows you to take a shower when inside a house.");
	}
	new house = getStandingExit(playerid, 150.0);
	if(house == -1) {
		SendClientMessage(playerid, X11_TOMATO_2, "You aren't in a house!");
		return 1;
	}
	SendClientMessage(playerid, COLOR_LIGHTBLUE, "You took a shower and you feel much better now!");
	destroyEvidenceOnPlayer(playerid);
	return 1;
}
