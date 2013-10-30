enum ETypeApartments {
	Ghetto_Apt,
};
enum EApartmentInfo {
	Float:EApartmentX,
	Float:EApartmentY,
	Float:EApartmentZ,
	Float:EApartmentExitX,
	Float:EApartmentExitY,
	Float:EApartmentExitZ,
	EApartmentInterior,
	EApartmentName[64],
	EApartmentSQLID,
	EApartmentPickup,
	EApartmentLocked,
	Text3D:EApartmentTextLabel,
};
enum EApartmentIntType {
	Float: EIntApartmentXDoor,
	Float: EIntApartmentYDoor,
	Float: EIntApartmentZDoor,
	ETypeApartments:IntType,
	ETypeApDesc[32],
	EIntInteriorID,
}
new ApartmentIntType[][EApartmentIntType] = {
	{1699.71, -1589.19, -3.58, Ghetto_Apt, "Ghetto Apartment", 40}
};
#define MAX_APARTMENTS 2000
new Apartments[MAX_APARTMENTS][EApartmentInfo];
forward OnLoadApartments();
forward ReloadApartment(apartmentid);

apartmentsOnGameModeInit() {
	loadApartments();
	loadApartmentMapping();
}
loadApartmentMapping() {
	//Ghetto Apartment Interior
	//VW -1 (So it streams to all vw's) Int, 40.
	CreateDynamicObject(9946, 1701.49, -1606.18, -4.34,   0.00, 0.00, 0.00, -1, 40); //Create a solid ground so the players don't fall when going in
	CreateDynamicObject(9946, 1701.49, -1606.18, -0.62,   0.00, 180.00, 0.00, -1, 40); //Create a solid ground so the players don't fall when going in
	CreateDynamicObject(19368, 1697.15, -1587.54, -2.48,   0.00, 0.00, 0.00, -1, 40);
	CreateDynamicObject(19368, 1697.15, -1590.75, -2.48,   0.00, 0.00, 0.00, -1, 40);
	CreateDynamicObject(19368, 1697.15, -1584.33, -2.48,   0.00, 0.00, 0.00, -1, 40);
	CreateDynamicObject(19368, 1702.15, -1587.54, -2.48,   0.00, 0.00, 0.00, -1, 40);
	CreateDynamicObject(19368, 1702.15, -1584.33, -2.48,   0.00, 0.00, 0.00, -1, 40);
	CreateDynamicObject(19368, 1702.15, -1590.75, -2.48,   0.00, 0.00, 0.00, -1, 40);
	CreateDynamicObject(19368, 1697.15, -1593.96, -2.48,   0.00, 0.00, 0.00, -1, 40);
	CreateDynamicObject(19368, 1702.15, -1593.96, -2.48,   0.00, 0.00, 0.00, -1, 40);
	CreateDynamicObject(19368, 1702.15, -1597.16, -2.48,   0.00, 0.00, 0.00, -1, 40);
	CreateDynamicObject(19368, 1697.15, -1597.16, -2.48,   0.00, 0.00, 0.00, -1, 40);
	CreateDynamicObject(19368, 1702.15, -1600.36, -2.48,   0.00, 0.00, 0.00, -1, 40);
	CreateDynamicObject(19368, 1702.15, -1603.58, -2.48,   0.00, 0.00, 0.00, -1, 40);
	CreateDynamicObject(19368, 1700.46, -1587.81, -2.48,   0.00, 0.00, 90.00, -1, 40);
	CreateDynamicObject(19368, 1707.06, -1605.09, -2.48,   0.00, 0.00, 90.00, -1, 40);
	CreateDynamicObject(19368, 1697.15, -1600.36, -2.48,   0.00, 0.00, 0.00, -1, 40);
	CreateDynamicObject(19368, 1710.27, -1605.09, -2.48,   0.00, 0.00, 90.00, -1, 40);
	CreateDynamicObject(19368, 1713.48, -1605.09, -2.48,   0.00, 0.00, 90.00, -1, 40);
	CreateDynamicObject(19368, 1703.84, -1609.09, -2.48,   0.00, 0.00, 90.00, -1, 40);
	CreateDynamicObject(19368, 1707.06, -1609.09, -2.48,   0.00, 0.00, 90.00, -1, 40);
	CreateDynamicObject(19368, 1710.27, -1609.09, -2.48,   0.00, 0.00, 90.00, -1, 40);
	CreateDynamicObject(19368, 1713.48, -1609.09, -2.48,   0.00, 0.00, 90.00, -1, 40);
	CreateDynamicObject(19368, 1715.00, -1606.79, -2.48,   0.00, 0.00, 180.00, -1, 40);
	CreateDynamicObject(19368, 1715.00, -1610.00, -2.48,   0.00, 0.00, 180.00, -1, 40);
	CreateDynamicObject(19368, 1702.15, -1610.61, -2.48,   0.00, 0.00, 0.00, -1, 40);
	CreateDynamicObject(19368, 1702.15, -1613.82, -2.48,   0.00, 0.00, 0.00, -1, 40);
	CreateDynamicObject(19368, 1702.15, -1617.03, -2.48,   0.00, 0.00, 0.00, -1, 40);
	CreateDynamicObject(19368, 1697.15, -1603.58, -2.48,   0.00, 0.00, 0.00, -1, 40);
	CreateDynamicObject(19368, 1697.15, -1606.79, -2.48,   0.00, 0.00, 180.00, -1, 40);
	CreateDynamicObject(19368, 1697.15, -1610.00, -2.48,   0.00, 0.00, 180.00, -1, 40);
	CreateDynamicObject(19368, 1697.15, -1613.82, -2.48,   0.00, 0.00, 0.00, -1, 40);
	CreateDynamicObject(19368, 1697.15, -1610.61, -2.48,   0.00, 0.00, 0.00, -1, 40);
	CreateDynamicObject(19368, 1697.15, -1617.03, -2.48,   0.00, 0.00, 0.00, -1, 40);
	CreateDynamicObject(19368, 1697.15, -1620.24, -2.48,   0.00, 0.00, 0.00, -1, 40);
	CreateDynamicObject(19368, 1702.15, -1620.24, -2.48,   0.00, 0.00, 0.00, -1, 40);
	CreateDynamicObject(19368, 1703.84, -1605.09, -2.48,   0.00, 0.00, 90.00, -1, 40);
	CreateDynamicObject(19368, 1687.53, -1623.44, -2.48,   0.00, 0.00, 0.00, -1, 40);
	CreateDynamicObject(19368, 1697.43, -1625.14, -2.48,   0.00, 0.00, 90.00, -1, 40);
	CreateDynamicObject(19368, 1695.46, -1621.76, -2.48,   0.00, 0.00, 90.00, -1, 40);
	CreateDynamicObject(19368, 1694.22, -1625.14, -2.48,   0.00, 0.00, 90.00, -1, 40);
	CreateDynamicObject(19368, 1692.26, -1621.76, -2.48,   0.00, 0.00, 90.00, -1, 40);
	CreateDynamicObject(19368, 1689.05, -1621.76, -2.48,   0.00, 0.00, 90.00, -1, 40);
	CreateDynamicObject(19368, 1692.26, -1625.14, -2.48,   0.00, 0.00, 90.00, -1, 40);
	CreateDynamicObject(19368, 1689.05, -1625.14, -2.48,   0.00, 0.00, 90.00, -1, 40);
	CreateDynamicObject(19368, 1702.15, -1623.44, -2.48,   0.00, 0.00, 0.00, -1, 40);
	CreateDynamicObject(19368, 1700.63, -1625.14, -2.48,   0.00, 0.00, 90.00, -1, 40);
	CreateDynamicObject(19368, 1697.25, -1587.81, -2.48,   0.00, 0.00, 90.00, -1, 40);
	CreateDynamicObject(1501, 1697.27, -1614.65, -4.24,   0.00, 0.00, 90.00, -1, 40);
	CreateDynamicObject(1501, 1697.27, -1604.44, -4.24,   0.00, 0.00, 90.00, -1, 40);
	CreateDynamicObject(1501, 1697.27, -1609.54, -4.24,   0.00, 0.00, 90.00, -1, 40);
	CreateDynamicObject(2677, 1712.96, -1606.86, -3.94,   0.00, 0.00, 355.01, -1, 40);
	CreateDynamicObject(17969, 1706.59, -1605.22, -2.83,   0.00, 0.00, 90.00, -1, 40);
	CreateDynamicObject(365, 1705.74, -1605.59, -4.13,   0.00, 85.00, 305.08, -1, 40);
	CreateDynamicObject(365, 1705.06, -1605.42, -4.13,   0.00, 85.00, 37.69, -1, 40);
	CreateDynamicObject(365, 1705.37, -1605.36, -4.13,   0.00, 85.00, 124.92, -1, 40);
	CreateDynamicObject(18659, 1700.31, -1625.02, -2.45,   0.00, 0.00, -90.00, -1, 40);
	CreateDynamicObject(1712, 1701.53, -1597.59, -4.22,   0.00, 0.00, -90.00, -1, 40);
	CreateDynamicObject(3785, 1701.96, -1601.13, -1.22,   90.00, 0.00, 180.00, -1, 40);
	CreateDynamicObject(3785, 1701.95, -1614.68, -1.22,   90.00, 0.00, 180.00, -1, 40);
	CreateDynamicObject(18687, 1687.32, -1586.70, -2.28,   0.00, 0.00, 0.00, -1, 40);
	CreateDynamicObject(366, 1702.03, -1604.74, -2.45,   0.00, 40.00, 90.00, -1, 40);
	CreateDynamicObject(1775, 1701.56, -1602.35, -3.16,   0.00, 0.00, -90.00, -1, 40);
	CreateDynamicObject(1501, 1702.03, -1614.73, -4.24,   0.00, 0.00, -90.00, -1, 40);
	CreateDynamicObject(1501, 1702.03, -1610.05, -4.24,   0.00, 0.00, -90.00, -1, 40);
	CreateDynamicObject(1501, 1702.03, -1620.73, -4.24,   0.00, 0.00, -90.00, -1, 40);
	CreateDynamicObject(1501, 1705.88, -1608.98, -4.24,   0.00, 0.00, 180.00, -1, 40);
	CreateDynamicObject(1501, 1711.12, -1605.22, -4.24,   0.00, 0.00, 0.00, -1, 40);
	CreateDynamicObject(1501, 1687.65, -1624.23, -4.24,   0.00, 0.00, 90.00, -1, 40);
	CreateDynamicObject(1501, 1710.88, -1608.98, -4.24,   0.00, 0.00, 180.00, -1, 40);
	CreateDynamicObject(1501, 1691.99, -1621.88, -4.24,   0.00, 0.00, 0.00, -1, 40);
	CreateDynamicObject(1533, 1698.22, -1587.92, -4.22,   0.00, 0.00, 0.00, -1, 40);
	CreateDynamicObject(1533, 1699.70, -1587.92, -4.22,   0.00, 0.00, 0.00, -1, 40);
	CreateDynamicObject(1501, 1691.99, -1625.03, -4.24,   0.00, 0.00, 180.00, -1, 40);
	CreateDynamicObject(1264, 1714.04, -1608.30, -3.72,   0.00, 0.00, 0.00, -1, 40);
	CreateDynamicObject(1501, 1696.99, -1625.03, -4.24,   0.00, 0.00, 180.00, -1, 40);
	CreateDynamicObject(3785, 1701.96, -1591.13, -1.22,   90.00, 0.00, 180.00, -1, 40);
	CreateDynamicObject(1347, 1701.66, -1624.70, -3.70,   0.00, 0.00, 0.00, -1, 40);
	CreateDynamicObject(2653, 1697.87, -1618.70, -0.60,   0.00, 180.00, 0.00, -1, 40);
	CreateDynamicObject(2653, 1697.87, -1610.82, -0.60,   0.00, 180.00, 0.00, -1, 40);
	CreateDynamicObject(2653, 1697.87, -1602.94, -0.60,   0.00, 180.00, 0.00, -1, 40);
	CreateDynamicObject(2653, 1697.87, -1595.06, -0.60,   0.00, 180.00, 0.00, -1, 40);
	CreateDynamicObject(2653, 1697.87, -1587.18, -0.60,   0.00, 180.00, 0.00, -1, 40);
	CreateDynamicObject(2653, 1694.26, -1622.24, -0.60,   0.00, 180.00, 90.00, -1, 40);
	CreateDynamicObject(2653, 1686.38, -1622.24, -0.60,   0.00, 180.00, 90.00, -1, 40);
	CreateDynamicObject(1369, 1708.13, -1606.10, -3.63,   0.00, 0.00, 298.07, -1, 40);
	CreateDynamicObject(1776, 1701.64, -1600.99, -3.13,   0.00, 0.00, -90.00, -1, 40);
	CreateDynamicObject(2986, 1699.27, -1606.80, -0.77,   0.00, 180.00, 0.00, -1, 40);
	CreateDynamicObject(2986, 1699.27, -1619.80, -0.77,   0.00, 180.00, 0.00, -1, 40);
	CreateDynamicObject(2986, 1699.27, -1591.80, -0.77,   0.00, 180.00, 0.00, -1, 40);
	CreateDynamicObject(1712, 1697.76, -1599.93, -4.22,   0.00, 0.00, 90.00, -1, 40);
	//
}
loadApartments() {
	query[0] = 0;
	format(query, sizeof(query), "SELECT `id`,`X`,`Y`,`Z`,`EX`,`EY`,`EZ`,`interior`,`name`,`locked` FROM `apartments`");
	mysql_function_query(g_mysql_handle, query, true, "OnLoadApartments", "");
}
public OnLoadApartments() {
	new rows, fields;
	new id_string[64];
	cache_get_data(rows, fields);
	for(new i=0;i<rows;i++) {
		if(Apartments[i][EApartmentSQLID] != 0) continue; //because this is also used for reloading apartments
		cache_get_row(i, 0, id_string);
		Apartments[i][EApartmentSQLID] = strval(id_string);
		
		cache_get_row(i, 1, id_string);
		Apartments[i][EApartmentX] = floatstr(id_string);
		
		cache_get_row(i, 2, id_string);
		Apartments[i][EApartmentY] = floatstr(id_string);
		
		cache_get_row(i, 3, id_string);
		Apartments[i][EApartmentZ] = floatstr(id_string);
		
		cache_get_row(i, 4, id_string);
		Apartments[i][EApartmentExitX] = floatstr(id_string);
		
		cache_get_row(i, 5, id_string);
		Apartments[i][EApartmentExitY] = floatstr(id_string);
		
		cache_get_row(i, 6, id_string);
		Apartments[i][EApartmentExitZ] = floatstr(id_string);
		
		cache_get_row(i, 7, id_string);
		Apartments[i][EApartmentInterior] = strval(id_string);
		
		cache_get_row(i, 8, Apartments[i][EApartmentName]);
		
		cache_get_row(i, 9, id_string);
		Apartments[i][EApartmentLocked] = strval(id_string);
		
		Apartments[i][EApartmentPickup] = CreateDynamicPickup(1239,16,Apartments[i][EApartmentX], Apartments[i][EApartmentY], Apartments[i][EApartmentZ]);
		
		new labeltext[256];
		getApartmentTextLabel(i, labeltext, sizeof(labeltext));
		Apartments[i][EApartmentTextLabel] = CreateDynamic3DTextLabel(labeltext, X11_ORANGE, Apartments[i][EApartmentX], Apartments[i][EApartmentY], Apartments[i][EApartmentZ]+1.5,10.0);
	}
	return 1;
}
apartmentGetVirtualWorld(apartmentid) {
	return apartmentid+20000;
}
apartmentGetInterior(apartmentid) {
	return Apartments[apartmentid][EApartmentInterior];
}
apartmentTryEnterExit(playerid) {
	for(new i=0;i<sizeof(Apartments);i++) {
		if(IsPlayerInRangeOfPoint(playerid, 1.5, Apartments[i][EApartmentX],Apartments[i][EApartmentY],Apartments[i][EApartmentZ])) {
			WaitForObjectsToStream(playerid);
			SetPlayerPos(playerid,  Apartments[i][EApartmentExitX],Apartments[i][EApartmentExitY],Apartments[i][EApartmentExitZ]);
			SetPlayerInterior(playerid, apartmentGetInterior(i));
			SetPlayerVirtualWorld(playerid, apartmentGetVirtualWorld(i));
		} else if(IsPlayerInRangeOfPoint(playerid, 5.0, Apartments[i][EApartmentExitX],Apartments[i][EApartmentExitY],Apartments[i][EApartmentExitZ])) {
			if(GetPlayerVirtualWorld(playerid) == apartmentGetVirtualWorld(i)) {
				SetPlayerPos(playerid, Apartments[i][EApartmentX],Apartments[i][EApartmentY],Apartments[i][EApartmentZ]);
				SetPlayerInterior(playerid, 0);
				SetPlayerVirtualWorld(playerid, 0);
			}
		}
	}
	return 1;
}
YCMD:makeapartment(playerid, params[], help) {
	if(help) {
		SendClientMessage(playerid, X11_WHITE,"Creates an apartment");
		return 1;
	}
	new type;
	new Float: X, Float: Y, Float: Z;
	if (!sscanf(params, "d", type)) {
		SendClientMessage(playerid, COLOR_LIGHTGREEN, "Attempting to create apartment.");
	} else {
		SendClientMessage(playerid, X11_WHITE,"USAGE: /makeapartment [type]");
		return 1;
	}
	GetPlayerPos(playerid, X, Y, Z);
	makeApartment(X, Y, Z, type);
	return 1;
}
makeApartment(Float:X,Float:Y,Float:Z,type) {
	query[0] = 0;
	format(query,sizeof(query),"INSERT INTO `apartments` (`X`,`Y`,`Z`,`EX`,`EY`,`EZ`,`interior`,`locked`) VALUES (%f,%f,%f,%f,%f,%f,%d,%d)",X,Y,Z,ApartmentIntType[type][EIntApartmentXDoor],ApartmentIntType[type][EIntApartmentYDoor],ApartmentIntType[type][EIntApartmentZDoor],ApartmentIntType[type][EIntInteriorID],0);
	mysql_function_query(g_mysql_handle, query, true, "OnApartmentCreate", "ffffffdd",X,Y,Z,ApartmentIntType[type][EIntApartmentXDoor],ApartmentIntType[type][EIntApartmentYDoor],ApartmentIntType[type][EIntApartmentZDoor],ApartmentIntType[type][EIntInteriorID],type);
}
forward OnApartmentCreate(Float:X,Float:Y,Float:Z,Float:EX,Float:EY,Float:EZ,interior, ETypeApartments:type);
public OnApartmentCreate(Float:X,Float:Y,Float:Z,Float:EX,Float:EY,Float:EZ,interior, ETypeApartments:type) {
	new id = mysql_insert_id();
	new index = findFreeApartment();
	new data[128];
	if(index == -1) {
		ABroadcast(X11_RED,"[AdmWarn]: Failed to create Apartment. Apartment array is full.",EAdminFlags_BasicAdmin);
		return 0;
	}
	Apartments[index][EApartmentSQLID] = id;
	//format(Apartments[index][EBusinessName],64,"%s",name);
	Apartments[index][EApartmentX] = X;
	Apartments[index][EApartmentY] = Y;
	Apartments[index][EApartmentZ] = Z;
	Apartments[index][EApartmentExitX] = EX;
	Apartments[index][EApartmentExitY] = EY;
	Apartments[index][EApartmentExitZ] = EZ;
	Apartments[index][EApartmentInterior] = interior;
	Apartments[index][EApartmentPickup] = CreateDynamicPickup(1239, 16, Apartments[index][EApartmentX], Apartments[index][EApartmentY], Apartments[index][EApartmentZ]);
	getApartmentTextLabel(index, data, sizeof(data));
	Apartments[index][EApartmentTextLabel] = CreateDynamic3DTextLabel(data, X11_ORANGE, Apartments[index][EApartmentX], Apartments[index][EApartmentY], Apartments[index][EApartmentZ]+1.5,10.0);
	format(data,sizeof(data),"[AdmNotice]: Apartment ID: %d",id);
	ABroadcast(X11_RED,data,EAdminFlags_BasicAdmin);
	return 1;
}
findFreeApartment() {
	for(new i=0;i<sizeof(Apartments);i++) {
		if(Apartments[i][EApartmentSQLID] == 0) {
			return i;
		}
	}
	return -1;
}
YCMD:gotoapartment(playerid, params[], help) {
	if(help) {
		SendClientMessage(playerid, X11_WHITE, "Takes you to an apartment's entrance.");
		return 1;
	}
	new apartmentid;
	if(!sscanf(params,"d", apartmentid)) {
		if(apartmentid < 0 || apartmentid > sizeof(Apartments) || Apartments[apartmentid][EApartmentSQLID] == 0) {
			SendClientMessage(playerid, X11_TOMATO_2, "Invalid Apartment");
			return 1;
		}
		SetPlayerPos(playerid, Apartments[apartmentid][EApartmentX],Apartments[apartmentid][EApartmentY],Apartments[apartmentid][EApartmentZ]);
		SetPlayerInterior(playerid, 0);
		SetPlayerVirtualWorld(playerid, 0);
		SendClientMessage(playerid, X11_ORANGE, "You have been teleported");
	} else {
		SendClientMessage(playerid, X11_WHITE, "USAGE: /gotoapartment [apartmentid]");
	}
	return 1;
}
public ReloadApartment(apartmentid) {
	query[0] = 0;
	format(query, sizeof(query), "SELECT `id`,`X`,`Y`,`Z`,`EX`,`EY`,`EZ`,`interior`,`name`,`locked` FROM `apartments` WHERE `id` = %d",Apartments[apartmentid][EApartmentSQLID]);
	Apartments[apartmentid][EApartmentSQLID] = 0;
	DestroyDynamicPickup(Apartments[apartmentid][EApartmentPickup]);
	DestroyDynamic3DTextLabel(Apartments[apartmentid][EApartmentTextLabel]);
	mysql_function_query(g_mysql_handle, query, true, "OnLoadApartments", "");
}
getApartmentTextLabel(apartmentid, dst[], dstlen) {
	new rand = random(4);
	switch(rand) {
		case 0: {
			format(dst, dstlen, "* Apartment Complex: {FF0000}H%dA",apartmentid);
		}
		case 1: {
			format(dst, dstlen, "* Apartment Complex: {FF0000}H%dB",apartmentid);
		}
		case 2: {
			format(dst, dstlen, "* Apartment Complex: {FF0000}H%dC",apartmentid);
		}
		case 3: {
			format(dst, dstlen, "* Apartment Complex: {FF0000}H%dD",apartmentid);
		}
	}
}

/* Unused
saveApartmentInfo(apartmentid) {
	query[0] = 0;
	format(query, sizeof(query), "UPDATE `apartments` SET `locked` = %d WHERE `id` = %d",Apartments[apartmentid][EApartmentLocked],Apartments[apartmentid][EApartmentOwnerSQLID],Apartments[apartmentid][EApartmentSQLID]);
	mysql_function_query(g_mysql_handle, query, true, "EmptyCallback", "");
}
getStandingApartment(playerid, Float:radi = 2.0) {
	for(new i=0;i<sizeof(Apartments);i++) {
		if(IsPlayerInRangeOfPoint(playerid, radi, Apartments[i][EApartmentX],Apartments[i][EApartmentY],Apartments[i][EApartmentZ])) {
			return i;
		}
	}
	return -1;
}
getApartmentStandingExit(playerid, Float:radi = 5.0) {
	for(new i=0;i<sizeof(Apartments);i++) {
		if(IsPlayerInRangeOfPoint(playerid, radi, Apartments[i][EApartmentExitX],Apartments[i][EApartmentExitY],Apartments[i][EApartmentExitZ])) {
			if(GetPlayerVirtualWorld(playerid) == apartmentGetVirtualWorld(i)) {
				return i;
			}
		}
	}
	return -1;
}
apartmentIDFromSQLID(sqlid) {
	for(new i=0;i<sizeof(Apartments);i++) {
		if(Apartments[i][EApartmentSQLID] == sqlid) {
			return i;
		}
	}
	return -1;
}
*/
