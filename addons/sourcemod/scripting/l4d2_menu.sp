
#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>
#include <pan0s>

#define CVAR_FLAGS			FCVAR_NOTIFY
#define VERSION             "v1.2"

// ConVar
ConVar cvar_menuOptions;

char g_sCmds[21][32];
char g_sCvar_cmds[512];

public Plugin myinfo =
{
	name = "L4D2 Menu",
	description = "A simple plugin to collect the commands",
	author = "pan0s",
	url = "https://forums.alliedmods.net/showthread.php?t=332614"
};

public void OnPluginStart()
{
    LoadTranslations("l4d2_menu.phrases");
    LoadTranslations("l4d2_tags.phrases");
    
    RegConsoleCmd("sm_menu", HandleCmdMenu);

    CreateConVar("l4d2_menu_version", VERSION, "L4D2 menu version", CVAR_FLAGS);

    cvar_menuOptions = CreateConVar("l4d2_menu_options", "sm_ivote,sm_buy ammo,sm_buy,sm_hat,sm_srs,sm_lightmenu,sm_top10,sm_eff,sm_sound", "Use ',' to split the command. Remember to add transitions text for it.", CVAR_FLAGS);

    cvar_menuOptions.AddChangeHook(OnHookConvarChage);

    AutoExecConfig(true, "l4d2_menu");

    SplitOptions();
}

public void OnHookConvarChage(ConVar convar, const char[] oldValue, const char[] newValue)
{
    SplitOptions();
}

public void SplitOptions()
{
    int sizes[2];
    sizes[0] = sizeof(g_sCmds);
    sizes[1] = sizeof(g_sCmds[]);
    
    //clear the text
    for(int i =0; i<sizes[0]; i++)
        for(int j=0; j<sizes[1]; j++)
            g_sCmds[i][j] = '\0';

    for(int i=0; i<sizeof(g_sCvar_cmds); i++) g_sCvar_cmds[i] = '\0';

    cvar_menuOptions.GetString(g_sCvar_cmds, sizeof(g_sCvar_cmds));
    SplitStringEx(g_sCvar_cmds, sizeof(g_sCvar_cmds), g_sCmds, sizes, ',');
}

public Action HandleCmdMenu(int client, int args)
{
    Menu menu = new Menu(HandleMenuOpen);
    menu.SetTitle("%T", "MENU", client);
    
    for(int i=0; i<sizeof(g_sCmds); i++)
    {
        if(g_sCmds[i][0] == '\0') break;
        char option [64];
        char optionName [10];
        if(TranslationPhraseExists(g_sCmds[i])) Format(option, sizeof(option), "%T", g_sCmds[i], client);
        else Format(option, sizeof(option), "%s", g_sCmds[i]);
        Format(optionName, sizeof(optionName),"option%d", i);
        menu.AddItem(optionName, option);
    }
    menu.ExitButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
}

public int HandleMenuOpen(Handle menu, MenuAction action, int client, int option) 
{
    switch(action)
    {
        case MenuAction_End: delete menu;
        case MenuAction_Select:
        {
            if(IsValidClient(client)) FakeClientCommand(client, g_sCmds[option]);
        }
    }
}