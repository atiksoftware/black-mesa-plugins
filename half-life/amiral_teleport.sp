#include <sdktools>

public Plugin myinfo = {
	name = "Amiral Teleport",
	author = "Amiral Router",
	description = "Teleport functions",
	version = SOURCEMOD_VERSION,
	url = "http://www.sourcemod.net/"
};

enum struct Position{
    float origin[3];
    float angles[3];
}

ArrayList g_Positions;

public void OnPluginStart(){
    g_Positions = new ArrayList(sizeof(Position));
    for(int i = 1; i <= MaxClients; i++){
        Position position; 
        g_Positions.PushArray(position);
    }
}

public Action OnClientSayCommand(int client, const char[] command, const char[] sArgs){
    if(StrEqual(sArgs, "!amiral_teleport")){
        MenuShow(client);
        return Plugin_Handled;
    }
    return Plugin_Continue;
}

public void MenuShow(int client){
    Menu menu = new Menu(MenuHandler, MenuAction_Select);
    menu.SetTitle("Teleport Menu"); 
    menu.AddItem("0", "Save Current Location");
    menu.AddItem("1", "Teleport to Saved Location");
    menu.AddItem("2", "Teleport to Aim Location");
    menu.AddItem("3", "Teleport to Forward");
    menu.AddItem("4", "Teleport Other Players to Here"); 
    menu.Display(client, MENU_TIME_FOREVER);
}

public int MenuHandler(Menu menu, MenuAction action, int client, int param2){
    switch(action){ 
        case MenuAction_Select:{
            char info[32];
            menu.GetItem(param2, info, sizeof(info));
            if (StrEqual(info, "0")){
                SaveCurrentLocation(client);
            }
            if (StrEqual(info, "1")){
                TeleportToSavedLocation(client);
            }
            if (StrEqual(info, "2")){
                TeleportToAimLocation(client);
            } 
            if (StrEqual(info, "3")){
                TeleportToForward(client);
            }
            if (StrEqual(info, "4")){
                TeleportOtherPlayersToHere(client);
            }
        } 
    }

    return 0;
}

public void SaveCurrentLocation(int client){
    Position position;
    GetClientAbsOrigin(client, position.origin);
    GetClientAbsAngles(client,  position.angles);
    g_Positions.SetArray(client, position);
    PrintToChat(client, "Location Saved"); 
}

public void TeleportToSavedLocation(int client){
    Position position;
    g_Positions.GetArray(client, position);
    if(position.origin[0] == 0 && position.origin[1] == 0 && position.origin[2] == 0){
        PrintToChat(client, "You have not saved a location yet");
        return;
    }
    TeleportPlayer(client, position.origin, position.angles);
    PrintToChat(client, "Teleported to Saved Location");
}

public void TeleportToAimLocation(int client){
    if (!IsClientInGame(client))
        return;

    float vecangles[3], vecorigin[3], vec[3];
    GetClientEyeAngles(client, vecangles);
    GetClientEyePosition(client, vecorigin);

    Handle traceray = TR_TraceRayFilterEx(vecorigin, vecangles, MASK_SHOT_HULL, RayType_Infinite, TraceEntityFilterPlayers);
    if (TR_DidHit(traceray)) {
        TR_GetEndPosition(vec, traceray);
        TeleportPlayer(client, vec, vecangles);
        delete traceray;

        return;
    }
    delete traceray;
    return;
}

stock bool TraceEntityFilterPlayers(int entity, int contentsMask) {
    return entity > MaxClients;
} 

public void TeleportToForward(int client){
    Position position;
    GetClientAbsOrigin(client, position.origin);
    GetClientAbsAngles(client,  position.angles);
    float pForward[3];
    GetAngleVectors(pForward,position.angles,NULL_VECTOR,NULL_VECTOR);
    position.origin[0] += pForward[0] * 10;
    position.origin[1] += pForward[1] * 10;
    position.origin[2] += pForward[2] * 10;
    TeleportPlayer(client, position.origin, position.angles);
    PrintToChat(client, "Teleported to Forward"); 
}

public void TeleportOtherPlayersToHere(int client){
    Position position;
    GetClientAbsOrigin(client, position.origin);
    GetClientAbsAngles(client,  position.angles);
    for(int i = 1; i <= MaxClients; i++){
        if(IsClientInGame(i) && i != client){
            TeleportPlayer(i, position.origin, position.angles);
        }
    }
}

public void TeleportPlayer(int client, float origin[3], float angles[3]){ 
    TeleportEntity(client, origin, angles, NULL_VECTOR);
}
 