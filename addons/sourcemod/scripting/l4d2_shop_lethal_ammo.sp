/****************************************************************************
 *																			*
 *						L4D2 Shop Extra Item Lethal Weapon					*
 *						Author: ztar (modified by pan0s)					*
 *								Version: v1.0								*
 *																			*
 ****************************************************************************/


/*******************************************************
*
* 		L4D2: Lethal Weapon v2.1
*
* 		      Author: ztar
* 		   Edited: M249-M4A1
* http://forums.alliedmods.net/showthread.php?p=1121995
*
********************************************************
* CHANGELOG:
*
* - Added several ConVars to customize effects
*   - Enable/disable sounds
*   - Enable/disable use of extra ammo
*   - Enable/disable some effects (to be discreet)
*   - Enable/disable charging while crouched and moving
*
* - Renamed ConVars and CFG to be more uniform
* - Fixed some grammar and spelling issues
* - Removed text gauge as it was kinda annoying
* - Made it easier to change sounds (#define)
* - Updated some sounds
* - Fixed bug where Survivors would be launched away
*   and killed unless "g_cvFF" is enabled
* - Fixed bug where if you were limited to 1 lethal
*   charged shot, you fired, then the limit was
*   removed, you wouldn't be able to charge again
* - Added screen shake
*
*******************************************************/
#include <sourcemod>
#include <sdktools>
#include <pan0s>

#define PLUGIN_VERSION "1.0"
#define CVAR_FLAGS FCVAR_SPONLY|FCVAR_NOTIFY
#define MOLOTOV 0
#define EXPLODE 1
#pragma newdecls required

/* Sound */
#define CHARGESOUND 	"ambient/spacial_loops/lights_flicker.wav"
#define CHARGEDUPSOUND	"level/startwam.wav"
#define AWPSHOT			"weapons/awp/gunfire/awp1.wav"
#define EXPLOSIONSOUND	"animation/bombing_run_01.wav"

bool g_bChargeLock[MAXPLAYERS + 1];
bool g_bIncapped[MAXPLAYERS + 1];
bool g_bReleaseLock[MAXPLAYERS + 1];
bool g_bFiring[MAXPLAYERS + 1];
int g_iChargeEndTime[MAXPLAYERS + 1];
int g_iAmmos[MAXPLAYERS + 1];
int g_iCurrentWeapon;
int g_iClipSize;
int g_sprite;

float myPos[3], trsPos[3], trsPos002[3];

Handle g_hClientTimer[MAXPLAYERS + 1];

/* Sprite */
#define SPRITE_BEAM		"materials/sprites/laserbeam.vmt"

ConVar g_cvLethalWeapon, g_cvLethalDamage, g_cvLethalForce, g_cvChargeTime, 
		g_cvShootOnce, g_cvFF, g_cvFlash, g_cvChargingSound, g_cvChargedSound, //g_cvMoveAndCharge, 
		g_cvChargeParticle, g_cvUseAmmo, g_cvShake, 
		g_cvShakeIntensity, g_cvShakeShooteronly, g_cvLaserOffset;

public Plugin myinfo = 
{
	name = "[L4D2] Shop - Extra Item Lethal Weapon",
	author = "ztar modified by pan0s",
	description = "Sniper rifles can be charged up and fired to create a huge explosion",
	version = PLUGIN_VERSION,
	url = "http://forums.alliedmods.net/showthread.php?p=1121995"
}

public void OnPluginStart()
{
	LoadTranslations("l4d2_weapons.phrases");
	
	RegAdminCmd("sm_give_lethal_ammo", HandleCmdGiveAmmo, ADMFLAG_ROOT);

	// ConVars
	g_cvLethalWeapon	= CreateConVar("l4d2_shop_ei_la_LethalWeapon","1", "Enable Lethal Weapon (0:OFF 1:ON 2:SIMPLE)", CVAR_FLAGS);
	g_cvLethalDamage	= CreateConVar("l4d2_shop_ei_la_LethalDamage","3000.0", "Lethal Weapon base damage", CVAR_FLAGS);
	g_cvLethalForce		= CreateConVar("l4d2_shop_ei_la_LethalForce","500.0", "Lethal Weapon force", CVAR_FLAGS);
	g_cvChargeTime		= CreateConVar("l4d2_shop_ei_la_ChargeTime","7", "Lethal Weapon charge time", CVAR_FLAGS);
	g_cvShootOnce		= CreateConVar("l4d2_shop_ei_la_ShootOnce","0", "Survivor can use Lethal Weapon once per round", CVAR_FLAGS);
	g_cvFF				= CreateConVar("l4d2_shop_ei_la_FF","0", "Lethal Weapon can deal direct damage to other survivors", CVAR_FLAGS);
	g_cvLaserOffset		= CreateConVar("l4d2_shop_ei_la_LaserOffset", "36", "Tracker offeset", FCVAR_NOTIFY);
	
	// Additional ConVars
	g_cvFlash				= CreateConVar("l4d2_shop_ei_la_Flash", "0", "Enable screen flash");
	g_cvChargingSound		= CreateConVar("l4d2_shop_ei_la_ChargingSound", "1", "Enable charging sound");
	g_cvChargedSound		= CreateConVar("l4d2_shop_ei_la_ChargedSound", "1", "Enable charged up sound");
	//g_cvMoveAndCharge		= CreateConVar("l4d2_shop_ei_la_MoveandCharge", "1", "Enable charging while crouched and moving");
	g_cvChargeParticle		= CreateConVar("l4d2_shop_ei_la_ChargeParticle", "1", "Enable showing electric particles when charged");
	g_cvUseAmmo				= CreateConVar("l4d2_shop_ei_la_UseAmmo", "0", "Enable and require use of addtional ammunition");
	g_cvShake				= CreateConVar("l4d2_shop_ei_la_Shake", "0", "Enable screen shake during explosion");
	g_cvShakeIntensity		= CreateConVar("l4d2_shop_ei_la_ShakeIntensity", "15.0", "Intensity of screen shake");
	g_cvShakeShooteronly	= CreateConVar("l4d2_shop_ei_la_ShakeShooteronly", "0", "Only the shooter experiences screen shake");
	
	// Hooks
	HookEvent("player_spawn", Event_Player_Spawn);
	HookEvent("weapon_fire", Event_Weapon_Fire);
	HookEvent("bullet_impact", Event_Bullet_Impact);
	HookEvent("player_incapacitated", Event_Player_Incap, EventHookMode_Pre);
	HookEvent("player_hurt", Event_Player_Hurt, EventHookMode_Pre);
	HookEvent("player_death", Event_Player_Hurt, EventHookMode_Pre);
	HookEvent("infected_death", Event_Infected_Hurt, EventHookMode_Pre);
	HookEvent("infected_hurt", Event_Infected_Hurt, EventHookMode_Pre);
	HookEvent("round_end", Event_Round_End, EventHookMode_Pre);
	HookEvent("revive_success", Event_ReviveSuccess);
	
	// Weapon stuff
	g_iCurrentWeapon	= FindSendPropInfo ("CTerrorPlayer", "m_hActiveWeapon");
	g_iClipSize	= FindSendPropInfo("CBaseCombatWeapon", "m_iClip1");
	
	InitCharge();
	
	AutoExecConfig(true, "l4d2_shop_lethal_ammo");
}

public void OnMapStart()
{
	InitPrecache();
}

public void OnConfigsExecuted()
{
	InitPrecache();
}

public void InitCharge()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidEntity(i) && IsClientInGame(i))
		{
			if (GetClientTeam(i) == 2)
				g_hClientTimer[i] = CreateTimer(0.5, ChargeTimer, i, TIMER_REPEAT);
		}
	}
}

public void InitPrecache()
{
	/* Precache models */
	PrecacheModel("models/props_junk/propanecanister001a.mdl", true);
	PrecacheModel("models/props_junk/gascan001a.mdl", true);
	
	/* Precache sounds */
	PrecacheSound(CHARGESOUND, true);
	PrecacheSound(CHARGEDUPSOUND, true);
	PrecacheSound(AWPSHOT, true);
	PrecacheSound(EXPLOSIONSOUND, true);
	
	/* Precache particles */
	PrecacheParticle("gas_explosion_main");
	PrecacheParticle("electrical_arc_01_cp0");
	PrecacheParticle("electrical_arc_01_system");
	
	g_sprite = PrecacheModel(SPRITE_BEAM);
}

public void OnClientDisconnect(int client)
{
	g_iAmmos[client] = 0;
}

public Action Event_Round_End(Event event, const char[] event_name, bool dontBroadcast)
{
	/* Timer end */
	for (int i = 1; i <= MaxClients; i++)
	{
		if (g_hClientTimer[i] != INVALID_HANDLE)
		{
			CloseHandle(g_hClientTimer[i]);
			g_hClientTimer[i] = INVALID_HANDLE;
		}
		if (IsValidEntity(i) && IsClientInGame(i))
		{
			g_iChargeEndTime[i] = 0;
			g_bReleaseLock[i] = false;
			g_bFiring[i] = false;
			g_bChargeLock[i] = false;
			g_bIncapped[i] = false;
		}
	}
	return Plugin_Continue;
}

public Action Event_Player_Spawn(Event event, const char[] name, bool dontBroadcast)
{
	/* Timer start */
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if (client > 0 && client <= MaxClients)
	{
		if (IsSurvivor(client))
		{
			if (g_hClientTimer[client] != INVALID_HANDLE)
				CloseHandle(g_hClientTimer[client]);
			g_bChargeLock[client] = false;
			g_bIncapped[client] = false;
			g_hClientTimer[client] = CreateTimer(0.5, ChargeTimer, client, TIMER_REPEAT);
		}
	}
	return Plugin_Continue;
}

public Action Event_Player_Incap(Event event, const char[] name, bool dontBroadcast)
{
	/* Reset client condition */
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	g_bReleaseLock[client] = false;
	ResetChargedTime(client);
	g_bIncapped[client] = true;
	return Plugin_Continue;
}

public Action Event_Bullet_Impact(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if (g_bReleaseLock[client] && g_bFiring[client])
	{
		float TargetPosition[3];
		
		TargetPosition[0] = GetEventFloat(event,"x");
		TargetPosition[1] = GetEventFloat(event,"y");
		TargetPosition[2] = GetEventFloat(event,"z");
		
		/* Explode effect */
		ExplodeMain(TargetPosition);
	}
	return Plugin_Continue;
}

public Action Event_Infected_Hurt(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "attacker"));
	
	if (g_bReleaseLock[client])
	{
		float TargetPosition[3];
		int target = GetClientAimTarget(client, false);
		if (target < 0)
			return Plugin_Continue;
		GetEntityAbsOrigin(target, TargetPosition);
		
		/* Explode effect */
		EmitSoundToAll(EXPLOSIONSOUND, target);
		ExplodeMain(TargetPosition);
		
		/* Reset Lethal Weapon lock */
		g_bReleaseLock[client] = false;
	}
	return Plugin_Continue;
}

public Action Event_Player_Hurt(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "attacker"));
	int target = GetClientOfUserId(GetEventInt(event, "userid"));
	int dtype = GetEventInt(event, "type");
	
	if (g_bReleaseLock[client] && dtype != 268435464 && g_bFiring[client])
	{
		int health = GetEventInt(event,"health");
		int damage = GetConVarInt(g_cvLethalDamage);
		
		float AttackPosition[3];
		float TargetPosition[3];
		GetClientAbsOrigin(client, AttackPosition);
		GetClientAbsOrigin(target, TargetPosition);
		
		/* Explode effect */
		EmitSoundToAll(EXPLOSIONSOUND, target);
		ExplodeMain(TargetPosition);
		
		/* Smash target */
		if (GetConVarInt(g_cvLethalWeapon) != 2)
			Smash(client, target, GetConVarFloat(g_cvLethalForce), 1.5, 2.0);
		
		/* Deal lethal damage */
		if ((GetClientTeam(client) != GetClientTeam(target)) || GetConVarInt(g_cvFF))
			SetEntProp(target, Prop_Data, "m_iHealth", health - damage);
		
		/* Reset Lethal Weapon lock */
		g_bReleaseLock[client] = false;
	}
	return Plugin_Continue;
}

public void ResetChargedTime(int client)
{
	g_iChargeEndTime[client] = RoundToCeil(GetGameTime()) + g_cvChargeTime.IntValue;
}

public Action Event_Weapon_Fire(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	ResetChargedTime(client);
	
	if (g_bReleaseLock[client] && !g_bFiring[client])
	{
		g_bFiring[client] = true;
		Weapon w;
		w.client = client;
		if(!w.IsGun()) return Plugin_Continue;
		g_iAmmos[client]--;
		/* Flash screen */
		if (GetConVarInt(g_cvFlash))
		{
			ScreenFade(client, 200, 200, 255, 255, 100, 1);
		}

		if (GetConVarInt(g_cvShake))
		{
			ScreenShake(client);
		}
		
		/* Laser effect */
		GetTracePosition(client);
		CreateLaserEffect(client, 0, 0, 200, 230, 2.0, 1.00);
		
		/* Emit sound */
		EmitSoundToAll(
			AWPSHOT, client,
			SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL,
			125, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
		
		/* Reset client condition */
		CreateTimer(0.2, ReleaseTimer, client);
		if (GetConVarInt(g_cvShootOnce))
		{
			g_bChargeLock[client] = true;
			PrintHintText(client, "Lethal Weapon can only be fired once per round");
		}
		else
		{
			// Enable shooting more than once per round again
			g_bChargeLock[client] = false;
		}
		if(g_iAmmos[client]==0)PrintHintText(client, "%T: %d", "lethal_ammo", client, g_iAmmos[client]);	
	}
	return Plugin_Continue;
}

public Action ReleaseTimer(Handle timer, int client)
{
	/* Set ammo after using */
	if (GetConVarInt(g_cvUseAmmo))
	{
		int Weapon = GetEntDataEnt2(client, g_iCurrentWeapon);
		int iAmmo = FindDataMapInfo(client,"m_iAmmo");
		SetEntData(Weapon, g_iClipSize, 0);
		SetEntData(client, iAmmo+8,  RoundToFloor(GetEntData(client, iAmmo+8)  / 2.0));
		SetEntData(client, iAmmo+36, RoundToFloor(GetEntData(client, iAmmo+36) / 2.0));
		SetEntData(client, iAmmo+40, RoundToFloor(GetEntData(client, iAmmo+40) / 2.0));
	}

	/* Reset flags */
	g_bReleaseLock[client] = false;
	ResetChargedTime(client);
	return Plugin_Continue;
}

public Action ChargeTimer(Handle timer, int client)
{
	if(!IsSurvivor(client) || g_bIncapped[client] || !IsPlayerAlive(client)) return Plugin_Continue;

	// Make sure we remove the lock if this ConVar is later disabled
	if (GetConVarInt(g_cvShootOnce) < 1)
	{
		g_bChargeLock[client] = false;
	}

	StopSound(client, SNDCHAN_AUTO, CHARGESOUND);
	if (!g_cvLethalWeapon.BoolValue || g_bChargeLock[client])
		return Plugin_Continue;

	if (!IsValidClient(client))
	{
		g_hClientTimer[client] = INVALID_HANDLE;
		return Plugin_Stop;
	}
	
	/* Get data */
	int gt = RoundToCeil(GetGameTime());
	int ct = GetConVarInt(g_cvChargeTime);
	int buttons = GetClientButtons(client);
	Weapon w;
	w.client = client;
	w.UpdateActiveName();
	/* These weapons allow you to start charging */
	/* Now allowed: Hunting Rifle, G3SG1, Scout, AWP */


	if (!w.IsGun())
	{
		StopSound(client, SNDCHAN_AUTO, CHARGESOUND);
		g_bReleaseLock[client] = false;
		g_iChargeEndTime[client] = gt + ct;
		return Plugin_Continue;
	}

	w.UpdateSlotAndClips();

	if (g_iAmmos[client] > 0 && w.clips > 0)
	{
		g_bFiring[client] = false;
		if (g_iChargeEndTime[client] < gt)
		{
			/* Charge end, ready to fire */
			if (!g_bReleaseLock[client])
			{
				PrintHintText(client, "%T", "LA_CHARGED", client);
				float pos[3];
				GetClientAbsOrigin(client, pos);
				if (g_cvChargedSound.BoolValue)
				{
					EmitSoundToAll(CHARGEDUPSOUND, client);
				}
				if (GetConVarInt(g_cvChargeParticle))
				{
					ShowParticle(pos, "electrical_arc_01_system", 5.0);
				}
			}
			g_bReleaseLock[client] = true;
		}
		else
		{
			/* Not charged yet. Display charge gauge */
			int i, j;
			char ChargeBar[50];
			char Gauge1[2] = "|";
			char Gauge2[2] = " ";
			float GaugeNum = (float(ct) - (float(g_iChargeEndTime[client] - gt))) * (100.0/float(ct))/2.0;
			g_bReleaseLock[client] = false;
			if(GaugeNum > 50.0)
				GaugeNum = 50.0;
			
			for(i=0; i<GaugeNum; i++)
				ChargeBar[i] = Gauge1[0];
			for(j=i; j<50; j++)
				ChargeBar[j] = Gauge2[0];
			if (GaugeNum >= 15)
			{
				/* Gauge meter is 30% or more */
				float pos[3];
				GetClientAbsOrigin(client, pos);
				pos[2] += 45;
				if (GetConVarInt(g_cvChargeParticle))
				{
					ShowParticle(pos, "electrical_arc_01_cp0", 5.0);
				}
				if (GetConVarInt(g_cvChargingSound))
				{
					EmitSoundToAll(CHARGESOUND, client);
				}
			}
			/* Display gauge */
			PrintHintText(client, "%T\n%s|\n%T: %d", "LA_CHARGING", client, ChargeBar, "LA_REMAINING", client, g_iAmmos[client]);
		}
	}
	else
	{
		/* Not matching condition */
		StopSound(client, SNDCHAN_AUTO, CHARGESOUND);
		g_bReleaseLock[client] = false;
		g_iChargeEndTime[client] = gt + ct;
	}
	return Plugin_Continue;
}

public void ExplodeMain(float pos[3])
{
	/* Main effect when hit */
	if (GetConVarInt(g_cvChargeParticle))
	{
		ShowParticle(pos, "electrical_arc_01_system", 5.0);
	}
	LittleFlower(pos, EXPLODE);
	
	if (GetConVarInt(g_cvLethalWeapon) == 1)
	{
		ShowParticle(pos, "gas_explosion_main", 5.0);
		LittleFlower(pos, MOLOTOV);
	}
}

public void ShowParticle(float pos[3], char[] particlename, float time)
{
	/* Show particle effect you like */
	int particle = CreateEntityByName("info_particle_system");
	if (IsValidEdict(particle))
	{
		TeleportEntity(particle, pos, NULL_VECTOR, NULL_VECTOR);
		DispatchKeyValue(particle, "effect_name", particlename);
		DispatchKeyValue(particle, "targetname", "particle");
		DispatchSpawn(particle);
		ActivateEntity(particle);
		AcceptEntityInput(particle, "start");
		CreateTimer(time, DeleteParticles, particle);
	}  
}

public void PrecacheParticle(char[] particlename)
{
	/* Precache particle */
	int particle = CreateEntityByName("info_particle_system");
	if (IsValidEdict(particle))
	{
		DispatchKeyValue(particle, "effect_name", particlename);
		DispatchKeyValue(particle, "targetname", "particle");
		DispatchSpawn(particle);
		ActivateEntity(particle);
		AcceptEntityInput(particle, "start");
		CreateTimer(0.01, DeleteParticles, particle);
	}  
}

public Action DeleteParticles(Handle timer, any particle)
{
	/* Delete particle */
	if (IsValidEntity(particle))
	{
		char classname[64];
		GetEdictClassname(particle, classname, sizeof(classname));
		if (StrEqual(classname, "info_particle_system", false)) RemoveEdict(particle);
	}
	return Plugin_Continue;
}

public void LittleFlower(float pos[3], int type)
{
	/* Cause fire(type=0) or explosion(type=1) */
	int entity = CreateEntityByName("prop_physics");
	if (IsValidEntity(entity))
	{
		pos[2] += 10.0;
		if (type == 0)
			/* fire */
			DispatchKeyValue(entity, "model", "models/props_junk/gascan001a.mdl");
		else
			/* explode */
			DispatchKeyValue(entity, "model", "models/props_junk/propanecanister001a.mdl");
		DispatchSpawn(entity);
		SetEntData(entity, GetEntSendPropOffs(entity, "m_CollisionGroup"), 1, 1, true);
		TeleportEntity(entity, pos, NULL_VECTOR, NULL_VECTOR);
		AcceptEntityInput(entity, "break");
	}
}

public Action GetEntityAbsOrigin(int entity, float origin[3])
{
	/* Get target posision */
	float mins[3], maxs[3];
	GetEntPropVector(entity,Prop_Send,"m_vecOrigin",origin);
	GetEntPropVector(entity,Prop_Send,"m_vecMins",mins);
	GetEntPropVector(entity,Prop_Send,"m_vecMaxs",maxs);
	
	origin[0] += (mins[0] + maxs[0]) * 0.5;
	origin[1] += (mins[1] + maxs[1]) * 0.5;
	origin[2] += (mins[2] + maxs[2]) * 0.5;
	return Plugin_Continue;
}

public void Smash(int client, int target, float power, float powHor, float powVec)
{
	/* Smash target */
	// Check so that we don't "smash" other Survivors (only if "g_cvFF" is 0)
	if (GetConVarInt(g_cvFF) || GetClientTeam(target) != 2)
	{
		float HeadingVector[3], AimVector[3];
		GetClientEyeAngles(client, HeadingVector);
	
		AimVector[0] = Cosine(DegToRad(HeadingVector[1]))* power * powHor;
		AimVector[1] = Sine(DegToRad(HeadingVector[1])) * power * powHor;
	
		float current[3];
		GetEntPropVector(target, Prop_Data, "m_vecVelocity", current);
	
		float resulting[3];
		resulting[0] = current[0] + AimVector[0];	
		resulting[1] = current[1] + AimVector[1];
		resulting[2] = power * powVec;
	
		TeleportEntity(target, NULL_VECTOR, NULL_VECTOR, resulting);
	}
}

public void ScreenFade(int target, int red, int green, int blue, int alpha, int duration, int type)
{
	Handle msg = StartMessageOne("Fade", target);
	BfWriteShort(msg, 500);
	BfWriteShort(msg, duration);
	if (type == 0)
	{
		BfWriteShort(msg, (0x0002 | 0x0008));
	}
	else
	{
		BfWriteShort(msg, (0x0001 | 0x0010));
	}
	BfWriteByte(msg, red);
	BfWriteByte(msg, green);
	BfWriteByte(msg, blue);
	BfWriteByte(msg, alpha);
	EndMessage();
}

public void ScreenShake(int target)
{
	Handle msg;
	if (GetConVarInt(g_cvShakeShooteronly))
	{
		msg = StartMessageAll("Shake");
	}
	else
	{
		msg = StartMessageOne("Shake", target);
	}
	BfWriteByte(msg, 0);
 	BfWriteFloat(msg, GetConVarFloat(g_cvShakeIntensity));
 	BfWriteFloat(msg, 10.0);
 	BfWriteFloat(msg, 3.0);
	EndMessage();
}

public void GetTracePosition(int client)
{
	float myAng[3];
	GetClientEyePosition(client, myPos);
	GetClientEyeAngles(client, myAng);
	Handle trace = TR_TraceRayFilterEx(myPos, myAng, CONTENTS_SOLID|CONTENTS_MOVEABLE, RayType_Infinite, TraceEntityFilterPlayer, client);
	if(TR_DidHit(trace))
		TR_GetEndPosition(trsPos, trace);
	CloseHandle(trace);
	for(int i = 0; i < 3; i++)
		trsPos002[i] = trsPos[i];
}

public bool TraceEntityFilterPlayer(int entity, int contentsMask)
{
	return entity > MaxClients || !entity;
}

public void CreateLaserEffect(int client, int colRed, int colGre, int colBlu, int alpha, float width, float duration)
{
	float tmpVec[3];
	SubtractVectors(myPos, trsPos, tmpVec);
	NormalizeVector(tmpVec, tmpVec);
	ScaleVector(tmpVec, GetConVarFloat(g_cvLaserOffset));
	SubtractVectors(myPos, tmpVec, trsPos);
	
	int color[4];
	color[0] = colRed; 
	color[1] = colGre;
	color[2] = colBlu;
	color[3] = alpha;
	TE_SetupBeamPoints(myPos, trsPos002, g_sprite, 0, 0, 0, duration, width, width, 1, 0.0, color, 0);
	TE_SendToAll();
}

public Action HandleCmdGiveAmmo(int client, int args)
{
	if( g_cvLethalWeapon.IntValue > 0 )
	{
		if( args == 0 )
		{
			return Plugin_Handled;
		}
		else
		{
			char arg1[32];
			GetCmdArg(1, arg1, sizeof(arg1));

			int target_list[MAXPLAYERS], target_count;
			bool tn_is_ml;
			char target_name[MAX_TARGET_LENGTH];

			if( (target_count = ProcessTargetString(
				arg1,
				client,
				target_list,
				MAXPLAYERS,
				COMMAND_FILTER_ALIVE,
				target_name,
				sizeof(target_name),
				tn_is_ml)) <= 0 )
			{
				ReplyToTargetError(client, target_count);
				return Plugin_Handled;
			}

			int target;
			for( int i = 0; i < target_count; i++ )
			{
				target = target_list[i];
				if( GetClientTeam(target) == 2 )
				{
					if( args == 1 )
					{
						g_iAmmos[target] += 5;
					}
					else
					{
						GetCmdArg(2, arg1, sizeof(arg1));
						g_iAmmos[target] += StringToInt(arg1);
					}
					float pos[3];
					GetClientAbsOrigin(target, pos);
					EmitSoundToAll(CHARGEDUPSOUND, target);
					ShowParticle(pos, "electrical_arc_01_system", 5.0);
				}
			}
		}
	}
	return Plugin_Handled;
}

public Action Event_ReviveSuccess(Event event, char[] event_name, bool dontBroadcast)
{
	int client = GetEventClient(event, "userid");
	int target = GetEventClient(event, "subject");

	if(IsInfected(client) || IsInfected(target) || client == target) return Plugin_Continue;

	g_bIncapped[client] = false;
	g_bIncapped[target] = false;
	return Plugin_Continue;
}