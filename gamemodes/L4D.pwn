#if defined GAMEMODE CREDITS

        Scripter : Kazuji Takahashi
        Support & Spesial Thanks To : SA-MP Team

                Kazuji Gamemode Zombie Project v0.5

        Kalo ada bug mohon di maklumi karna ini gm test jadi ya awikawok  
        
#endif
#include <a_samp>
#include <YSI\y_ini>
#include <sscanf2>
#include <zcmd>
#include <foreach>
#include <rnpc>

#include "Data\DEFINE.inc"
#include "Data\COLORS.inc"
#include "Data\FORWARD.inc"
#include "Data\ENUM.inc"
#include "Data\FUNCTION.inc"

main()
{
    print("[SERVER]: Your gamemode successfully loaded!");
}

public OnGameModeInit()
{
//	SetGameModeText("L4D v0.5 BETA");
	SetGameModeText("Rev 0.5.5");
    DisableInteriorEnterExits();
    UsePlayerPedAnims();
    SetNameTagDrawDistance(30.0);
    EnableStuntBonusForAll(false);
    DisableInteriorEnterExits();
    AddPlayerClass(1,649.3278,-1353.5999,13.5483,312.8730,0,0,0,0,0,0); 
    for(new i = 0; i < MAX_ZOMBIES; i++)
	{
	    ZombieData[i][zombie_species] = RUNNER_ZOMBIE;
	    ZombieData[i][zombie_victim] = INVALID_PLAYER_ID;
	    ZombieData[i][zombie_movement] = 0;
	}

	ServerData[server_zombies] = 0;
	ServerData[server_zombietimer] = SetTimer("OnZombieCreate", 80, true);
	SetTimer("OnZombieUpdate", 1000, true);
	return 1;
}

public OnGameModeExit()
{
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	return 1;
}

public OnPlayerConnect(playerid)
{
    SetPlayerColor(playerid, -1);
    SetPlayerScore(playerid, UserData[playerid][pLevel]);
    if(!IsPlayerNPC(playerid))
    {
        if(fexist(UserPath(playerid)))
        { 
            INI_ParseFile(UserPath(playerid), "LoadUser_%s", .bExtra = true, .extra = playerid);
            ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_INPUT,""COL_WHITE"Login",""COL_WHITE"Type your password below to login.","Login","Quit");
        }
		else
	    {
	        ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_INPUT,""COL_WHITE"Registering...",""COL_WHITE"Type your password below to register a new account.","Register","Quit");
	    }
    }
    return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    new INI:File = INI_Open(UserPath(playerid));
    INI_SetTag(File,"data");
    INI_WriteInt(File,"Kills",UserData[playerid][pKills]);
    INI_WriteInt(File,"Deaths",UserData[playerid][pDeaths]);
    INI_WriteInt(File,"V.I.P",UserData[playerid][pVip]);
    INI_WriteInt(File,"Level",UserData[playerid][pLevel]);
    INI_WriteInt(File,"XP",UserData[playerid][pXP]);
    INI_WriteInt(File,"Playing Hours",UserData[playerid][PHours]);
    INI_WriteInt(File,"Medkit",UserData[playerid][pMedkit]);
    INI_Close(File);
    return 1;
}

public OnPlayerSpawn(playerid)
{
	GivePlayerWeapon(playerid, WEAPON_DEAGLE, 9999);
	if(IsPlayerNPC(playerid))
	{
	    new players = GetOnlinePlayers(), targetid = GetRandomPlayer(), position = random(10), Float:pos[3], health = random(5) + 3;
		if(players > 0 && targetid != INVALID_PLAYER_ID)
		{
			GetPlayerPos(targetid, pos[0], pos[1], pos[2]);
			
			ClearAnimations(playerid);

			SetPlayerPos(playerid, pos[0], pos[1], pos[2] + 500.0);
			SetPlayerInterior(playerid, 0);
			SetPlayerVirtualWorld(playerid, 0);

			if(position == 0) { SetPlayerPos(playerid, pos[0] + 100.0, pos[1], pos[2] + 500.00); }
			else if(position == 1) { SetPlayerPos(playerid, pos[0], pos[1] + 100.0, pos[2] + 500.00); }
			else if(position == 2) { SetPlayerPos(playerid, pos[0] - 100.0, pos[1], pos[2] + 500.00); }
			else if(position == 3) { SetPlayerPos(playerid, pos[0], pos[1] - 100.0, pos[2] + 500.00); }
			else if(position == 4) { SetPlayerPos(playerid, pos[0] + 150.0, pos[1], pos[2] + 500.00); }
			else if(position == 5) { SetPlayerPos(playerid, pos[0], pos[1] + 150.0, pos[2] + 500.00); }
			else if(position == 6) { SetPlayerPos(playerid, pos[0] - 150.0, pos[1], pos[2] + 500.00); }
			else { SetPlayerPos(playerid, pos[0], pos[1] - 150.0, pos[2] + 500.00); }
		}
		else
		{
			ClearAnimations(playerid);
			
			SetPlayerPos(playerid, 0.0, 0.0, 0.0 + 500.00);
			SetPlayerInterior(playerid, 0);
			SetPlayerVirtualWorld(playerid, 0);

			if(position == 0) { SetPlayerPos(playerid, 0.0 + 100.0, 0.0, 0.0 + 500.00); }
			else if(position == 1) { SetPlayerPos(playerid, 0.0, 0.0 + 100.0, 0.0 + 500.00); }
			else if(position == 2) { SetPlayerPos(playerid, 0.0 - 100.0, 0.0, 0.0 + 500.00); }
			else if(position == 3) { SetPlayerPos(playerid, 0.0, 0.0 - 100.0, 0.0 + 500.00); }
			else if(position == 4) { SetPlayerPos(playerid, 0.0 + 150.0, 0.0, 0.0 + 500.00); }
			else if(position == 5) { SetPlayerPos(playerid, 0.0, 0.0 + 150.0, 0.0 + 500.00); }
			else if(position == 6) { SetPlayerPos(playerid, 0.0 - 150.0, 0.0, 0.0 + 500.00); }
		}

		SetRNPCHealth(playerid, health);
		SetPlayerSkin(playerid, ZOMBIE_SKIN);
		SetPlayerColor(playerid, ZOMBIE_COLOUR);

		RNPC_SetShootable(playerid, 1);
		RNPC_ToggleVehicleCollisionCheck(playerid, 1);

		ZombieData[playerid][zombie_victim] = INVALID_PLAYER_ID;

	    ZombieData[playerid][zombie_roam] = 0;
	    ZombieData[playerid][zombie_movement] = 0;
	}
	else if(!IsPlayerNPC(playerid))
	{
    	VictimData[playerid][victim_status] = 0;
	    VictimData[playerid][victim_detect] = ZOMBIE_DETECT;
	}    
    new pname[MAX_PLAYER_NAME];
    GetPlayerName(playerid, pname, sizeof(pname));
    SetPlayerScore(playerid, UserData[playerid][pLevel]);
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
    if(IsPlayerNPC(killerid))
	{
		new health = random(25) + 15;
		SetRNPCHealth(killerid, health);
		ApplyAnimation(killerid, "BOMBER", "BOM_Plant", 4.1, 0, 1, 1, 1, 0, 1);
		SendDeathMessage(killerid, ZombieData[killerid][zombie_victim], reason);
		ZombieData[killerid][zombie_victim] = INVALID_PLAYER_ID;
	}    
    SendDeathMessage(playerid, killerid, reason);
    return 1;
}

public OnPlayerText(playerid, text[])
{
    new message[128], pname[MAX_PLAYER_NAME];
    GetPlayerName(playerid, pname, sizeof(pname));
    format(message, sizeof(message), "%s says: %s", pname, text);
    ProxDetector(30.0, playerid, message, -1);
    ApplyAnimation(playerid,"PED","IDLE_CHAT",2.0,1,0,0,1,1);
	return 0;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	return 0;
}

CMD:stats(playerid, params[])
{
    new string[256], pname[MAX_PLAYER_NAME];
    GetPlayerName(playerid, pname, sizeof(pname));
    format(string, sizeof(string), "Account Database\nUsername: %s\nKills: %d\nDeaths: %d\nPlaying Hours: %d\nLevel: %d\nDeaths: %d", pname, UserData[playerid][pKills], UserData[playerid][pDeaths], UserData[playerid][PHours], UserData[playerid][pLevel],UserData[playerid][pXP]);
    ShowPlayerDialog(playerid, 12371, DIALOG_STYLE_MSGBOX, "Left 4 Dead - Account Stats", string, "Close","");
    return 1;
}

CMD:engine(playerid, params[])
{
    new pname[MAX_PLAYER_NAME], string[128];
    GetPlayerName(playerid, pname, sizeof(pname));
    new vehicleid = GetPlayerVehicleID(playerid);
    new engine, lights, alarm, doors, bonnet, boot, objective;
    if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COLOR_RED, "[SERVER]: You're not inside a vehicle!");
    {
        if(GetPlayerVehicleSeat(playerid) == 0) 
            {
            GetVehicleParamsEx(vehicleid,engine,lights,alarm,doors,bonnet,boot,objective);
            if(engine == 1)
            {
                GetVehicleParamsEx(vehicleid,engine,lights,alarm,doors,bonnet,boot,objective);
                SetVehicleParamsEx(vehicleid,false,lights,alarm,doors,bonnet,boot,objective);
                GameTextForPlayer(playerid,"You turned the enigne off!",2000,6);
                format(string, sizeof(string), "* %s twists the key, turning off the engine. *", pname);
                ProxDetector(30, playerid, string, COLOR_PURPLE);
                return 1;
            }
            else
            SetVehicleParamsEx(vehicleid,true,lights,alarm,doors,bonnet,boot,objective);
            GameTextForPlayer(playerid,"You turned the engine on!",2000,6);
            format(string, sizeof(string), "* %s twists the key, turning on the engine. *", pname);
            ProxDetector(30, playerid, string, COLOR_PURPLE);
        }
        else SendClientMessage(playerid, COLOR_RED,"[SERVER]: You're not in the driver seat.");
        return 1;
    }
}

CMD:fixmyvw(playerid, params[])
{
    if(GetPlayerVirtualWorld(playerid) == 0) return SendClientMessage(playerid, COLOR_RED, "[SERVER]: Your virtual world is already fixed!");
    SetPlayerVirtualWorld(playerid, 0);
    SendClientMessage(playerid, COLOR_YELLOW, "[SERVER]: Your virtual world successfully fixed it!");
    return 1;
}
CMD:shout(playerid, params[])
{
    new string[128], shout[100], pname[MAX_PLAYER_NAME];
    GetPlayerName(playerid, pname, sizeof(pname));
    if(sscanf(params, "s[100]", shout)) return SendClientMessage(playerid, COLOR_RED, "[SERVER]: Usage: /shout [Action].");
    format(string, sizeof(string), "%s shouts: %s!", pname, shout);
    ProxDetector(50.0, playerid, string, -1);
    return 1;
}
CMD:b(playerid, params[])
{
    new string[128], text[100], pname[MAX_PLAYER_NAME];
    GetPlayerName(playerid, pname, sizeof(pname));
    if(sscanf(params, "s[100]", text)) return SendClientMessage(playerid, COLOR_RED, "[SERVER]: Usage: /b [Action].");
    format(string, sizeof(string), "* %s says: %s ))", pname, text);
    ProxDetector(30.0, playerid, string, -1);
    return 1;
}

CMD:useitem(playerid, params[])
{
    new itemname[32], pname[MAX_PLAYER_NAME], string[128];
    GetPlayerName(playerid, pname, sizeof(pname));
    if(sscanf(params,"s[32]",itemname))
    {
        SendClientMessage(playerid, COLOR_YELLOW, "[SERVER]: Usage: /useitems (Itemname).");
        SendClientMessage(playerid, COLOR_YELLOW, "[SERVER]: Items: Medkit (100HP)");
        return 1;
    }
    if(strcmp(itemname, "medkit", true) == 0)
    {
        if(UserData[playerid][pMedkit] < 1) return SendClientMessage(playerid, COLOR_RED, "[SERVER]: You don't have enough medkits to use!");
        {
            GameTextForPlayer(playerid, "~r~Used Medkit!", 3000, 5);
            UserData[playerid][pMedkit] -= 1;
            SendClientMessage(playerid, COLOR_YELLOW, "[SERVER]: You used 1 Medkit.");
            SetPlayerHealth(playerid, 100);
            format(string, sizeof(string), "* %s used a medkit, %s patched all of his wounds. *", pname, pname);
            ProxDetector(30, playerid, string, COLOR_PURPLE);
            return 1;
       }
    }
    return 1;           
}   
CMD:inventory(playerid, params[])
{
    new string[128];
    format(string, sizeof(string), "Medkits: %d", UserData[playerid][pMedkit]);
    ShowPlayerDialog(playerid, 12341, DIALOG_STYLE_MSGBOX, "Left 4 Dead - Inventory Item", string, "Close","");
    return 1;
}
CMD:inv(playerid, params[]) return cmd_inventory(playerid, params);

CMD:creategun(playerid, params[])
{
    new gunname[32], pname[MAX_PLAYER_NAME];
    GetPlayerName(playerid, pname, sizeof(pname));
    if(sscanf(params,"s[32]",gunname))
    {
        SendClientMessage(playerid, COLOR_YELLOW, "[SERVER]: Usage: /creategun (Gunname).");
        SendClientMessage(playerid, COLOR_YELLOW, "[SERVER]: Items: 9mm, shotgun, deagle, mp5, uzi, ak47, rifle");
        return 1;
    }
    if(strcmp(gunname, "9mm", true) == 0)
    {
		GameTextForPlayer(playerid, "~r~Crafted a gun 9mm!", 3000, 5);
		GivePlayerWeapon(playerid, WEAPON_COLT45, 99999);
		return 1;
    }
    if(strcmp(gunname, "shotgun", true) == 0)
    {
		GameTextForPlayer(playerid, "~r~Crafted a gun shotgun!", 3000, 5);
		GivePlayerWeapon(playerid, WEAPON_SHOTGUN, 99999);
		return 1;
    }
    if(strcmp(gunname, "deagle", true) == 0)
    {
		GameTextForPlayer(playerid, "~r~Crafted a gun desert eagle!", 3000, 5);
		GivePlayerWeapon(playerid, WEAPON_DEAGLE, 99999);
		return 1;
    }
    if(strcmp(gunname, "mp5", true) == 0)
    {
		GameTextForPlayer(playerid, "~r~Crafted a gun mp5!", 3000, 5);
		GivePlayerWeapon(playerid, WEAPON_MP5, 99999);
		return 1;
    }
    if(strcmp(gunname, "uzi", true) == 0)
    {
		GameTextForPlayer(playerid, "~r~Crafted a gun uzi!", 3000, 5);
		GivePlayerWeapon(playerid, WEAPON_UZI, 99999);
		return 1;
    }
    if(strcmp(gunname, "ak47", true) == 0)
    {
		GameTextForPlayer(playerid, "~r~Crafted a gun ak-47!", 3000, 5);
		GivePlayerWeapon(playerid, WEAPON_AK47, 99999);
		return 1;
    }
    if(strcmp(gunname, "rifle", true) == 0)
    {
		GameTextForPlayer(playerid, "~r~Crafted a gun rifle!", 3000, 5);
		GivePlayerWeapon(playerid, WEAPON_RIFLE, 99999);
		return 1;
    }
    return 1;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveCheckpoint(playerid)
{
	return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveRaceCheckpoint(playerid)
{
	return 1;
}

public OnRconCommand(cmd[])
{
	return 1;
}

public OnPlayerRequestSpawn(playerid)
{
	return 1;
}

public OnObjectMoved(objectid)
{
	return 1;
}

public OnPlayerObjectMoved(playerid, objectid)
{
	return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
	return 1;
}

public OnVehicleMod(playerid, vehicleid, componentid)
{
	return 1;
}

public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
	return 1;
}

public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
	return 1;
}

public OnPlayerSelectedMenuRow(playerid, row)
{
	return 1;
}

public OnPlayerExitedMenu(playerid)
{
	return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(!IsPlayerNPC(playerid))
    {
		if(PRESSED(KEY_JUMP) && GetPlayerState(playerid) == PLAYER_STATE_ONFOOT)//Shift
		{
		    if(VictimData[playerid][victim_status] == 0)
		    {
			    VictimData[playerid][victim_detect] = (ZOMBIE_DETECT * 2);
				VictimData[playerid][victim_status] = 1;
				VictimData[playerid][victim_timer] = SetTimerEx("ResetDetectRange", 25000, false, "i", playerid);
			}
			return 1;
		}

        if(HOLDING(KEY_SPRINT) && GetPlayerState(playerid) == PLAYER_STATE_ONFOOT)//Space
		{
		    if(VictimData[playerid][victim_status] == 0)
		    {
			    VictimData[playerid][victim_detect] = (ZOMBIE_DETECT * 2);
				VictimData[playerid][victim_status] = 1;
				VictimData[playerid][victim_timer] = SetTimerEx("ResetDetectRange", 25000, false, "i", playerid);
			}
			return 1;
		}

		if(HOLDING(KEY_FIRE) && GetPlayerState(playerid) == PLAYER_STATE_ONFOOT)//LMB
		{
			if(IsHoldingFirearm(playerid) == 1)
			{
			    if(GetPlayerWeapon(playerid) != 23)
			    {
					VictimData[playerid][victim_detect] = (ZOMBIE_DETECT * 4);
					if(VictimData[playerid][victim_status] == 1) { KillTimer(VictimData[playerid][victim_timer]); }
					VictimData[playerid][victim_status] = 1;
					VictimData[playerid][victim_timer] = SetTimerEx("ResetDetectRange", 25000, false, "i", playerid);
				}
			}
			return 1;
		}
	}    
    return 1;
}
public OnRconLoginAttempt(ip[], password[], success)
{
	return 1;
}

public OnPlayerUpdate(playerid)
{
	return 1;
}

public OnPlayerStreamIn(playerid, forplayerid)
{
	return 1;
}

public OnPlayerStreamOut(playerid, forplayerid)
{
	return 1;
}

public OnVehicleStreamIn(vehicleid, forplayerid)
{
	return 1;
}

public OnVehicleStreamOut(vehicleid, forplayerid)
{
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    switch( dialogid )
    {
        case DIALOG_REGISTER:
        {
            if (!response) return Kick(playerid);
            if(response)
            {
                if(!strlen(inputtext)) return ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_INPUT, ""COL_WHITE"Registering...",""COL_RED"You have entered an invalid password.\n"COL_WHITE"Type your password below to register a new account.","Register","Quit");
                new INI:File = INI_Open(UserPath(playerid));
                INI_SetTag(File,"data");
                INI_WriteInt(File,"Password",udb_hash(inputtext));
                INI_WriteInt(File,"Kills",0);
                INI_WriteInt(File,"Deaths",0);
                INI_WriteInt(File,"V.I.P",0);
                INI_WriteInt(File,"Level",1);
                INI_WriteInt(File,"XP",0);
                INI_WriteInt(File,"Dialog Status",0);
                INI_WriteInt(File,"Playing Hours",0);
                INI_WriteInt(File,"Medkit",0);
                INI_Close(File);

                ForceClassSelection(playerid);
                ShowPlayerDialog(playerid, DIALOG_SUCCESS_1, DIALOG_STYLE_MSGBOX,""COL_WHITE"Success!",""COL_GREEN"Great! Your Y_INI system works perfectly. Relog to save your stats!","Ok","");
			}
        }

        case DIALOG_LOGIN:
        {
            if ( !response ) return Kick ( playerid );
            if( response )
            {
                if(udb_hash(inputtext) == UserData[playerid][pPass])
                {
                    INI_ParseFile(UserPath(playerid), "LoadUser_%s", .bExtra = true, .extra = playerid);
					ShowPlayerDialog(playerid, DIALOG_SUCCESS_2, DIALOG_STYLE_MSGBOX,""COL_WHITE"Success!",""COL_GREEN"You have successfully logged in!","Ok","");
                }
                else
                {
                    ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_INPUT,""COL_WHITE"Login",""COL_RED"You have entered an incorrect password.\n"COL_WHITE"Type your password below to login.","Login","Quit");
				}
                return 1;
            }
        }
    }
    return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}
