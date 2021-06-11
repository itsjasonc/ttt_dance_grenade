
AddCSLuaFile()

SWEP.HoldType			  = "weapon"

if CLIENT then
	
	SWEP.Author = "kreb"
	SWEP.Contact = "https://steamcommunity.com/id/verendus/"
	SWEP.Slot				= 3

	SWEP.ViewModelFlip	= false
	SWEP.ViewModelFOV	 = 54

	SWEP.Icon				= "vgui/ttt/icon_nades"
	SWEP.IconLetter		= "h"
	
	SWEP.PrintName = 'Dance Grenade'
	SWEP.Instructions = 'Primary attack to pull the pin! Throw it at your enemies to force them to dance!'
	
	SWEP.EquipMenuData = {
		type = 'item_weapon',
		name = 'Dance Grenade',
		desc = 'Primary attack to pull the pin! Throw it at your enemies to force them to dance!'
	}
end

SWEP.Base					= "weapon_tttbasegrenade"

SWEP.WeaponID			  = WEAPON_EQUIP
SWEP.CanBuy = { ROLE_TRAITOR, ROLE_DETECTIVE }
SWEP.Kind                   = WEAPON_NADE

SWEP.Spawnable			 = true
SWEP.AutoSpawnable		= true

SWEP.UseHands			  = true
SWEP.ViewModel			 = "models/weapons/cstrike/c_eq_fraggrenade.mdl"
SWEP.WorldModel			= "models/weapons/w_eq_fraggrenade.mdl"

SWEP.Weight				 = 5

-- really the only difference between grenade weapons: the model and the thrown
-- ent.

function SWEP:GetGrenadeName()
	return "ttt_dance_grenade_proj"
end
