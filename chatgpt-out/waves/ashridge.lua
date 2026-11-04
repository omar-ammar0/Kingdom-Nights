-- Kingdom Nights / Ashridge waves W1 / version: 3 / author: ChatGPT
-- PROPOSAL ONLY: pending Omar approval. Existing enemy stats only; no engineering changes.
-- Full old/new counts, HP budgets, economy and limitations: W1-design-review.md.
-- Four-player counts use math.round(Count*2.05) per entry; base HP without modifiers.
ashridge = {
    Id = "ashridge", Display = "Ashridge", Theme = "Highland", Difficulty = "Medium",
    StartGold = 3, UnlockLevel = 3, DifficultyMult = 1.2,
    Model = "Map_Ashridge", HeroLevelCap = 3, TargetSeconds = 450,
    Nights = {
        -- 1: Opening unchanged from accepted baseline.
        -- Solo count/HP 16/792; four-player 33/1629; last release 10.10s / 13.20s.
        { Night = 1, Entries = {
            { EnemyId = "weakling", Count = 12, SpawnIndex = 1, StartDelay = 0, Interval = 0.55 },
            { EnemyId = "slime", Count = 4, SpawnIndex = 1, StartDelay = 8, Interval = 0.7 },
        }},
        -- 2: Opening unchanged from accepted baseline.
        -- Solo count/HP 24/1668; four-player 49/3381; last release 11.75s / 15.05s.
        { Night = 2, Entries = {
            { EnemyId = "weakling", Count = 12, SpawnIndex = 1, StartDelay = 0, Interval = 0.5 },
            { EnemyId = "swordsman", Count = 6, SpawnIndex = 2, StartDelay = 3, Interval = 0.65 },
            { EnemyId = "slime", Count = 6, SpawnIndex = 2, StartDelay = 9, Interval = 0.55 },
        }},
        -- 3: North spiderling introduction after the screen.
        -- Solo count/HP 32/2644; four-player 66/5458; last release 12.80s / 14.95s.
        { Night = 3, Entries = {
            { EnemyId = "swordsman", Count = 10, SpawnIndex = 1, StartDelay = 0, Interval = 0.6 },
            { EnemyId = "weakling", Count = 12, SpawnIndex = 3, StartDelay = 0, Interval = 0.5 },
            { EnemyId = "slime", Count = 2, SpawnIndex = 2, StartDelay = 4, Interval = 0.55 },
            { EnemyId = "racer", Count = 2, SpawnIndex = 2, StartDelay = 12, Interval = 0.8 },
            { EnemyId = "spiderling", Count = 6, SpawnIndex = 2, StartDelay = 10, Interval = 0.45 },
        }},
        -- 4: Northeast swarm reinforcement.
        -- Solo count/HP 40/3982; four-player 81/8089; last release 11.15s / 14.75s.
        { Night = 4, Entries = {
            { EnemyId = "swordsman", Count = 12, SpawnIndex = 1, StartDelay = 0, Interval = 0.5 },
            { EnemyId = "archer_e", Count = 6, SpawnIndex = 1, StartDelay = 5, Interval = 0.6 },
            { EnemyId = "slime", Count = 6, SpawnIndex = 3, StartDelay = 0, Interval = 0.45 },
            { EnemyId = "pikeman", Count = 8, SpawnIndex = 2, StartDelay = 3, Interval = 0.6 },
            { EnemyId = "spiderling", Count = 8, SpawnIndex = 3, StartDelay = 8, Interval = 0.45 },
        }},
        -- 5: Northeast swarm; original wasp introduction retained.
        -- Solo count/HP 48/5208; four-player 98/10666; last release 12.10s / 14.90s.
        { Night = 5, Entries = {
            { EnemyId = "swordsman", Count = 14, SpawnIndex = 1, StartDelay = 0, Interval = 0.45 },
            { EnemyId = "slime", Count = 8, SpawnIndex = 3, StartDelay = 0, Interval = 0.4 },
            { EnemyId = "pikeman", Count = 10, SpawnIndex = 2, StartDelay = 2, Interval = 0.55 },
            { EnemyId = "wasp", Count = 4, SpawnIndex = 2, StartDelay = 10, Interval = 0.7 },
            { EnemyId = "racer", Count = 4, SpawnIndex = 3, StartDelay = 10, Interval = 0.7 },
            { EnemyId = "spiderling", Count = 8, SpawnIndex = 3, StartDelay = 8, Interval = 0.45 },
        }},
        -- 6: One late north exploder; early ram retained.
        -- Solo count/HP 55/6934; four-player 112/14056; last release 13.80s / 16.20s.
        { Night = 6, Entries = {
            { EnemyId = "ram", Count = 1, SpawnIndex = 2, StartDelay = 0, Interval = 0.6 },
            { EnemyId = "swordsman", Count = 18, SpawnIndex = 1, StartDelay = 0, Interval = 0.4 },
            { EnemyId = "slime", Count = 18, SpawnIndex = 3, StartDelay = 0, Interval = 0.4 },
            { EnemyId = "archer_e", Count = 6, SpawnIndex = 2, StartDelay = 2, Interval = 0.55 },
            { EnemyId = "pikeman", Count = 7, SpawnIndex = 2, StartDelay = 4, Interval = 0.55 },
            { EnemyId = "wasp", Count = 4, SpawnIndex = 3, StartDelay = 12, Interval = 0.6 },
            { EnemyId = "exploder", Count = 1, SpawnIndex = 2, StartDelay = 10, Interval = 1.2 },
        }},
        -- 7: Northwest exploder and northeast swarm.
        -- Solo count/HP 63/7760; four-player 130/15896; last release 13.20s / 16.00s.
        { Night = 7, Entries = {
            { EnemyId = "swordsman", Count = 18, SpawnIndex = 1, StartDelay = 0, Interval = 0.35 },
            { EnemyId = "slime", Count = 10, SpawnIndex = 3, StartDelay = 0, Interval = 0.35 },
            { EnemyId = "pikeman", Count = 10, SpawnIndex = 2, StartDelay = 0, Interval = 0.45 },
            { EnemyId = "archer_e", Count = 6, SpawnIndex = 2, StartDelay = 4, Interval = 0.5 },
            { EnemyId = "racer", Count = 4, SpawnIndex = 3, StartDelay = 10, Interval = 0.6 },
            { EnemyId = "wasp", Count = 3, SpawnIndex = 1, StartDelay = 12, Interval = 0.6 },
            { EnemyId = "ogre", Count = 1, SpawnIndex = 2, StartDelay = 0, Interval = 0.6 },
            { EnemyId = "spiderling", Count = 10, SpawnIndex = 3, StartDelay = 7, Interval = 0.45 },
            { EnemyId = "exploder", Count = 1, SpawnIndex = 1, StartDelay = 10, Interval = 1.2 },
        }},
        -- 8: Combined established threats; no boss.
        -- Solo count/HP 75/9961; four-player 154/20298; last release 11.80s / 16.00s.
        { Night = 8, Entries = {
            { EnemyId = "swordsman", Count = 20, SpawnIndex = 1, StartDelay = 0, Interval = 0.3 },
            { EnemyId = "slime", Count = 12, SpawnIndex = 3, StartDelay = 0, Interval = 0.3 },
            { EnemyId = "pikeman", Count = 14, SpawnIndex = 2, StartDelay = 0, Interval = 0.4 },
            { EnemyId = "archer_e", Count = 8, SpawnIndex = 2, StartDelay = 3, Interval = 0.45 },
            { EnemyId = "racer", Count = 4, SpawnIndex = 3, StartDelay = 10, Interval = 0.6 },
            { EnemyId = "wasp", Count = 4, SpawnIndex = 1, StartDelay = 10, Interval = 0.6 },
            { EnemyId = "ogre", Count = 2, SpawnIndex = 2, StartDelay = 0, Interval = 0.6 },
            { EnemyId = "spiderling", Count = 10, SpawnIndex = 3, StartDelay = 7, Interval = 0.45 },
            { EnemyId = "exploder", Count = 1, SpawnIndex = 1, StartDelay = 10, Interval = 1.2 },
        }},
    },
},
