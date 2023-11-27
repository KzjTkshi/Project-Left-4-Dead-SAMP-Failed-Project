enum uData
{
    pPass,
    pKills,
    pDeaths,
    pVip,
    pLevel,
    pXP,
    PHours,
    pMedkit
}
new UserData[MAX_PLAYERS][uData]; 

enum server_data
{
	server_zombies,
	server_zombietimer
};
new ServerData[server_data];

enum zombie_data
{
	zombie_species,
	zombie_victim,
	zombie_roam,
	zombie_movement
};
new ZombieData[MAX_ZOMBIES][zombie_data];

enum victim_data
{
	victim_detect,
	victim_timer,
	victim_status,
	victim_kill
};
new VictimData[MAX_PLAYERS][victim_data];