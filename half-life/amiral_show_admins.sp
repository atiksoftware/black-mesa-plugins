public Plugin myinfo = {
	name = "Show Admins",
	author = "Amiral Router",
	description = "Show admin list as HUD text on client screen every 1 second. (B flag only)",
	version = SOURCEMOD_VERSION,
	url = "http://www.sourcemod.net/"
};

public void OnPluginStart(){  
    CreateTimer(1.0, TimerTick, 0, TIMER_REPEAT);
}
 
public Action:TimerTick(Handle:hTimer){
	for(new client=1; client<=MaxClients; client++){
		if(IsClientInGame(client) && GetUserFlagBits(client) & (ADMFLAG_GENERIC) == (ADMFLAG_GENERIC))
			TimerEvent(client);
	}
}

public Action:TimerEvent(int client){   
    char sName[32];
    char buffer[256];  
 
    for(new i=1; i<=MaxClients; i++){
        if(IsClientInGame(i) && GetUserFlagBits(i) & (ADMFLAG_GENERIC) == (ADMFLAG_GENERIC)){
            GetClientName(i, sName, sizeof(sName)); 
            StrCat(buffer, sizeof(buffer), sName );
            StrCat(buffer, sizeof(buffer), "\n" );
        }
    }
 
    new Handle:hHudText = CreateHudSynchronizer();
    SetHudTextParams(0.01, 0.02, 1.0, 0, 255, 0, 255);
    ShowSyncHudText(client, hHudText, buffer);
    CloseHandle(hHudText);
    
    return Plugin_Continue;
}