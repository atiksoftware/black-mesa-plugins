#include <sourcemod>
#include <sdktools>

public Plugin myinfo = {
	name = "Amiral Give",
	author = "Amiral Router",
	description = "Give something to me",
	version = SOURCEMOD_VERSION,
	url = "http://www.sourcemod.net/"
};


public Action OnClientSayCommand(int client, const char[] command, const char[] sArgs){
    if(StrEqual(sArgs, "!amiral_give")){
        MenuShow(client);
        return Plugin_Handled;
    }
    return Plugin_Continue;
}

public void MenuShow(int client){
    Menu menu = new Menu(MenuHandler, MenuAction_Select);
    menu.SetTitle("Give Menu"); 
    menu.AddItem("0", "Weapon");
    menu.AddItem("1", "Ammo");
    menu.AddItem("2", "Health");
    menu.AddItem("3", "Armor");
    menu.AddItem("4", "Long Jump");
    menu.AddItem("5", "Suit");
    menu.AddItem("6", "Suit Battery");
    menu.AddItem("7", "Health Kit"); 
    menu.Display(client, MENU_TIME_FOREVER);
}

public int MenuHandler(Menu menu, MenuAction action, int client, int param2){
    switch(action){ 
        case MenuAction_Select:{
            char item_key[32];
            menu.GetItem(param2, item_key, sizeof(item_key));
            if (StrEqual(item_key, "0")){
                WeaponMenuShow(client);
            }
            if (StrEqual(item_key, "1")){
                GiveAmmo(client);
            }
            if (StrEqual(item_key, "2")){
                GiveHealth(client);
            } 
            if (StrEqual(item_key, "3")){
                GiveArmor(client);
            }
            if (StrEqual(item_key, "4")){
                GiveLongJump(client);
            }
            if (StrEqual(item_key, "5")){
                GiveSuit(client);
            }
            if (StrEqual(item_key, "6")){
                GiveSuitBattery(client);
            }
            if (StrEqual(item_key, "7")){
                GiveHealthKit(client);
            }
        } 
    }

    return 0;
}

public void WeaponMenuShow(int client){
    Menu menu = new Menu(WeaponMenuHandler, MENU_ACTIONS_ALL);
    menu.SetTitle("Weapon Menu"); 
    menu.AddItem("weapon_crowbar", "Crowbar - Levye");
    menu.AddItem("weapon_pipewrench", "Pipe Wrench - Boru Anahtari");
    menu.AddItem("weapon_medkit", "Medkit");
    menu.AddItem("weapon_grapple", "Barnacle Grapple");
    menu.AddItem("weapon_glock", "Glock");
    menu.AddItem("weapon_357", ".357 Magnum");
    menu.AddItem("weapon_eagle", "Desert Eagle");
    menu.AddItem("weapon_uzi", "Uzi");
    menu.AddItem("weapon_uziakimbo", "Uzi Kimbo");
    menu.AddItem("weapon_mp5", "Mp5");
    menu.AddItem("weapon_shotgun", "Shotgun - Pompali");
    menu.AddItem("weapon_crossbow", "Crossbow - Arbalet");
    menu.AddItem("weapon_m16", "Assault Rifle");
    menu.AddItem("weapon_rpg", "RPG - Roket");
    menu.AddItem("weapon_tau", "Tau - Lazer");
    menu.AddItem("weapon_gluon", "Gluon Gun - Elektrik");
    menu.AddItem("weapon_hivehand", "Hivehand - Sinek");
    menu.AddItem("weapon_frag(grenades)", "Grenade");
    menu.AddItem("weapon_satchel", "Satchel Charge");
    menu.AddItem("weapon_tripmine", "Laser Tripmine");
    menu.AddItem("weapon_snark", "Snark - Bocek");
    menu.AddItem("weapon_sniperrifle", "Sniper Rifle");
    menu.AddItem("weapon_m249", "M249"); 
    menu.AddItem("weapon_sporelauncher", "Spore Launcher"); 
    menu.AddItem("weapon_shockrifle", "Shock Roach"); 
    menu.AddItem("weapon_displacer", "Displacer Cannon");  
    menu.Display(client, MENU_TIME_FOREVER);  
}
public int WeaponMenuHandler(Menu menu, MenuAction action, int client, int param2){
    switch(action){  
        case MenuAction_Select:{
            char item_name[32];
            menu.GetItem(param2, item_name, sizeof(item_name));
            GivePlayerItem(client, item_name)
        } 
    } 
    return 0;
}

public void GiveAmmo(int client){ 
    for(int i = 0; i < 10; i++){
        GivePlayerAmmo(client, 100, i); 
    }
    GivePlayerItem(client, "ammo_sporeclip");
    GivePlayerItem(client, "ammo_displacerclip");
    GivePlayerItem(client, "ammo_rockets");
    GivePlayerItem(client, "ammo_grenades");
    // for(int i = 0; i < 10; i++){ 
    //     GivePlayerItem(client, "item_weapon_tripmine");
    //     GivePlayerItem(client, "item_weapon_snark");
    //     GivePlayerItem(client, "item_weapon_satchel");
    // }

    PrintToChat(client, "Ammo given");
}

public void GiveHealth(int client){
    SetEntProp(client, Prop_Send, "m_iHealth", 100);
    PrintToChat(client, "Health given");
}

public void GiveArmor(int client){
    SetEntProp(client, Prop_Send, "m_ArmorValue", 100);
    PrintToChat(client, "Armor given");
}

public void GiveLongJump(int client){
    GivePlayerItem(client, "item_longjump");
    PrintToChat(client, "Long Jump given");
}

public void GiveSuit(int client){
    GivePlayerItem(client, "item_suit");
    PrintToChat(client, "Suit given");
}

public void GiveSuitBattery(int client){
    GivePlayerItem(client, "item_battery");
    PrintToChat(client, "Suit Battery given");
}

public void GiveHealthKit(int client){
    GivePlayerItem(client, "item_healthkit");
    PrintToChat(client, "Health Kit given");
}