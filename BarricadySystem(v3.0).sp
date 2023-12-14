#include <sourcemod>
#include <sdktools>
#include <adminmenu>
#include <clientprefs>

ConVar MAX_OBJECT;


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//*
//*                 BarricadySystem
//*                 Status: 3.0 Version.
//*					Автор релиза BatrakovScripts Ник на форуме(Alexander_Mirny)
//*					Плагин размещен - https://forum.myarena.ru/index.php?/topic/45769-sistema-barikadingameobjecteditor/#entry363090
//*
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

//Модели
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

new count[MAXPLAYERS];
new bool:PlayerDeath[MAXPLAYERS];
new Float:Pos[3];
new Float:Angles[3];
new id;
new Float:SpeedObject = 0.5;
new Float:RotateSpeedObject = 0.5;

char String[PLATFORM_MAX_PATH];


stock GetObject(ID) return (count[ID] == 0) ? true : false;

//События
public OnPluginStart()
{
	MAX_OBJECT = CreateConVar("max_object", "20", "Максимум, сколько можно создать объектов", FCVAR_NOTIFY);
	HookEvent("player_say", player_say);
	HookEvent("player_death", player_death);
	HookEvent("player_spawn", player_spawn);
	BuildPath(Path_SM, String, sizeof(String), "logs/saveobject.log");
	RegConsoleCmd("save", Save);
}
public Action Save(client, args)
{
	for (new i = 1; i <= MaxClients; i++) { 
	LogToFileEx(String, "Count = %d Pos[0] = %.1f Pos[1] = %.1f Pos[2] = %.1f Angles[0] = %.1f Angles[1] = %.1f Angles[2] = %.1f",count[i],Pos[0],Pos[1],Pos[2],Angles[0],Angles[1],Angles[2]); break; }
	return Plugin_Continue;
}
public OnMapStart()
{
	PrecacheModel(Fance);
	PrecacheModel(Dumpster);
	PrecacheModel(Vehicle);
	PrecacheModel(BarrelFire);
	PrecacheModel(Sofa2);
	PrecacheModel(BarricadeDoor);
	PrecacheModel(Minigun);
	PrecacheModel(AmmoStack);
}
public Action:player_death(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid")); 
    //
	PlayerDeath[client] = true;
	return Plugin_Continue;
}
public Action:player_spawn(Handle:event, const String:name[], bool:dontBroadcast) 
{ 
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(IsClientInGame(client) && !IsFakeClient(client))
    {
		PlayerDeath[client] = false;
	}
	return Plugin_Continue;
}
public Action:player_say(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	decl String:Text[35];
	GetEventString(event, "text", Text, 35);
	if (StrEqual(Text, "rotateobject"))
	{
		if(PlayerDeath[client] == true) { PrintToChat(client, DeathMessage); return Plugin_Handled; } 
		if(GetObject(client)) { PrintToChat(client, ErrorMessage); return Plugin_Handled; } 
		new Handle:menu = CreateMenu(MenuObjectRootSpeed);
		SetMenuTitle(menu, "Скорость вращения");
		AddMenuItem(menu, "option1", "0.5");
		AddMenuItem(menu, "option2", "0.10");
		AddMenuItem(menu, "option3", "0.20");
		AddMenuItem(menu, "option4", "0.25");
		AddMenuItem(menu, "option5", "0.30");
		AddMenuItem(menu, "option6", "1.5");
		AddMenuItem(menu, "option7", "1.10");
		AddMenuItem(menu, "option8", "1.20");
		AddMenuItem(menu, "option9", "1.25");
		AddMenuItem(menu, "option10", "1.30");
		SetMenuExitButton(menu, true);
		DisplayMenu(menu, client, MENU_TIME_FOREVER);
	}
	if (StrEqual(Text, "speedobject"))
	{
		if(PlayerDeath[client] == true) { PrintToChat(client, DeathMessage); return Plugin_Handled; } 
		if(GetObject(client)) { PrintToChat(client, ErrorMessage); return Plugin_Handled; }
		new Handle:menu = CreateMenu(MenuObjectSpeed);
		SetMenuTitle(menu, "Скорость переещения");
		AddMenuItem(menu, "option1", "0.5");
		AddMenuItem(menu, "option2", "0.10");
		AddMenuItem(menu, "option3", "0.20");
		AddMenuItem(menu, "option4", "0.25");
		AddMenuItem(menu, "option5", "0.30");
		AddMenuItem(menu, "option6", "1.5");
		AddMenuItem(menu, "option7", "1.10");
		AddMenuItem(menu, "option8", "1.20");
		AddMenuItem(menu, "option9", "1.25");
		AddMenuItem(menu, "option10", "1.30");
		SetMenuExitButton(menu, true);
		DisplayMenu(menu, client, MENU_TIME_FOREVER);
	}
	if (StrEqual(Text, "edit 1"))
	{
		if(PlayerDeath[client] == true) { PrintToChat(client, DeathMessage); return Plugin_Handled; } 
		if(GetObject(client)) { PrintToChat(client, ErrorMessage); return Plugin_Handled; }
		new Handle:menu = CreateMenu(MenuObjectPos);
		SetMenuTitle(menu, "Позиция объекта");
		AddMenuItem(menu, "option1", "Верх(Z)");
		AddMenuItem(menu, "option2", "Низ(Z)");
		AddMenuItem(menu, "option3", "Лево(Y)");
		AddMenuItem(menu, "option4", "Право(Y)");
		AddMenuItem(menu, "option5", "Лево(X)");
		AddMenuItem(menu, "option6", "Право(X)");
		SetMenuExitButton(menu, true);
		DisplayMenu(menu, client, MENU_TIME_FOREVER);
		PrintToChat(client, "Вы редактируете позицию объекта");
	}
	if (StrEqual(Text, "edit 2"))
	{
		if(PlayerDeath[client] == true) { PrintToChat(client, DeathMessage); return Plugin_Handled; } 
		if(GetObject(client)) { PrintToChat(client, ErrorMessage); return Plugin_Handled; }
		new Handle:menu = CreateMenu(MenuObjectRoot);
		SetMenuTitle(menu, "Ротация объекта");
		AddMenuItem(menu, "option1", "Верх(RZ)");
		AddMenuItem(menu, "option2", "Низ(RZ)");
		AddMenuItem(menu, "option3", "Лево(RY)");
		AddMenuItem(menu, "option4", "Право(RY)");
		AddMenuItem(menu, "option5", "Лево(RX)");
		AddMenuItem(menu, "option6", "Право(RX)");
		SetMenuExitButton(menu, true);
		DisplayMenu(menu, client, MENU_TIME_FOREVER);
		PrintToChat(client, "Вы редактируете ротацию объекта");
	}
	if (StrEqual(Text, "create"))
	{
		if(count[client] == GetConVarInt(MAX_OBJECT)) {	PrintToChat(client, ObjectMessage);	return Plugin_Handled;	}
		if(PlayerDeath[client] == true) { PrintToChat(client, DeathMessage); return Plugin_Handled; } 
		new Handle:menu = CreateMenu(MenuObjectList);
		SetMenuTitle(menu, "Объекты");
		AddMenuItem(menu, "option1", "Забор");
		AddMenuItem(menu, "option2", "Мусорный бак");
		AddMenuItem(menu, "option3", "Тачанка");
		AddMenuItem(menu, "option4", "Бочка с огнем");
		AddMenuItem(menu, "option5", "Диван");
		AddMenuItem(menu, "option6", "Барикадные ворота");
		AddMenuItem(menu, "option7", "Миниган");
		AddMenuItem(menu, "option8", "Патроны");
		SetMenuExitButton(menu, true);
		DisplayMenu(menu, client, MENU_TIME_FOREVER);
	}
	if (StrEqual(Text, "delete"))
	{
		if(PlayerDeath[client] == true) { PrintToChat(client, DeathMessage); return Plugin_Handled; } 
		if(GetObject(client)) { PrintToChat(client, ErrorMessage); return Plugin_Handled; }
		RemoveEdict(id);
		for (new i = 1; i <= MaxClients; i++) { count[i]--; }
	}
	return Plugin_Continue;
}
public MenuObjectList(Handle:menu, MenuAction:action, client, itemNum)
{
	for (new i = 1; i <= MaxClients; i++)
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
					Pos[1] += 55.0;
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
					Pos[1] += 55.0;
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
					Pos[1] += 55.0;
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
					Pos[1] += 55.0;
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
					Pos[1] += 55.0;
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
					Pos[1] += 55.0;
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
					Pos[1] += 55.0;
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
					Pos[1] += 55.0;
					DispatchKeyValueVector(id, "Origin", Pos );
					DispatchKeyValueVector(id, "Angles", Angles );
					DispatchSpawn(id);
					PrintToChat(client, "Объект создан, порядковый ID:%d.", count[i]);
					count[i]++;
				}
			}
			break;//Убирает дублирование PrintToChat
		}
	}
}
public MenuObjectRootSpeed(Handle:menu, MenuAction:action, client, itemNum)
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
}
public MenuObjectSpeed(Handle:menu, MenuAction:action, client, itemNum)
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
}
public MenuObjectPos(Handle:menu, MenuAction:action, client, itemNum)
{
	if ( action == MenuAction_Select ) 
	{ 
		switch (itemNum)
		{
			case 0:
			{
				TeleportEntity(id, Pos, NULL_VECTOR, NULL_VECTOR);
				Pos[2]+=SpeedObject;
				//
				menu = CreateMenu(MenuObjectPos);
				SetMenuTitle(menu, "Позиция объекта");
				AddMenuItem(menu, "option1", "Верх(Z)");
				AddMenuItem(menu, "option2", "Низ(Z)");
				AddMenuItem(menu, "option3", "Лево(Y)");
				AddMenuItem(menu, "option4", "Право(Y)");
				AddMenuItem(menu, "option5", "Лево(X)");
				AddMenuItem(menu, "option6", "Право(X)");
				SetMenuExitButton(menu, true);
				DisplayMenu(menu, client, MENU_TIME_FOREVER);
				//
				PrintHintText(client, "X:(%.1f) Y:(%.1f) Z:(%.1f)", Pos[0], Pos[1], Pos[2]);
				
			}
			case 1:
			{
				TeleportEntity(id, Pos, NULL_VECTOR, NULL_VECTOR);
				Pos[2]-=SpeedObject;
				//
				menu = CreateMenu(MenuObjectPos);
				SetMenuTitle(menu, "Позиция объекта");
				AddMenuItem(menu, "option1", "Верх(Z)");
				AddMenuItem(menu, "option2", "Низ(Z)");
				AddMenuItem(menu, "option3", "Лево(Y)");
				AddMenuItem(menu, "option4", "Право(Y)");
				AddMenuItem(menu, "option5", "Лево(X)");
				AddMenuItem(menu, "option6", "Право(X)");
				SetMenuExitButton(menu, true);
				DisplayMenu(menu, client, MENU_TIME_FOREVER);
				//
				PrintHintText(client, "X:(%.1f) Y:(%.1f) Z:(%.1f)", Pos[0], Pos[1], Pos[2]);
			}
			case 2:
			{
				TeleportEntity(id, Pos, NULL_VECTOR, NULL_VECTOR);
				Pos[1]+=SpeedObject;
				//
				menu = CreateMenu(MenuObjectPos);
				SetMenuTitle(menu, "Позиция объекта");
				AddMenuItem(menu, "option1", "Верх(Z)");
				AddMenuItem(menu, "option2", "Низ(Z)");
				AddMenuItem(menu, "option3", "Лево(Y)");
				AddMenuItem(menu, "option4", "Право(Y)");
				AddMenuItem(menu, "option5", "Лево(X)");
				AddMenuItem(menu, "option6", "Право(X)");
				SetMenuExitButton(menu, true);
				DisplayMenu(menu, client, MENU_TIME_FOREVER);
				//
				PrintHintText(client, "X:(%.1f) Y:(%.1f) Z:(%.1f)", Pos[0], Pos[1], Pos[2]);
			}
			case 3:
			{
				TeleportEntity(id, Pos, NULL_VECTOR, NULL_VECTOR);
				Pos[1]-=SpeedObject;
				//
				menu = CreateMenu(MenuObjectPos);
				SetMenuTitle(menu, "Позиция объекта");
				AddMenuItem(menu, "option1", "Верх(Z)");
				AddMenuItem(menu, "option2", "Низ(Z)");
				AddMenuItem(menu, "option3", "Лево(Y)");
				AddMenuItem(menu, "option4", "Право(Y)");
				AddMenuItem(menu, "option5", "Лево(X)");
				AddMenuItem(menu, "option6", "Право(X)");
				SetMenuExitButton(menu, true);
				DisplayMenu(menu, client, MENU_TIME_FOREVER);
				//
				PrintHintText(client, "X:(%.1f) Y:(%.1f) Z:(%.1f)", Pos[0], Pos[1], Pos[2]);
			}
			case 4:
			{
				TeleportEntity(id, Pos, NULL_VECTOR, NULL_VECTOR);
				Pos[0]+=SpeedObject;
				//
				menu = CreateMenu(MenuObjectPos);
				SetMenuTitle(menu, "Позиция объекта");
				AddMenuItem(menu, "option1", "Верх(Z)");
				AddMenuItem(menu, "option2", "Низ(Z)");
				AddMenuItem(menu, "option3", "Лево(Y)");
				AddMenuItem(menu, "option4", "Право(Y)");
				AddMenuItem(menu, "option5", "Лево(X)");
				AddMenuItem(menu, "option6", "Право(X)");
				SetMenuExitButton(menu, true);
				DisplayMenu(menu, client, MENU_TIME_FOREVER);
				//
				PrintHintText(client, "X:(%.1f) Y:(%.1f) Z:(%.1f)", Pos[0], Pos[1], Pos[2]);
			}
			case 5:
			{
				TeleportEntity(id, Pos, NULL_VECTOR, NULL_VECTOR);
				Pos[0]-=SpeedObject;
				//
				menu = CreateMenu(MenuObjectPos);
				SetMenuTitle(menu, "Позиция объекта");
				AddMenuItem(menu, "option1", "Верх(Z)");
				AddMenuItem(menu, "option2", "Низ(Z)");
				AddMenuItem(menu, "option3", "Лево(Y)");
				AddMenuItem(menu, "option4", "Право(Y)");
				AddMenuItem(menu, "option5", "Лево(X)");
				AddMenuItem(menu, "option6", "Право(X)");
				SetMenuExitButton(menu, true);
				DisplayMenu(menu, client, MENU_TIME_FOREVER);
				//
				PrintHintText(client, "X:(%.1f) Y:(%.1f) Z:(%.1f)", Pos[0], Pos[1], Pos[2]);
			}
		}
	}
}
public MenuObjectRoot(Handle:menu, MenuAction:action, client, itemNum)
{
	if ( action == MenuAction_Select ) 
	{ 
		switch (itemNum)
		{
			case 0:
			{
				TeleportEntity(id, NULL_VECTOR, Angles, NULL_VECTOR);
				Angles[2]+=RotateSpeedObject;
				//
				menu = CreateMenu(MenuObjectRoot);
				SetMenuTitle(menu, "Ротация объекта");
				AddMenuItem(menu, "option1", "Верх(RZ)");
				AddMenuItem(menu, "option2", "Низ(RZ)");
				AddMenuItem(menu, "option3", "Лево(RY)");
				AddMenuItem(menu, "option4", "Право(RY)");
				AddMenuItem(menu, "option5", "Лево(RX)");
				AddMenuItem(menu, "option6", "Право(RX)");
				SetMenuExitButton(menu, true);
				DisplayMenu(menu, client, MENU_TIME_FOREVER);
				//
				PrintHintText(client, "RX:(%.1f) RY:(%.1f) RZ:(%.1f)", Angles[0], Angles[1], Angles[2]);
			}
			case 1:
			{
				TeleportEntity(id, NULL_VECTOR, Angles, NULL_VECTOR);
				Angles[2]-=RotateSpeedObject;
				//
				menu = CreateMenu(MenuObjectRoot);
				SetMenuTitle(menu, "Ротация объекта");
				AddMenuItem(menu, "option1", "Верх(RZ)");
				AddMenuItem(menu, "option2", "Низ(RZ)");
				AddMenuItem(menu, "option3", "Лево(RY)");
				AddMenuItem(menu, "option4", "Право(RY)");
				AddMenuItem(menu, "option5", "Лево(RX)");
				AddMenuItem(menu, "option6", "Право(RX)");
				SetMenuExitButton(menu, true);
				DisplayMenu(menu, client, MENU_TIME_FOREVER);
				//
				PrintHintText(client, "RX:(%.1f) RY:(%.1f) RZ:(%.1f)", Angles[0], Angles[1], Angles[2]);
			}
			case 2:
			{
				TeleportEntity(id, NULL_VECTOR, Angles, NULL_VECTOR);
				Angles[1]+=RotateSpeedObject;
				//
				menu = CreateMenu(MenuObjectRoot);
				SetMenuTitle(menu, "Ротация объекта");
				AddMenuItem(menu, "option1", "Верх(RZ)");
				AddMenuItem(menu, "option2", "Низ(RZ)");
				AddMenuItem(menu, "option3", "Лево(RY)");
				AddMenuItem(menu, "option4", "Право(RY)");
				AddMenuItem(menu, "option5", "Лево(RX)");
				AddMenuItem(menu, "option6", "Право(RX)");
				SetMenuExitButton(menu, true);
				DisplayMenu(menu, client, MENU_TIME_FOREVER);
				//
				PrintHintText(client, "RX:(%.1f) RY:(%.1f) RZ:(%.1f)", Angles[0], Angles[1], Angles[2]);
			}
			case 3:
			{
				TeleportEntity(id, NULL_VECTOR, Angles, NULL_VECTOR);
				Angles[1]-=RotateSpeedObject;
				//
				menu = CreateMenu(MenuObjectRoot);
				SetMenuTitle(menu, "Ротация объекта");
				AddMenuItem(menu, "option1", "Верх(RZ)");
				AddMenuItem(menu, "option2", "Низ(RZ)");
				AddMenuItem(menu, "option3", "Лево(RY)");
				AddMenuItem(menu, "option4", "Право(RY)");
				AddMenuItem(menu, "option5", "Лево(RX)");
				AddMenuItem(menu, "option6", "Право(RX)");
				SetMenuExitButton(menu, true);
				DisplayMenu(menu, client, MENU_TIME_FOREVER);
				//
				PrintHintText(client, "RX:(%.1f) RY:(%.1f) RZ:(%.1f)", Angles[0], Angles[1], Angles[2]);
			}
			case 4:
			{
				TeleportEntity(id, NULL_VECTOR, Angles, NULL_VECTOR);
				Angles[0]+=RotateSpeedObject;
				//
				menu = CreateMenu(MenuObjectRoot);
				SetMenuTitle(menu, "Ротация объекта");
				AddMenuItem(menu, "option1", "Верх(RZ)");
				AddMenuItem(menu, "option2", "Низ(RZ)");
				AddMenuItem(menu, "option3", "Лево(RY)");
				AddMenuItem(menu, "option4", "Право(RY)");
				AddMenuItem(menu, "option5", "Лево(RX)");
				AddMenuItem(menu, "option6", "Право(RX)");
				SetMenuExitButton(menu, true);
				DisplayMenu(menu, client, MENU_TIME_FOREVER);
				//
				PrintHintText(client, "RX:(%.1f) RY:(%.1f) RZ:(%.1f)", Angles[0], Angles[1], Angles[2]);
			}
			case 5:
			{
				TeleportEntity(id, NULL_VECTOR, Angles, NULL_VECTOR);
				Angles[0]-=RotateSpeedObject;
				//
				menu = CreateMenu(MenuObjectRoot);
				SetMenuTitle(menu, "Ротация объекта");
				AddMenuItem(menu, "option1", "Верх(RZ)");
				AddMenuItem(menu, "option2", "Низ(RZ)");
				AddMenuItem(menu, "option3", "Лево(RY)");
				AddMenuItem(menu, "option4", "Право(RY)");
				AddMenuItem(menu, "option5", "Лево(RX)");
				AddMenuItem(menu, "option6", "Право(RX)");
				SetMenuExitButton(menu, true);
				DisplayMenu(menu, client, MENU_TIME_FOREVER);
				//
				PrintHintText(client, "RX:(%.1f) RY:(%.1f) RZ:(%.1f)", Angles[0], Angles[1], Angles[2]);
			}
		}
	}
}
CreateEntity(const String:entity[], const String:item[], const String:model[] = "" )
{
	new client;
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