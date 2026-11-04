-- ReplicatedStorage/Shared/Config.luau (ModuleScript)
--!strict
-- Kingdom Nights: Castle Defense — single source of truth for every tunable number.
-- v2: adds Heroes, Shards, Difficulty tiers, Matchmaking, Endless, Mounts;
--     rebuilds Monetize; shortens runs to 6-9 minutes.
-- Rule: no gameplay number is hardcoded anywhere else in the codebase.
-- Balance iteration, A/B tests and liveops tuning are all one-file edits.

local Types = require(script.Parent.Types)

local Config = {}

Config.Version = 2
Config.LobbyPlaceId = 0   -- TODO: set after publishing
Config.MatchPlaceId = 0   -- TODO: set after publishing

-- ═══════════════════════════════════════════════════════════════════
-- MATCH — phase timings, ranges, co-op scaling
-- ═══════════════════════════════════════════════════════════════════
Config.Match = {
	MorningSeconds        = 6,
	AfkSeconds            = 180,   -- no input for this long → auto-ready
	MaxDaySeconds         = 300,   -- hard ceiling; night starts regardless
	DayCountdownWarning   = 60,    -- banner appears this many seconds before the ceiling

	BuildRange            = 24,    -- studs; server adds +8 latency grace
	RallyRadius           = 120,   -- max distance a rally flag can sit from its building
	UnitLeashRange        = 25,    -- unit disengages and returns beyond this from its flag

	DownedSeconds         = 12,    -- auto-revive at castle
	TeammateReviveSeconds = 3,     -- hold-to-revive duration
	TeammateReviveRange   = 10,
	ReviveHpFraction      = 0.5,

	CoopEnemyScalePerPlayer = 0.35, -- waveCount *= 1 + 0.35*(players-1)
	CoopDropCurve           = 0.70, -- dropScale = (0.70*scale + 0.30) / scale
	CoopCrownBonus          = 0.10, -- +10% crowns if 2+ players for the whole run

	UpgradeChoiceSeconds  = 12,    -- payer must pick within this, else auto-pick default
	TickRate              = 10,    -- Hz for the light Match_Tick replication

	-- v2: run length is a HARD constraint. If a map tests longer than this,
	-- cut nights - never shorten the day phase, which is the part players enjoy.
	TargetRunSeconds      = 480,   -- 8 minutes
	MaxRunSeconds         = 540,   -- 9 minutes; anything longer is a design bug
	TargetNightSeconds    = 60,    -- author waves to 45-75s
	FreeLastStandPerRun   = 1,     -- all towers revive once below 30% castle HP.
	                               -- This exists INSTEAD of a Robux continue. Never sell one.
	BuildHintNights       = 3,     -- suggested-slot glow for the first N nights
	BuildHintDisableAfterRuns = 3,
}

-- ═══════════════════════════════════════════════════════════════════
-- ECONOMY
-- ═══════════════════════════════════════════════════════════════════
Config.Economy = {
	CoinMagnetRadius  = 20,
	CoinCollectRadius = 8,
	CoinMagnetSpeed   = 6,    -- lerp alpha per second
	CoinLifetime      = 45,   -- auto-collects after this so nothing is wasted
	GoldMineStart     = 6,
	GoldMineDecay     = 1,
	GoldMineFloor     = 1,
	HarbourMaxBoats   = 5,
	HarbourBoatIncome = 1,
}

-- ═══════════════════════════════════════════════════════════════════
-- DAMAGE MATRIX — the heart of the combat design.
-- Zeros and 2x+ values ARE the design. Do not flatten into a 0.9-1.1 band.
-- ═══════════════════════════════════════════════════════════════════
Config.Damage = {
	--                 Normal Flying  Fast  Siege Monster Armored Boss
	HeavyMelee   = { Normal=1.0, Flying=0.0, Fast=0.7, Siege=1.4, Monster=1.0, Armored=1.2, Boss=3.0 },
	LightMelee   = { Normal=1.0, Flying=0.5, Fast=2.0, Siege=0.8, Monster=1.0, Armored=0.7, Boss=2.0 },
	Bow          = { Normal=1.0, Flying=2.2, Fast=1.2, Siege=0.5, Monster=1.0, Armored=0.6, Boss=2.0 },
	Crossbow     = { Normal=1.0, Flying=1.0, Fast=0.7, Siege=1.0, Monster=1.0, Armored=1.8, Boss=1.5 },
	Magic        = { Normal=1.0, Flying=1.2, Fast=1.0, Siege=0.6, Monster=1.8, Armored=1.0, Boss=1.0 },
	TowerArrow   = { Normal=1.0, Flying=1.3, Fast=0.8, Siege=1.0, Monster=1.0, Armored=0.8, Boss=1.0 },
	TowerBallista= { Normal=1.0, Flying=0.6, Fast=0.5, Siege=2.5, Monster=1.0, Armored=2.0, Boss=1.5 },
	TowerFire    = { Normal=1.0, Flying=1.0, Fast=1.4, Siege=1.0, Monster=1.4, Armored=0.7, Boss=1.0 },
	UnitMelee    = { Normal=1.0, Flying=0.0, Fast=1.0, Siege=1.2, Monster=1.0, Armored=1.0, Boss=1.0 },
	UnitRanged   = { Normal=1.0, Flying=1.5, Fast=1.0, Siege=0.7, Monster=1.0, Armored=0.7, Boss=1.0 },
	CastleGuard  = { Normal=1.0, Flying=1.0, Fast=1.0, Siege=1.0, Monster=1.0, Armored=1.0, Boss=1.0 },
}

-- ═══════════════════════════════════════════════════════════════════
-- BUILDINGS — gold costs kept 1:1 with the source design (small, readable).
-- HP is source value x5. Never inflate in-run gold.
-- ═══════════════════════════════════════════════════════════════════
Config.Buildings = {
	Castle = {
		Id = "Castle", Display = "Castle Center", Category = "Special", Model = "Castle",
		Levels = {
			{ Cost = 0,  Hp = 2000, AttackDamage = 12, AttackInterval = 1.2, AttackRange = 70,
			  ProjectileSpeed = 140 },
			{ Cost = 8,  Hp = 3200, AttackDamage = 18, AttackInterval = 1.0, AttackRange = 80,
			  ProjectileSpeed = 150, UpgradeChoices = { "royal_training", "builders_guild", "magic_armor" } },
			{ Cost = 20, Hp = 5000, AttackDamage = 26, AttackInterval = 0.85, AttackRange = 90,
			  ProjectileSpeed = 160, UpgradeChoices = { "royal_mastery", "commander", "castle_up" } },
		},
	},

	House = {
		Id = "House", Display = "House", Category = "Economy", Model = "House",
		Levels = {
			{ Cost = 2, Hp = 100, Income = 1 },
			{ Cost = 2, Hp = 200, Income = 2 },
		},
	},

	Mill = {
		Id = "Mill", Display = "Mill", Category = "Economy", Model = "Mill",
		Levels = {
			{ Cost = 3, Hp = 150, Income = 1,
			  UpgradeChoices = { "improved_plow", "explosive_trap", "scarecrows" } },
			{ Cost = 4, Hp = 220, Income = 2 },
			{ Cost = 6, Hp = 320, Income = 6 },   -- the payoff level; budget for the full chain
		},
	},

	Field = {
		Id = "Field", Display = "Field", Category = "Economy", Model = "Field",
		Levels = {
			{ Cost = 1, Hp = 50, Income = 1 },    -- deliberately fragile
		},
	},

	GoldMine = {
		Id = "GoldMine", Display = "Gold Mine", Category = "Economy", Model = "GoldMine",
		Levels = {
			{ Cost = 5, Hp = 100, Income = 6 },   -- depletes 1/night, floor 1 (see Config.Economy)
		},
	},

	Harbour = {
		Id = "Harbour", Display = "Fishing Harbour", Category = "Economy", Model = "Harbour",
		Levels = {
			{ Cost = 3, Hp = 300 },
			{ Cost = 7, Hp = 450 },               -- doubles boat income
		},
	},

	Tower = {
		Id = "Tower", Display = "Tower", Category = "Defense", Model = "Tower",
		Levels = {
			{ Cost = 3, Hp = 500,  AttackDamage = 10, AttackInterval = 1.0, AttackRange = 70,
			  ProjectileSpeed = 150 },
			{ Cost = 5, Hp = 800,  AttackDamage = 16, AttackInterval = 0.9, AttackRange = 75,
			  ProjectileSpeed = 160,
			  UpgradeChoices = { "castle_tower", "sniper_tower", "armored_tower" } },
			{ Cost = 9, Hp = 1200, AttackDamage = 26, AttackInterval = 0.8, AttackRange = 82,
			  ProjectileSpeed = 175,
			  UpgradeChoices = { "archers_spire", "ballistic_spire", "fire_spire", "healing_spire" } },
		},
	},

	Wall = {
		Id = "Wall", Display = "Wall", Category = "Defense", Model = "Wall",
		Levels = {
			{ Cost = 3, Hp = 1200 },
			{ Cost = 4, Hp = 2200 },
			{ Cost = 7, Hp = 3800 },
		},
	},

	Barracks = {
		Id = "Barracks", Display = "Barracks", Category = "Military", Model = "Barracks",
		Levels = {
			{ Cost = 4,  Hp = 150, UnitId = "knight", UnitCount = 4 },
			{ Cost = 6,  Hp = 250, UnitId = "knight", UnitCount = 8 },
			{ Cost = 10, Hp = 380, UnitId = "knight", UnitCount = 12 },
		},
	},

	ArcheryRange = {
		Id = "ArcheryRange", Display = "Archery Range", Category = "Military", Model = "ArcheryRange",
		Levels = {
			{ Cost = 4,  Hp = 150, UnitId = "archer", UnitCount = 4 },
			{ Cost = 6,  Hp = 250, UnitId = "archer", UnitCount = 8 },
			{ Cost = 10, Hp = 380, UnitId = "archer", UnitCount = 12 },
		},
	},

	HeroQuarters = {
		Id = "HeroQuarters", Display = "Hero's Quarters", Category = "Military", Model = "HeroQuarters",
		Levels = {
			{ Cost = 6,  Hp = 250, UnitId = "golem", UnitCount = 1 },
			{ Cost = 10, Hp = 400, UnitId = "golem", UnitCount = 1 },  -- heroes scale, don't multiply
		},
	},

	Blacksmith = {
		Id = "Blacksmith", Display = "Blacksmith", Category = "Special", Model = "Blacksmith",
		Levels = {
			{ Cost = 4,  Hp = 400, UpgradeChoices = { "res_melee_dmg", "res_ranged_dmg", "res_melee_armor", "res_ranged_armor" } },
			{ Cost = 9,  Hp = 600, UpgradeChoices = { "res_melee_dmg", "res_ranged_dmg", "res_melee_armor", "res_ranged_armor" } },
			{ Cost = 16, Hp = 900, UpgradeChoices = { "res_melee_dmg", "res_ranged_dmg", "res_melee_armor", "res_ranged_armor" } },
		},
	},

	RoyalForge = {
		Id = "RoyalForge", Display = "Royal Forge", Category = "Special", Model = "RoyalForge",
		Levels = {
			{ Cost = 4,  Hp = 400, UpgradeChoices = { "forge_lighter", "forge_armor", "forge_blessed", "forge_sharper" } },
			{ Cost = 7,  Hp = 600, UpgradeChoices = { "forge_lighter", "forge_armor", "forge_blessed", "forge_sharper" } },
			{ Cost = 14, Hp = 900, UpgradeChoices = { "forge_lighter", "forge_armor", "forge_blessed", "forge_sharper" } },
		},
	},

	Temple = {
		Id = "Temple", Display = "Temple", Category = "Special", Model = "Temple",
		Levels = {
			{ Cost = 2,  Hp = 750,  UpgradeChoices = { "temple_overload", "temple_icerain", "temple_wisdom" } },
			{ Cost = 6,  Hp = 1100, UpgradeChoices = { "temple_overload", "temple_icerain", "temple_wisdom" } },
			{ Cost = 25, Hp = 1800, UpgradeChoices = { "temple_overload", "temple_icerain", "temple_wisdom" } },
		},
	},
}

-- ═══════════════════════════════════════════════════════════════════
-- UPGRADES — branching choices. Permanent for the run.
-- Kind: "Instant" applies immediately; "Research" takes N nights.
-- ═══════════════════════════════════════════════════════════════════
Config.Upgrades = {
	-- Castle L2
	royal_training  = { Display = "Royal Training", Kind = "Instant", Desc = "+75% champion HP and damage",
	                    ChampHpMult = 1.75, ChampDamageMult = 1.75 },
	builders_guild  = { Display = "Builder's Guild", Kind = "Instant", Desc = "Free house upgrade each morning, +50% champion HP",
	                    ChampHpMult = 1.50, AutoUpgradeHousePerMorning = 1 },
	magic_armor     = { Display = "Magic Armor", Kind = "Instant", Desc = "Attackers take reflected damage, +150% champion HP",
	                    ChampHpMult = 2.50, ReflectFraction = 0.25 },
	-- Castle L3
	royal_mastery   = { Display = "Royal Mastery", Kind = "Instant", Desc = "+75% champion HP and damage",
	                    ChampHpMult = 1.75, ChampDamageMult = 1.75 },
	commander       = { Display = "Commander", Kind = "Instant", Desc = "Units fight while rallied, +60% unit speed, healing aura",
	                    UnitsFightWhileRallied = true, UnitSpeedMult = 1.60, HealAura = 0.02 },
	castle_up       = { Display = "Castle-Up", Kind = "Instant", Desc = "Wall and tower upgrade costs -1 each night (min 1)",
	                    UpgradeCostDecayPerNight = 1 },

	-- Tower L2
	castle_tower    = { Display = "Castle Tower", Kind = "Instant", Desc = "+150 HP, faster attacks",
	                    HpAdd = 150, IntervalMult = 0.85 },
	sniper_tower    = { Display = "Sniper Tower", Kind = "Instant", Desc = "More damage, longer range, slower fire",
	                    DamageMult = 2.2, RangeMult = 1.4, IntervalMult = 1.8 },
	armored_tower   = { Display = "Armored Tower", Kind = "Instant", Desc = "+350 HP, gains a shield when hit",
	                    HpAdd = 350, ShieldOnHit = 60 },
	-- Tower L3
	archers_spire   = { Display = "Archer's Spire", Kind = "Instant", Desc = "Fires an extra arrow, faster",
	                    HpAdd = 350, ExtraProjectiles = 1, IntervalMult = 0.8 },
	ballistic_spire = { Display = "Ballistic Spire", Kind = "Instant", Desc = "Massive damage, slows the target",
	                    DamageMult = 3.5, IntervalMult = 2.0, SlowFactor = 0.5, SlowSeconds = 2,
	                    DamageProfile = "TowerBallista" },
	fire_spire      = { Display = "Fire Spire", Kind = "Instant", Desc = "Splash damage with burning oil",
	                    HpAdd = 250, SplashRadius = 14, BurnDps = 8, DamageProfile = "TowerFire" },
	healing_spire   = { Display = "Healing Spire", Kind = "Instant", Desc = "Heals nearby allies instead of attacking",
	                    HpAdd = 750, HealsInstead = true, HealPerSecond = 22, HealRadius = 55 },

	-- Mill L1
	improved_plow   = { Display = "Improved Plow", Kind = "Instant", Desc = "+1 income for every future mill upgrade",
	                    IncomePerUpgrade = 1 },
	explosive_trap  = { Display = "Explosive Trap", Kind = "Instant", Desc = "Explodes when destroyed",
	                    DeathExplosionDamage = 400, DeathExplosionRadius = 30 },
	scarecrows      = { Display = "Scarecrows", Kind = "Instant", Desc = "Free anti-air scarecrow on each of its fields",
	                    ScarecrowDamage = 14, ScarecrowRange = 45 },

	-- Blacksmith research (army-wide)
	res_melee_dmg   = { Display = "Melee Weapons",  Kind = "Research", Nights = 3, Desc = "+20% melee damage",  ArmyMeleeDamageMult = 1.20 },
	res_ranged_dmg  = { Display = "Ranged Weapons", Kind = "Research", Nights = 3, Desc = "+20% ranged damage", ArmyRangedDamageMult = 1.20 },
	res_melee_armor = { Display = "Melee Armor",    Kind = "Research", Nights = 2, Desc = "+30% melee resistance",  ArmyMeleeResist = 0.30 },
	res_ranged_armor= { Display = "Ranged Armor",   Kind = "Research", Nights = 2, Desc = "+30% ranged resistance", ArmyRangedResist = 0.30 },

	-- Royal Forge research (champions)
	forge_lighter   = { Display = "Lighter Weaponry", Kind = "Research", Nights = 2, Desc = "-40% attack cooldown", ChampCooldownMult = 0.60 },
	forge_armor     = { Display = "Additional Armor", Kind = "Research", Nights = 2, Desc = "+50% HP and regen",    ChampHpMult = 1.50, ChampRegenMult = 1.50 },
	forge_blessed   = { Display = "Blessed Weaponry", Kind = "Research", Nights = 3, Desc = "-40% ability cooldown",ChampAbilityCdMult = 0.60 },
	forge_sharper   = { Display = "Sharper Weaponry", Kind = "Research", Nights = 3, Desc = "+40% weapon damage",   ChampDamageMult = 1.40 },

	-- Temple research (powerful, with real drawbacks)
	temple_overload = { Display = "Overload", Kind = "Research", Nights = 2, Desc = "Towers buffed but slowly lose health",
	                    TowerDamageMult = 1.60, TowerHpDrainPerSecond = 6 },
	temple_icerain  = { Display = "Ice Rain", Kind = "Research", Nights = 3, Desc = "Ice damages everything, including your own units",
	                    IceRainDps = 18, IceRainHitsAllies = true },
	temple_wisdom   = { Display = "Wisdom", Kind = "Research", Nights = 3, Desc = "Destroyed buildings drop gold, but all buildings slowly lose HP",
	                    DestroyedBuildingGold = 2, AllBuildingDrainPerSecond = 3 },
}

-- ═══════════════════════════════════════════════════════════════════
-- ENEMIES — HP and damage are source values x5. Speed is source x1.8, cap 30.
-- ═══════════════════════════════════════════════════════════════════
local function enemy(t): Types.EnemyDef return t :: any end

Config.Enemies = {
	weakling = enemy{ Id="weakling", Display="Weakling", Family="Human", Tags={"Normal"},
		Hp=45, Damage=5, AttackInterval=1.2, AttackRange=6, Speed=7, GoldDrop=1,
		Model="Weakling", TargetPriority="Nearest", Flying=false },

	swordsman = enemy{ Id="swordsman", Display="Swordsman", Family="Human", Tags={"Normal"},
		Hp=125, Damage=13, AttackInterval=1.1, AttackRange=6, Speed=9, GoldDrop=2,
		Model="Swordsman", TargetPriority="Nearest", Flying=false },

	archer_e = enemy{ Id="archer_e", Display="Archer", Family="Human", Tags={"Normal"},
		Hp=100, Damage=13, AttackInterval=1.4, AttackRange=45, Speed=9, GoldDrop=2,
		Model="ArcherEnemy", TargetPriority="Nearest", Flying=false },

	pikeman = enemy{ Id="pikeman", Display="Pikeman", Family="Human", Tags={"Armored"},
		Hp=125, Damage=18, AttackInterval=1.3, AttackRange=9, Speed=9, GoldDrop=3,
		Model="Pikeman", TargetPriority="Nearest", Flying=false },

	ogre = enemy{ Id="ogre", Display="Ogre", Family="Human", Tags={"Armored"},
		Hp=1000, Damage=100, AttackInterval=2.0, AttackRange=8, Speed=7, GoldDrop=8,
		Model="Ogre", TargetPriority="Nearest", Flying=false },

	darkwarrior = enemy{ Id="darkwarrior", Display="Dark Warrior", Family="Human", Tags={"Armored","Fast"},
		Hp=675, Damage=50, AttackInterval=1.0, AttackRange=7, Speed=13, GoldDrop=7,
		Model="DarkWarrior", TargetPriority="Nearest", Flying=false },

	slime = enemy{ Id="slime", Display="Slime", Family="Monster", Tags={"Monster"},
		Hp=63, Damage=6, AttackInterval=1.2, AttackRange=6, Speed=9, GoldDrop=1,
		Model="Slime", TargetPriority="Nearest", Flying=false },

	racer = enemy{ Id="racer", Display="Racer", Family="Monster", Tags={"Monster","Fast"},
		Hp=175, Damage=13, AttackInterval=0.9, AttackRange=6, Speed=18, GoldDrop=3,
		Model="Racer", TargetPriority="Buildings", Flying=false },

	spiderling = enemy{ Id="spiderling", Display="Spiderling", Family="Monster", Tags={"Monster","Fast"},
		Hp=63, Damage=12, AttackInterval=0.7, AttackRange=5, Speed=27, GoldDrop=2,
		Model="Spiderling", TargetPriority="Nearest", Flying=false },

	wasp = enemy{ Id="wasp", Display="Wasp", Family="Monster", Tags={"Monster","Flying"},
		Hp=125, Damage=13, AttackInterval=1.0, AttackRange=6, Speed=14, GoldDrop=3,
		Model="Wasp", TargetPriority="Buildings", Flying=true },

	bloodwing = enemy{ Id="bloodwing", Display="Bloodwing", Family="Monster", Tags={"Monster","Flying","Fast"},
		Hp=250, Damage=15, AttackInterval=0.9, AttackRange=7, Speed=21, GoldDrop=5,
		Model="Bloodwing", TargetPriority="Buildings", Flying=true },

	exploder = enemy{ Id="exploder", Display="Exploder", Family="Monster", Tags={"Monster","Fast"},
		Hp=325, Damage=450, AttackInterval=99, AttackRange=8, Speed=16, GoldDrop=5,
		Model="Exploder", TargetPriority="Buildings", Flying=false, SuicideOnAttack=true,
		ExplosionRadius=22 },

	ram = enemy{ Id="ram", Display="Battering Ram", Family="Siege", Tags={"Siege"},
		Hp=1250, Damage=75, AttackInterval=2.2, AttackRange=10, Speed=4, GoldDrop=10,
		Model="Ram", TargetPriority="Buildings", Flying=false },

	catapult = enemy{ Id="catapult", Display="Catapult", Family="Siege", Tags={"Siege"},
		Hp=225, Damage=750, AttackInterval=5.0, AttackRange=90, Speed=4, GoldDrop=12,
		Model="Catapult", TargetPriority="Buildings", Flying=false },

	-- Boss
	fenwraith = enemy{ Id="fenwraith", Display="The Fen Wraith", Family="Boss", Tags={"Boss","Monster"},
		Hp=50000, Damage=78, AttackInterval=1.6, AttackRange=14, Speed=6, GoldDrop=120,
		Model="FenWraith", TargetPriority="Castle", Flying=false },
}

Config.EliteMultipliers = { Hp = 4.0, Damage = 3.0, GoldDrop = 2.5 }

-- ═══════════════════════════════════════════════════════════════════
-- ALLIED UNITS
-- ═══════════════════════════════════════════════════════════════════
Config.Units = {
	RespawnSeconds = 14,
	knight = { Id="knight", Display="Knight", Hp=525, Damage=13, AttackInterval=1.0, AttackRange=7,
	           Speed=9, DamageProfile="UnitMelee", Model="Knight" },
	archer = { Id="archer", Display="Archer", Hp=125, Damage=20, AttackInterval=1.2, AttackRange=55,
	           Speed=9, DamageProfile="UnitRanged", Model="Archer", ProjectileSpeed=150 },
	golem  = { Id="golem",  Display="Golem",  Hp=1800, Damage=165, AttackInterval=1.8, AttackRange=10,
	           Speed=7, DamageProfile="UnitMelee", Model="Golem", SplashRadius=12 },
}

-- ═══════════════════════════════════════════════════════════════════
-- WEAPONS — auto-attack floor, active-ability ceiling
-- ═══════════════════════════════════════════════════════════════════
Config.Weapons = {
	greatsword = {
		Id="greatsword", Display="Greatsword", DamageProfile="HeavyMelee",
		Range=13, Damage=22, Cooldown=1.0, Aoe=10,
		Ability = { Id="whirlwind", Cooldown=9, Display="Whirlwind",
		            Description="Spin, dealing 3x damage in a wide arc",
		            Radius=18, Multiplier=3.0 },
		UnlockCost=0, UnlockLevel=1,
	},
	spear = {
		Id="spear", Display="War Spear", DamageProfile="LightMelee",
		Range=18, Damage=14, Cooldown=0.75,
		Ability = { Id="impale", Cooldown=7, Display="Impale",
		            Description="Lunge forward, slowing everything hit for 3s",
		            Length=30, SlowFactor=0.45, SlowSeconds=3, Multiplier=2.5 },
		UnlockCost=1000, UnlockLevel=3,
	},
	longbow = {
		Id="longbow", Display="Longbow", DamageProfile="Bow",
		Range=60, Damage=18, Cooldown=0.95,
		Ability = { Id="volley", Cooldown=10, Display="Arrow Volley",
		            Description="Rain arrows on an area, hitting flying enemies hardest",
		            Radius=22, Waves=4, Multiplier=1.2 },
		UnlockCost=1500, UnlockLevel=4,
	},
	crossbow = {
		Id="crossbow", Display="Heavy Crossbow", DamageProfile="Crossbow",
		Range=52, Damage=32, Cooldown=1.6,
		Ability = { Id="pierce", Cooldown=8, Display="Piercing Bolt",
		            Description="A bolt that passes through every enemy in a line",
		            Length=70, Multiplier=2.2 },
		UnlockCost=2500, UnlockLevel=8,
	},
	vials = {
		Id="vials", Display="Alchemist's Vials", DamageProfile="Magic",
		Range=45, Damage=9, Cooldown=0.9, Aoe=14,
		Ability = { Id="tonic", Cooldown=12, Display="Restorative Tonic",
		            Description="Heal all allies in a large area and slow enemies in it",
		            Radius=35, HealFraction=0.30, SlowFactor=0.5, SlowSeconds=4 },
		UnlockCost=3500, UnlockLevel=12,
	},
	stormstaff = {
		Id="stormstaff", Display="Storm Staff", DamageProfile="Magic",
		Range=55, Damage=7, Cooldown=0.4, Aoe=8,
		Ability = { Id="chainstorm", Cooldown=14, Display="Chain Storm",
		            Description="Lightning arcs between up to 12 enemies",
		            Chains=12, ChainRange=25, Multiplier=2.0 },
		UnlockCost=5000, UnlockLevel=18,
	},
}

-- ═══════════════════════════════════════════════════════════════════
-- CHAMPIONS
-- ═══════════════════════════════════════════════════════════════════
Config.Champions = {
	warden = { Id="warden", Display="Warden", Hp=500, WalkSpeed=18, SprintSpeed=28,
	           DefaultWeapon="greatsword", AuraType="WallHp",     AuraRadius=60, AuraValue=0.15,
	           UnlockCost=0 },
	ranger = { Id="ranger", Display="Ranger", Hp=420, WalkSpeed=20, SprintSpeed=30,
	           DefaultWeapon="longbow",    AuraType="TowerRange", AuraRadius=60, AuraValue=0.20,
	           UnlockCost=4000 },
	marshal= { Id="marshal",Display="Marshal",Hp=470, WalkSpeed=19, SprintSpeed=29,
	           DefaultWeapon="spear",      AuraType="UnitDamage", AuraRadius=45, AuraValue=0.25,
	           UnlockCost=6000 },
	alchemist={ Id="alchemist",Display="Alchemist",Hp=400, WalkSpeed=19, SprintSpeed=28,
	           DefaultWeapon="vials",      AuraType="UnitRegen",  AuraRadius=45, AuraValue=0.02,
	           UnlockCost=8000 },
}

Config.Champion = {
	RegenDelay = 5,            -- seconds out of combat before regen starts
	RegenPerSecond = 0.03,     -- fraction of max HP
	SprintRequiresFullHp = true,   -- overridden by the agile_horse perk
	DownedWalkSpeed = 8,
	PositionCheckHz = 3,
	PositionTolerance = 1.5,   -- multiplier on sprintSpeed * elapsed before snap-back
}

-- ═══════════════════════════════════════════════════════════════════
-- PERKS — many are TRADE-OFFS, not upgrades. That is the point.
-- ═══════════════════════════════════════════════════════════════════
Config.Perks = {
	-- Economic
	royal_mint      = { Display="Royal Mint",      Cost=600,  Level=1,  CastleIncomePerLevel={1,2,3} },
	interest        = { Display="Interest",        Cost=1200, Level=5,  InterestRatio=3, InterestCap=20 },
	treasure_hunter = { Display="Treasure Hunter", Cost=1800, Level=9,  LateGold={15,25,40} },
	loan            = { Display="Loan",            Cost=600,  Level=2,  StartGold=7, ForfeitFirstDrops=10 },
	pumpkin_fields  = { Display="Pumpkin Fields",  Cost=1500, Level=7,  MillIncomeAdd=1, FieldHpMult=5.0 },
	-- Military
	warrior_training= { Display="Warrior Training",Cost=2000, Level=10, ChampDamageMaxMult=2.0, AllyDamageMult=0.5 },
	commander_mode  = { Display="Commander Mode",  Cost=2000, Level=10, AllyDamageMult=1.5, ChampDamageMult=0.5 },
	glass_cannon    = { Display="Glass Cannon",    Cost=1400, Level=6,  ChampDamageMult=1.5, ChampHpMult=0.45 },
	daredevil       = { Display="Daredevil",       Cost=2200, Level=14, LowHpDamageMaxBonus=1.15 },
	agile_horse     = { Display="Agile Horse",     Cost=600,  Level=1,  SprintAtAnyHp=true },
	elite_warriors  = { Display="Elite Warriors",  Cost=1600, Level=8,  UnitHpMult=2.0, UnitRespawnMult=1.7 },
	gladiator_school= { Display="Gladiator School",Cost=1400, Level=6,  UnitRespawnMult=0.55 },
	melee_damage    = { Display="Sharpened Blades",Cost=800,  Level=2,  MeleeDamageMult=1.35 },
	ranged_damage   = { Display="Fletching",       Cost=800,  Level=2,  RangedDamageMult=1.25 },
	-- Defense
	castle_blueprints={Display="Castle Blueprints",Cost=1000, Level=4,  WallTowerHpMult=1.5 },
	fortified_houses= { Display="Fortified Houses",Cost=1200, Level=5,  HouseHpMult=3.5, HouseArrowDamage=40, HouseArrowInterval=5 },
	explosive_walls = { Display="Explosive Walls", Cost=1800, Level=9,  WallDeathDamage=350, WallDeathRadius=26 },
	last_stand      = { Display="Last Stand",      Cost=2400, Level=15, ReviveTowersAtCastlePct=0.5 },
	outpost         = { Display="Outpost",         Cost=1000, Level=4,  FreeFarTowers=2 },
	-- Special
	ring_of_res     = { Display="Ring of Resurrection", Cost=3000, Level=20, RevivesPerNight=1, RevivesUnits=true },
	anti_air_scope  = { Display="Anti-Air Telescope",   Cost=1600, Level=8,  FlyingHpMult=0.75, FlyingDamageMult=0.75 },
	health_potions  = { Display="Health Potions",       Cost=1400, Level=6,  UnitRegenPerSecond=0.025 },
}

Config.PerkSlots = { { Level = 1, Slots = 3 }, { Level = 8, Slots = 4 }, { Level = 20, Slots = 5 } }
Config.MaxPerkSlots = 6   -- with the Extra Perk Slot game pass

-- ═══════════════════════════════════════════════════════════════════
-- MUTATORS — the cheapest content in the game: global modifiers over
-- systems that already exist. Ship more of these.
-- ═══════════════════════════════════════════════════════════════════
Config.Mutators = {
	elite_god    = { Display="Trial of the Elite",  Reward=0.75, EveryNthSpawnElite=3 },
	growth_god   = { Display="Trial of Growth",     Reward=0.50, EnemyStatPerNight=0.08 },
	afterlife    = { Display="Trial of the Afterlife", Reward=0.50, RespawnDeadAfter=25 },
	turtle_god   = { Display="Trial of the Turtle", Reward=0.40, EnemyHpMult=1.75 },
	tiger_god    = { Display="Trial of the Tiger",  Reward=0.20, EnemyDamageMult=1.75 },
	falcon_god   = { Display="Trial of the Falcon", Reward=0.20, EnemySpeedMult=1.75 },
	snake_god    = { Display="Trial of the Serpent",Reward=0.30, GoldDropMult=0.5 },
	no_towers    = { Display="Pact of No Towers",   Reward=0.20, BlockSlotTypes={ "Tower" } },
	no_walls     = { Display="Pact of No Walls",    Reward=0.10, BlockSlotTypes={ "Wall" } },
	war_gods     = { Display="Mercy of the War Gods", Reward=-0.40, EnemyHpMult=0.8, EnemyDamageMult=0.8 },
}

-- ═══════════════════════════════════════════════════════════════════
-- MAPS — slot counts ARE the level design. Vary the SHAPE, not just the scale.
-- ═══════════════════════════════════════════════════════════════════
Config.Maps = {
	greenhollow = {
		Id="greenhollow", Display="Greenhollow", Theme="Meadow", Difficulty="Easy",
		StartGold=3, UnlockLevel=1, DifficultyMult=1.0,
		HeroLevelCap=1,        -- v2: campaign is power-normalized (spec S36.1)
		TargetSeconds=300,     -- v2: tutorial run is 5 minutes
		Nights = {
			{ Night=1, Entries={
				{ EnemyId="weakling", Count=6,  SpawnIndex=1, StartDelay=0, Interval=0.9 },
			}},
			{ Night=2, Entries={
				{ EnemyId="weakling", Count=9,  SpawnIndex=1, StartDelay=0, Interval=0.8 },
				{ EnemyId="slime",    Count=4,  SpawnIndex=2, StartDelay=8, Interval=1.0 },
			}},
			{ Night=3, Entries={
				{ EnemyId="weakling", Count=10, SpawnIndex=1, StartDelay=0,  Interval=0.7 },
				{ EnemyId="swordsman",Count=4,  SpawnIndex=2, StartDelay=10, Interval=1.2 },
			}},
			{ Night=4, Entries={
				{ EnemyId="swordsman",Count=8,  SpawnIndex=1, StartDelay=0,  Interval=0.9 },
				{ EnemyId="slime",    Count=8,  SpawnIndex=2, StartDelay=6,  Interval=0.8 },
				{ EnemyId="racer",    Count=2,  SpawnIndex=2, StartDelay=16, Interval=2.0 },
			}},
			{ Night=5, Entries={
				{ EnemyId="swordsman",Count=10, SpawnIndex=1, StartDelay=0,  Interval=0.8 },
				{ EnemyId="archer_e", Count=4,  SpawnIndex=1, StartDelay=8,  Interval=1.4 },
				{ EnemyId="slime",    Count=10, SpawnIndex=2, StartDelay=4,  Interval=0.7 },
				{ EnemyId="ogre",     Count=1,  SpawnIndex=2, StartDelay=25, Interval=1.0 },
			}},
		},
	},

	-- ashridge / frostmere / blackfen: author to the slot-count table in the spec (S23.3)
	-- and fill Nights the same way. Keep waves hand-authored, never procedural
	-- (Endless is the sole exception -- see Config.Endless).
	--
	-- v2 constraints for every campaign map:
	--   * 8-10 nights, 45-75s each  -> total run 6-9 minutes
	--   * HeroLevelCap: ashridge 2, frostmere 3, blackfen 5
	--   * TargetSeconds: 420 / 480 / 540
}

-- ═══════════════════════════════════════════════════════════════════
-- CHALLENGES
-- ═══════════════════════════════════════════════════════════════════
Config.Challenges = {
	Pool = {
		{ Kind="CompleteMap",         Tier="Medium", Display="Win a run on %s",              Target=1,   ParamFrom="Map" },
		{ Kind="UseWeapon",           Tier="Medium", Display="Win a run using the %s",       Target=1,   ParamFrom="Weapon" },
		{ Kind="KillEnemies",         Tier="Easy",   Display="Defeat %d enemies",            Target=150 },
		{ Kind="KillEnemies",         Tier="Hard",   Display="Defeat %d monsters",           Target=300, Param="Monster" },
		{ Kind="SurviveNights",       Tier="Easy",   Display="Survive %d nights",            Target=12 },
		{ Kind="NoBuildingLost",      Tier="Hard",   Display="Finish %d nights without losing a building", Target=3 },
		{ Kind="PlayCoop",            Tier="Easy",   Display="Complete a run with a friend", Target=1 },
		{ Kind="BuildCount",          Tier="Easy",   Display="Construct %d buildings",       Target=25 },
		{ Kind="CompleteWithMutator", Tier="Hard",   Display="Win a run with a Trial active",Target=1 },
	},
	Rewards = {
		Easy   = { Crowns = 150, Xp = 60 },
		Medium = { Crowns = 300, Xp = 120 },
		Hard   = { Crowns = 500, Xp = 200 },
	},
	AllThreeBonus = { Crowns = 250, Xp = 100 },
	StreakBonusPerDay = 50,
	StreakBonusCap    = 500,
}

-- ═══════════════════════════════════════════════════════════════════
-- PROGRESSION — Crowns are paid on EVERY run, win or lose. Non-negotiable.
-- ═══════════════════════════════════════════════════════════════════
Config.Progression = {
	BaseCrowns          = 100,
	CrownsPerNight      = 25,
	WinBonus            = 200,
	CrownsPerBuilding   = 3,
	CrownsPerTenKills   = 2,
	MaxLevel            = 40,
	XpForLevel = function(n: number): number
		return math.floor(120 * n ^ 1.35)
	end,
	XpPerNight = 12,
	XpWinBonus = 100,
	-- v2: final crown formula is
	--   base x MapDifficultyMult x Difficulty[tier].CrownMult x MutatorMult
	--         x (1 + CoopCrownBonus) x PassMult
	-- Shards roll independently (see Config.Shards / RewardService:RollShards).
}

-- ═══════════════════════════════════════════════════════════════════
-- PERFORMANCE CAPS — verify on a real mid-range Android in Phase 2
-- ═══════════════════════════════════════════════════════════════════
Config.Perf = {
	MaxActiveEnemies    = 200,   -- hard cap; spawner waits rather than exceed
	DesignPeakEnemies   = 180,   -- author waves to THIS
	EnemyPoolSize       = 220,
	CoinPoolSize        = 150,
	ProjectilePoolSize  = 120,
	DamageLabelPoolSize = 60,
	SpatialGridCell     = 32,
	TargetSearchInterval= 0.4,   -- seconds between enemy target re-acquisition
	SlowTickHz          = 10,    -- auras, proximity checks, income previews
}

-- ═══════════════════════════════════════════════════════════════════
-- v2: DIFFICULTY TIERS — default a new player to Casual, let them opt into pain
-- ═══════════════════════════════════════════════════════════════════
Config.Difficulty = {
	Casual = { Display="Casual", EnemyHpMult=0.75, EnemyDamageMult=0.75,
	           CrownMult=0.7, ShardMult=0.7, ForceBuildHints=true },
	Normal = { Display="Normal", EnemyHpMult=1.00, EnemyDamageMult=1.00,
	           CrownMult=1.0, ShardMult=1.0 },
	Heroic = { Display="Heroic", EnemyHpMult=1.45, EnemyDamageMult=1.35,
	           CrownMult=1.5, ShardMult=1.6, RequiresNormalWin=true },
}
Config.DefaultTierUntilRuns = 3   -- new players default to Casual for their first 3 runs

-- ═══════════════════════════════════════════════════════════════════
-- v2: HERO COLLECTION — the retention engine. Two new heroes per month.
-- Heroes reuse UnitService entirely. Do NOT write a separate simulation.
-- ═══════════════════════════════════════════════════════════════════
Config.Heroes = {
	stoneguard = { Id="stoneguard", Display="Stoneguard", Rarity="Common", Role="Tank",
		Hp=900, Damage=40, AttackInterval=1.4, AttackRange=8, Speed=7,
		DamageProfile="UnitMelee", Model="Stoneguard", ShardsToUnlock=20,
		Passive={ Kind="WallResist", Radius=45, Value=0.15 } },

	bowcaptain = { Id="bowcaptain", Display="Bowman Captain", Rarity="Common", Role="Ranged",
		Hp=300, Damage=34, AttackInterval=1.1, AttackRange=55, Speed=9,
		DamageProfile="UnitRanged", Model="BowCaptain", ShardsToUnlock=20,
		Passive={ Kind="TowerFireRate", Radius=50, Value=0.10 } },

	houndhandler = { Id="houndhandler", Display="Hound Handler", Rarity="Common", Role="AntiFast",
		Hp=420, Damage=30, AttackInterval=0.8, AttackRange=9, Speed=12,
		DamageProfile="LightMelee", Model="HoundHandler", ShardsToUnlock=20,
		Passive={ Kind="TagDamage", Radius=0, Value=2.0, Tag="Fast" } },

	torchbearer = { Id="torchbearer", Display="Torchbearer", Rarity="Rare", Role="AntiMonster",
		Hp=480, Damage=42, AttackInterval=1.2, AttackRange=14, Speed=9,
		DamageProfile="Magic", Model="Torchbearer", ShardsToUnlock=45, SplashRadius=10,
		Passive={ Kind="Burn", Radius=0, Value=10 } },

	skylancer = { Id="skylancer", Display="Sky Lancer", Rarity="Rare", Role="AntiAir",
		Hp=380, Damage=48, AttackInterval=1.0, AttackRange=60, Speed=10,
		DamageProfile="Bow", Model="SkyLancer", ShardsToUnlock=45,
		Passive={ Kind="TagDamage", Radius=0, Value=2.4, Tag="Flying" } },

	siegebreaker = { Id="siegebreaker", Display="Siege Breaker", Rarity="Rare", Role="AntiSiege",
		Hp=760, Damage=70, AttackInterval=1.6, AttackRange=10, Speed=7,
		DamageProfile="HeavyMelee", Model="SiegeBreaker", ShardsToUnlock=45,
		Passive={ Kind="TagDamage", Radius=0, Value=2.5, Tag="Siege" } },

	fieldmedic = { Id="fieldmedic", Display="Field Medic", Rarity="Rare", Role="Support",
		Hp=340, Damage=12, AttackInterval=1.5, AttackRange=30, Speed=10,
		DamageProfile="Magic", Model="FieldMedic", ShardsToUnlock=45,
		Passive={ Kind="UnitHeal", Radius=50, Value=0.03 } },

	golem = { Id="golem", Display="Golem", Rarity="Epic", Role="Tank/AoE",
		Hp=1800, Damage=165, AttackInterval=1.8, AttackRange=10, Speed=7,
		DamageProfile="UnitMelee", Model="Golem", ShardsToUnlock=90, SplashRadius=12,
		Passive={ Kind="Taunt", Radius=35, Value=1 } },

	frostwarden = { Id="frostwarden", Display="Frost Warden", Rarity="Epic", Role="Control",
		Hp=620, Damage=55, AttackInterval=1.3, AttackRange=40, Speed=9,
		DamageProfile="Magic", Model="FrostWarden", ShardsToUnlock=90,
		Passive={ Kind="Slow", Radius=0, Value=0.40, Seconds=3 } },

	firewing = { Id="firewing", Display="Firewing", Rarity="Epic", Role="FlyingDPS",
		Hp=520, Damage=78, AttackInterval=1.0, AttackRange=45, Speed=14, Flying=true,
		DamageProfile="Magic", Model="Firewing", ShardsToUnlock=90,
		Passive={ Kind="IgnoresPathing", Radius=0, Value=1 } },

	lizardrider = { Id="lizardrider", Display="Lizard Rider", Rarity="Legendary", Role="Hybrid",
		Hp=1100, Damage=120, AttackInterval=0.9, AttackRange=16, Speed=16,
		DamageProfile="LightMelee", Model="LizardRider", ShardsToUnlock=160,
		Passive={ Kind="DualTagDamage", Radius=0, Value=2.0, Tags={"Flying","Siege"} } },

	ashenqueen = { Id="ashenqueen", Display="The Ashen Queen", Rarity="Legendary", Role="Nuke",
		Hp=900, Damage=60, AttackInterval=1.2, AttackRange=50, Speed=8,
		DamageProfile="Magic", Model="AshenQueen", ShardsToUnlock=160, SplashRadius=16,
		Passive={ Kind="PeriodicNova", Radius=90, Value=180, Seconds=12 } },
}

Config.HeroLevels = {
	-- [level] = { ShardCostMult (of ShardsToUnlock), StatMult, PassiveMult }
	[2] = { ShardCostMult=1.5, StatMult=1.15, PassiveMult=1.0 },
	[3] = { ShardCostMult=2.5, StatMult=1.35, PassiveMult=1.0 },
	[4] = { ShardCostMult=4.0, StatMult=1.60, PassiveMult=1.25 },
	[5] = { ShardCostMult=7.0, StatMult=2.00, PassiveMult=1.50, UniqueVisual=true },
}

Config.HeroRosterSlots = { { Level=1, Slots=3 }, { Level=15, Slots=4 }, { Level=30, Slots=5 } }
Config.MaxHeroRosterSlots = 6   -- with the Hero Collector pass

Config.Shards = {
	Base       = 8,
	PerNight   = 2,
	WinBonus   = 12,
	MaxPerGrant= 4,
	-- Display these odds in the shard-pack purchase UI. Platform policy expects it
	-- and players punish hidden odds.
	RarityWeights = { Common=0.55, Rare=0.30, Epic=0.12, Legendary=0.03 },
	-- Near-completion bias: weight *= 1 + NearCompletionBias * (owned / required).
	-- This is what turns a random drop into a visible ladder. Do not remove it.
	NearCompletionBias = 2.0,
}

-- ═══════════════════════════════════════════════════════════════════
-- v2: MATCHMAKING — nobody ever waits more than SoloSeconds. Ever.
-- ═══════════════════════════════════════════════════════════════════
Config.Matchmaking = {
	PollSeconds         = 3,
	WaitSeconds         = 15,    -- launch with 2+ players after this
	SoloSeconds         = 30,    -- HARD ceiling: launch with whoever is there
	QueueTtl            = 120,
	RejoinTtl           = 1200,  -- MemoryStore HashMap TTL for the rejoin record
	RejoinWindowSeconds = 300,   -- ghost marker holds the slot this long
	MaxPartySize        = 4,
}

-- ═══════════════════════════════════════════════════════════════════
-- v2: ENDLESS SIEGE — the ONLY place procedural waves are allowed
-- ═══════════════════════════════════════════════════════════════════
Config.Endless = {
	MapId          = "lastwatch",
	BaseBudget     = 400,
	Growth         = 1.11,      -- budget *= 1.11^night
	MaxPerEntry    = 25,
	SpawnPoints    = 4,
	EliteFromNight = 20,
	EliteChance    = 0.25,
	MilestoneEvery = 5,         -- boss / permanent mutator / free upgrade
	HeroPowerCapped= false,     -- full roster power applies here. This is the payoff
	LeaderboardTtl = 604800,    -- MemoryStore SortedMap, resets Monday 00:00 UTC
}

-- ═══════════════════════════════════════════════════════════════════
-- v2: MOUNTS — cosmetic ONLY. Grant no stats. Not 1%.
-- The moment a mount grants speed it becomes power and lives in balance forever.
-- ═══════════════════════════════════════════════════════════════════
Config.Mounts = {
	bay_horse     = { Display="Bay Horse",     Source="Default", Cost=0 },
	warhorse      = { Display="Warhorse",      Source="Crowns",  Cost=2500 },
	dire_wolf     = { Display="Dire Wolf",     Source="Crowns",  Cost=4500 },
	sand_lizard   = { Display="Sand Lizard",   Source="StablePass" },
	skeletal_steed= { Display="Skeletal Steed",Source="StablePass" },
	sun_stag      = { Display="Sun Stag",      Source="Event", NeverResold=true },
}

-- ═══════════════════════════════════════════════════════════════════
-- UI
-- ═══════════════════════════════════════════════════════════════════
Config.UI = {
	Palette = {
		Gold      = Color3.fromRGB(255, 199, 64),
		Crown     = Color3.fromRGB(140, 200, 255),
		Danger    = Color3.fromRGB(226, 78, 78),
		Good      = Color3.fromRGB(96, 200, 120),
		Panel     = Color3.fromRGB(28, 30, 38),
		PanelLight= Color3.fromRGB(44, 48, 60),
		Text      = Color3.fromRGB(240, 240, 245),
	},
	CornerRadius   = UDim.new(0, 10),
	MinTapPixels   = 50,
	TweenFeedback  = 0.15,
	TweenScreen    = 0.35,
	SuperHitThreshold = 2.0,   -- damage multiplier at which numbers turn gold and enlarge
}

-- ═══════════════════════════════════════════════════════════════════
-- MONETIZATION — never sell in-run power. Meta acceleration only.
-- ═══════════════════════════════════════════════════════════════════
Config.Monetize = {
	-- Prices are set to how players actually HOLD Robux (400/800/1700 denominations).
	-- 399 converts better than 449. Do not round up "because it's close."
	Passes = {
		royal_treasury = { Id=0, R=249, Display="Royal Treasury", Axis="Acceleration",
		                   CrownMult=1.50 },
		vip            = { Id=0, R=799, Display="VIP", Axis="Identity",
		                   CrownMult=1.50, ExtraPerkSlots=1, NameTag=true,
		                   Grants={ CastleSkin="royal_gold", Banner="gold" } },
		coin_magnet    = { Id=0, R=149, Display="Coin Magnet", Axis="Convenience",
		                   CoinRadiusMult=3.0 },
		extra_perk     = { Id=0, R=199, Display="Extra Perk Slot", Axis="Expression",
		                   ExtraPerkSlots=1 },
		hero_collector = { Id=0, R=399, Display="Hero Collector", Axis="Acceleration",
		                   ExtraHeroSlots=1, ShardMult=1.25 },
		stable_pass    = { Id=0, R=299, Display="Stable Pass", Axis="Expression",
		                   Grants={ "sand_lizard", "skeletal_steed" }, FutureMounts=true },
		champion_pack  = { Id=0, R=399, Display="Champion Pack", Axis="Access",
		                   Grants={ "marshal", "alchemist" } },
		auto_ready     = { Id=0, R=99,  Display="Auto-Ready", Axis="Convenience",
		                   SkipReadyConfirm=true, DayPrepSpeed=1.10 },
		private_kingdom= { Id=0, R=99,  Display="Private Kingdom", Axis="Access" },
		double_xp      = { Id=0, R=199, Display="2x XP", Axis="Acceleration", XpMult=2.0 },
	},

	Products = {
		crowns_pouch    = { Id=0, R=25,   Crowns=1000 },
		crowns_chest    = { Id=0, R=99,   Crowns=4500,  Badge="POPULAR" },
		crowns_vault    = { Id=0, R=399,  Crowns=20000 },
		crowns_hoard    = { Id=0, R=899,  Crowns=50000 },
		crowns_treasury = { Id=0, R=1999, Crowns=125000, Badge="BEST VALUE" },

		-- Its job is not revenue. Its job is manufacturing a FIRST purchase,
		-- which multiplies the odds of every later one. Offer once, time-limited,
		-- immediately after the player's first WIN.
		starter_pack    = { Id=0, R=199, Crowns=4000, Shards=60,
		                    Grants={ Champion="ranger", Mount="warhorse" },
		                    OneTime=true, OfferAfterFirstWin=true, OfferHours=48 },

		shards_small    = { Id=0, R=149, Shards=80 },
		shards_large    = { Id=0, R=499, Shards=300 },
		challenge_reroll= { Id=0, R=25 },
		skin_bundle     = { Id=0, R=299 },
		gift_crowns     = { Id=0, R=99,  Crowns=4500, Giftable=true },
	},

	-- NEVER ADD A ROBUX CONTINUE. It destroys score integrity, poisons the
	-- MapAbandoned balance signal, and turns a designed moment of tension into a
	-- checkout screen. Config.Match.FreeLastStandPerRun exists instead.
	AllowPaidContinue = false,

	PromptContexts = {
		ResultsNearUnlock  = "crowns_chest",
		HeroRosterFull     = "hero_collector",
		ShardsNearUnlock   = "shards_small",
		ThirdRunOfSession  = "royal_treasury",
		SawTeammateMount   = "stable_pass",
		FirstWin           = "starter_pack",
	},
}

Config.Codes = {
	-- Codes redeem for Crowns and shards, NEVER heroes directly -- a code-unlocked
	-- Legendary devalues the collection for everyone who earned it.
	-- Redemption is recorded in profile.Data.RedeemedCodes for idempotency.
	LAUNCH  = { Crowns=1000, Shards=40, Expires=0 },
	NIGHTFALL = { Crowns=500, Shards=20, Expires=0 },
}

Config.Events = {
	-- DataStore-backed flag polled every few minutes; MessagingService as an
	-- instant-refresh hint. Never route stateful data through MessagingService.
	BloodMoon = { CrownMult=2.0, ShardMult=2.0, ForcedMutator="elite_god",
	              WinsForBanner=3, BannerId="bloodmoon" },
	PollSeconds = 180,
}

return Config
