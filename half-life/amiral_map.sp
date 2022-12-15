#define LAST_MAP_FILE_NAME "amiral_map_last_map_name.txt"

public Plugin myinfo = {
	name = "Amiral Map",
	author = "Amiral Router",
	description = "Save current map for next game and change map",
	version = SOURCEMOD_VERSION,
	url = "http://www.sourcemod.net/"
}; 


public Action OnClientSayCommand(int client, const char[] command, const char[] sArgs){
    if(StrEqual(sArgs, "!amiral_map")){
        MenuShow(client);
        return Plugin_Handled;
    }
    return Plugin_Continue;
}

public void MenuShow(int client){
    char last_mapname[32];
    ReadLastMapNameFromFile (last_mapname); 
    Menu menu = new Menu(MenuHandler, MenuAction_Select);
    menu.SetTitle("Map Menu");  
    menu.AddItem("0", "Save Current Map");
    if(!StrEqual(last_mapname, "")){ 
        char item_text[32];
        Format(item_text, sizeof(item_text), "Load Last Map (%s)", last_mapname);
        menu.AddItem("1", item_text);
    } 
    menu.Display(client, MENU_TIME_FOREVER);
}

public int MenuHandler(Menu menu, MenuAction action, int client, int param2){
    switch(action){ 
        case MenuAction_Select:{
            char info[32];
            menu.GetItem(param2, info, sizeof(info));
            if (StrEqual(info, "0")){
                SaveCurrentMapNameToFile(client);
            }
            else if (StrEqual(info, "1")){
                char last_mapname[32];
                ReadLastMapNameFromFile (last_mapname);
                if(!StrEqual(last_mapname, "")){ 
                    ForceChangeLevel(last_mapname, "amiral_map");
                }
            }
        } 
    }

    return 0;
}

public void SaveCurrentMapNameToFile(int client){
    char mapname[32];
    GetCurrentMap(mapname, sizeof(mapname));
    char filename[32];
    Format(filename, sizeof(filename), LAST_MAP_FILE_NAME);
    File file = OpenFile(filename, "w");
    if (file == null){
        PrintToServer("Error: Could not open file %s", filename);
        return;
    }
    WriteFileString(file, mapname, false);
    CloseHandle(file);
    PrintToChat(client, "Current map saved: %s", mapname);
}

public void ReadLastMapNameFromFile(char[] mapname){
    char filename[32];
    Format(filename, sizeof(filename), LAST_MAP_FILE_NAME);
    File file = OpenFile(filename, "r");
    if (file == null){
        PrintToServer("Error: Could not open file %s", filename);
        return;
    } 
    ReadFileString(file, mapname, 32);
    CloseHandle(file); 
}
 