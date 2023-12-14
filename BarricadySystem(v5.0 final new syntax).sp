#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <adminmenu>
#include <clientprefs>

ConVar PluginOn;
ConVar MAX_OBJECT;
ConVar MAX_AMMO;

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//*
//*                 BarricadySystem
//*                 Status: 5.0 Version.
//*					Автор релиза BatrakovScripts Ник на форуме(Alexander_Mirny)
//*					Плагин размещен - https://forum.myarena.ru/index.php?/topic/45769-sistema-barikadingameobjecteditor/#entry363090
//*
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

//Модели
#define M16 "models/w_models/weapons/w_rifle_m16a2.mdl"
#define autoshot "models/w_models/weapons/w_autoshot_m4super.mdl"
#define Sniper "models/w_models/weapons/w_sniper_mini14.mdl"
#define SMG "models/w_models/weapons/w_smg_uzi.mdl"
#define pumpshot "models/w_models/weapons/w_pumpshotgun_A.mdl"
#define Fance "models/props_exteriors/roadsidefence_512.mdl"
#define Dumpster "models/props_junk/dumpster.mdl"
#define Vehicle "models/props_junk/wheebarrow01a.mdl"
#define BarrelFire "models/props_junk/barrel_fire.mdl"
#define Sofa2 "models/props_interiors/sofa02.mdl"
#define BarricadeDoor "models/props_street/barricade_door_01.mdl"
#define Minigun "models/w_models/weapons/w_minigun.mdl"
#define AmmoStack "models/props/terror/ammo_stack.mdl"
//Мессенджеры
#define DeathMessage "Вы мертвы ,в режиме ожидания команды не доступны."
#define RotateMessage "Скорость вращения изменена: %.1f"
#define SpeedMessage "Скорость переещения изменена: %.1f"
#define ObjectMessage "Превышен лимит создания объектов!"
#define ErrorMessage "Вы еще не создали объект!"
//Переменные
#define CVAR_FLAGS FCVAR_NOTIFY
int count[MAXPLAYERS], id, iMAX_OBJECT, iMAX_AMMO;
bool PlayerDeath[MAXPLAYERS];
float Pos[3], Angles[3], SpeedObject = 0.5, RotateSpeedObject = 0.5;
char String[PLATFORM_MAX_PATH];

//События
public void OnPluginStart()
{
    BuildPath(Path_SM, String, sizeof(String), "logs/saveobject.log");
    RegConsoleCmd("save", Save);
    
    PluginOn = CreateConVar("plugin_on", "1", "Вкл./Выкл. плагин", CVAR_FLAGS);
    MAX_OBJECT = CreateConVar("max_object", "20", "Максимум, сколько можно создать объектов", CVAR_FLAGS);
    MAX_AMMO = CreateConVar("max_ammo_weapon", "999", "Количество патронов которое будет выдаваться при спавне объекта.", CVAR_FLAGS);
    
    PluginOn.AddChangeHook(ConVarPluginOnChanges);
    MAX_OBJECT.AddChangeHook(ConVarsChanges);
    MAX_AMMO.AddChangeHook(ConVarsChanges);
    
    AutoExecConfig(true, "hlstats_skins");
}

Action Save(int client, int args)
{
	for (int i = 1; i <= MaxClients; i++) { 
	LogToFileEx(String, "Count = %d Pos[0] = %.1f Pos[1] = %.1f Pos[2] = %.1f Angles[0] = %.1f Angles[1] = %.1f Angles[2] = %.1f",count[i],Pos[0],Pos[1],Pos[2],Angles[0],Angles[1],Angles[2]); break; }
	return Plugin_Continue;
}

public void OnMapStart()
{
	PrecacheModel(M16);
	PrecacheModel(autoshot);
	PrecacheModel(Sniper);
	PrecacheModel(SMG);
	PrecacheModel(pumpshot);
	PrecacheModel(Fance);
	PrecacheModel(Dumpster);
	PrecacheModel(Vehicle);
	PrecacheModel(BarrelFire);
	PrecacheModel(Sofa2);
	PrecacheModel(BarricadeDoor);
	PrecacheModel(Minigun);
	PrecacheModel(AmmoStack);
}

public void OnConfigsExecuted()
{
	IsAllowed();
}

void IsAllowed()
{
	bool bAllow = PluginOn.BoolValue;
	if(bAllow)
	{
		GetCvars();
		HookEvent("player_say", player_say);
		HookEvent("player_death", player_death);
		HookEvent("player_spawn", player_spawn);
	}
	else
	{
		UnhookEvent("player_say", player_say);
		UnhookEvent("player_death", player_death);
		UnhookEvent("player_spawn", player_spawn);
	}
}

void ConVarPluginOnChanges(ConVar convar, const char[] oldValue, const char[] newValue)
{
	IsAllowed();
}

void ConVarsChanges(ConVar convar, const char[] oldValue, const char[] newValue)
{
	GetCvars();
}

void GetCvars()
{
	iMAX_OBJECT = MAX_OBJECT.IntValue;
	iMAX_AMMO = MAX_AMMO.IntValue;
}

Action player_death(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid")); 
    //
	PlayerDeath[client] = true;
	return Plugin_Continue;
}

Action player_spawn(Event event, const char[] name, bool dontBroadcast) 
{ 
	int client = GetClientOfUserId(event.GetInt("userid"));
	if(IsClientInGame(client) && !IsFakeClient(client))
    {
		PlayerDeath[client] = false;
	}
	return Plugin_Continue;
}

Action player_say(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	char Text[35];
	event.GetString("text", Text, 35);
	if (StrEqual(Text, "rotateobject"))
	{
		if(PlayerDeath[client] == true) { PrintToChat(client, DeathMessage); return Plugin_Handled; } 
		if(GetObject(client)) { PrintToChat(client, ErrorMessage); return Plugin_Handled; } 
		Menu menu = new Menu(MenuObjectRootSpeed);
		menu.SetTitle("Скорость вращения");
		menu.AddItem("option1", "0.5");
		menu.AddItem("option2", "0.10");
		menu.AddItem("option3", "0.20");
		menu.AddItem("option4", "0.25");
		menu.AddItem("option5", "0.30");
		menu.AddItem("option6", "1.5");
		menu.AddItem("option7", "1.10");
		menu.AddItem("option8", "1.20");
		menu.AddItem("option9", "1.25");
		menu.AddItem("option10", "1.30");
		menu.ExitButton = true;
		menu.Display(client, MENU_TIME_FOREVER);
	}
	if (StrEqual(Text, "speedobject"))
	{
		if(PlayerDeath[client] == true) { PrintToChat(client, DeathMessage); return Plugin_Handled; } 
		if(GetObject(client)) { PrintToChat(client, ErrorMessage); return Plugin_Handled; }
		Menu menu = new Menu(MenuObjectSpeed);
		menu.SetTitle("Скорость переещения");
		menu.AddItem("option1", "0.5");
		menu.AddItem("option2", "0.10");
		menu.AddItem("option3", "0.20");
		menu.AddItem("option4", "0.25");
		menu.AddItem("option5", "0.30");
		menu.AddItem("option6", "1.5");
		menu.AddItem("option7", "1.10");
		menu.AddItem("option8", "1.20");
		menu.AddItem("option9", "1.25");
		menu.AddItem("option10", "1.30");
		menu.ExitButton = true;
		menu.Display(client, MENU_TIME_FOREVER);
	}
	if (StrEqual(Text, "edit 1"))
	{
		if(PlayerDeath[client] == true) { PrintToChat(client, DeathMessage); return Plugin_Handled; } 
		if(GetObject(client)) { PrintToChat(client, ErrorMessage); return Plugin_Handled; }
		Menu menu = new Menu(MenuObjectPos);
		menu.SetTitle("Позиция объекта");
		menu.AddItem("option1", "Верх(Z)");
		menu.AddItem("option2", "Низ(Z)");
		menu.AddItem("option3", "Лево(Y)");
		menu.AddItem("option4", "Право(Y)");
		menu.AddItem("option5", "Лево(X)");
		menu.AddItem("option6", "Право(X)");
		menu.ExitButton = true;
		menu.Display(client, MENU_TIME_FOREVER);
		PrintToChat(client, "Вы редактируете позицию объекта");
	}
	if (StrEqual(Text, "edit 2"))
	{
		if(PlayerDeath[client] == true) { PrintToChat(client, DeathMessage); return Plugin_Handled; } 
		if(GetObject(client)) { PrintToChat(client, ErrorMessage); return Plugin_Handled; }
		Menu menu = new Menu(MenuObjectRoot);
		menu.SetTitle("Ротация объекта");
		menu.AddItem("option1", "Верх(RZ)");
		menu.AddItem("option2", "Низ(RZ)");
		menu.AddItem("option3", "Лево(RY)");
		menu.AddItem("option4", "Право(RY)");
		menu.AddItem("option5", "Лево(RX)");
		menu.AddItem("option6", "Право(RX)");
		menu.ExitButton = true;
		menu.Display(client, MENU_TIME_FOREVER);
		PrintToChat(client, "Вы редактируете ротацию объекта");
	}
	if (StrEqual(Text, "create"))
	{
		if(count[client] == iMAX_OBJECT) {	PrintToChat(client, ObjectMessage);	return Plugin_Handled;	}
		if(PlayerDeath[client] == true) { PrintToChat(client, DeathMessage); return Plugin_Handled; } 
		Menu menu = new Menu(MenuObjectList);
		menu.SetTitle("Объекты");
		menu.AddItem("option1", "Забор");
		menu.AddItem("option2", "Мусорный бак");
		menu.AddItem("option3", "Тачанка");
		menu.AddItem("option4", "Бочка с огнем");
		menu.AddItem("option5", "Диван");
		menu.AddItem("option6", "Барикадные ворота");
		menu.AddItem("option7", "Миниган");
		menu.AddItem("option8", "Патроны");
		menu.AddItem("option9", "Эмка");
		menu.AddItem("option10", "Автодробовик");
		menu.AddItem("option11", "Снайперка");
		menu.AddItem("option12", "Узишка");
		menu.AddItem("option13", "Помповый дробовик");
		menu.ExitButton = true;
		menu.Display(client, MENU_TIME_FOREVER);
	}
	if (StrEqual(Text, "delete"))
	{
		if(PlayerDeath[client] == true) { PrintToChat(client, DeathMessage); return Plugin_Handled; } 
		if(GetObject(client)) { PrintToChat(client, ErrorMessage); return Plugin_Handled; }
		RemoveEdict(id);
		for (int i = 1; i <= MaxClients; i++) { count[i]--; }
	}
	return Plugin_Continue;
}

int MenuObjectList(Menu menu, MenuAction action, int client, int itemNum)
{
	for (int i = 1; i <= MaxClients; i++)
		//Установил цикл что-бы count выдавался всем, даже если 1 игрок использует систему барикад. 
		//Чтобы система ограничений работала не только на 1 игрока а на всех.
	{
		if ( action == MenuAction_Select ) 
		{ 
			switch (itemNum)
			{
				case 0:
				{
					id = CreateEntityByName("prop_dynamic_override");
					DispatchKeyValue(id, "solid", "6");
					SetEntityModel(id, Fance);
					TeleportEntity(id, Pos, Angles, NULL_VECTOR);
					GetClientAbsOrigin(client, Pos);
					GetClientAbsAngles(client, Angles);
					Pos[1]  +=  55.0;
					DispatchKeyValueVector(id, "Origin", Pos );
					DispatchKeyValueVector(id, "Angles", Angles );
					DispatchSpawn(id);
					PrintToChat(client, "Объект создан, порядковый ID:%d.", count[i]);
					count[i]++;
				}
				case 1:
				{
					id = CreateEntityByName("prop_dynamic_override");
					DispatchKeyValue(id, "solid", "6");
					SetEntityModel(id, Dumpster);
					TeleportEntity(id, Pos, Angles, NULL_VECTOR);
					GetClientAbsOrigin(client, Pos);
					GetClientAbsAngles(client, Angles);
					Pos[1]  +=  55.0;
					DispatchKeyValueVector(id, "Origin", Pos );
					DispatchKeyValueVector(id, "Angles", Angles );
					DispatchSpawn(id);
					PrintToChat(client, "Объект создан, порядковый ID:%d.", count[i]);
					count[i]++;
				}
				case 2:
				{
					id = CreateEntityByName("prop_dynamic_override");
					DispatchKeyValue(id, "solid", "6");
					SetEntityModel(id, Vehicle);
					TeleportEntity(id, Pos, Angles, NULL_VECTOR);
					GetClientAbsOrigin(client, Pos);
					GetClientAbsAngles(client, Angles);
					Pos[1]  +=  55.0;
					DispatchKeyValueVector(id, "Origin", Pos );
					DispatchKeyValueVector(id, "Angles", Angles );
					DispatchSpawn(id);
					PrintToChat(client, "Объект создан, порядковый ID:%d.", count[i]);
					count[i]++;
				}
				case 3:
				{
					id = CreateEntityByName("prop_dynamic_override");
					DispatchKeyValue(id, "solid", "6");
					SetEntityModel(id, BarrelFire);
					TeleportEntity(id, Pos, Angles, NULL_VECTOR);
					GetClientAbsOrigin(client, Pos);
					GetClientAbsAngles(client, Angles);
					Pos[1]  +=  55.0;
					DispatchKeyValueVector(id, "Origin", Pos );
					DispatchKeyValueVector(id, "Angles", Angles );
					DispatchSpawn(id);
					PrintToChat(client, "Объект создан, порядковый ID:%d.", count[i]);
					count[i]++;
				}
				case 4:
				{
					id = CreateEntityByName("prop_dynamic_override");
					DispatchKeyValue(id, "solid", "6");
					SetEntityModel(id, Sofa2);
					TeleportEntity(id, Pos, Angles, NULL_VECTOR);
					GetClientAbsOrigin(client, Pos);
					GetClientAbsAngles(client, Angles);
					Pos[1]  +=  55.0;
					DispatchKeyValueVector(id, "Origin", Pos );
					DispatchKeyValueVector(id, "Angles", Angles );
					DispatchSpawn(id);
					PrintToChat(client, "Объект создан, порядковый ID:%d.", count[i]);
					count[i]++;
				}
				case 5:
				{
					id = CreateEntityByName("prop_dynamic_override");
					DispatchKeyValue(id, "solid", "6");
					SetEntityModel(id, BarricadeDoor);
					TeleportEntity(id, Pos, Angles, NULL_VECTOR);
					GetClientAbsOrigin(client, Pos);
					GetClientAbsAngles(client, Angles);
					Pos[1]  +=  55.0;
					DispatchKeyValueVector(id, "Origin", Pos );
					DispatchKeyValueVector(id, "Angles", Angles );
					DispatchSpawn(id);
					PrintToChat(client, "Объект создан, порядковый ID:%d.", count[i]);
					count[i]++;
				}
				case 6:
				{
					id = CreateEntity("prop_minigun", "minigun", Minigun);
					GetClientAbsOrigin(client, Pos);
					GetClientAbsAngles(client, Angles);
					Pos[1]  +=  55.0;
					DispatchKeyValueVector(id, "Origin", Pos );
					DispatchKeyValueVector(id, "Angles", Angles );
					DispatchKeyValueFloat(id, "MaxPitch",  40.00 );
					DispatchKeyValueFloat(id, "MinPitch", -30.00 );
					DispatchKeyValueFloat(id, "MaxYaw",    90.00 );
					DispatchSpawn(id);
					PrintToChat(client, "Объект создан, порядковый ID:%d.", count[i]);
					count[i]++;
				}
				case 7:
				{
					id = CreateEntity("weapon_ammo_spawn", "ammo stack", AmmoStack);
					GetClientAbsOrigin(client, Pos);
					GetClientAbsAngles(client, Angles);
					Pos[1]  +=  55.0;
					DispatchKeyValueVector(id, "Origin", Pos );
					DispatchKeyValueVector(id, "Angles", Angles );
					DispatchSpawn(id);
					PrintToChat(client, "Объект создан, порядковый ID:%d.", count[i]);
					count[i]++;
				}
				case 8:
				{
					id = CreateEntity("weapon_rifle", "_spawn", M16);
					GetClientAbsOrigin(client, Pos);
					GetClientAbsAngles(client, Angles);
					Pos[1]  +=  55.0;
					DispatchKeyValueVector(id, "Origin", Pos );
					DispatchKeyValueVector(id, "Angles", Angles );
					DispatchSpawn(id);
					SetEntProp(id, Prop_Send, "m_iExtraPrimaryAmmo", iMAX_AMMO, 4);
					PrintToChat(client, "Объект создан, порядковый ID:%d.", count[i]);
					count[i]++;
				}
				case 9:
				{
					id = CreateEntity("weapon_autoshotgun", "_spawn", autoshot);
					GetClientAbsOrigin(client, Pos);
					GetClientAbsAngles(client, Angles);
					Pos[1]  +=  55.0;
					DispatchKeyValueVector(id, "Origin", Pos );
					DispatchKeyValueVector(id, "Angles", Angles );
					DispatchSpawn(id);
					SetEntProp(id, Prop_Send, "m_iExtraPrimaryAmmo", iMAX_AMMO, 4);
					PrintToChat(client, "Объект создан, порядковый ID:%d.", count[i]);
					count[i]++;
				}
				case 10:
				{
					id = CreateEntity("weapon_hunting_rifle", "_spawn", Sniper);
					GetClientAbsOrigin(client, Pos);
					GetClientAbsAngles(client, Angles);
					Pos[1]  +=  55.0;
					DispatchKeyValueVector(id, "Origin", Pos );
					DispatchKeyValueVector(id, "Angles", Angles );
					DispatchSpawn(id);
					SetEntProp(id, Prop_Send, "m_iExtraPrimaryAmmo", iMAX_AMMO, 4);
					PrintToChat(client, "Объект создан, порядковый ID:%d.", count[i]);
					count[i]++;
				}
				case 11:
				{
					id = CreateEntity("weapon_smg", "_spawn", SMG);
					GetClientAbsOrigin(client, Pos);
					GetClientAbsAngles(client, Angles);
					Pos[1]  +=  55.0;
					DispatchKeyValueVector(id, "Origin", Pos );
					DispatchKeyValueVector(id, "Angles", Angles );
					DispatchSpawn(id);
					SetEntProp(id, Prop_Send, "m_iExtraPrimaryAmmo", iMAX_AMMO, 4);
					PrintToChat(client, "Объект создан, порядковый ID:%d.", count[i]);
					count[i]++;
				}
				case 12:
				{
					id = CreateEntity("weapon_pumpshotgun", "_spawn", pumpshot);
					GetClientAbsOrigin(client, Pos);
					GetClientAbsAngles(client, Angles);
					Pos[1]  +=  55.0;
					DispatchKeyValueVector(id, "Origin", Pos );
					DispatchKeyValueVector(id, "Angles", Angles );
					DispatchSpawn(id);
					SetEntProp(id, Prop_Send, "m_iExtraPrimaryAmmo", iMAX_AMMO, 4);
					PrintToChat(client, "Объект создан, порядковый ID:%d.", count[i]);
					count[i]++;
				}
			}
			break;//Убирает дублирование PrintToChat
		}
	}
	return 0;
}

int MenuObjectRootSpeed(Menu menu, MenuAction action, int client, int itemNum)
{
	if ( action == MenuAction_Select ) 
	{ 
		switch (itemNum)
		{
			case 0: RotateSpeedObject = 0.5,  PrintToChat(client, RotateMessage, RotateSpeedObject);
			case 1: RotateSpeedObject = 0.10, PrintToChat(client, RotateMessage, RotateSpeedObject);
			case 2: RotateSpeedObject = 0.20, PrintToChat(client, RotateMessage, RotateSpeedObject);
			case 3: RotateSpeedObject = 0.25, PrintToChat(client, RotateMessage, RotateSpeedObject);
			case 4: RotateSpeedObject = 0.30, PrintToChat(client, RotateMessage, RotateSpeedObject);
			case 5: RotateSpeedObject = 1.5,  PrintToChat(client, RotateMessage, RotateSpeedObject);
			case 6: RotateSpeedObject = 1.10, PrintToChat(client, RotateMessage, RotateSpeedObject);
			case 7: RotateSpeedObject = 1.20, PrintToChat(client, RotateMessage, RotateSpeedObject);
			case 8: RotateSpeedObject = 1.25, PrintToChat(client, RotateMessage, RotateSpeedObject);
			case 9: RotateSpeedObject = 1.30, PrintToChat(client, RotateMessage, RotateSpeedObject);
		}
	}
	return 0;
}

int MenuObjectSpeed(Menu menu, MenuAction action, int client, int itemNum)
{
	if ( action == MenuAction_Select ) 
	{ 
		switch (itemNum)
		{
			case 0: SpeedObject = 0.5, 	PrintToChat(client, SpeedMessage, SpeedObject);
			case 1: SpeedObject = 0.10, PrintToChat(client, SpeedMessage, SpeedObject);
			case 2: SpeedObject = 0.20, PrintToChat(client, SpeedMessage, SpeedObject);
			case 3: SpeedObject = 0.25, PrintToChat(client, SpeedMessage, SpeedObject);
			case 4: SpeedObject = 0.30, PrintToChat(client, SpeedMessage, SpeedObject);
			case 5: SpeedObject = 1.5, 	PrintToChat(client, SpeedMessage, SpeedObject);
			case 6: SpeedObject = 1.10, PrintToChat(client, SpeedMessage, SpeedObject);
			case 7: SpeedObject = 1.20, PrintToChat(client, SpeedMessage, SpeedObject);
			case 8: SpeedObject = 1.25, PrintToChat(client, SpeedMessage, SpeedObject);
			case 9: SpeedObject = 1.30, PrintToChat(client, SpeedMessage, SpeedObject);
		}
	}
	return 0;
}

int MenuObjectPos(Menu menu, MenuAction action, int client, int itemNum)
{
	if ( action == MenuAction_Select ) 
	{ 
		switch (itemNum)
		{
			case 0:
			{
				TeleportEntity(id, Pos, NULL_VECTOR, NULL_VECTOR);
				Pos[2] += SpeedObject;
				//
				menu = new Menu(MenuObjectPos);
				menu.SetTitle("Позиция объекта");
				menu.AddItem("option1", "Верх(Z)");
				menu.AddItem("option2", "Низ(Z)");
				menu.AddItem("option3", "Лево(Y)");
				menu.AddItem("option4", "Право(Y)");
				menu.AddItem("option5", "Лево(X)");
				menu.AddItem("option6", "Право(X)");
				menu.ExitButton = true;
				menu.Display(client, MENU_TIME_FOREVER);
				//
				PrintHintText(client, "X:(%.1f) Y:(%.1f) Z:(%.1f)", Pos[0], Pos[1], Pos[2]);
				
			}
			case 1:
			{
				TeleportEntity(id, Pos, NULL_VECTOR, NULL_VECTOR);
				Pos[2] -= SpeedObject;
				//
				menu = new Menu(MenuObjectPos);
				menu.SetTitle("Позиция объекта");
				menu.AddItem("option1", "Верх(Z)");
				menu.AddItem("option2", "Низ(Z)");
				menu.AddItem("option3", "Лево(Y)");
				menu.AddItem("option4", "Право(Y)");
				menu.AddItem("option5", "Лево(X)");
				menu.AddItem("option6", "Право(X)");
				menu.ExitButton = true;
				menu.Display(client, MENU_TIME_FOREVER);
				//
				PrintHintText(client, "X:(%.1f) Y:(%.1f) Z:(%.1f)", Pos[0], Pos[1], Pos[2]);
			}
			case 2:
			{
				TeleportEntity(id, Pos, NULL_VECTOR, NULL_VECTOR);
				Pos[1] += SpeedObject;
				//
				menu = new Menu(MenuObjectPos);
				menu.SetTitle("Позиция объекта");
				menu.AddItem("option1", "Верх(Z)");
				menu.AddItem("option2", "Низ(Z)");
				menu.AddItem("option3", "Лево(Y)");
				menu.AddItem("option4", "Право(Y)");
				menu.AddItem("option5", "Лево(X)");
				menu.AddItem("option6", "Право(X)");
				menu.ExitButton = true;
				menu.Display(client, MENU_TIME_FOREVER);
				//
				PrintHintText(client, "X:(%.1f) Y:(%.1f) Z:(%.1f)", Pos[0], Pos[1], Pos[2]);
			}
			case 3:
			{
				TeleportEntity(id, Pos, NULL_VECTOR, NULL_VECTOR);
				Pos[1] -= SpeedObject;
				//
				menu = new Menu(MenuObjectPos);
				menu.SetTitle("Позиция объекта");
				menu.AddItem("option1", "Верх(Z)");
				menu.AddItem("option2", "Низ(Z)");
				menu.AddItem("option3", "Лево(Y)");
				menu.AddItem("option4", "Право(Y)");
				menu.AddItem("option5", "Лево(X)");
				menu.AddItem("option6", "Право(X)");
				menu.ExitButton = true;
				menu.Display(client, MENU_TIME_FOREVER);
				//
				PrintHintText(client, "X:(%.1f) Y:(%.1f) Z:(%.1f)", Pos[0], Pos[1], Pos[2]);
			}
			case 4:
			{
				TeleportEntity(id, Pos, NULL_VECTOR, NULL_VECTOR);
				Pos[0] += SpeedObject;
				//
				menu = new Menu(MenuObjectPos);
				menu.SetTitle("Позиция объекта");
				menu.AddItem("option1", "Верх(Z)");
				menu.AddItem("option2", "Низ(Z)");
				menu.AddItem("option3", "Лево(Y)");
				menu.AddItem("option4", "Право(Y)");
				menu.AddItem("option5", "Лево(X)");
				menu.AddItem("option6", "Право(X)");
				menu.ExitButton = true;
				menu.Display(client, MENU_TIME_FOREVER);
				//
				PrintHintText(client, "X:(%.1f) Y:(%.1f) Z:(%.1f)", Pos[0], Pos[1], Pos[2]);
			}
			case 5:
			{
				TeleportEntity(id, Pos, NULL_VECTOR, NULL_VECTOR);
				Pos[0] -= SpeedObject;
				//
				menu = new Menu(MenuObjectPos);
				menu.SetTitle("Позиция объекта");
				menu.AddItem("option1", "Верх(Z)");
				menu.AddItem("option2", "Низ(Z)");
				menu.AddItem("option3", "Лево(Y)");
				menu.AddItem("option4", "Право(Y)");
				menu.AddItem("option5", "Лево(X)");
				menu.AddItem("option6", "Право(X)");
				menu.ExitButton = true;
				menu.Display(client, MENU_TIME_FOREVER);
				//
				PrintHintText(client, "X:(%.1f) Y:(%.1f) Z:(%.1f)", Pos[0], Pos[1], Pos[2]);
			}
		}
	}
	return 0;
}

int MenuObjectRoot(Menu menu, MenuAction action, int client, int itemNum)
{
	if ( action == MenuAction_Select ) 
	{ 
		switch (itemNum)
		{
			case 0:
			{
				TeleportEntity(id, NULL_VECTOR, Angles, NULL_VECTOR);
				Angles[2] += RotateSpeedObject;
				//
				menu = new Menu(MenuObjectRoot);
				menu.SetTitle("Ротация объекта");
				menu.AddItem("option1", "Верх(RZ)");
				menu.AddItem("option2", "Низ(RZ)");
				menu.AddItem("option3", "Лево(RY)");
				menu.AddItem("option4", "Право(RY)");
				menu.AddItem("option5", "Лево(RX)");
				menu.AddItem("option6", "Право(RX)");
				menu.ExitButton = true;
				menu.Display(client, MENU_TIME_FOREVER);
				//
				PrintHintText(client, "RX:(%.1f) RY:(%.1f) RZ:(%.1f)", Angles[0], Angles[1], Angles[2]);
			}
			case 1:
			{
				TeleportEntity(id, NULL_VECTOR, Angles, NULL_VECTOR);
				Angles[2] -= RotateSpeedObject;
				//
				menu = new Menu(MenuObjectRoot);
				menu.SetTitle("Ротация объекта");
				menu.AddItem("option1", "Верх(RZ)");
				menu.AddItem("option2", "Низ(RZ)");
				menu.AddItem("option3", "Лево(RY)");
				menu.AddItem("option4", "Право(RY)");
				menu.AddItem("option5", "Лево(RX)");
				menu.AddItem("option6", "Право(RX)");
				menu.ExitButton = true;
				menu.Display(client, MENU_TIME_FOREVER);
				//
				PrintHintText(client, "RX:(%.1f) RY:(%.1f) RZ:(%.1f)", Angles[0], Angles[1], Angles[2]);
			}
			case 2:
			{
				TeleportEntity(id, NULL_VECTOR, Angles, NULL_VECTOR);
				Angles[1] += RotateSpeedObject;
				//
				menu = new Menu(MenuObjectRoot);
				menu.SetTitle("Ротация объекта");
				menu.AddItem("option1", "Верх(RZ)");
				menu.AddItem("option2", "Низ(RZ)");
				menu.AddItem("option3", "Лево(RY)");
				menu.AddItem("option4", "Право(RY)");
				menu.AddItem("option5", "Лево(RX)");
				menu.AddItem("option6", "Право(RX)");
				menu.ExitButton = true;
				menu.Display(client, MENU_TIME_FOREVER);
				//
				PrintHintText(client, "RX:(%.1f) RY:(%.1f) RZ:(%.1f)", Angles[0], Angles[1], Angles[2]);
			}
			case 3:
			{
				TeleportEntity(id, NULL_VECTOR, Angles, NULL_VECTOR);
				Angles[1] -= RotateSpeedObject;
				//
				menu = new Menu(MenuObjectRoot);
				menu.SetTitle("Ротация объекта");
				menu.AddItem("option1", "Верх(RZ)");
				menu.AddItem("option2", "Низ(RZ)");
				menu.AddItem("option3", "Лево(RY)");
				menu.AddItem("option4", "Право(RY)");
				menu.AddItem("option5", "Лево(RX)");
				menu.AddItem("option6", "Право(RX)");
				menu.ExitButton = true;
				menu.Display(client, MENU_TIME_FOREVER);
				//
				PrintHintText(client, "RX:(%.1f) RY:(%.1f) RZ:(%.1f)", Angles[0], Angles[1], Angles[2]);
			}
			case 4:
			{
				TeleportEntity(id, NULL_VECTOR, Angles, NULL_VECTOR);
				Angles[0] += RotateSpeedObject;
				//
				menu = new Menu(MenuObjectRoot);
				menu.SetTitle("Ротация объекта");
				menu.AddItem("option1", "Верх(RZ)");
				menu.AddItem("option2", "Низ(RZ)");
				menu.AddItem("option3", "Лево(RY)");
				menu.AddItem("option4", "Право(RY)");
				menu.AddItem("option5", "Лево(RX)");
				menu.AddItem("option6", "Право(RX)");
				menu.ExitButton = true;
				menu.Display(client, MENU_TIME_FOREVER);
				//
				PrintHintText(client, "RX:(%.1f) RY:(%.1f) RZ:(%.1f)", Angles[0], Angles[1], Angles[2]);
			}
			case 5:
			{
				TeleportEntity(id, NULL_VECTOR, Angles, NULL_VECTOR);
				Angles[0]  -=  RotateSpeedObject;
				//
				menu = new Menu(MenuObjectRoot);
				menu.SetTitle("Ротация объекта");
				menu.AddItem("option1", "Верх(RZ)");
				menu.AddItem("option2", "Низ(RZ)");
				menu.AddItem("option3", "Лево(RY)");
				menu.AddItem("option4", "Право(RY)");
				menu.AddItem("option5", "Лево(RX)");
				menu.AddItem("option6", "Право(RX)");
				menu.ExitButton = true;
				menu.Display(client, MENU_TIME_FOREVER);
				//
				PrintHintText(client, "RX:(%.1f) RY:(%.1f) RZ:(%.1f)", Angles[0], Angles[1], Angles[2]);
			}
		}
	}
	return 0;
}

int CreateEntity(const char[] entity, const char[] item, const char[] model = "" )
{
	int client;
	id = CreateEntityByName(entity);
	if(id == -1)
	{
		PrintToChat(client, "Не удолось создать %s", item);
		return -1;
	}
	if(strlen(model) != 0)
	{
		if (!IsModelPrecached(model))
		{
			PrecacheModel(model);
		}
		SetEntityModel(id, model);
	}
	return id;
}

stock int GetObject(int ID)
{
        return (count[ID] == 0) ? true : false;
}
