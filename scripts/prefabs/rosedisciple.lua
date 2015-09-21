
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
 
-- Eating Meat Bonus
local function oneat(inst, food)
    if food and food.components.edible and food.components.edible.foodtype == FOODTYPE.MEAT then -- If it is food, edible, and meat
     
        local healthvalue = food.components.edible.healthvalue -- Shortcuts for having to write only "healthvalue" instead of "food.components.edible.healthvalue"
        local hungervalue = food.components.edible.foodvalue
        local sanityvalue = food.components.edible.sanityvalue
         
        if healthvalue and not healthvalue == 0 then -- If the food item has a health value, and it isn't 0
            if healthvalue >= 0 then -- If the food item's health value is over 0
            inst.components.health:DoDelta(healthvalue * 7.5) -- Multiplies food's health value by 1.5
            else -- If the food item's health value is below 0
            inst.components.health:DoDelta(healthvalue * -9.5) -- Multiplies food's health value by 1.5 and makes it positive
            end
        end
        if hungervalue and not hungervalue == 0 then
            if hungervalue >= 0 then
            inst.components.hunger:DoDelta(hungervalue * 7.5) -- Multiplies food's hunger value by 1.5
            else
            inst.components.hunger:DoDelta(hungervalue * -9.5) -- Multiplies food's hunger value by 1.5 and makes it positive
            end
        end
        if sanityvalue and not sanityvalue == 0 then
            if sanityvalue >= 0 then
            inst.components.sanity:DoDelta(sanityvalue * 7.5) -- Multiplies food's sanity value by 1.5
            else
            inst.components.sanity:DoDelta(sanityvalue * -9.5) -- Multiplies food's sanity value by 1.5 and makes it positive
            end
        end
    end
end
 
 
-- This initializes for both clients and the host
local common_postinit = function(inst)
    inst.MiniMapEntity:SetIcon( "rosedisciple.tex" ) -- Minimap icon
end
 
-- This initializes for the host only
local master_postinit = function(inst)
    inst.soundsname = "willow" -- The sounds your character will play
    inst.components.temperature.inherentinsulation = (TUNING.INSULATION_MED * 5)
	inst.components.temperature.mintemp = 20
	inst.components.temperature.maxtemp = 60
	inst.components.health.fire_damage_scale = 0
	inst.components.locomotor.walkspeed = (TUNING.WILSON_WALK_SPEED * 5.2)
	inst.components.locomotor.runspeed = (TUNING.WILSON_RUN_SPEED * 6.3)
	inst.components.locomotor.triggerscreep = false
	inst.components.eater.monsterimmune = true
	
local OldEat = inst.components.eater.Eat
inst.components.eater.Eat = function(self, food)
    if self:CanEat(food) and food.prefab:find("meat") then
        food.components.edible.healthvalue = food.components.edible.healthvalue + 8
		food.components.edible.foodvalue = food.components.edible.foodvalue + 8
		food.components.edible.sanityvalue = food.components.edible.sanityvalue + 8
    end
    return OldEat(self, food)
end
	-- Uncomment if "wathgrithr"(Wigfrid) or "webber" voice is used
    --inst.talker_path_override = "dontstarve_DLC001/characters/"
    -- Stats    
    inst.components.health:SetMaxHealth(600) -- Base health
    inst.components.hunger:SetMax(600) -- Base hunger
    inst.components.sanity:SetMax(600) -- Base sanity
	
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
     
    -- Add the eater component
    if inst.components.eater == nil then -- If the character doesn't have the component
    inst:AddComponent("eater") -- Add the component "eater" to let us execute a function when it eats
    end
    -- Execute a function when the character eats
    inst.components.eater:SetOnEatFn(oneat) -- Execute a function when the character eats
     
end

return MakePlayerCharacter("rosedisciple", prefabs, assets, common_postinit, master_postinit, start_inv)
