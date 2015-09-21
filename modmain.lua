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

local require = GLOBAL.require
local STRINGS = GLOBAL.STRINGS

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

