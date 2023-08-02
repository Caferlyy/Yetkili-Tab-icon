#include <sourcemod>
#include <cstrike>
#include <sdktools>
#include <ScoreboardCustomLevels>
#include <sdkhooks>
#include <warden>
#undef REQUIRE_PLUGIN

#define LoopClients(%1) for(int %1 = 1; %1 <= MaxClients; %1++) if(IsClientInGame(%1))

int m_iOffset = -1;
int m_iLevel[MAXPLAYERS + 1];

bool g_bCustomLevels;
ConVar yetkili = null;
ConVar kurucu = null;

public Plugin:myinfo =
{
	name = "[GENEL] Yetkili Tab İcon",
	description = "Yetkililerinze skor tablosunda icon verir.",
	author = "Caferly",
	version = "1.1",
	url = "https://hovnect.com"
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	MarkNativeAsOptional("SCL_GetLevel");
	return APLRes_Success;
}


public void OnPluginStart()
{
	HookEvent("player_team", EventDeath, EventHookMode:1);
	HookEvent("player_spawn", EventSpawn, EventHookMode:1);
	HookEvent("round_start", RoundStart, EventHookMode:1);
	
	m_iOffset = FindSendPropInfo("CCSPlayerResource", "m_nPersonaDataPublicLevel");
	for (int i = 1; i <= MaxClients; i++)
	{
		m_iLevel[i] = -1;
	}
	g_bCustomLevels = LibraryExists("ScoreboardCustomLevels");
	yetkili = CreateConVar("sm_yetkili_ikon", "2023", "İkonu panelinize yüklerken arkasına koyduğunuz sayı. Örnek level2031 ise 2031 yazıcaksınız.");
	kurucu = CreateConVar("sm_kurucu_ikon", "2031", "İkonu panelinize yüklerken arkasına koyduğunuz sayı. Örnek level2031 ise 2031 yazıcaksınız.");
	
}
 
public void OnClientPutInServer(client)
{
	LoopClients(client)
	{
		if(client > 0)
		{
			HandleTag(client);
		}
	}
}

public Action RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	LoopClients(client)
	{
		if(client > 0)
		{
			HandleTag(client);
		}
	}
}

public Action EventSpawn(Event event, const char[] name, bool dontBroadcast)
{
	LoopClients(client)
	{
		if(client > 0)
		{
			HandleTag(client);
		}
	}
}

public Action EventDeath(Event event, const char[] name, bool dontBroadcast)
{
	LoopClients(client)
	{
		if(client > 0)
		{
			HandleTag(client);
		}
	}
}

public void OnLibraryAdded(const char[] name)
{
	if (StrEqual(name, "ScoreboardCustomLevels"))
		g_bCustomLevels = true;
}

public void OnLibraryRemoved(const char[] name)
{
	if (StrEqual(name, "ScoreboardCustomLevels"))
		g_bCustomLevels = false;
}

public void OnMapStart()
{
	char buffer[512];
	Format(buffer, sizeof(buffer), "materials/panorama/images/icons/xp/level%d.png", yetkili.IntValue);
	AddFileToDownloadsTable(buffer);
	SDKHook(GetPlayerResourceEntity(), SDKHook_ThinkPost, OnThinkPost);
	AutoExecConfig(true, "YetkiliTabIkon", "Meydan");
}
 
void HandleTag(client)
{
     if (CheckCommandAccess(client, "kurucu", ADMFLAG_ROOT))
    {
		    		m_iLevel[client] = kurucu.IntValue;
    }
    else if (CheckCommandAccess(client, "adminyetkili", ADMFLAG_BAN))
	{
		    		m_iLevel[client] = yetkili.IntValue;
	}
}

public void OnThinkPost(int m_iEntity)
{
	int m_iLevelTemp[MAXPLAYERS + 1] = 0;
	GetEntDataArray(m_iEntity, m_iOffset, m_iLevelTemp, MAXPLAYERS + 1);
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (m_iLevel[i] != -1)
		{
			if (m_iLevel[i] != m_iLevelTemp[i])
			{
				if (g_bCustomLevels && SCL_GetLevel(i) > 0)continue; // dont overwritte other custom level
				
				SetEntData(m_iEntity, m_iOffset + (i * 4), m_iLevel[i]);
			}
		}
	}
} 