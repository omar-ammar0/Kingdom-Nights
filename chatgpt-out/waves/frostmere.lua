-- Kingdom Nights / Frostmere waves W1 / version: 2 / author: ChatGPT
-- PROPOSAL ONLY: pending Omar approval. Existing enemy stats only; no engineering changes.
-- Full old/new counts, HP budgets, economy and limitations: W1-design-review.md.
-- Four-player counts use math.round(Count*2.05) per entry; base HP without modifiers.
frostmere = {
    Id = "frostmere", Display = "Frostmere", Theme = "Frost", Difficulty = "Hard",
    StartGold = 6, UnlockLevel = 6, DifficultyMult = 1.4,
    Model = "Map_Frostmere", HeroLevelCap = 3, TargetSeconds = 500,
    Nights = {
        -- 1: Opening unchanged from accepted baseline.
        -- Solo count/HP 24/1188; four-player 49/2421; last release 6.80s / 14.40s.
        { Night = 1, Entries = {
            { EnemyId = "weakling", Count = 18, SpawnIndex = 1, StartDelay = 0, Interval = 0.4 },
            { EnemyId = "slime", Count = 6, SpawnIndex = 1, StartDelay = 4, Interval = 0.5 },
        }},
        -- 2: North spiderlings replace part of the weakling pack.
        -- Solo count/HP 32/3324; four-player 65/6773; last release 9.15s / 12.75s.
        { Night = 2, Entries = {
            { EnemyId = "swordsman", Count = 12, SpawnIndex = 1, StartDelay = 0, Interval = 0.4 },
            { EnemyId = "weakling", Count = 6, SpawnIndex = 2, StartDelay = 0, Interval = 0.35 },
            { EnemyId = "racer", Count = 6, SpawnIndex = 2, StartDelay = 6, Interval = 0.4 },
            { EnemyId = "spiderling", Count = 8, SpawnIndex = 2, StartDelay = 6, Interval = 0.45 },
        }},
        -- 3: One western exploder after the infantry screen.
        -- Solo count/HP 39/4631; four-player 80/9450; last release 9.00s / 10.40s.
        { Night = 3, Entries = {
            { EnemyId = "swordsman", Count = 12, SpawnIndex = 1, StartDelay = 0, Interval = 0.35 },
            { EnemyId = "slime", Count = 12, SpawnIndex = 3, StartDelay = 0, Interval = 0.35 },
            { EnemyId = "pikeman", Count = 8, SpawnIndex = 2, StartDelay = 0, Interval = 0.45 },
            { EnemyId = "racer", Count = 6, SpawnIndex = 3, StartDelay = 6, Interval = 0.4 },
            { EnemyId = "exploder", Count = 1, SpawnIndex = 1, StartDelay = 9, Interval = 1.2 },
        }},
        -- 4: Eastern bloodwing pair replaces four wasps.
        -- Solo count/HP 46/5106; four-player 95/10525; last release 8.80s / 10.40s.
        { Night = 4, Entries = {
            { EnemyId = "swordsman", Count = 14, SpawnIndex = 1, StartDelay = 0, Interval = 0.35 },
            { EnemyId = "slime", Count = 12, SpawnIndex = 3, StartDelay = 0, Interval = 0.35 },
            { EnemyId = "pikeman", Count = 10, SpawnIndex = 2, StartDelay = 0, Interval = 0.4 },
            { EnemyId = "wasp", Count = 2, SpawnIndex = 3, StartDelay = 6, Interval = 0.4 },
            { EnemyId = "archer_e", Count = 6, SpawnIndex = 2, StartDelay = 3, Interval = 0.4 },
            { EnemyId = "bloodwing", Count = 2, SpawnIndex = 3, StartDelay = 8, Interval = 0.8 },
        }},
        -- 5: Western mixed air and eastern swarm.
        -- Solo count/HP 58/7354; four-player 119/15133; last release 8.45s / 11.25s.
        { Night = 5, Entries = {
            { EnemyId = "swordsman", Count = 16, SpawnIndex = 1, StartDelay = 0, Interval = 0.3 },
            { EnemyId = "pikeman", Count = 12, SpawnIndex = 2, StartDelay = 0, Interval = 0.35 },
            { EnemyId = "racer", Count = 10, SpawnIndex = 3, StartDelay = 3, Interval = 0.3 },
            { EnemyId = "wasp", Count = 4, SpawnIndex = 1, StartDelay = 5, Interval = 0.35 },
            { EnemyId = "archer_e", Count = 6, SpawnIndex = 2, StartDelay = 2, Interval = 0.4 },
            { EnemyId = "bloodwing", Count = 2, SpawnIndex = 1, StartDelay = 7, Interval = 0.8 },
            { EnemyId = "spiderling", Count = 8, SpawnIndex = 3, StartDelay = 6, Interval = 0.35 },
        }},
        -- 6: First central Dark Warrior; one western exploder.
        -- Solo count/HP 61/11275; four-player 125/22975; last release 10.00s / 11.60s.
        { Night = 6, Entries = {
            { EnemyId = "ram", Count = 1, SpawnIndex = 2, StartDelay = 0, Interval = 0.4 },
            { EnemyId = "ogre", Count = 1, SpawnIndex = 2, StartDelay = 0, Interval = 0.5 },
            { EnemyId = "swordsman", Count = 16, SpawnIndex = 1, StartDelay = 0, Interval = 0.3 },
            { EnemyId = "pikeman", Count = 12, SpawnIndex = 2, StartDelay = 0, Interval = 0.35 },
            { EnemyId = "racer", Count = 16, SpawnIndex = 3, StartDelay = 2, Interval = 0.3 },
            { EnemyId = "wasp", Count = 5, SpawnIndex = 3, StartDelay = 4, Interval = 0.35 },
            { EnemyId = "archer_e", Count = 6, SpawnIndex = 1, StartDelay = 2, Interval = 0.35 },
            { EnemyId = "bloodwing", Count = 2, SpawnIndex = 3, StartDelay = 7, Interval = 0.8 },
            { EnemyId = "darkwarrior", Count = 1, SpawnIndex = 2, StartDelay = 4, Interval = 0.9 },
            { EnemyId = "exploder", Count = 1, SpawnIndex = 1, StartDelay = 10, Interval = 1.2 },
        }},
        -- 7: Mobile central armour, western air, eastern swarm.
        -- Solo count/HP 74/11980; four-player 152/24448; last release 9.15s / 13.00s.
        { Night = 7, Entries = {
            { EnemyId = "ogre", Count = 1, SpawnIndex = 2, StartDelay = 0, Interval = 0.5 },
            { EnemyId = "swordsman", Count = 18, SpawnIndex = 1, StartDelay = 0, Interval = 0.3 },
            { EnemyId = "pikeman", Count = 16, SpawnIndex = 2, StartDelay = 0, Interval = 0.3 },
            { EnemyId = "racer", Count = 12, SpawnIndex = 3, StartDelay = 1, Interval = 0.3 },
            { EnemyId = "wasp", Count = 5, SpawnIndex = 1, StartDelay = 3, Interval = 0.3 },
            { EnemyId = "archer_e", Count = 6, SpawnIndex = 3, StartDelay = 2, Interval = 0.35 },
            { EnemyId = "bloodwing", Count = 3, SpawnIndex = 1, StartDelay = 6, Interval = 0.8 },
            { EnemyId = "spiderling", Count = 10, SpawnIndex = 3, StartDelay = 6, Interval = 0.35 },
            { EnemyId = "darkwarrior", Count = 3, SpawnIndex = 2, StartDelay = 4, Interval = 0.9 },
        }},
        -- 8: Established combined finale; 84 solo enemies.
        -- Solo count/HP 84/14232; four-player 172/28952; last release 10.55s / 15.80s.
        { Night = 8, Entries = {
            { EnemyId = "ogre", Count = 2, SpawnIndex = 2, StartDelay = 0, Interval = 0.45 },
            { EnemyId = "swordsman", Count = 20, SpawnIndex = 1, StartDelay = 0, Interval = 0.28 },
            { EnemyId = "pikeman", Count = 18, SpawnIndex = 2, StartDelay = 0, Interval = 0.3 },
            { EnemyId = "racer", Count = 12, SpawnIndex = 3, StartDelay = 0, Interval = 0.28 },
            { EnemyId = "wasp", Count = 6, SpawnIndex = 3, StartDelay = 2, Interval = 0.3 },
            { EnemyId = "archer_e", Count = 4, SpawnIndex = 1, StartDelay = 1, Interval = 0.35 },
            { EnemyId = "bloodwing", Count = 4, SpawnIndex = 3, StartDelay = 6, Interval = 0.8 },
            { EnemyId = "spiderling", Count = 14, SpawnIndex = 3, StartDelay = 6, Interval = 0.35 },
            { EnemyId = "darkwarrior", Count = 3, SpawnIndex = 2, StartDelay = 4, Interval = 0.9 },
            { EnemyId = "exploder", Count = 1, SpawnIndex = 1, StartDelay = 10, Interval = 1.2 },
        }},
    },
},
