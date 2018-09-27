items = {
	--{"name","rarity(1-100)",stacks(true-false),weight,armor(for helmet and vests only)},
	{"medkit",100,true,10,false},
	{"first_aid",100,true,10,false},
	{"bandage",100,true,10,false},
	{"energy_drink",100,true,10,false},
	{"painkiller",100,true,10,false},
	{"helmet1",100,false,10,100},
	{"helmet2",100,false,20,200},
	{"helmet3",100,false,30,300},
	{"backpack_small",100,false,10,false},
	{"backpack_medium",100,false,20,false},
	{"backpack_large",100,false,30,false},
	{"armor1",100,false,10,100},
	{"armor2",100,false,20,200},
	{"armor3",100,false,30,300},
	{"jerrycan",100,true,20,false},
	{"ammo_9mm",100,true,1,false},
	{"ammo_762mm",100,true,1,false},
	{"ammo_12gauge",100,true,1,false},
	{"ammo_556mm",100,true,1,false},
	{"molotov",100,true,10,false},
	{"grenade",100,true,10,false},
	{"awm",100,true,30,false},
	{"ak47",100,true,20,false},
	{"m16a4",100,true,20,false},
	{"kar98k",100,true,20,false},
	{"shotgun",100,true,20,false},
	{"mp5",100,true,10,false},
	{"uzi",100,true,10,false},
	{"crowbar",100,true,10,false},
	{"machete",100,true,10,false},
	{"colt45",100,true,10,false},
	{"pan",100,true,10,false},
};

vipitems = {
	{"colt45",1},
	{"ammo_9mm",80},
	{"backpack","backpack_small"},
}

allowed_serial = "C8DB1EE6EAE2F77B9E1F148CA6650384";
activation_code = "DO_NOT_CHANGE_THIS";

equipment_damage_reduction = {
	["helmet1"] = 0.8,
	["helmet2"] = 0.6,
	["helmet3"] = 0.5,
	["armor1"] = 0.8,
	["armor2"] = 0.6,
	["armor3"] = 0.5,
	["pan"] = 0.5,
};

slots = {
	["backpack_small"] = 200,
	["backpack_medium"] = 400,
	["backpack_large"] = 600,
	["armor1"] = 100,
	["armor2"] = 100,
	["armor3"] = 100,
};

weapons = {
	["awm"] = {"primary",34,6,358,"ammo_762mm"},
	["ak47"] = {"primary",30,5,355,"ammo_556mm"},
	["m16a4"] = {"primary",31,5,356,"ammo_556mm"},
	["kar98k"] = {"primary",33,6,357,"ammo_762mm"},
	["shotgun"] = {"primary",25,3,349,"ammo_12gauge"},
	["mp5"] = {"secondary",29,4,353,"ammo_9mm"},
	["uzi"] = {"secondary",28,4,352,"ammo_9mm"},
	["colt45"] = {"secondary",22,2,346,"ammo_9mm"},
	["pan"] = {"meele",3,1,334,""},
	["crowbar"] = {"meele",2,1,333,""},
	["machete"] = {"meele",8,1,339,""},
	["molotov"] = {"grenade",18,8,344,"molotov"},
	["grenade"] = {"grenade",16,8,342,"grenade"},
};

weapons_damage = {
	["awm"] = 100,
	["ak47"] = 10,
	["m16a4"] = 10,
	["kar98k"] = 90,
	["shotgun"] = 50,
	["mp5"] = 10,
	["uzi"] = 10,
	["colt45"] = 10,
	["pan"] = 30,
	["crowbar"] = 25,
	["machete"] = 30,
	["molotov"] = 50,
	["grenade"] = 100,
};

wepidToName = {
	[34] = "awm",
	[30] = "ak47",
	[31] = "m16a4",
	[33] = "kar98k",
	[25] = "shotgun",
	[29] = "mp5",
	[28] = "uzi",
	[22] = "colt45",
	[3] = "pan",
	[2] = "crowbar",
	[8] = "machete",
	[18] = "molotov",
	[16] = "grenade",
};