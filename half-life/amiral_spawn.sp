#include <sdktools>

public Plugin myinfo = {
	name = "Amiral Spawn",
	author = "Amiral Router",
	description = "Display The entity name the player is aiming at in the console",
	version = SOURCEMOD_VERSION,
	url = "http://www.sourcemod.net/"
}; 

int last_detected_entity_index = -1;

public void OnPluginStart(){
    CreateTimer(0.1, TimerTick, 0, TIMER_REPEAT);
}

public Action OnClientSayCommand(int client, const char[] command, const char[] sArgs){
    if(StrEqual(sArgs, "!amiral_spawn")){
        MenuShow(client);
        return Plugin_Handled;
    }
    return Plugin_Continue;
}

public void MenuShow(int client){ 
    Menu menu = new Menu(MenuHandler, MenuAction_Select|MenuAction_End);
    menu.SetTitle("Spawn Menu");  
    menu.AddItem("npc_human_security", "NPC Human - Security");  
    menu.AddItem("npc_human_scientist", "NPC Human - Scientist");
    menu.AddItem("npc_human_scientist_female", "NPC Human - Scientist Female");
    menu.AddItem("npc_human_scientist_kleiner", "NPC Human - Scientist Kleiner");
    menu.AddItem("npc_human_scientist_eli", "NPC Human - Scientist Eli");
    menu.AddItem("npc_zombie_security", "NPC Zombie - Security");
    menu.AddItem("npc_zombie_scientist", "NPC Zombie - Scientist");
    menu.AddItem("npc_human_grunt", "NPC Human - Grunt");
    menu.AddItem("npc_human_grunt_ally", "NPC Human - Grunt Ally");
    menu.AddItem("npc_human_medic", "NPC Human - Medic");
    menu.AddItem("npc_human_commander", "NPC Human - Commander");
    menu.Display(client, MENU_TIME_FOREVER);
}
public int MenuHandler(Menu menu, MenuAction action, int client, int param2){
    switch(action){ 
        case MenuAction_Select:{
            char item_key[32];
            menu.GetItem(param2, item_key, sizeof(item_key)); 
            float vecangles[3], vecorigin[3], target_location[3];
            GetClientEyeAngles(client, vecangles);
            GetClientEyePosition(client, vecorigin); 
            Handle traceray = TR_TraceRayFilterEx(vecorigin, vecangles, MASK_SHOT_HULL, RayType_Infinite, TraceEntityFilterPlayers);
            if (TR_DidHit(traceray)) {
                TR_GetEndPosition(target_location, traceray); 
                target_location[2] += 100.0;
                int entity_index = CreateEntityByName(item_key, 100);
                if(entity_index > 0){
                    PrintToChatAll("Entity Index: %d, Entity Name: %s", entity_index, item_key);
                    DispatchSpawn(entity_index);
                    TeleportEntity(entity_index, target_location, {0.0,0.0,0.0}, NULL_VECTOR); 
                }
            }
            delete traceray;
            FakeClientCommand(client, "say !amiral_spawn");
        }  
    } 
    return 0;
}
 
 
 
 
public Action:TimerTick(Handle:hTimer)
{
	for(new i=1; i<=MaxClients; i++){
        TimerEvent(i, false);  
	}
}

public Action:TimerEvent(int client, bool bFirst)
{
    if(!IsClientInGame(client))
        return Plugin_Handled;
 
    // detect entity the player is aiming at via trace
    float vecangles[3], vecorigin[3];
    GetClientEyeAngles(client, vecangles);
    GetClientEyePosition(client, vecorigin);

    Handle traceray = TR_TraceRayFilterEx(vecorigin, vecangles, MASK_SHOT_HULL, RayType_Infinite, TraceEntityFilterPlayers);
    if (TR_DidHit(traceray)) {
        int entity_index = TR_GetEntityIndex(traceray); 
        char buffer[64];
        if (entity_index > 0) {
            char entityname[64];
            GetEntityClassname(entity_index, entityname, sizeof(entityname));
            Format(buffer, sizeof(buffer), "Entity Index: %d, Entity Name: %s", entity_index, entityname);
        }else{ 
            Format(buffer, sizeof(buffer), "Entity Index: %d, Entity Name: %s", entity_index, "World");
        }

        new Handle:hHudText = CreateHudSynchronizer();
        SetHudTextParams(-1.0, 0.1, 0.02, 0, 255, 255, 255);
        ShowSyncHudText(client, hHudText, buffer);
        CloseHandle(hHudText);

        if(last_detected_entity_index != entity_index){
            last_detected_entity_index = entity_index;
            PrintToChatAll(buffer);
        }

        return;
    }
    delete traceray;
}
stock bool TraceEntityFilterPlayers(int entity, int contentsMask) {
    return entity > MaxClients;
} 

 

