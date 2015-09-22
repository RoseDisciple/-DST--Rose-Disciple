local MakePlayerCharacter = require "prefabs/player_common"

local assets = {
        Asset( "ANIM", "anim/player_basic.zip" ),
        Asset( "ANIM", "anim/player_idles_shiver.zip" ),
        Asset( "ANIM", "anim/player_actions.zip" ),
        Asset( "ANIM", "anim/player_actions_axe.zip" ),
        Asset( "ANIM", "anim/player_actions_pickaxe.zip" ),
        Asset( "ANIM", "anim/player_actions_shovel.zip" ),
        Asset( "ANIM", "anim/player_actions_blowdart.zip" ),
        Asset( "ANIM", "anim/player_actions_eat.zip" ),
        Asset( "ANIM", "anim/player_actions_item.zip" ),
        Asset( "ANIM", "anim/player_actions_uniqueitem.zip" ),
        Asset( "ANIM", "anim/player_actions_bugnet.zip" ),
        Asset( "ANIM", "anim/player_actions_fishing.zip" ),
        Asset( "ANIM", "anim/player_actions_boomerang.zip" ),
        Asset( "ANIM", "anim/player_bush_hat.zip" ),
        Asset( "ANIM", "anim/player_attacks.zip" ),
        Asset( "ANIM", "anim/player_idles.zip" ),
        Asset( "ANIM", "anim/player_rebirth.zip" ),
        Asset( "ANIM", "anim/player_jump.zip" ),
        Asset( "ANIM", "anim/player_amulet_resurrect.zip" ),
        Asset( "ANIM", "anim/player_teleport.zip" ),
        Asset( "ANIM", "anim/wilson_fx.zip" ),
        Asset( "ANIM", "anim/player_one_man_band.zip" ),
        Asset( "ANIM", "anim/shadow_hands.zip" ),
        Asset( "SOUND", "sound/sfx.fsb" ),
        Asset( "SOUND", "sound/wilson.fsb" ),
        Asset( "ANIM", "anim/beard.zip" ),

        Asset( "ANIM", "anim/rosedisciple.zip" ),
        Asset( "ANIM", "anim/ghost_rosedisciple_build.zip" ),
}
local prefabs = {}

-- Custom starting items
local start_inv = {
 "heatrock",
 "heatrock",
 "orangeamulet",
 "tentaclespike",
}

-- Heat Immunity function
local function onstartoverheating(inst)
    inst.components.temperature:SetTemperature(23) -- Sets the temperature to 23ÂºC
end
 
-- Wetness Debuff function
local function onmoisturedelta(inst)
    if inst.components.moisture:IsWet() then -- If the character is wet
        inst.components.sanity.dapperness = TUNING.DAPPERNESS_TINY*-1 -- Drain sanity at a rate of 1.33/minute
    else -- If the character is not wet
        inst.components.sanity.dapperness = 0 -- Reset the sanity drain to 0
    end
end

local function updatestats(inst)
	if inst.sg:HasStateTag("nomorph") or
		inst:HasTag("playerghost") or
		inst.components.health:IsDead() then
		return
	end
	
	local sanitypercent = inst.components.sanity:GetPercent()
	if TheWorld.state.isday then
		inst.Light:Enable(false)
	elseif TheWorld.state.isdusk then
		inst.Light:Enable(false)
	elseif TheWorld.state.isnight then
		if sanitypercent >= 0.5 then
			inst.Light:Enable(true)
		else
			inst.Light:Enable(false)
		end
	end
end

local function onsanitydelta(inst, data)
	updatestats(inst)
end


local function onsave(inst, data)
end

local function onpreload(ins, data)
end

local function onbecameghost(inst)
	if inst._wasnomorph ~= nil then
		inst.wasnomorph = nil
		inst.talksoundoverride = nil
		inst.hurtsoundoverride = nil
		inst:RemoveEventCallback("sanitydelta", onsanitydelta)
	end
end

local function onbecamehuman(inst)
	if inst._wasnomorph == nil then
		inst._wasnomorph = inst.sg:HasStateTag("nomorph")
		inst.talksoundoverride = nil
		inst.hurtsoundoverride = nil
		inst:ListenForEvent("sanitydelta", onsanitydelta)
		onsanitydelta(inst, nil, true)
	end
end

local function onload(inst)
	inst:ListenForEvent("ms_respawnedfromghost", onbecamehuman)
	inst:ListenForEvent("ms_becameghost", onbecameghost)
	
	if inst:HasTag("playerghost") then
		onbecameghost(inst)
	else
		onbecamehuman(inst)
	end
end


-- This initializes for both clients and the host
local common_postinit = function(inst)
    inst.MiniMapEntity:SetIcon( "rosedisciple.tex" ) -- Minimap icon
end
 
-- This initializes for the host only
local master_postinit = function(inst)
	
    inst.soundsname = "willow" -- The sounds your character will play
	
	-- Uncomment if "wathgrithr"(Wigfrid) or "webber" voice is used
    --inst.talker_path_override = "dontstarve_DLC001/characters/"
    -- Stats    
    inst.components.health:SetMaxHealth(600) -- Base health
    inst.components.hunger:SetMax(600) -- Base hunger
    inst.components.sanity:SetMax(600) -- Base sanity
	inst.components.temperature.inherentinsulation = (TUNING.INSULATION_MED * 5)
	inst.components.temperature.mintemp = 20
	inst.components.temperature.maxtemp = 60
	inst.components.health.fire_damage_scale = 0
	inst.components.locomotor.walkspeed = (TUNING.WILSON_WALK_SPEED * 5.2)
	inst.components.locomotor.runspeed = (TUNING.WILSON_RUN_SPEED * 6.3)
	inst.components.locomotor.triggerscreep = false
	
    -- Damage multiplier (optional)
    inst.components.combat.damagemultiplier = 9
	
	-- Hunger rate (optional)
	inst.components.hunger.hungerrate = 1 * TUNING.WILSON_HUNGER_RATE
	
    -- Fire Immunity
    inst.components.health.fire_damage_scale = TUNING.WILLOW_FIRE_DAMAGE -- Willow's fire immunity
    inst.components.health.fire_timestart = TUNING.WILLOW_FIRE_IMMUNITY -- Willow's fire immunity
     
    -- Heat Immunity
    inst:ListenForEvent("startoverheating", onstartoverheating) -- Wait for the event saying the character starts overheating, and execute a function when it does
     
    -- Wetness Debuff
    inst:ListenForEvent("moisturedelta", onmoisturedelta) -- Wait for the event saying the moisture of the character has changed, and execute a function when it does
     
    -- Hounds don't attack you
    inst:AddTag("hound") -- Add the tag "hound" to the player
	
	-- Eating meat bonus and immunity to negative food stats
	inst.components.eater.strongstomach = true
	inst.components.eater.oldEat = inst.components.eater.Eat
	function inst.components.eater:Eat(food)
		if self:CanEat(food) then
			if food.components.edible.foodtype == FOODTYPE.MEAT then
				food.components.edible.healthvalue = food.components.edible.healthvalue * 1.5
				food.components.edible.hungervalue = food.components.edible.hungervalue * 1.5
				food.components.edible.sanityvalue = food.components.edible.sanityvalue * 1.5
			end
		end
		return inst.components.eater:oldEat(food)
	end
	
	-- Night Vision
	local light = inst.entity:AddLight()
	inst.Light:Enable(false)
    inst.Light:SetIntensity(.75)
    inst.Light:SetColour(197 / 255, 197 / 255, 50 / 255)
    inst.Light:SetFalloff(0.5)
    inst.Light:SetRadius(2)
	
	inst:WatchWorldState("daytime", function(inst) updatestats(inst) end , TheWorld)
	inst:WatchWorldState("dusktime", function(inst) updatestats(inst) end , TheWorld)
	inst:WatchWorldState("nighttime", function(inst) updatestats(inst) end , TheWorld)
	updatestats(inst)
	
	inst:ListenForEvent("sanitydelta", onsanitydelta)
	
	inst.OnSave = onsave
	inst.OnPreload = onpreload
	inst.OnLoad = onload
	
	return inst
    
end

return MakePlayerCharacter("rosedisciple", prefabs, assets, common_postinit, master_postinit, start_inv)
