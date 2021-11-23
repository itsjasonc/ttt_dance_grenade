if SERVER then
	resource.AddFile('materials/vgui/ttt/hud_icon_dancing.png')
end

AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "ttt_basegrenade_proj"
ENT.Model = Model("models/weapons/w_eq_fraggrenade_thrown.mdl")


if (CLIENT) then
	hook.Add('Initialize', 'ttt2_dance_grenade_status_init', function()
		STATUS:RegisterStatus('ttt2_dance_grenade_status', {
			hud = Material('vgui/ttt/hud_icon_dancing.png'),
			type = 'bad'
		})
	end)
end

function ENT:Initialize()
	self:SetModel(self.Model)
	
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_BBOX)
	self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
	self:Activate()
	
	if SERVER then
		self.CurrentSong = DANCEGRENADE:GetRandomSong()
		self.SongTimer = ""
		self.Exploded = false
	end
end

function ENT:GetNearbyDancers()
	local pos = self:GetPos()
	
	local near = ents.FindInSphere(pos, GetConVar("ttt_dance_grenade_distance"):GetInt())
	if not near then return end
	
	local near_players = {}
	
	local ent = nil
	for i=1, #near do
		ent = near[i]
		if IsValid(ent) and ent:IsPlayer() then
			table.insert(near_players, { ent=ent, dist=pos:LengthSqr()})
		end
	end
	
	return near_players
end

function ENT:StartExplosion(tr)
	if SERVER then
		self:SetMoveType(MOVETYPE_NONE)
		-- pull out of the surface
		if tr.Fraction != 1.0 then
			self:SetPos(tr.HitPos + tr.HitNormal * 0.6)
		end

		local pos = self:GetPos()
	
		self.SongTimer = 'ttt2_dance_grenade_timer_' .. tostring(CurTime())
		self.tick = 0
		
		self:EmitSound(self.CurrentSong, 130)
		
		timer.Create(self.SongTimer, GetConVar("ttt_dance_grenade_duration"):GetInt(), 1, function()
			timer.Stop(self.SongTimer)
			self:Remove()
		end)
	else
		
		PrintTable(effects.EffectTable)
		local spos = self:GetPos()
		local trs = util.TraceLine({start=spos + Vector(0,0,64), endpos=spos + Vector(0,0,-128), filter=self})
		util.Decal("Scorch", trs.HitPos + trs.HitNormal, trs.HitPos - trs.HitNormal)	

		self:SetDetonateExact(0)
	end
end

function ENT:Explode(tr)
	if SERVER then
		if not self.Exploded then
			self.Exploded = true
			self:StartExplosion(tr)
		end

		local pos = self:GetPos()
		
		local clr = Color( math.random(255), math.random(255), math.random(255), math.random(255) )

		local r = bit.band( clr.r, 255 )
		local g = bit.band( clr.g, 255 )
		local b = bit.band( clr.b, 255 )
		local a = bit.band( clr.a, 255 )

		local numberClr = bit.lshift( r, 24 ) + bit.lshift( g, 16 ) + bit.lshift( b, 8 ) + a

		local effect = EffectData()
		effect:SetOrigin(pos)
		effect:SetRadius(GetConVar("ttt_dance_grenade_distance"):GetInt())
		effect:SetColor(numberClr)
		effect:SetMagnitude(0.5)
		effect:SetScale(1)
		util.Effect("dance_sphere", effect, true, true)
		util.Effect("sparks", effect, true, true)
		util.Effect("VortDispel", effect, true, true)

		if tr.Fraction != 1.0 then
			effect:SetNormal(tr.HitNormal)
		end
		
		local dancers = self:GetNearbyDancers()
		
		-- table.SortByMember(dancers, "dist", function(a, b) return a > b end)
		for i=1,#dancers do
			local dancer = dancers[i]
			if dancer and IsValid(dancer.ent) then
				self:StartDance(dancer.ent, self:GetThrower())
				dancer.ent:ViewPunch(Angle(
					(math.random() * 60) - 20,
					(math.random() * 60) - 20,
					(math.random() * 40) - 10
				))
				dancer.ent:ScreenFade( SCREENFADE.IN, Color( math.random(255), math.random(255), math.random(255), 128 ), 0.3, 0 )
			end
		end
	end
end


function ENT:OnRemove()
	local players = player.GetAll()
	
	for i=1,#players do
		hook.Call('StopDancing', nil, players[i])
	end
	
	if SERVER then
		self:StopSound(self.CurrentSong)
	end
end

if CLIENT then
	net.Receive('ttt2_dance_grenade_dance', function()
		local target = net.ReadEntity()
		
		if not target or not IsValid(target) then return end

		if target:Alive() then
			target.dancing = net.ReadBool()
			
			if target.dancing then
				-- start dance animation
				if math.random(0, 1) == 0 then
					target:AnimRestartGesture(GESTURE_SLOT_CUSTOM, ACT_GMOD_GESTURE_TAUNT_ZOMBIE, false)
				else
					target:AnimRestartGesture(GESTURE_SLOT_CUSTOM, ACT_GMOD_TAUNT_DANCE, false)
				end
			else
				-- stop dance animation
				target:AnimResetGestureSlot(GESTURE_SLOT_CUSTOM)
			end
		else
			target:AnimResetGestureSlot(GESTURE_SLOT_CUSTOM)
		end
	end)
	-- draw a screen overlay
	hook.Add('RenderScreenspaceEffects', 'ttt2_dancegun_screen_overlay', function()
		return
	end)
end

if SERVER then
	util.AddNetworkString('ttt2_dance_grenade_dance')

	function ENT:StartDance(ply, attacker)
		if not ply or not IsValid(ply) then return end
		if not ply:IsPlayer() then return end
		
		if not ply:IsFrozen() then
			hook.Call('StartDancing', nil, ply)
		end
	end
	
	hook.Add('StartDancing', 'ttt2_dance_grenade_start_dance', function(ply)
		if not IsValid(ply) or not ply:IsPlayer() then return end
		
		STATUS:AddStatus(ply, 'ttt2_dance_grenade_status')
		ply:Freeze(true)
		ply.dancing = true
		
		net.Start('ttt2_dance_grenade_dance')
		net.WriteEntity(ply)
		net.WriteBool(true)
		net.Broadcast()
		
		return true
	end)
	
	hook.Add('StopDancing', 'ttt2_dance_grenade_stop_dance', function(ply)
		if not IsValid(ply) or not ply:IsPlayer() then return end
		
		STATUS:RemoveStatus(ply, 'ttt2_dance_grenade_status')
		ply:Freeze(false)
		ply.dancing = false
			
		net.Start('ttt2_dance_grenade_dance')
		net.WriteEntity(ply)
		net.WriteBool(false)
		net.Broadcast()
		
		return true
	end)

	-- handle death of dancing player
	hook.Add('PlayerDeath', 'ttt2_dancegun_player_death', function(ply)
		if not IsValid(ply) or not ply:IsPlayer() then return end
		
		STATUS:RemoveStatus(ply, 'ttt2_dance_grenade_status')
		ply:Freeze(false)
		ply.dancing = false
			
		net.Start('ttt2_dance_grenade_dance')
		net.WriteEntity(ply)
		net.WriteBool(false)
		net.Broadcast()
	end)

	-- stop dancing on round end
	hook.Add('TTTEndRound', 'ttt2_dancegun_end_round', function(ply)
		for _, p in ipairs(player.GetAll()) do
			if p.dancing then
				STATUS:RemoveStatus(p, 'ttt2_dance_grenade_status')
				p:Freeze(false)
				p.dancing = false
					
				net.Start('ttt2_dance_grenade_dance')
				net.WriteEntity(p)
				net.WriteBool(false)
				net.Broadcast()
			end
		end
	end)
end