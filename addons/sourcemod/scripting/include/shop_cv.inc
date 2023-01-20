// Shop shared constant variables v1.3
#define STR stock char

/** SF cv start **/
enum
{
	AUTO_BHOP
	, QING_GONG
	, GRAY_AMMO
	, GREEN_AMMO
	, BLUE_AMMO
	, GOLD_AMMO
	, RED_AMMO
	, SF_SIZE
}

// Special functoins
STR g_sSF[][][] =
{	// FunctionNo		Trial price		permanent price 	Description				FunctionID:
	{ "AUTO_BHOP",		"30",			"300",			"buying a SMG"}				// 0
	, { "QING_GONG",	"30",			"300",			"buying a qing gong"}		// 1
	, { "GRAY_AMMO",	"200",			"1000",			"buying a gary laser tag"}	// 2
	, { "GREEN_AMMO",	"300",			"3000",			"buying a green laser tag"}	// 3
	, { "BLUE_AMMO",	"400",			"4000",			"buying a green laser tag"}	// 4
	, { "GOLD_AMMO",	"600",			"6000",			"buying a green laser tag"}	// 5
	, { "RED_AMMO",		"999",			"9999",			"buying a red laser tag"}	// 6
};
/** SF cv end **/

/** Shop cv start **/
// SHOP_INDEX
enum
{
	SHOP_MAIN,
	SHOP_INFECTED,
	SHOP_GUNS,
	SHOP_SMGS,
	SHOP_RIFLES,
	SHOP_SNIPERS,
	SHOP_SHOTGUNS,
	SHOP_OTHERS,
	SHOP_MELEES,
	SHOP_THROWABLES,
	SHOP_AMMOS,
	SHOP_MEDICINES,
	SHOP_AIRSTRIKE,
	SHOP_SF_TRIAL,
	SHOP_SF_PERMANENT,
	SHOP_SF,
	SHOP_SF_BAG,
	SHOP_TRANSFER,
	SHOP_SIZE,
};

// how to open the above shops by cmd
STR g_sShopCmds[SHOP_SIZE][64];

STR g_sShopNames[][] =
{
	"SHOP_MAIN",
	"SHOP_INFECTED",
	"SHOP_GUNS",
	"SHOP_SMGS",
	"SHOP_RIFLES",
	"SHOP_SNIPERS",
	"SHOP_SHOTGUNS",
	"SHOP_OTHERS",
	"SHOP_MELEES",
	"SHOP_THROWABLES",
	"SHOP_AMMOS",
	"SHOP_MEDICINES",
	"SHOP_AIRSTRIKE",
	"SHOP_SF_TRIAL",
	"SHOP_SF_PERMANENT",
	"SHOP_SF",
	"SHOP_SF_BAG",
	"SHOP_TRANSFER",
};

// Shop menu, must be same to once of g_sShopNames
STR g_sMainShop[][] = {"SHOP_GUNS","SHOP_MELEES","SHOP_THROWABLES","SHOP_AMMOS","SHOP_MEDICINES","SHOP_AIRSTRIKE","SHOP_SF","SHOP_TRANSFER"};
STR g_sGunsShop[][] = {"SHOP_SMGS","SHOP_RIFLES","SHOP_SNIPERS","SHOP_SHOTGUNS","SHOP_OTHERS",};
STR g_sSFShop[][] = {"SHOP_SF_TRIAL","SHOP_SF_PERMANENT", "SHOP_SF_BAG",};

// Shop items ------------------------------------>
// ** If price is less than 0, the item will be disabled (dont show on the Menu and no one can buy it.) **
STR g_sInfectedItems[][][] =
{	//item name								price 	Description								Infected Items ID:
	{ "kill",								"4",	"suicide"}								// 0
	, { "health",							"10",	"full healing"}							// 1
	, { "boomer",							"10",	"becoming a boomer"}					// 2
	, { "hunter",							"5",	"becoming a hunter"}					// 3
	, { "smoker",							"7",	"becoming a smoker"}					// 4
	, { "spitter",							"7",	"becoming a spitter"}					// 5
	, { "charger",							"7",	"becoming a charger"}					// 6 , fixed by ryxzxz
	, { "jockey",							"7",	"becoming a jockey"}					// 7
	, { "tank",								"50",	"becoming a tank"}						// 8
	, { "witch",							"30",	"generating a witch"}					// 9
	, { "mob",								"18",	"generating a mini-event/mob"}			// 10
	, { "director_force_panic_event",		"23",	"becoming a mega mob "}					// 11
};

STR g_sSmgs[][][] =
{	//item name								price 	Description								SMG Items ID:
	{ "smg",								"13",	"buying a SMG"}							// 0
	, { "smg_silenced",						"13",	"buying a Silenced SMG"}				// 1
	, { "smg_mp5",							"13",	"buying a MP5 SMG"}						// 2
};

STR g_sRifles[][][] =
{	//item name								price	Description								Rifle ID:
	{ "rifle",								"30",	"buying a rifle"}						// 0
	, { "rifle_desert",						"30",	"buying a desert rifle"}				// 1
	, { "rifle_ak47",						"30",	"buying an AK47 rifle"}					// 2
	, { "rifle_sg552",						"30",	"buying a SG552 rifle"}					// 3
	, { "rifle_m60",						"160",	"buying a heavy gun M60"}				// 4
};

STR g_sSnipers[][][] =
{	//item name								price	Description								Rifle ID:
	{ "hunting_rifle",						"25",	"buying a hunting rifle"}				// 0
	, { "sniper_military",					"25",	"buying a sniper military"}				// 1
	, { "sniper_awp",						"50",	"buying an AWP"}						// 2
	, { "sniper_scout",						"40",	"buying a scout"}						// 3
};

STR g_sShotguns[][][] =
{	//item name								price	Description								Shotgen ID:
	{ "pumpshotgun",						"13",	"buying a pumpshotgun"}					// 0
	, { "shotgun_chrome",					"13",	"buying a shotgun chrome"}				// 1
	, { "autoshotgun",						"30",	"buying a auto shotgun"}				// 2
	, { "shotgun_spas",						"30",	"buying a shotgun_spas"}				// 3
};

STR g_sOthers[][][] =
{	//item name								price	Description								Other ID:
	{ "pistol",								"5",	"buying a pistol"}						// 0
	, { "pistol_magnum",					"13",	"buying a pistol magnum"}				// 1
	, { "grenade_launcher",					"38",	"buying a grenade launcher"}			// 2
	, { "extinguisher",						"40",	"buying a extinguisher"}				// 3
};


STR g_sShopMelees[][][] =
{	//item name								price	Description								Melee ID:
	{ "katana",								"9",	"buying a katana"}						// 0
	, { "fireaxe",							"9",	"buying a fireaxe"}						// 1
	, { "machete",							"9",	"buying a fireaxe"}						// 2
	, { "machete",							"9",	"buying a machete"}						// 3
	, { "flamethrower",						"-1",	"buying a flamethrower"}				// 4
	, { "knife",							"5",	"buying a knife"}						// 5
	, { "chainsaw",							"16",	"buying a chainsaw"}					// 6
	, { "pitchfork",						"9",	"buying a pitchfork"}					// 7
	, { "shovel",							"9",	"buying a shovel"}						// 8
	, { "golfclub",							"9",	"buying a golf club"}					// 9
	, { "electric_guitar",					"9",	"buying an electric guitar"}			// 10
	, { "tonfa",							"9",	"buying a tonfa"}						// 11
	, { "baseball_bat",						"9",	"buying a baseball bat"}				// 12
	, { "cricket_bat",						"9",	"buying a cricket bat"}					// 13
	, { "frying_pan",						"9",	"buying a frying pan"}					// 14
	, { "crowbar",							"9",	"buying a crowbar"}						// 15
};

STR g_sThrowables[][][] =
{	//item name								price	Description								Throwable ID:
	{ "pipe_bomb",							"28",	"buying a pipe bomb"}					// 0
	, { "molotov",							"28",	"buying a molotov"}						// 1
	, { "vomitjar",							"28",	"buying a vomitjar"}					// 2
	, { "gascan",							"18",	"buying a gas can"}						// 3
	, { "propanetank",						"18",	"buying a propane tank"}				// 4
	, { "fireworkcrate",					"18",	"buying a firework crate"}				// 5
	, { "oxygentank",						"18",	"buying a oxygen tank"}					// 6
	, { "cola_bottles",						"68",	"buying a cola bottles"}				// 7
	, { "gnome",							"68",	"buying a gnome"}						// 8
};

STR g_sAmmos[][][] =
{	//item name								price	Description								Ammo ID:
	{ "laser_sight",						"10",	"upgrading laser sight"}				// 0
	, { "ammo",								"12",	"refilling ammo"}						// 1
	, { "incendiary_ammo",					"12",	"upgrading incendiary ammo"}			// 2
	, { "explosive_ammo",					"12",	"upgrading explosive ammo"}				// 3
	, { "upgradepack_incendiary",			"18",	"buying an incendiary upgrade pack "}	// 4
	, { "upgradepack_explosive",			"18",	"buying an explosive upgrade pack "}	// 5
	, { "lethal_ammo_3",					"60",	"buying a 3 lethal ammo"}					// 6
};

STR g_sMedicines[][][] =
{	//item name								price	Description								Medicine ID:
	{ "first_aid_kit",						"88",	"buying a first_aid_kit"}				// 0
	, { "adrenaline",						"43",	"buying an adrenaline"}					// 1
	, { "pain_pills",						"43",	"buying a pain pills"}					// 2
	, { "defibrillator",					"50",	"buying a defibrillator"}				// 3
	, { "health",							"98",	"full healing"}							// 4
};

//new airstrike menu
STR g_sAirstrike[][][] =
{	//item name								price	Description								Airstrike ID:
	{ "airstrike_on_crosshair",				"88",	"calling an airstrike (crosshair)"}		// 0
	, { "airstrike_on_position",			"88",	"calling an airstrike (positin)"}		// 1
};
// <------------------------------------ Shop items

// Shortcut variables
STR g_sShortcutItemCmds[][][]=
{
	// full form				//shortcut
	{"pistol",					"gun"},
	{"pistol_magnum",			"eagle"},
	{"pistol_magnum",			"magnum"},
	{"smg_silenced",			"slient"},
	{"smg_silenced",			"silenced"},
	{"smg_mp5",					"mp5"},
	{"rifle_ak47",				"ak"},
	{"rifle_ak47",				"ak47"},
	{"rifle",					"m16"},
	{"rifle_desert",			"desert"},
	{"rifle_desert",			"scar"},
	{"rifle_sg552",				"sg552"},
	{"rifle_m60",				"m60"},
	{"autoshotgun",				"auto"},
	{"shotgun_spas",			"spas"},
	{"pumpshotgun",				"pump"},
	{"shotgun_chrome",			"chrome"},
	{"hunting_rifle",			"hunt"},
	{"hunting_rifle",			"hunting"},
	{"hunting_rifle",			"hrifle"},
	{"sniper_military",			"mili"},
	{"sniper_military",			"military"},
	{"sniper_military",			"sniper"},
	{"sniper_awp",				"awp"},
	{"sniper_scout",			"scout"},
	{"grenade_launcher",		"grenade"},
	{"grenade_launcher",		"launcher"},
	{"grenade_launcher",		"nuke"},
	{"katana",					"kat"},
	{"fireaxe",					"axe"},
	{"machete",					"mac"},
	{"knife",					"cs"},
	{"chainsaw",				"saw"},
	{"pitchfork",				"fork"},
	{"golfclub",				"golf"},
	{"golfclub",				"club"},
	{"tonfa",					"police"},
	{"tonfa",					"nightstick"},
	{"tonfa",					"stick"},
	{"baseball_bat",			"bat"},
	{"baseball_bat",			"baseball"},
	{"cricket_bat",				"cricket"},
	{"cricket_bat",				"ket"},
	{"frying_pan",				"frying"},
	{"frying_pan",				"pan"},
	{"crowbar",					"crow"},
	{"crowbar",					"bar"},
	{"electric_guitar",			"guitar"},
	{"pipe_bomb",				"pipe"},
	{"pipe_bomb",				"bomb"},
	{"molotov",					"molo"},
	{"molotov",					"moly"},
	{"molotov",					"molly"},
	{"vomitjar",				"jar"},
	{"vomitjar",				"bile"},
	{"upgradepack_incendiary",	"packfire"},
	{"upgradepack_explosive",	"packexp"},
	{"laser_sight",				"laser"},
	//{"incendiary_ammo",		"fire"},
	{"incendiary_ammo",			"fireammo"},
	{"explosive_ammo",			"expammo"},
	{"explosive_ammo",			"exp"},
	{"ammo",					"a"},
	{"first_aid_kit",			"first"},
	{"first_aid_kit",			"aid"},
	{"first_aid_kit",			"kit"},
	{"first_aid_kit",			"healthpack"},
	{"first_aid_kit",			"medkit"},
	{"adrenaline",				"adren"},
	{"pain_pills",				"pill"},
	{"pain_pills",				"pills"},
	{"defibrillator",			"defib"},
	{"health",					"heal"},
	{"health",					"full"},
	{"health",					"fheal"},
	{"gascan",					"gas"},
	{"propanetank",				"propane"},
	{"fireworkcrate",			"firework"},
	{"oxygentank",				"oxygen"},
	{"extinguisher",			"extinguisher"},
	{"extinguisher",			"ext"},
	{"extinguisher",			"flamethrower"},
	{"extinguisher",			"flamer"},
	{"extinguisher",			"fire"},
};
/** Shop cv end **/