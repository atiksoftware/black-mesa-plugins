#include <json> 
#include <sdktools>

#define JSON_FILE_NAME "amiral_coop.json"
#define AC_STORAGE_DIR "amiral_coop"
#define AC_CLIENTS_DIR "amiral_coop/clients"

public Plugin myinfo = {
	name = "Amiral Coop",
	author = "Amiral Router",
	description = "Save Coop Stats",
	version = SOURCEMOD_VERSION,
	url = "http://www.sourcemod.net/"
}; 

public void OnPluginStart(){   
    if(!FileExists(AC_STORAGE_DIR)){
        CreateDirectory(AC_STORAGE_DIR, 777);
    }
    if(!FileExists(AC_CLIENTS_DIR)){
        CreateDirectory(AC_CLIENTS_DIR, 777);
    } 
}

public Action OnClientSayCommand(int client, const char[] command, const char[] sArgs){
    if(StrEqual(sArgs, "!amiral_coop")){
        MenuShow(client);
        return Plugin_Handled;
    }
    return Plugin_Continue;
}

public void MenuShow(int client){ 
    Menu menu = new Menu(MenuHandler, MenuAction_Select);
    menu.SetTitle("Map Menu");  
    menu.AddItem("add_checkpoint", "Add Checkpoint"); 
    menu.AddItem("load_last_checkpoint", "Load Last Checkpoint");
    menu.Display(client, MENU_TIME_FOREVER);
}

public int MenuHandler(Menu menu, MenuAction action, int client, int param2){
    switch(action){ 
        case MenuAction_Select:{
            char item_key[32];
            menu.GetItem(param2, item_key, sizeof(item_key));
            if(StrEqual(item_key, "add_checkpoint")){
                AddCheckpoint();
            }
            if(StrEqual(item_key, "load_last_checkpoint")){
                LoadLastCheckpoint();
            } 
        } 
    }

    return 0;
}

public void AddCheckpoint(){  
    SaveMapInformations();
    SaveClientsInformations(); 
}

public void SaveMapInformations(){
    JSON_Object map_data = new JSON_Object();
    char name[32];
    GetCurrentMap(name, sizeof(name));
    map_data.SetString("name", name);
    
    char storage_path[64];
    Format(storage_path, sizeof(storage_path), "%s/map_informations.json", AC_STORAGE_DIR); 
    map_data.WriteToFile(storage_path);
}

public void SaveClientsInformations(){
    // clear files in AC_CLIENTS_DIR
    char storage_path[64];
    Format(storage_path, sizeof(storage_path), "%s/*", AC_CLIENTS_DIR);
    DeleteFile(storage_path); 

    for(int i = 1; i <= MaxClients; i++){
        if(IsClientInGame(i)){ 
            SaveClientInformations(i);
        }
    } 
}

public void SaveClientInformations(int client_id){
    JSON_Object client_data = new JSON_Object();

    // nick
    char nick[32];
    GetClientName(client_id, nick, sizeof(nick));
    client_data.SetString("nick", nick);

    // steamid
    char steam_id[32];
    GetClientAuthId(client_id, AuthId_SteamID64, steam_id, sizeof(steam_id));
    client_data.SetString("steam_id", steam_id);

    // health
    client_data.SetInt("health", GetClientHealth(client_id));

    // armor
    client_data.SetInt("armor", GetClientArmor(client_id));

    // origin
    float origin[3];
    GetClientAbsOrigin(client_id, origin);
    JSON_Array origin_array = new JSON_Array();
    origin_array.PushFloat(origin[0]);
    origin_array.PushFloat(origin[1]);
    origin_array.PushFloat(origin[2]);
    client_data.SetObject("origin", origin_array);

    // ammos
    JSON_Array ammos_data = new JSON_Array();
    int ammo_type;
    int ammos[128];
    int ammo_type_count = GetEntPropArraySize(client_id, Prop_Send, "m_iAmmo"); 
    for(int i = 0; i < ammo_type_count; i++){ 
        ammos[i] = GetEntProp(client_id, Prop_Send, "m_iAmmo", _, i);
        ammos_data.PushInt(ammos[i]);
    }
    client_data.SetObject("ammos", ammos_data);

    // weapons
    JSON_Array weapons_data = new JSON_Array();
    char weapon_name[32]; 
    int weapons_array_size = GetEntPropArraySize(client_id, Prop_Send, "m_hMyWeapons");
    for(int i = 0; i < weapons_array_size; i++){
        int weapon_entity_index = GetEntPropEnt(client_id, Prop_Send, "m_hMyWeapons", i);  
        if(weapon_entity_index > 0){
            JSON_Object weapon_data = new JSON_Object();
            GetEntityClassname(weapon_entity_index, weapon_name, sizeof(weapon_name));
            weapon_data.SetString("name", weapon_name);
            weapon_data.SetInt("clip", GetEntProp(weapon_entity_index, Prop_Send, "m_iClip1")); 
            ammo_type = GetEntProp(weapon_entity_index, Prop_Send, "m_iPrimaryAmmoType");
            weapon_data.SetInt("ammo_type", ammo_type); 
            if(ammo_type > -1){
                weapon_data.SetInt("ammo", ammos[ammo_type]);
            } 
            weapons_data.PushObject(weapon_data);
        }
    }
    client_data.SetObject("weapons", weapons_data);
 
    


 
    char storage_path[64];
    Format(storage_path, sizeof(storage_path), "%s/%s.json", AC_CLIENTS_DIR, nick);
    client_data.WriteToFile(storage_path);
}
 
public void LoadLastCheckpoint(){
    if(LoadMapInformations()){
        LoadClientsInformations();
    }
}

public bool LoadMapInformations(){
    char storage_path[64];
    Format(storage_path, sizeof(storage_path), "%s/map_informations.json", AC_STORAGE_DIR); 

    JSON_Object map_data = json_read_from_file(storage_path);
    if(map_data == null){
        PrintToChatAll("No checkpoint found");
        return false;
    }

    char current_map_name[32];
    GetCurrentMap(current_map_name, sizeof(current_map_name));

    char saved_map_name[32];
    map_data.GetString("name", saved_map_name, sizeof(saved_map_name));

    if(StrEqual(current_map_name, saved_map_name)){
        PrintToChatAll("You are already in the checkpoint map");
        return true;
    }

    ForceChangeLevel(saved_map_name, "amiral_map");

    return false;
}

public void LoadClientsInformations(){ 
    DirectoryListing directory_listing = OpenDirectory(AC_CLIENTS_DIR);
    if(directory_listing == null){
        PrintToChatAll("No clients informations found");
        return;
    }
    int fileCounter = 0;
    char fileBuffer[512][48];
    while (directory_listing.GetNext(fileBuffer[fileCounter], sizeof(fileBuffer))) {
        if (fileBuffer[fileCounter][0] == '.') {
            continue;
        }
        fileCounter++;

        if (fileCounter >= sizeof(fileBuffer)) {
            break;
        } 
    }  

    for(int i = 0; i < fileCounter; i++){
        LoadClientInformations(fileBuffer[i]);
    }
}

public void LoadClientInformations(char file_name[48]){
    char storage_path[64];
    Format(storage_path, sizeof(storage_path), "%s/%s", AC_CLIENTS_DIR, file_name); 

    JSON_Object client_data = json_read_from_file(storage_path);
    if(client_data == null){
        PrintToChatAll("No client informations found");
        return;
    }

    char nick[32];
    client_data.GetString("nick", nick, sizeof(nick));

    int client_id = -1;
    for(int i = 1; i <= MaxClients; i++){
        char client_nick[32];
        GetClientName(i, client_nick, sizeof(client_nick));
        if(StrEqual(client_nick, nick)){
            client_id = i;
            break;
        }
    }
    if(client_id == -1){
        PrintToChatAll("Client not found");
        return;
    }

    char steam_id[32];
    client_data.GetString("steam_id", steam_id, sizeof(steam_id));

    // health
    int health = client_data.GetInt("health");
    SetEntProp(client_id, Prop_Send, "m_iHealth", health);
    

    // armor
    int armor = client_data.GetInt("armor");
    SetEntProp(client_id, Prop_Send, "m_ArmorValue", armor);

    // origin 
    JSON_Array origin_array = view_as<JSON_Array>(client_data.GetObject("origin"));
    float origin[3];
    origin[0] = origin_array.GetFloat(0);
    origin[1] = origin_array.GetFloat(1);
    origin[2] = origin_array.GetFloat(2);
    TeleportEntity(client_id, origin, NULL_VECTOR, NULL_VECTOR);

    // weapons
    // drop all weapons
    // int weapons_array_size = GetEntPropArraySize(client_id, Prop_Send, "m_hMyWeapons");
    // for(int i = 0; i < weapons_array_size; i++){
    //     int weapon_entity_index = GetEntPropEnt(client_id, Prop_Send, "m_hMyWeapons", i);  
    //     if(weapon_entity_index > 0){
    //         AcceptEntityInput(weapon_entity_index, "Kill"); 
    //         AcceptEntityInput(client_id, "DispatchWeapon", weapon_entity_index);
    //     }
    // } 

    JSON_Array weapons = view_as<JSON_Array>(client_data.GetObject("weapons"));
    int weapons_count = weapons.Length;
    for(int i = 0; i < weapons_count; i++){
        JSON_Object weapon = weapons.GetObject(i);
        char weapon_name[32];
        weapon.GetString("name", weapon_name, sizeof(weapon_name));
        PrintToServer("### Giving %s", weapon_name);
        // give weapon
        int weapon_entity_index = GivePlayerItem(client_id, weapon_name);
        if(weapon_entity_index == -1){
            PrintToServer("Weapon %s not found", weapon_name);
            continue;
        }
        // dispatch weapon
        AcceptEntityInput(client_id, "DispatchWeapon", weapon_entity_index);

        int clip = weapon.GetInt("clip");
        if(clip > -1 && clip < 255){
            SetEntProp(weapon_entity_index, Prop_Send, "m_iClip1", clip); 
        } 
        int ammo = weapon.GetInt("ammo");
        int ammo_type = weapon.GetInt("ammo_type");
        if(ammo_type > -1){
            SetEntProp(client_id, Prop_Send, "m_iAmmo", ammo, ammo_type);
        }

        // int weapon_entity_index = CreateEntityByName(weapon_name);
        // if(weapon_entity_index > 0){
        //     SetEntPropEnt(client_id, Prop_Send, "m_hActiveWeapon", weapon_entity_index);
        //     SetEntPropEnt(client_id, Prop_Send, "m_hMyWeapons", weapon_entity_index, i);
        //     SetEntProp(weapon_entity_index, Prop_Send, "m_hOwner", client_id);
        //     SetEntProp(weapon_entity_index, Prop_Send, "m_iClip1", weapon.GetInt("clip"));
        //     int ammo_type = weapon.GetInt("ammo_type");
        //     if(ammo_type > -1){
        //         SetEntProp(client_id, Prop_Send, "m_iAmmo", weapon.GetInt("ammo"), ammo_type);
        //     }
        // }
    }

    // ammos
    JSON_Array ammos = view_as<JSON_Array>(client_data.GetObject("ammos"));
    int ammos_count = ammos.Length;
    for(int i = 0; i < ammos_count; i++){
        int count = ammos.GetInt(i);
        SetEntProp(client_id, Prop_Send, "m_iAmmo", count, i);
    }
}