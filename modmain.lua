local require = GLOBAL.require
local STRINGS = GLOBAL.STRINGS
local Trader = require "components/trader"
local FindEntity = GLOBAL.FindEntity

PrefabFiles = {
	"rosedisciple",
}

Assets = {
    Asset( "IMAGE", "images/saveslot_portraits/rosedisciple.tex" ),
    Asset( "ATLAS", "images/saveslot_portraits/rosedisciple.xml" ),

    Asset( "IMAGE", "images/selectscreen_portraits/rosedisciple.tex" ),
    Asset( "ATLAS", "images/selectscreen_portraits/rosedisciple.xml" ),
	
    Asset( "IMAGE", "images/selectscreen_portraits/rosedisciple_silho.tex" ),
    Asset( "ATLAS", "images/selectscreen_portraits/rosedisciple_silho.xml" ),

    Asset( "IMAGE", "bigportraits/rosedisciple.tex" ),
    Asset( "ATLAS", "bigportraits/rosedisciple.xml" ),
	
	Asset( "IMAGE", "images/map_icons/rosedisciple.tex" ),
	Asset( "ATLAS", "images/map_icons/rosedisciple.xml" ),
	
	Asset( "IMAGE", "images/avatars/avatar_rosedisciple.tex" ),
    Asset( "ATLAS", "images/avatars/avatar_rosedisciple.xml" ),
	
	Asset( "IMAGE", "images/avatars/avatar_ghost_rosedisciple.tex" ),
    Asset( "ATLAS", "images/avatars/avatar_ghost_rosedisciple.xml" ),

}


AddComponentPostInit("combat", function(inst)
	local old_SuggestTarget = inst.SuggestTarget
	function inst:SuggestTarget(target)
		if not self.target and target ~= nil
		and target.prefab == "rosedisciple" and target:HasTag("houndwhisperer")
		and (self.inst.components.follower and target.components.follower
		and (self.inst.components.follower.leader and target.components.follower.leader
		and (self.inst.components.follower.leader == target.components.follower.leader))) then
			return false
		end
		return old_SuggestTarget(self, target)
	end
end)


local old_CanAccept = Trader.CanAccept
function Trader:CanAccept(item , giver)
	return self.enabled and (not self.test or self.test(self.inst, item, giver))
end

local old_AcceptGift = Trader.AcceptGift
function Trader:AcceptGift(giver, item)
	if not self.enabled then
		return false
	end
		
	if self:CanAccept(item, giver) then
		if item.components.stackable and item.components.stackable.stacksize > 1 then
			item = item.components.stackable:Get()
		else
			item.components.inventoryitem:RemoveFromOwner()
		end
		
		if self.inst.components.inventory then
			self.inst.components.inventory:GiveItem(item)
		else
			item:Remove()
		end
		
		if self.onaccept then
			self.onaccept(self.inst, giver, item)
		end
		
		self.inst:PushEvent("trade", {giver = giver, item = item})
		
		return true
	end
	
	if self.onrefuse then
		self.onrefuse(self.inst, giver, item)
	end
end


-- Hounds
local function Hound_ShouldAcceptItem(inst, item, giver)
	if not giver:HasTag("houndwhisperer") then
		return false
	end
	if inst.components.sleeper:IsAsleep() then
		return false
	end
	if inst.components.eater:CanEat(item) then
		return true
	end
end

local function Hound_OnGetItemFromPlayer(inst, giver, item)
	if inst.components.eater:CanEat(item) then  
		local playedfriendsfx = false
		if giver.components.leader then
			inst.SoundEmitter:PlaySound("dontstarve/common/makeFriend")
			playedfriendsfx = true
			inst.components.combat:SetTarget(nil)
			giver.components.leader:AddFollower(inst)
			--the companion tag already exists in the game : it will mark befriended hounds for Wilburn.
			--Note: McTusk has "pet_hound"s instead of "companion"s. It has to be different.
			inst:AddTag("companion")
			for k,v in pairs(giver.components.leader.followers) do
				if k.components.combat and k.components.follower then
					k.components.combat:SetTarget(nil)
				end
			end
			inst.components.follower:AddLoyaltyTime(item.components.edible:GetHunger() * TUNING.PIG_LOYALTY_PER_HUNGER)
		end
	end
end

local function Hound_OnRefuseItem(inst, item)
	if inst.components.sleeper:IsAsleep() then
		inst.components.sleeper:WakeUp()
	end
end

local function Hound_General_PostInit(inst)
	if not GLOBAL.TheWorld.ismastersim then
		return inst
	end
	
	local old_targetfn = inst.components.combat.targetfn
	inst.components.combat:SetRetargetFunction(3, function(inst)
		if inst:HasTag("companion") then
			return FindEntity(inst, TUNING.HOUND_FOLLOWER_TARGET_DIST, function(guy)
				return not guy:HasTag("wall")
					and not guy:HasTag("houndmound")
					and not (guy:HasTag("hound") or guy:HasTag("houndfriend"))
					and not (inst.components.follower and inst.components.follower.leader
							and guy == inst.components.follower.leader)
					and inst.components.combat:CanTarget(guy)
			end)
		else
			return old_targetfn(inst)
		end
	end)
	
	if not inst.components.follower then
		inst:AddComponent("follower")
	end
	
	inst.components.follower.maxfollowtime = TUNING.TOTAL_DAY_TIME * 2.5
	if not inst.components.trader then
		inst:AddComponent("trader")
	end
	
	inst.components.trader:SetAcceptTest(Hound_ShouldAcceptItem)
	inst.components.trader.onaccept = Hound_OnGetItemFromPlayer
	inst.components.trader.onrefuse = Hound_OnRefuseItem
	if GLOBAL.TheWorld.ismastersim then
		local old_sleeptestfn = inst.components.sleeper.sleeptestfn
		inst.components.sleeper:SetSleepTest(function(inst)
			if not inst:HasTag("companion") then
				return old_sleeptestfn(inst)
			else
				return not GLOBAL.TheWorld.state.isday
					and not (inst.components.combat and inst.components.combat.target)
					and not (inst.components.burnable and inst.components.burnable:IsBurning() )
					and (not inst.components.homeseeker or inst:IsNear(inst.components.homeseeker.home, SLEEP_NEAR_HOME_DISTANCE))
			end
		end)
	end
	
	local old_sanityaura = inst.components.sanityaura.aura
	inst.components.sanityaura.aurafn = (function(inst)
		if inst:HasTag("companion") then
			return -TUNING.SANITYAURA_SMALL
		end
		return old_sanityaura
	end)
	
	local old_OnSave = inst.OnSave
	inst.OnSave = (function(inst, data)
		data.iscompanion = inst:HasTag("companion")
		return old_OnSave(inst, data)
	end)
	
	local old_OnLoad = inst.OnLoad
	inst.OnLoad = (function(inst, data)
		if data then 
			if data.iscompanion then
				inst:AddTag("companion")
				if inst.sg then
					inst.sg:GoToState("idle")
				end
			else
				return old_OnLoad(inst, data)
			end
		end
	end)
end

AddPrefabPostInit("hound", Hound_General_PostInit)
AddPrefabPostInit("firehound", Hound_General_PostInit)
AddPrefabPostInit("icehound", Hound_General_PostInit)


-- The character select screen lines
STRINGS.CHARACTER_TITLES.rosedisciple = "Rose Disciple"
STRINGS.CHARACTER_NAMES.rosedisciple = "Rose"
STRINGS.CHARACTER_DESCRIPTIONS.rosedisciple = "*Fire and Heat resistant\n*Hellishly Strong\n*Fast"
STRINGS.CHARACTER_QUOTES.rosedisciple = "\"A friend of hounds\""

-- Custom speech strings
STRINGS.CHARACTERS.ROSEDISCIPLE = require "speech_rosedisciple"

-- The character's name as appears in-game 
STRINGS.NAMES.ROSEDISCIPLE = "Rose"

-- The default responses of examining the character
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ROSEDISCIPLE = 
{
	GENERIC = "It's Rose!",
	ATTACKER = "That Rose looks shifty...",
	MURDERER = "Murderer!",
	REVIVER = "Rose, friend of ghosts.",
	GHOST = "Rose could use a heart.",
}


AddMinimapAtlas("images/map_icons/rosedisciple.xml")

-- Add mod character to mod character list. Also specify a gender. Possible genders are MALE, FEMALE, ROBOT, NEUTRAL, and PLURAL.
AddModCharacter("rosedisciple", "FEMALE")

