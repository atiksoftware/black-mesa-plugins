#include <sdktools_gamerules>

public Plugin myinfo = {
	name = "Amiral Menu",
	author = "Amiral Router",
	description = "Amiral menu to support players",
	version = SOURCEMOD_VERSION,
	url = "http://www.sourcemod.net/"
}; 

public Action OnClientSayCommand(int client, const char[] command, const char[] sArgs){
    if(StrEqual(sArgs, "!amiral_menu")){
        MenuShow(client);
        return Plugin_Handled;
    }
    return Plugin_Continue;
} 

public void MenuShow(int client){ 
    Menu menu = new Menu(MenuHandler, MenuAction_Select); 
    menu.SetTitle("Amiral Menu");
    menu.AddItem("0", "Teleport");
    menu.AddItem("1", "Give");
    menu.AddItem("2", "Team");
    menu.AddItem("3", "Map");
    menu.AddItem("spawn", "Spawn"); 
    menu.AddItem("coop", "Coop"); 
    menu.Display(client, MENU_TIME_FOREVER); 
}

public int MenuHandler(Menu menu, MenuAction action, int client, int param2)
{
    switch(action){ 
        case MenuAction_Select:{
            char item_key[32];
            menu.GetItem(param2, item_key, sizeof(item_key));
            if (StrEqual(item_key, "0")){
                FakeClientCommand(client, "say !amiral_teleport"); 
            }
            if (StrEqual(item_key, "1")){
                FakeClientCommand(client, "say !amiral_give");
            }
            if (StrEqual(item_key, "2")){
                FakeClientCommand(client, "say !amiral_team");
            } 
            if (StrEqual(item_key, "3")){
                FakeClientCommand(client, "say !amiral_map");
            }
            if (StrEqual(item_key, "spawn")){
                FakeClientCommand(client, "say !amiral_spawn");
            }
            if (StrEqual(item_key, "coop")){
                FakeClientCommand(client, "say !amiral_coop");
            }
        } 
    }

    return 0;
}