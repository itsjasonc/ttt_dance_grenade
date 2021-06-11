-- DANCEGRENADE CONVARS
CreateConVar('ttt_dance_grenade_duration', 10.0, {FCVAR_NOTIFY, FCVAR_ARCHIVE})
CreateConVar('ttt_dance_grenade_distance', 150, {FCVAR_NOTIFY, FCVAR_ARCHIVE})

-- DANCEGRENADE HANDLING
DANCEGRENADE = {}
DANCEGRENADE.songs = {}

hook.Add('TTTUlxInitCustomCVar', 'ttt2_dance_grenade_replicate_convars', function(name)
	for _, song_name in ipairs(DANCEGRENADE.songs) do
		local convar_name = 'ttt_dance_grenade_song_' .. song_name .. '_enable'
		local repvar_name = 'rep_ttt_dance_grenade_song_' .. song_name .. '_enable'

		ULib.replicatedWritableCvar(convar_name, repvar_name, GetConVar(convar_name):GetBool(), true, false, name)
	end

	ULib.replicatedWritableCvar('ttt_dance_grenade_duration', 'rep_ttt_dance_grenade_duration', GetConVar('ttt_dance_grenade_duration'):GetFloat(), true, false, name)
	ULib.replicatedWritableCvar('ttt_dance_grenade_distance', 'rep_ttt_dance_grenade_distance', GetConVar('ttt_dance_grenade_distance'):GetInt(), true, false, name)
end)

function DANCEGRENADE:RegisterSong(song_id, song_path)
	CreateConVar('ttt_dance_grenade_song_' .. song_id .. '_enable', 1, {FCVAR_NOTIFY, FCVAR_ARCHIVE})
	table.insert(self.songs, song_id)

	sound.Add({
		name = song_id,
		channel = CHAN_STATIC,
		volume = 1.0,
		level = 130,
		sound = song_path
	})

	if SERVER then
		resource.AddFile('sound/' .. song_path)
	end
end

if SERVER then
	function DANCEGRENADE:GetRandomSong()
		local enabled_songs = {}
		for _, song_name in ipairs(DANCEGRENADE.songs) do
			local convar_name = 'ttt_dance_grenade_song_' .. song_name .. '_enable'

			if GetConVar(convar_name):GetBool() then
				table.insert(enabled_songs, song_name)
			end
		end

		-- no song enabled
		if #enabled_songs == 0 then return end

		-- return an enabled song
		return enabled_songs[math.random(#enabled_songs)]
	end
end

-- registering songs
hook.Add('OnGamemodeLoaded', 'ttt2_dance_grenade_register_songs', function()
	DANCEGRENADE:RegisterSong('russian', 'songs/russian.wav')
	DANCEGRENADE:RegisterSong('dug_dance', 'songs/dug_dance.wav')
	DANCEGRENADE:RegisterSong('90s_running', 'songs/90s_running.wav')
	DANCEGRENADE:RegisterSong('beverly_hills', 'songs/beverly_hills.wav')
	DANCEGRENADE:RegisterSong('hey_yeah', 'songs/hey_yeah.wav')
	DANCEGRENADE:RegisterSong('horse', 'songs/horse.wav')
	DANCEGRENADE:RegisterSong('spongebob', 'songs/spongebob.wav')
	DANCEGRENADE:RegisterSong('epic_sax', 'songs/epic_sax.wav')
	DANCEGRENADE:RegisterSong('number_one', 'songs/number_one.wav')
	DANCEGRENADE:RegisterSong('harry_potter', 'songs/harry_potter.wav')
	DANCEGRENADE:RegisterSong('take_on_me', 'songs/take_on_me.wav')
	DANCEGRENADE:RegisterSong('africa', 'songs/africa.wav')

	-- use this hook to add further songs
	hook.Run('TTT2DanceGrenadeAddSongs')
end)

-- add to ULX
if CLIENT then
	hook.Add('TTTUlxModifyAddonSettings', 'ttt2_dance_grenade_add_to_ulx', function(name)
		local tttrspnl = xlib.makelistlayout{w = 415, h = 318, parent = xgui.null}

		-- Basic Settings
		local tttrsclp = vgui.Create('DCollapsibleCategory', tttrspnl)
		tttrsclp:SetSize(390, 75)
		tttrsclp:SetExpanded(1)
		tttrsclp:SetLabel('Basic Settings')

		local tttrslst = vgui.Create('DPanelList', tttrsclp)
		tttrslst:SetPos(5, 25)
		tttrslst:SetSize(390, 75)
		tttrslst:SetSpacing(5)

		local tttslid1 = xlib.makeslider{label = 'ttt_dance_grenade_duration (def. 10.0)', repconvar = 'rep_ttt_dance_grenade_duration', min = 0, max = 60, decimal = 5, parent = tttrslst}
		tttrslst:AddItem(tttslid1)

		local tttslid2 = xlib.makeslider{label = 'ttt_dance_grenade_distance (def. 150)', repconvar = 'rep_ttt_dance_grenade_distance', min = 0, max = 1000, decimal = 0, parent = tttrslst}
		tttrslst:AddItem(tttslid2)

		-- Song Settings
		local tttrsclp1 = vgui.Create('DCollapsibleCategory', tttrspnl)
		tttrsclp1:SetSize(390, 20 * #DANCEGRENADE.songs)
		tttrsclp1:SetExpanded(1)
		tttrsclp1:SetLabel('Enable Songs')

		local tttrslst1 = vgui.Create('DPanelList', tttrsclp1)
		tttrslst1:SetPos(5, 25)
		tttrslst1:SetSize(390, 20 * #DANCEGRENADE.songs)
		tttrslst1:SetSpacing(5)

		for _, song_name in ipairs(DANCEGRENADE.songs) do
			local convar_name = 'ttt_dance_grenade_song_' .. song_name .. '_enable'
			local repvar_name = 'rep_ttt_dance_grenade_song_' .. song_name .. '_enable'

			local song = xlib.makecheckbox{label = convar_name .. ' (def. 1)', repconvar = repvar_name, parent = tttrslst1}
			tttrslst1:AddItem(song)
		end

		-- add to ULX
		xgui.hookEvent('onProcessModules', nil, tttrspnl.processModules)
		xgui.addSubModule('Dance Grenade', tttrspnl, nil, name)
	end)
end
