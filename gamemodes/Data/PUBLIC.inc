public LoadUser_data(playerid,name[],value[])
{
    INI_Int("Password",UserData[playerid][pPass]);
    INI_Int("Kills",UserData[playerid][pKills]);
    INI_Int("Deaths",UserData[playerid][pDeaths]);
    INI_Int("V.I.P",UserData[playerid][pVip]);
    INI_Int("Level",UserData[playerid][pLevel]);
    INI_Int("XP",UserData[playerid][pXP]);
    INI_Int("Playing Hours",UserData[playerid][PHours]);
    INI_Int("Medkit",UserData[playerid][pMedkit]);
    return 1;
}

public OnRNPCDeath(npcid, killerid, reason)
{
    if(killerid != INVALID_PLAYER_ID)
	{
		if(VictimData[killerid][victim_kill] != npcid)
		{
			VictimData[killerid][victim_kill] = npcid;
			SetTimerEx("ResetZombieKill", 4000, false, "i", killerid);
			SendDeathMessage(killerid, npcid, reason);
	    }
	}
	
	SetPlayerColor(npcid, 0xFFFFFF00);

    ApplyAnimation(npcid, "PED", "KO_shot_front", 4.1, 0, 0, 0, 1, 0);
    SetTimerEx("RemoveZombieBody", 10000, false, "i", npcid);
	return 1;
}

public ResetDetectRange(playerid)
{
    VictimData[playerid][victim_status] = 0;
    VictimData[playerid][victim_detect] = ZOMBIE_DETECT;
	return 1;
}

public ResetZombieKill(playerid)
{
    VictimData[playerid][victim_kill] = INVALID_PLAYER_ID;
	return 1;
}

public RemoveZombieBody(npcid)
{
	RespawnRNPC(npcid);
	return 1;
}

public OnZombieCreate()
{
	RNPC_SetUpdateRate(80);
	
    MapAndreas_Init(MAP_ANDREAS_MODE_NOBUFFER);

	new type = random(4), name[MAX_PLAYER_NAME], zombieid = ServerData[server_zombies];
	if(type == SPRINTER_ZOMBIE)
	{
		ZombieData[zombieid][zombie_species] = SPRINTER_ZOMBIE;
	}
	else
	{
		ZombieData[zombieid][zombie_species] = RUNNER_ZOMBIE;
	}

	ZombieData[zombieid][zombie_victim]= INVALID_PLAYER_ID;

	format(name, sizeof(name), "Zombie_%i", zombieid + 1);
	ConnectRNPC(name);

	ServerData[server_zombies]++;

	if(ServerData[server_zombies] >= MAX_ZOMBIES)
	{
		KillTimer(ServerData[server_zombietimer]);
		printf("Number of zombies created: %i", ServerData[server_zombies]);
	}
	return 1;
}

public OnZombieUpdate()
{
	for(new i = 0; i < MAX_ZOMBIES; i++)
	{
		if(IsPlayerConnected(i) || IsPlayerNPC(i))
		{
			if(GetRNPCHealth(i) > 0)
			{
				new victimid, Float:pos[3];
				victimid = GetZombieVictim(i);
				GetPlayerPos(i, pos[0], pos[1], pos[2]);

				if(victimid != INVALID_PLAYER_ID)
			  	{
					if(IsPlayerInRangeOfPoint(victimid, VictimData[victimid][victim_detect], pos[0], pos[1], pos[2]))
					{
						if(IsPlayerInRangeOfPoint(victimid, 1.0, pos[0], pos[1], pos[2]))
						{
							ZombieData[i][zombie_victim] = victimid;

							ZombieData[i][zombie_movement] = 0;
							ZombieData[i][zombie_roam] = 0;

							RNPC_CreateBuild(i, PLAYER_RECORDING_TYPE_ONFOOT);
							RNPC_AddPause(100);
							RNPC_SetKeys(KEY_FIRE);
							RNPC_AddPause(100);
							RNPC_SetKeys(0);
							RNPC_FinishBuild();
							RNPC_StartBuildPlayback(i);

							new Float:health;
							GetPlayerHealth(victimid, health);
							SetPlayerHealth(victimid, health - ZOMBIE_DAMAGE);

							GameTextForPlayer(victimid, "~r~You are being bitten!", 3000, 5);
							continue;
						}
						else
						{
							ZombieData[i][zombie_movement] = 0;
							ZombieData[i][zombie_roam] = 0;

							GetPlayerPos(victimid, pos[0], pos[1], pos[2]);

							if(ZombieData[i][zombie_species] == SPRINTER_ZOMBIE)
							{
								MoveRNPC(i, pos[0], pos[1], pos[2], RNPC_SPEED_SPRINT, 1);
							}
							else
							{
								MoveRNPC(i, pos[0], pos[1], pos[2], RNPC_SPEED_RUN, 1);
							}
							continue;
						}
					}
				}
				else if(victimid == INVALID_PLAYER_ID)
				{
				    if(ZombieData[i][zombie_roam] == 0)
				    {
						ZombieData[i][zombie_roam]++;
				        ZombieData[i][zombie_victim] = INVALID_PLAYER_ID;

						RNPC_SetKeys(0);

						new point = random(6);
						if(point == 0) { pos[0] = pos[0] + 100.0; }
						else if(point == 1) { pos[0] = pos[0] - 100.0; }
						else if(point == 2) { pos[1] = pos[1] + 100.0; }
						else if(point == 3) { pos[1] = pos[1] - 100.0; }

						else if(point == 4) { pos[0] = pos[0] + 100.0; pos[1] = pos[1] + 100.0; }
						else if(point == 5) { pos[0] = pos[0] - 100.0; pos[1] = pos[1] - 100.0; }

						MoveRNPC(i, pos[0], pos[1], pos[2], RNPC_SPEED_WALK, 1);
						continue;
				    }
				    else
				    {
						ZombieData[i][zombie_roam]++;

						if(ZombieData[i][zombie_roam] >= MAX_ROAM)
						{
							ZombieData[i][zombie_roam] = 0;
							ZombieData[i][zombie_victim] = INVALID_PLAYER_ID;

							RNPC_SetKeys(0);

							new point = random(6);
							if(point == 0) { pos[0] = pos[0] + 100.0; }
							else if(point == 1) { pos[0] = pos[0] - 100.0; }
							else if(point == 2) { pos[1] = pos[1] + 100.0; }
							else if(point == 3) { pos[1] = pos[1] - 100.0; }

							else if(point == 4) { pos[0] = pos[0] + 100.0; pos[1] = pos[1] + 100.0; }
							else if(point == 5) { pos[0] = pos[0] - 100.0; pos[1] = pos[1] - 100.0; }

							MoveRNPC(i, pos[0], pos[1], pos[2], RNPC_SPEED_WALK, 1);

			            	ZombieData[i][zombie_movement]++;

							if(ZombieData[i][zombie_movement] >= MAX_MOVEMENT && IsZombieStranded(i) == true)
							{
								ZombieData[i][zombie_movement] = 0;
								SetRNPCHealth(i, 0.0);
							}
							continue;
						}
					}
				}
			}
		}
	}
	return 1;
}