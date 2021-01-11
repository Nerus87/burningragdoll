#include <corecontrol>

#pragma newdecls required

#define PLUGIN_NAME				"Burning Bodies"
#define PLUGIN_VERSION			"v1.0"
#define PLUGIN_DESCRIPTION		"Continue burning ragdolls after kill, fire afect on other players in range of burning body."

public Plugin myinfo = {
	name = PLUGIN_NAME,
	author = "Nerus",
	description = PLUGIN_DESCRIPTION,
	version = PLUGIN_VERSION,
	url = "https://forums.alliedmods.net/"
};

public void OnPluginStart()
{
	HookEvent("player_death", OnPlayerDeath, EventHookMode_Pre);
}

public Action OnPlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	int victim = GetClientFromEvent(event);

	if(!IsValidPlayer(victim, false))
		return Plugin_Continue;

	char weapon[32];
	GetEventString(event, "weapon", weapon, 32);

	if(StrEqual(weapon, "inferno"))
	{
		int ragdoll = GetEntPropEnt(victim, Prop_Send, "m_hRagdoll");

		AcceptEntityInput(ragdoll, "Ignite");

		SDKHook(ragdoll, SDKHook_Touch, OnPlayerTouchFiringBody);
	}

	return Plugin_Continue;
}

/*public void OnEntityCreated(int entity, const char[] classname)
{
	if(StrEqual(classname, "m_hRagdoll"))
	{
		if(GetEntProp(entity, Prop_Send, "InputIgnite") > 0)
			
	}
}*/

public Action OnPlayerTouchFiringBody(int ragdoll, int entity)
{
	//PrintToChatAll("In OnPlayerTouchFiringBody with ent: %d, %d", ragdoll, entity);

	if(!IsValidEntity(ragdoll) || !IsValidEntity(entity))
		return Plugin_Continue;

	if(IsValidPlayer(entity, false))
	{
		//PrintToChatAll("Player %N on fire by body.", entity);

		IgniteEntity(entity, 3.0);

		int	health = GetClientHealth(entity);

		health -= 10;

		if(health > 0)
			SetEntityHealth(entity, health);
		else
			ForcePlayerSuicide(entity);
	}
	else
	{
		char name[32];
		GetEntityClassname(entity, name, 32);

		if(!StrEqual(name, "m_hRagdoll"))
			return Plugin_Continue;

		//PrintToChatAll("Body on fire by body.", entity);

		AcceptEntityInput(entity, "Ignite");
	}

	return Plugin_Continue;
}
