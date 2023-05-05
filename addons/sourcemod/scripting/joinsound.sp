#pragma semicolon 1

#include <sourcemod>
#include <sdktools>

#include <multicolors>
#include <emitsoundany>
#include <autoexecconfig>

#pragma newdecls required

#define JOINSOUND_VERSION "2.0.0"

ConVar g_cJoinSoundEnable = null;
ConVar g_cJoinSoundPath = null;

ConVar g_cJoinSoundStart = null;
ConVar g_cJoinSoundStartCommand = null;
char g_sJoinSoundStartCommand[32];

ConVar g_cJoinSoundStop = null;
ConVar g_cStopMessage = null;
ConVar g_cJoinSoundStopCommand = null;
char g_sJoinSoundStopCommand[32];

ConVar g_cJoinSoundVolume = null;
char g_sJoinSoundName[PLATFORM_MAX_PATH];

ConVar g_cMessageTime = null;

ConVar g_cAdminJoinSoundEnable = null;
ConVar g_cAdminJoinSoundChatEnable = null;
ConVar g_cAdminJoinSoundPath = null;
ConVar g_cAdminJoinSoundVolume = null;
char g_sAdminJoinSoundName[PLATFORM_MAX_PATH];
ConVar g_cAdminJoinSoundFlag = null;
char g_sAdminJoinSoundFlag[16];


public Plugin myinfo =
{
	name = "Admin / Player - Joinsound",
	author = "Bara",
	description = "Plays a custom joinsound if admin or player joins the server",
	version = JOINSOUND_VERSION,
	url = "www.bara.in"
};

public void OnPluginStart()
{
	CreateConVar("admin-joinsound_version", JOINSOUND_VERSION, "Joinsound", FCVAR_NOTIFY|FCVAR_DONTRECORD);

	LoadTranslations("joinsound.phrases");

	AutoExecConfig_SetFile("plugin.joinsound");
	AutoExecConfig_SetCreateFile(true);

	g_cJoinSoundEnable = AutoExecConfig_CreateConVar("joinsound_enable", "1", "Enable joinsound?", _, true, 0.0, true, 1.0);
	g_cJoinSoundPath = AutoExecConfig_CreateConVar("joinsound_path", "newsongformyserver/joinsound.mp3", "Which file sould be played? Path after cstrike/sound/ (JoinSound)");
	g_cJoinSoundStart = AutoExecConfig_CreateConVar("joinsound_start", "1", "Should '!start'-feature be enabled?", _, true, 0.0, true, 1.0);
	g_cJoinSoundStartCommand = AutoExecConfig_CreateConVar("joinsound_start_command", "start", "Command for start function");
	g_cJoinSoundStop = AutoExecConfig_CreateConVar("joinsound_stop", "1", "Should '!stop'-feature be enabled?", _, true, 0.0, true, 1.0);
	g_cStopMessage = AutoExecConfig_CreateConVar("joinsound_stop_message", "1", "Send a message?", _, true, 0.0, true, 1.0);
	g_cJoinSoundStopCommand = AutoExecConfig_CreateConVar("joinsound_stop_command", "stop", "Command for stop function");
	g_cJoinSoundVolume = AutoExecConfig_CreateConVar("joinsound_volume", "1.0", "Volume of joinsound (1 = default)");

	g_cMessageTime = AutoExecConfig_CreateConVar("joinsound_message_time", "5.0", "After how many seconds get a message after the beginning of the sound");

	g_cAdminJoinSoundEnable = AutoExecConfig_CreateConVar("admin_joinsound_enable", "1", "Enable admin joinsound?", _, true, 0.0, true, 1.0);
	g_cAdminJoinSoundChatEnable = AutoExecConfig_CreateConVar("admin_chat_enable", "1", "Enable admin joinmessage?", _, true, 0.0, true, 1.0);
	g_cAdminJoinSoundPath = AutoExecConfig_CreateConVar("admin_joinsound_path", "newsongformyserver/admin_joinsound.mp3", "Which file sould be played? Path after cstrike/sound/ (AdminJoinSound)");
	g_cAdminJoinSoundVolume = AutoExecConfig_CreateConVar("admin_joinsound_volume", "1.0", "Volume of admin joinsound (1 = default)");
	g_cAdminJoinSoundFlag = AutoExecConfig_CreateConVar("admin_joinsound_flag", "b", "Admin flags for admin join sound (b = default)");

	AutoExecConfig_CleanFile();
	AutoExecConfig_ExecuteFile();
}

public void OnConfigsExecuted()
{
	char sBuffer[PLATFORM_MAX_PATH];
	
	if(g_cJoinSoundEnable.IntValue)
	{
		g_cJoinSoundPath.GetString(g_sJoinSoundName, PLATFORM_MAX_PATH);
		PrecacheSoundAny(g_sJoinSoundName, true);
		Format(sBuffer, sizeof(sBuffer), "sound/%s", g_sJoinSoundName);
		AddFileToDownloadsTable(sBuffer);
	}

	if(g_cAdminJoinSoundEnable.IntValue)
	{
		g_cAdminJoinSoundPath.GetString(g_sAdminJoinSoundName, PLATFORM_MAX_PATH);
		PrecacheSoundAny(g_sAdminJoinSoundName, true);
		Format(sBuffer, sizeof(sBuffer), "sound/%s", g_sAdminJoinSoundName);
		AddFileToDownloadsTable(sBuffer);
	}

	if(g_cJoinSoundStart.IntValue)
	{
		g_cJoinSoundStartCommand.GetString(g_sJoinSoundStartCommand, sizeof(g_sJoinSoundStartCommand));
		Format(sBuffer, sizeof(sBuffer), "sm_%s", g_sJoinSoundStartCommand);
		RegConsoleCmd(sBuffer, Command_StartSound);
	}

	if(g_cJoinSoundStop.IntValue)
	{
		g_cJoinSoundStopCommand.GetString(g_sJoinSoundStopCommand, sizeof(g_sJoinSoundStopCommand));
		Format(sBuffer, sizeof(sBuffer), "sm_%s", g_sJoinSoundStopCommand);
		RegConsoleCmd(sBuffer, Command_StopSound);
	}
	
	if(g_cAdminJoinSoundEnable.IntValue)
		g_cAdminJoinSoundFlag.GetString(g_sAdminJoinSoundFlag, sizeof(g_sAdminJoinSoundFlag));
}

public void OnClientPostAdminCheck(int client)
{
	if(g_cJoinSoundEnable.IntValue)
	{
		if(IsClientValid(client))
		{
			EmitSoundToClientAny(client, g_sJoinSoundName, _, _, _, _, g_cJoinSoundVolume.FloatValue);

			if(g_cStopMessage.IntValue)
				CreateTimer(g_cMessageTime.FloatValue, Timer_Message, GetClientUserId(client));
		}
	}

	if(g_cAdminJoinSoundEnable.IntValue)
	{
		if(IsClientValid(client))
		{
			AdminFlag aFlags[16];
			FlagBitsToArray(ReadFlagString(g_sAdminJoinSoundFlag), aFlags, sizeof(aFlags));
			
			if(HasFlags(client, aFlags))
			{
				EmitSoundToAllAny(g_sAdminJoinSoundName, _, _, _, _, g_cAdminJoinSoundVolume.FloatValue);
				
				if(g_cAdminJoinSoundChatEnable.IntValue)
					for(int i = 1; i <= MaxClients; i++)
						if(IsClientValid(i))
							CPrintToChat(i, "%T", "AdminJoin", i, client);
			}
		}
	}
}

public Action Timer_Message(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);

	if(IsClientValid(client))
		CPrintToChat(client, "%T", "JoinStop", client, g_sJoinSoundStopCommand);
}

public Action Command_StopSound(int client, int args)
{
	if(g_cJoinSoundEnable.IntValue && g_cJoinSoundStop.IntValue)
		if(IsClientValid(client))
			StopSoundAny(client, SNDCHAN_AUTO, g_sJoinSoundName);
}

public Action Command_StartSound(int client, int args)
{
	if(g_cJoinSoundEnable.IntValue && g_cJoinSoundStart.IntValue)
	{
		if(IsClientValid(client))
		{
			EmitSoundToClientAny(client, g_sJoinSoundName, _, _, _, _, g_cJoinSoundVolume.FloatValue);

			if(g_cStopMessage.IntValue)
			{
				CreateTimer(g_cMessageTime.FloatValue, Timer_Message, GetClientUserId(client));
			}
		}
	}
}

stock bool IsClientValid(int client)
{
	if(client > 0 && client <= MaxClients && IsClientInGame(client))
		return true;
	return false;
}

stock bool HasFlags(int client, AdminFlag flags[16])
{
	int iFlags = GetUserFlagBits(client);

	for(int i = 0; i < sizeof(flags); i++)
		if(iFlags & FlagToBit(flags[i]))
			return true;
	
	return false;
}
