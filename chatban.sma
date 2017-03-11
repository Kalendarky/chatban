#include <amxmodx>
#include <amxmisc>
#include <dhudmessage>
#include <engine>
#include <fakemeta>
#include <hamsandwich>
#include <fun>
#include <colorchat>
#include <cstrike>
#include <nvault>

#define PLUGIN "ChatBan System v2.1 (BUGFIX1)"
#define VERSION "2.1 (AMXMODX 1.8.2)"
#define AUTHOR "Kalendarky"

#define CREDITS "Belo95135"

new name[32];

new BanHud;
new iBanTimeRemaining[33];
new g_iPlayerChatBanTime[33];
new get_minutes[32];
new bantime[32];

new g_nVault;

new const cansay[][] =
{
	"/rs",
	"/rank",
	"/top15",
	"/totojefixabynepisalotuhlaskusbanompritop15"
}
new const Nadavkoreklama[][] = 	
{
	"kokot",
	".kot",
	"ko kot",
	"mrdk",
	"debil",
	"dilinak",
	"pico",
	"prdel",
	"kurva",
	"dpc",
	"kurvo",
	"jebla",
	"mrd",
	"pica",
	"pice",
	"zkurvy",
	"zmrd",
	"curak",
	"kkt",
	"kokot",
	"vyjeban",
	"zasrane",
	"napic",
	"neser",
	"jebat",
	"piča",
	"píča",
	"vyjeb",
	"jebu",
	"dpc",
	"devka",
	"devko",
	"picus",
	"kotel",
	"gsko",
	"gamesit",
	"epiczone",
	"epic zone",
	"slaci.eu",
	"csforce",
	"cs-force",
	"gamenice",
	"v-gaming",
	"gigagame",
	"cs-down",
	"halfgam",
	"gamesites",
	"gayshits",
	"gay",
	"homos",
	"gsko",
	".cz",
	".com",
	".eu",
	".info",
	".ru",
	".sk",
	"buzerant",
	"jebly homos",
	"skap",
	"skap na rakovinu",
	"pojeb"
}

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_clcmd("say", "chat_madafaka")
	register_clcmd("say_team", "chat_madafaka")
	register_concmd("amx_chatban", "Chatban_CMD", ADMIN_BAN, "<name or #userid> <minutes> [reason]")
	register_concmd("amx_unchatban", "Unban_CMD", ADMIN_IMMUNITY, "<name or #userid>")
	
	BanHud = CreateHudSyncObj();
	
	g_nVault = nvault_open( "chatbanvault" );
}
public plugin_end( )
{
	nvault_close( g_nVault );
	
	return PLUGIN_CONTINUE;
}
public chat_madafaka(id) 
{	
	new Speech[192]
	read_args(Speech,192)
	remove_quotes(Speech)
	
	if(g_iPlayerChatBanTime[ id ] > 0)
		iBanTimeRemaining[id] = g_iPlayerChatBanTime[id] - time();
	else
		iBanTimeRemaining[ id ] = 0;
		
	for(new i = 0 ; i < sizeof ( cansay ) ; i++) 
	{
		if(iBanTimeRemaining[id] > 0 && equal(Speech,cansay[i]))
		{
			return PLUGIN_CONTINUE;
		}
		else if(iBanTimeRemaining[id] > 0 && !equal(Speech,cansay[i]))
		{
			ColorChat( id, GREEN, "^1[^4ChatBan^1] ^3Cas na ktory si dostal ban:^4 %d ^3minut (^4 %d ^3sekund)",get_minutes[id], bantime[id]);
			ColorChat( id, GREEN, "^1[^4ChatBan^1] ^3Mas ban na chat! Zostava:^4 %d ^3sekund",iBanTimeRemaining[ id ]);
			ColorChat( id, GREEN, "^1[^4ChatBan^1] ^3Prikazy ako ^4/rank, /rs, /top15 ^3su povolene!");
			return PLUGIN_HANDLED;
		}
	}
	for( new i = 0 ; i < sizeof ( Nadavkoreklama ) ; i++)  {
		if(containi(Speech, Nadavkoreklama[i]) != -1)
		{
			get_user_name( id, name, 31 )
			ColorChat( id, GREEN, "^1[^4ChatManager^1] ^1|^4Reklamy/Nadavky^1| ^3su zakazane.");
			ColorChat( id, GREEN, "^1[^4ChatBan^1] ^1Bol si zabanovany na chat na 1 minutu.");
			server_cmd("amx_chatban ^"%s^" 1 ^"Porusenie pravidiel[Nadavky/Reklama]^"", name)
			return PLUGIN_HANDLED;
		}
	}
	return PLUGIN_CONTINUE;
}
public client_connect(id)
{
	Load(id);
}
public client_disconnect(id)
{
	Save(id);
}
public Chatban_CMD(id, level, cid)
{
	if (!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED;
	
	new target[32], minutes[8], reason[64], admin[32], steamid[32];	
	read_argv(1, target, 31);
	read_argv(2, minutes, 7);
	read_argv(3, reason, 63);
	new targetid = cmd_target(id,target,8);
	
	get_user_authid(targetid,steamid,31);
	
	get_user_name(id,admin,31);
	
	
	if(!is_user_connected(targetid))
	{
		set_hudmessage( 255, 25, 60, -1.0, 0.16, 1, 0.03, 3.5, 0.03, 12.0 );
		ShowSyncHudMsg(id, BanHud,"Chyba, Chat ban nejde dat hracovy^nKtory neni pripojeny!");
		return PLUGIN_HANDLED;
	}
	
	get_user_name(targetid,name,31)
	
	get_minutes[targetid] = str_to_num(minutes);
	bantime[targetid] = str_to_num(minutes) * 60;
		
	g_iPlayerChatBanTime[targetid] = time() + bantime[targetid]; 
	
	set_hudmessage( 255, 25, 60, 0.27, 0.40, 0, 6.0, 12.0);	
	ShowSyncHudMsg(0,BanHud,"Hrac %s Dostal Chat Ban ^nod Admina: %s ^n Dovod:%s ^n Dlzka:%d minut", name ,admin ,reason, get_minutes[targetid]);
	
	return PLUGIN_HANDLED;
}	
public Unban_CMD(id, level, cid)
{
	if (!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED;
	
	new target[32], name[32], admin[32];
	
	read_argv(1, target, 31)
	new targetid = cmd_target(id,target,8)
	
	
	
	if(!is_user_connected(targetid))
	{
		set_hudmessage(0, 0, 255, 0.14, 0.04, 0, 6.0, 9.0)
		ShowSyncHudMsg(id, BanHud,"Chyba, UnChatban nejde dat hracovy^nKtory neni pripojeny!")
		return PLUGIN_HANDLED;
	}
	
	get_user_name(id,admin,31)

	
	g_iPlayerChatBanTime[targetid] = 0;
	iBanTimeRemaining[targetid] = 0;
	Save(targetid);

	Save(id)
	get_user_name(targetid,name,31)
	
	set_hudmessage( 255, 25, 60, 0.27, 0.40, 0, 6.0, 12.0);	
	ShowSyncHudMsg(0,BanHud,"Hrac %s Dostal Unban na Chat ^nod Admina: %s ", name ,admin);
	
	return PLUGIN_HANDLED;
}

public Save(id)
{
	new szAuthid[ 32 ];
	get_user_authid( id, szAuthid, charsmax(szAuthid) );
	
	new szVaultKey[ 128 ], szVaultData[ 512 ];
	
	formatex( szVaultKey, 127, "chatban-%s", szAuthid );
	formatex( szVaultData, 511, "%i %i %i", g_iPlayerChatBanTime[id], bantime[id], get_minutes[id]);
	nvault_set( g_nVault, szVaultKey, szVaultData );
}

public Load(id)
{
	new szAuthid[ 32 ];
	get_user_authid( id, szAuthid, charsmax(szAuthid) );
	
	new szVaultKey[ 128 ], szVaultData[ 512 ];
	
	formatex( szVaultKey, 127, "chatban-%s", szAuthid );
	formatex( szVaultData, 511, "%i %i %i", g_iPlayerChatBanTime[id], bantime[id], get_minutes[id]);
	
	nvault_get( g_nVault, szVaultKey, szVaultData, 511 );
	
	new chat_time[33],bants[33],getmin[33];
	
	parse( szVaultData, chat_time, 31, bants, 31, getmin, 31);
	
	new chattime[33];
	chattime[id] = str_to_num(chat_time);
	new bantss[33];
	bantss[id] = str_to_num(bants);
	new getmins[33];
	getmins[id] = str_to_num(getmin);
	
	if(chattime[id] > 0)
		g_iPlayerChatBanTime[ id ] = str_to_num(chat_time);
	else
		g_iPlayerChatBanTime[ id ] = 0;
	if(bantss[id] > 0)
		bantime[id] = str_to_num(bants);
	else
		bantime[id] = 0;
	if(getmins[id] > 0)
		get_minutes[id] = str_to_num(getmin);
	else
		get_minutes[id] = 0;
	
}
