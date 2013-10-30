enum EWepDamageType {
	EDamageType_Melee,
	EDamageType_Weapon,
	EDamageType_Rifle
};
enum eWepDamage {
	weapon,
	Float:damage,
	EWepDamageType:EDamageWeaponType,
	Float:PushVelocity,
	MaxTimes,
	TimeFreeze,
};
new WeaponDamage[][eWepDamage] = {
	{3, 30.0, EDamageType_Melee, 0.0, -1, -1}, //3
	{4, 40.0, EDamageType_Melee, 0.0, -1, -1}, //4
	{5, 30.0, EDamageType_Melee, 0.0, -1, -1}, //5
	{8, 40.0, EDamageType_Melee, 0.0, -1, -1}, //5
	{22, 40.0, EDamageType_Weapon, 0.025, 3, 250}, //22
	{23, 30.0, EDamageType_Weapon, 0.025, 3, 250}, //23
	{24, 96.0, EDamageType_Weapon, 0.025, 2, 550}, //24
	{25, 149.0, EDamageType_Weapon, 0.25, 2, 550}, //25
	{27, 109.0, EDamageType_Weapon, 0.25, 3, 550}, //27
	{28, 16.0, EDamageType_Weapon, 0.025, 5, 250}, //28
	{29, 26.0, EDamageType_Weapon, 0.025, 4, 250}, //29
	{30, 49.0, EDamageType_Weapon, 0.025, 3, 550}, //30
	{31, 44.0, EDamageType_Weapon, 0.025, 5, 250}, //31
	{33, 59.0, EDamageType_Rifle, 0.025, 2, 550}, //33
	{34, 341.0, EDamageType_Rifle, 0.025, 2, 550} //34
};

enum eWepSounds {
	weapon,
	link[128],
};
new WeaponSounds[][eWepSounds] = {
	{3, "-1"}, //22
	{4, "-1"}, //22
	{5, "-1"}, //22
	{22, "http://www.inglewoodrp.com/audio/gunsounds/p99_fire1.wav"}, //22
	{23, "http://www.inglewoodrp.com/audio/gunsounds/p99_fire_sil1.wav"}, //23
	{24, "http://www.inglewoodrp.com/audio/gunsounds/raptor_fire1.wav"}, //24
	{25, "http://www.inglewoodrp.com/audio/gunsounds/frinesi_fire.wav"}, //25
	{27, "http://www.inglewoodrp.com/audio/gunsounds/frinesi_fire.wav"}, //27
	{28, "http://www.inglewoodrp.com/audio/gunsounds/mp9_fire1.wav"}, //28
	{29, "http://www.inglewoodrp.com/audio/gunsounds/p90_fire2.wav"}, //29
	{30, "http://www.inglewoodrp.com/audio/gunsounds/sig552_fire3.wav"}, //30
	{31, "http://www.inglewoodrp.com/audio/gunsounds/sig552_fire3.wav"}, //31
	{33, "http://www.inglewoodrp.com/audio/gunsounds/l96_fire1.wav"}, //33
	{34, "http://www.inglewoodrp.com/audio/gunsounds/sniper_fire.wav"} //34
};
new Text3D:WoundedLabels[MAX_PLAYERS];

damageOnGameModeInit() {
	for(new i=0;i<MAX_PLAYERS;i++) {
		WoundedLabels[i] = Text3D:0;
	}
}

damageSystemOnPlayerTakeDamage(playershot, shooter, Float:amount, wep) {
	if(!isInPaintball(playershot) || !isPlayerDying(shooter) || GetPVarType(shooter, "HasTaser") == PLAYER_VARTYPE_NONE) {
		for(new wepid; wepid < sizeof(WeaponDamage); wepid++) {
			if (WeaponDamage[wepid][weapon] == wep) {
				decideWepAssign(WeaponDamage[wepid][EDamageWeaponType], playershot, shooter, amount, wepid);
			}
		}
	}
	return 1;
}
Float:factorBulletPower(playerid, shooterid) {
	new Float: X, Float: Y, Float: Z;
	GetPlayerPos(shooterid, X, Y, Z);
	new Float: BPDistance = GetPlayerDistanceFromPoint(playerid, X, Y, Z);
	return BPDistance;
}
Float:factorBulletSpeed(playerid, shooterid) {
	new Float: X, Float: Y, Float: Z;
	GetPlayerPos(shooterid, X, Y, Z);
	new Float: BPDistance = GetPlayerDistanceFromPoint(playerid, X, Y, Z);
	return BPDistance/9;
}
decideWepAssign(EWepDamageType:wepType, playershotid, shooterid, Float:dmgamount, gunid) {
	switch(wepType) {
		case EDamageType_Weapon: {
			if(isValidShootingDistance(playershotid, shooterid)) {
				authorizeWepDamage(playershotid, shooterid, dmgamount, gunid);
			}						
		}
		case EDamageType_Rifle: {
			if(isValidShootingDistance(playershotid, shooterid)) {
				authorizeWepDamage(playershotid, shooterid, dmgamount, gunid);
			}						
		}
		case EDamageType_Melee: {
			authorizeWepDamage(playershotid, shooterid, dmgamount, gunid);
		}
	}
	return 1;
}
stock gunDamagePushPlayer(playerid, shooterid, Float:distance) {
	new Float:X,Float:Y,Float:Z,Float:Angle;
	GetPlayerVelocity(playerid,X,Y,Z);
	GetPlayerFacingAngle(playerid,Angle);
	X += ( distance * floatsin( Angle, degrees ) );
	Y += ( distance * floatcos( Angle, degrees ) );
	if(isValidShootingDistance(playerid, shooterid)) {
		if(Angle > 180) {
			SetPlayerVelocity(playerid,-X,-Y,Z+distance);
		} else {
			SetPlayerVelocity(playerid,X,Y,Z+distance);
		}
	}
	return 1;
}
authorizeWepDamage(player, shooterid, Float:damageamount, wepid) {
	new Float:bulletpower, Float:bulletspeed, Float:bulletpowercalc, Float:bulletdamagecalc;
	//new EAccountFlags:aflags = EAccountFlags:GetPVarInt(player, "AccountFlags");
	bulletpower = factorBulletPower(player, shooterid);
	bulletspeed = factorBulletSpeed(player, shooterid);
	bulletpowercalc = WeaponDamage[wepid][PushVelocity]/bulletpower;
	switch(WeaponDamage[wepid][EDamageWeaponType]) {
		case EDamageType_Weapon: {
			bulletdamagecalc = WeaponDamage[wepid][damage]/bulletspeed;
		}
		case EDamageType_Rifle: {
			bulletdamagecalc = WeaponDamage[wepid][damage];
		}
		case EDamageType_Melee: {
			bulletdamagecalc = WeaponDamage[wepid][damage];
		}
	}
	revertWepDamageBeforeDamage(player, damageamount);
	/* Small Error Handling */
	if(bulletdamagecalc > WeaponDamage[wepid][damage]) { //Sometimes the divisions turn positive due to dividing a greater number by a lower one like 0.0...
		bulletdamagecalc = WeaponDamage[wepid][damage]; //So we just set it to the default damage for that single bullet in-case that happens
	}
	doWepDamage(player, bulletdamagecalc, wepid);
	gunDamagePushPlayer(player, shooterid, bulletpowercalc);
	setAttackerID(player, shooterid);
	sendGunSoundToInteriors(shooterid, wepid);
	/*
	if(aflags & EAccountFlags_ShowRedScreen) {
		colorScreen(player, 1, 4278190267);
		SetTimerEx("colorScreen",1000, false, "ddd",player,0,0);
	}
	*/
	//printf("BulletPowerCalc: %f", bulletpowercalc);
	//printf("BulletDamageCalc: %f", bulletdamagecalc);
}
setAttackerID(playerid, shooterid) {
	SetPVarInt(playerid, "AttackerID", shooterid);
}
getAttackerID(playerid) {
	if(GetPVarType(playerid, "AttackerID") != PLAYER_VARTYPE_NONE) {
		new returnattackerid = GetPVarInt(playerid, "AttackerID");
		return returnattackerid;
	}
	return -1;
}
dropPlayerFromBike(damagedid, wepid) {
	new Float:X, Float:Y, Float:Z;
	if(!IsPlayerBlocked(damagedid)) {
		if(WeaponDamage[wepid][EDamageWeaponType] != EDamageType_Melee) {
			if(IsPlayerInAnyVehicle(damagedid)) {
				new vehid = GetPlayerVehicleID(damagedid);
				new model = GetVehicleModel(vehid);
				if(IsABike(model) || IsABicycle(model)) {
					GetPlayerPos(damagedid,X,Y,Z);
					SetPlayerPos(damagedid, X, Y, Z+0.5);
				}
			}
		}
	}
}
revertWepDamageBeforeDamage(damagedid, Float:amountreset) {
	new Float:health;
	new Float:armour;
	GetPlayerHealth(damagedid, health);
	GetPlayerArmour(damagedid, armour);
	if(armour > 1 && armour <= MAX_ARMOUR) {
		SetPlayerArmourEx(damagedid, armour+amountreset);
	} else {
		if(health <= MAX_HEALTH) {
			SetPlayerHealthEx(damagedid, health+amountreset);
		}
	}
}
doWepDamage(damagedid, Float:amount, wepid) {
	new Float:health;
	new Float:armour;
	GetPlayerHealth(damagedid, health);
	GetPlayerArmour(damagedid, armour);
	if(armour > 1 && armour <= MAX_ARMOUR) {
		SetPlayerArmourEx(damagedid, armour-amount);
	} else {
		SetPlayerArmourEx(damagedid, 0);
		SetPlayerHealthEx(damagedid, health-amount);
	}
	tryToApplyHurt(damagedid, wepid, health, armour);
	dropPlayerFromBike(damagedid, wepid);
	wobbleScreenForPlayer(damagedid, 500, 64000); //clientid, time in ms, drunkLevelamount
}
tryToApplyHurt(damagedid, wepid, Float:health, Float:armour) {
	#pragma unused health
	if(armour < 34.0) {
		if(WeaponDamage[wepid][EDamageWeaponType] != EDamageType_Melee) {
			setPlayerHurt(damagedid, wepid);
		}
	}
	return 1;
}
/*
tryToApplyHurt(damagedid, wepid, Float:health, Float:armour) {
	if(health < 55.0) {
		if(armour < 34.0) {
			if(WeaponDamage[wepid][EDamageWeaponType] != EDamageType_Melee) {
				setPlayerHurt(damagedid, wepid);
			}
		}
	}
	return 1;
}
*/
setPlayerHurt(damagedid, wep) {
	SetPVarInt(damagedid, "ShotReason", WeaponDamage[wep][weapon]);
	if(getPlayerTimesShot(damagedid) < getMaxRoundsToHurt(wep)) {
		setPlayerTimesShot(damagedid, 1); //Shot one time
	} else {
		makePlayerWounded(damagedid, 1);
	}
}
wobbleScreenForPlayer(damagedid, mstime, amount) {
	new dizzylevel = GetPlayerDrunkLevel(damagedid);
	if(GetPVarType(damagedid, "OldDrunkLevel") != PLAYER_VARTYPE_NONE) {
		SetPVarInt(damagedid, "OldDrunkLevel", dizzylevel);
	}
	SetPlayerDrunkLevel(damagedid, dizzylevel+amount);
	SetTimerEx("stopScreenWobble",mstime, false, "d",damagedid);
}
forward stopScreenWobble(damagedid);
public stopScreenWobble(damagedid) {
	if(GetPVarType(damagedid, "OldDrunkLevel") != PLAYER_VARTYPE_NONE) {
		new OldDLevel = GetPVarInt(damagedid, "OldDrunkLevel");
		SetPlayerDrunkLevel(damagedid, OldDLevel);
		DeletePVar(damagedid, "OldDrunkLevel");
	} else {
		SetPlayerDrunkLevel(damagedid, 0);
	}
	return 1;
}
YCMD:togwounded(playerid, params[], help) {
	if(help) {
		SendClientMessage(playerid, X11_WHITE, "Toggle wounded on a person");
		return 1;
	}
	new target, status;
	if(!sscanf(params, "k<playerLookup>D(-1)", target,status)) {
		if(!IsPlayerConnectEx(target)) {
			SendClientMessage(playerid, X11_TOMATO_2, "User not found");
			return 1;
		}
		if((status == -1 && isPlayerWounded(target)) || status == 0) {
			makePlayerWounded(target, 0);
			SendClientMessage(playerid, COLOR_GREEN, "Wounded Status removed");
		} else {
			setPlayerTimesShot(target, 1);
			makePlayerWounded(target, 1);
			SendClientMessage(playerid, COLOR_GREEN, "Wounded Status set");
		}
	} else {
		SendClientMessage(playerid, X11_WHITE, "USAGE: /togwounded [playerid]");
	}
	return 1;
	
}
forward makePlayerWounded(damagedid, hurt);
public makePlayerWounded(damagedid, hurt) {
	if(hurt == 1) {
		if(!IsPlayerInAnyVehicle(damagedid)) {
			TogglePlayerControllableEx(damagedid, 0);
			ApplyAnimation(damagedid, "WUZI", "CS_DEAD_GUY", 4.0, 1, 1, 1, 1, 1, 1);
			ShowScriptMessage(damagedid, "You're ~r~ wounded~w~. Someone must help you up.",3000);
			setWounded3dTextLabel(damagedid, 1);
			SetPVarInt(damagedid, "DownOnGround", 1);
			SetPlayerArmedWeapon(damagedid, 0);
		}
		doEvidenceDropFromDamage(damagedid);
	} else {
		if(isPlayerDying(damagedid)) {
			ShowScriptMessage(damagedid, "You're very weak right now, you ~r~can't~w~ stand back up!.",3000);
			return 1;
		}
		clearTimesShot(damagedid);
		TogglePlayerControllableEx(damagedid, 1);
		destroyWounded3dTextLabel(damagedid);
		if(!IsPlayerInAnyVehicle(damagedid)) {
			ApplyAnimation(damagedid,"PED","getup",4.0,0,0,0,0,0,1);
		}
	}
	return 1;
}
doEvidenceDropFromDamage(damagedid) {
	new attackerid = getAttackerID(damagedid);
	new gunid = GetPVarInt(damagedid, "ShotReason");
	new amount = getPlayerTimesShot(damagedid);
	evidenceOnClothes(attackerid, damagedid, Evidence_Blood);
	dropEvidence(damagedid, Evidence_Blood);
	dropEvidence(attackerid, Evidence_Ammo, amount, gunid); /* I highly dislike this repetitive statement */
	sendGunShotToHAndBizzes(attackerid);
}
sendGunShotToHAndBizzes(attackerid) {
	new string[128];
	format(string, sizeof(string), "** You hear gun shots coming from outside **");
	sendMessageToHouses(attackerid, 60.0, string, COLOR_PURPLE);
	sendMessageToBusinesses(attackerid, 60.0, string, COLOR_PURPLE);
}
sendGunSoundToInteriors(shooterid, wepid) {
	if(WeaponSounds[wepid][weapon] >= 22) {
		sendAreaSound(shooterid, 60.0, WeaponSounds[wepid][link], 1);
	}
}
sendAreaSound(playerid, Float:radi = 30.0, url[], interiors = 1) {
	if(interiors == 1) {
		for(new i=0;i<sizeof(Business);i++) {
			if(IsPlayerInRangeOfPoint(playerid, radi, Business[i][EBusinessEntranceX],Business[i][EBusinessEntranceY],Business[i][EBusinessEntranceZ])) {
				sendAreaSoundXYZ(url, Business[i][EBusinessExitX],Business[i][EBusinessExitY],Business[i][EBusinessExitZ], Business[i][EBusinessVW], radi);
			}
		}
		for(new i=0;i<sizeof(Houses);i++) {
			if(IsPlayerInRangeOfPoint(playerid, radi, Houses[i][EHouseX],Houses[i][EHouseY],Houses[i][EHouseZ])) {
				sendAreaSoundXYZ(url, Houses[i][EHouseX], Houses[i][EHouseY], Houses[i][EHouseZ], houseGetVirtualWorld(i), radi);
			}
		}
	} else {
		new Float: X, Float: Y, Float: Z;
		new VW = GetPlayerVirtualWorld(playerid);
		GetPlayerPos(playerid, X, Y, Z);
		foreach(Player, i) {
			if(IsPlayerInRangeOfPoint(i, radi, X, Y, Z)) {
				if(GetPlayerVirtualWorld(i) == VW) {
					PlayAudioStreamForPlayer(i, url,X,Y,Z,radi,1);
				}
			}
		}
	}
	return 1;
}
isPlayerWounded(damagedid) {
	if(GetPVarType(damagedid, "DownOnGround") != PLAYER_VARTYPE_NONE) {
		return 1;
	}
	return 0;
}
isPlayerOnGround(damagedid) {
	if(GetPVarType(damagedid, "DownOnGround") != PLAYER_VARTYPE_NONE) {
		return 1;
	}
	return 0;
}
setPlayerTimesShot(damagedid, times) {
	new amount = getPlayerTimesShot(damagedid)+times;
	SetPVarInt(damagedid, "TimesShot", amount);
}
getMaxRoundsToHurt(wepid) {
	new maxroundstohurt = WeaponDamage[wepid][MaxTimes];
	return maxroundstohurt;
}
getPlayerTimesShot(damagedid) {
	if(GetPVarType(damagedid, "TimesShot") != PLAYER_VARTYPE_NONE) {
		new TimesShot = GetPVarInt(damagedid, "TimesShot");
		return TimesShot;
	} else {
		return 0;
	}
}
clearTimesShot(damagedid) {
	TogglePlayerControllableEx(damagedid, 1);
	DeletePVar(damagedid, "TimesShot");
	DeletePVar(damagedid, "ShotReason");
	DeletePVar(damagedid, "DownOnGround");
	DeletePVar(damagedid, "AttackerID");
}
isValidShootingDistance(damagedid, shooterid) {
	new Float: X, Float: Y, Float: Z;
	GetPlayerPos(damagedid, X, Y, Z);
	new Float: SDistance = GetPlayerDistanceFromPoint(shooterid, X, Y, Z);
	//printf("%f",SDistance);
	if(SDistance > 1.0) {
		return 1;
	}
	return 0;
}

YCMD:helpup(playerid, params[], help) {
	new Float:X, Float:Y, Float:Z, target;
	if(!sscanf(params, "k<playerLookup>", target)) {
		if(!IsPlayerConnectEx(target)) {
			SendClientMessage(playerid, X11_TOMATO_2, "User not found");
			return 1;
		}
		if(target == playerid && ~EAdminFlags:GetPVarInt(playerid, "AdminFlags") & EAdminFlags_BasicAdmin) {
			SendClientMessage(playerid, X11_TOMATO_2, "You cannot stand up by yourself wait for someone to help you up or ask for help!");
			return 1;
		}
		if(isPlayerWounded(playerid)) {
			SendClientMessage(playerid, X11_TOMATO_2, "You cannot help someone stand up while you're injured!");
			return 1;
		}
		if(!isPlayerWounded(target)) {
			SendClientMessage(playerid, X11_TOMATO_2, "This person is not wounded!");
			return 1;
		}
		if(isPlayerDying(target)) {
			SendClientMessage(playerid, X11_TOMATO_2, "This person is dying, you cannot help them up.");
			return 1;
		}
		GetPlayerPos(target, X, Y, Z);
		if(!IsPlayerInRangeOfPoint(playerid, 2.5, X, Y, Z) || GetPlayerVirtualWorld(playerid) != GetPlayerVirtualWorld(target)) {
			SendClientMessage(playerid, X11_TOMATO_2, "You must be around this person!");
			return 1;
		}
		if(IsPlayerInAnyVehicle(target)) {
			SendClientMessage(playerid, X11_TOMATO_2, "The person you are trying to help is inside a vehicle!");
			return 1;
		}
		new str[128];
		format(query, sizeof(query), "* You helped %s stand up.",GetPlayerNameEx(target, ENameType_RPName));
		SendClientMessage(playerid, COLOR_LIGHTBLUE, query);
		format(query, sizeof(query), "* %s helped you stand up.",GetPlayerNameEx(playerid, ENameType_RPName));
		SendClientMessage(target, COLOR_LIGHTBLUE, query);
		format(str, sizeof (str), "%s gets close to %s and helps %s stand up", GetPlayerNameEx(playerid, ENameType_RPName), GetPlayerNameEx(target, ENameType_RPName), GetPlayerNameEx(target, ENameType_RPName));
		ProxMessage(30.0,playerid, str, COLOR_PURPLE, COLOR_PURPLE, COLOR_PURPLE, COLOR_PURPLE, COLOR_PURPLE);
		makePlayerWounded(target, 0);
	} else {
		SendClientMessage(playerid, X11_WHITE, "USAGE: /helpup [playerid]");
	}
	return 1;
}
/*
getPlayerWounded3dLabelText(playerid) {
	new ret[128];
	new gunid = GetPVarInt(playerid, "ShotReason");
	format(ret, sizeof(ret), "Critically Wounded! (( /helpup [%d] ))", GetPVarInt(playerid,"MaskOn")?GetPVarInt(playerid, "MaskID"):playerid);
	return ret;
}
*/
getPlayerWounded3dLabelText(playerid) {
	new ret[128];
	new gunid = GetPVarInt(playerid, "ShotReason");
	format(ret, sizeof(ret), "Critically Wounded! (( /helpup [%d] ))\n %d %s rounds.", playerid, getPlayerTimesShot(playerid), GunName[gunid]);
	return ret;
}
setWounded3dTextLabel(playerid, status) {
	destroyWounded3dTextLabel(playerid);
	if(status == 1) {
		if(isPlayerWounded(playerid)) {
			if(WoundedLabels[playerid] == Text3D:0) {
				WoundedLabels[playerid] = CreateDynamic3DTextLabel(getPlayerWounded3dLabelText(playerid),X11_WHITE, 0.0, 0.0, 0.4, NAMETAG_DRAW_DISTANCE,playerid,.testlos=1);
			}
		}
	} else {
		destroyWounded3dTextLabel(playerid);
	}
	SetPVarInt(playerid, "WoundedLabel", status);
}
destroyWounded3dTextLabel(playerid) {
	if(WoundedLabels[playerid] != Text3D:0) {
		DestroyDynamic3DTextLabel(WoundedLabels[playerid]);
		WoundedLabels[playerid] = Text3D:0;
		DeletePVar(playerid, "WoundedLabel");
	}
}
damageSystemOnPlayerUpdate(playerid) {
	#pragma unused playerid
	/*
	if(WoundedLabels[playerid] != Text3D:0) {
		UpdateDynamic3DTextLabelText(WoundedLabels[playerid],X11_TOMATO_2,getPlayerWounded3dLabelText(playerid));
	}
	*/
}
damageSystemOnPlayerDeath(playerid, killerid, reason) {
	#pragma unused reason
	#pragma unused killerid
	clearTimesShot(playerid);
	destroyWounded3dTextLabel(playerid);
}
damageSystemOnPlayerDisconnect(playerid, reason) {
	#pragma unused reason
	destroyWounded3dTextLabel(playerid);
}
