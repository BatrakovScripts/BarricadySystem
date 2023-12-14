#include <sourcemod>
#include <sdktools>
#include <adminmenu>
#include <clientprefs>


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//*
//*                 BarricadySystem
//*                 Status: 1.0 Version.
//*					Автор релиза BatrakovScripts Ник на форуме(Alexander_Mirny)
//*					Плагин размещен - https://forum.myarena.ru/index.php?/topic/45769-sistema-barikadingameobjecteditor/#entry363090
//*
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#define Fance "models/props_exteriors/roadsidefence_512.mdl"
#define Dumpster "models/props_junk/dumpster.mdl"
#define Vehicle "models/props_junk/wheebarrow01a.mdl"
#define BarrelFire "models/props_junk/barrel_fire.mdl"
#define Sofa2 "models/props_interiors/sofa02.mdl"
#define BarricadeDoor "models/props_street/barricade_door_01.mdl"

new Float:Pos[3];
new Float:Angles[3];
new id;
new Float:SpeedObject = 3.0;
new Float:RotateSpeedObject = 3.0;

public OnPluginStart()
{
    HookEvent("player_say", player_say);
}
public OnMapStart()
{
	PrecacheModel(Fance);
	PrecacheModel(Dumpster);
	PrecacheModel(Vehicle);
	PrecacheModel(BarrelFire);
	PrecacheModel(Sofa2);
	PrecacheModel(BarricadeDoor);
}
public player_say(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	decl String:Text[35];
	GetEventString(event, "text", Text, 35);
	if (StrEqual(Text, "rotateobject"))
	{
		new Handle:menu = CreateMenu(MenuObjectRootSpeed);
		SetMenuTitle(menu, "Скорость вращения");
		AddMenuItem(menu, "option1", "1.5");
		AddMenuItem(menu, "option2", "3.6");
		AddMenuItem(menu, "option3", "4.7");
		AddMenuItem(menu, "option4", "5.8");
		AddMenuItem(menu, "option5", "6.9");
		AddMenuItem(menu, "option6", "7.10");
		AddMenuItem(menu, "option7", "8.13");
		AddMenuItem(menu, "option8", "9.3");
		AddMenuItem(menu, "option9", "10.2");
		AddMenuItem(menu, "option10", "11.5");
		AddMenuItem(menu, "option11", "12.9");
		AddMenuItem(menu, "option12", "13.23");
		SetMenuExitButton(menu, true);
		DisplayMenu(menu, client, MENU_TIME_FOREVER);
	}
	if (StrEqual(Text, "speedobject"))
	{
		new Handle:menu = CreateMenu(MenuObjectSpeed);
		SetMenuTitle(menu, "Скорость переещения");
		AddMenuItem(menu, "option1", "1.5");
		AddMenuItem(menu, "option2", "3.6");
		AddMenuItem(menu, "option3", "4.7");
		AddMenuItem(menu, "option4", "5.8");
		AddMenuItem(menu, "option5", "6.9");
		AddMenuItem(menu, "option6", "7.10");
		AddMenuItem(menu, "option7", "8.13");
		AddMenuItem(menu, "option8", "9.3");
		AddMenuItem(menu, "option9", "10.2");
		AddMenuItem(menu, "option10", "11.5");
		AddMenuItem(menu, "option11", "12.9");
		AddMenuItem(menu, "option12", "13.23");
		SetMenuExitButton(menu, true);
		DisplayMenu(menu, client, MENU_TIME_FOREVER);
	}
	if (StrEqual(Text, "edit 1"))
	{
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
		new Handle:menu = CreateMenu(MenuObjectList);
		SetMenuTitle(menu, "Объекты");
		AddMenuItem(menu, "option1", "Забор");
		AddMenuItem(menu, "option2", "Мусорный бак");
		AddMenuItem(menu, "option3", "Тачанка");
		AddMenuItem(menu, "option4", "Бочка с огнем");
		AddMenuItem(menu, "option5", "Диван");
		AddMenuItem(menu, "option7", "Барикадные ворота");
		SetMenuExitButton(menu, true);
		DisplayMenu(menu, client, MENU_TIME_FOREVER);
	}
	if (StrEqual(Text, "delete"))
	{
		RemoveEdict(id);
	}
}
public MenuObjectList(Handle:menu, MenuAction:action, client, itemNum)
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
				Pos[1] += 10.0;
				DispatchKeyValueVector(id, "Origin", Pos );
				DispatchKeyValueVector(id, "Angles", Angles );
				DispatchSpawn(id);
				PrintToChat(client, "Объект создан.");
			}
			case 1:
			{
				id = CreateEntityByName("prop_dynamic_override");
				DispatchKeyValue(id, "solid", "6");
				SetEntityModel(id, Dumpster);
				TeleportEntity(id, Pos, Angles, NULL_VECTOR);
				GetClientAbsOrigin(client, Pos);
				GetClientAbsAngles(client, Angles);
				Pos[1] += 10.0;
				DispatchKeyValueVector(id, "Origin", Pos );
				DispatchKeyValueVector(id, "Angles", Angles );
				DispatchSpawn(id);
				PrintToChat(client, "Объект создан.");
			}
			case 2:
			{
				id = CreateEntityByName("prop_dynamic_override");
				DispatchKeyValue(id, "solid", "6");
				SetEntityModel(id, Vehicle);
				TeleportEntity(id, Pos, Angles, NULL_VECTOR);
				GetClientAbsOrigin(client, Pos);
				GetClientAbsAngles(client, Angles);
				Pos[1] += 10.0;
				DispatchKeyValueVector(id, "Origin", Pos );
				DispatchKeyValueVector(id, "Angles", Angles );
				DispatchSpawn(id);
				PrintToChat(client, "Объект создан.");
			}
			case 3:
			{
				id = CreateEntityByName("prop_dynamic_override");
				DispatchKeyValue(id, "solid", "6");
				SetEntityModel(id, BarrelFire);
				TeleportEntity(id, Pos, Angles, NULL_VECTOR);
				GetClientAbsOrigin(client, Pos);
				GetClientAbsAngles(client, Angles);
				Pos[1] += 10.0;
				DispatchKeyValueVector(id, "Origin", Pos );
				DispatchKeyValueVector(id, "Angles", Angles );
				DispatchSpawn(id);
				PrintToChat(client, "Объект создан.");
			}
			case 4:
			{
				id = CreateEntityByName("prop_dynamic_override");
				DispatchKeyValue(id, "solid", "6");
				SetEntityModel(id, Sofa2);
				TeleportEntity(id, Pos, Angles, NULL_VECTOR);
				GetClientAbsOrigin(client, Pos);
				GetClientAbsAngles(client, Angles);
				Pos[1] += 10.0;
				DispatchKeyValueVector(id, "Origin", Pos );
				DispatchKeyValueVector(id, "Angles", Angles );
				DispatchSpawn(id);
				PrintToChat(client, "Объект создан.");
			}
			case 6:
			{
				id = CreateEntityByName("prop_dynamic_override");
				DispatchKeyValue(id, "solid", "6");
				SetEntityModel(id, BarricadeDoor);
				TeleportEntity(id, Pos, Angles, NULL_VECTOR);
				GetClientAbsOrigin(client, Pos);
				GetClientAbsAngles(client, Angles);
				Pos[1] += 10.0;
				DispatchKeyValueVector(id, "Origin", Pos );
				DispatchKeyValueVector(id, "Angles", Angles );
				DispatchSpawn(id);
				PrintToChat(client, "Объект создан.");
			}
		}
	}
}
public MenuObjectRootSpeed(Handle:menu, MenuAction:action, client, itemNum)
{
	if ( action == MenuAction_Select ) 
	{ 
		switch (itemNum)
		{
			case 0: RotateSpeedObject = 1.5, PrintToChat(client, "Скорость вращения изменена: %.1f", RotateSpeedObject);
			case 1: RotateSpeedObject = 3.6, PrintToChat(client, "Скорость вращения изменена: %.1f", RotateSpeedObject);
			case 2: RotateSpeedObject = 4.7, PrintToChat(client, "Скорость вращения изменена: %.1f", RotateSpeedObject);
			case 3: RotateSpeedObject = 5.8, PrintToChat(client, "Скорость вращения изменена: %.1f", RotateSpeedObject);
			case 4: RotateSpeedObject = 6.9, PrintToChat(client, "Скорость вращения изменена: %.1f", RotateSpeedObject);
			case 5: RotateSpeedObject = 7.10, PrintToChat(client, "Скорость вращения изменена: %.1f", RotateSpeedObject);
			case 6: RotateSpeedObject = 8.13, PrintToChat(client, "Скорость вращения изменена: %.1f", RotateSpeedObject);
			case 7: RotateSpeedObject = 9.3, PrintToChat(client, "Скорость вращения изменена: %.1f", RotateSpeedObject);
			case 8: RotateSpeedObject = 10.2, PrintToChat(client, "Скорость вращения изменена: %.1f", RotateSpeedObject);
			case 9: RotateSpeedObject = 11.5, PrintToChat(client, "Скорость вращения изменена: %.1f", RotateSpeedObject);
			case 10: RotateSpeedObject = 12.9, PrintToChat(client, "Скорость вращения изменена: %.1f", RotateSpeedObject);
			case 11: RotateSpeedObject = 13.23, PrintToChat(client, "Скорость вращения изменена: %.1f", RotateSpeedObject);
		}
	}
}
public MenuObjectSpeed(Handle:menu, MenuAction:action, client, itemNum)
{
	if ( action == MenuAction_Select ) 
	{ 
		switch (itemNum)
		{
			case 0: SpeedObject = 1.5, PrintToChat(client, "Скорость переещения изменена: %.1f", SpeedObject);
			case 1: SpeedObject = 3.6, PrintToChat(client, "Скорость переещения изменена: %.1f", SpeedObject);
			case 2: SpeedObject = 4.7, PrintToChat(client, "Скорость переещения изменена: %.1f", SpeedObject);
			case 3: SpeedObject = 5.8, PrintToChat(client, "Скорость переещения изменена: %.1f", SpeedObject);
			case 4: SpeedObject = 6.9, PrintToChat(client, "Скорость переещения изменена: %.1f", SpeedObject);
			case 5: SpeedObject = 7.10, PrintToChat(client, "Скорость переещения изменена: %.1f", SpeedObject);
			case 6: SpeedObject = 8.13, PrintToChat(client, "Скорость переещения изменена: %.1f", SpeedObject);
			case 7: SpeedObject = 9.3, PrintToChat(client, "Скорость переещения изменена: %.1f", SpeedObject);
			case 8: SpeedObject = 10.2, PrintToChat(client, "Скорость переещения изменена: %.1f", SpeedObject);
			case 9: SpeedObject = 11.5, PrintToChat(client, "Скорость переещения изменена: %.1f", SpeedObject);
			case 10: SpeedObject = 12.9, PrintToChat(client, "Скорость переещения изменена: %.1f", SpeedObject);
			case 11: SpeedObject = 13.23, PrintToChat(client, "Скорость переещения изменена: %.1f", SpeedObject);
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