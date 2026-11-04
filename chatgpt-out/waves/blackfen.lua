-- Kingdom Nights / Blackfen waves W1 / version: 2 / author: ChatGPT
-- PROPOSAL ONLY: pending Omar approval. Existing enemy stats only; no engineering changes.
-- Full old/new counts, HP budgets, economy and limitations: W1-design-review.md.
-- Four-player counts use math.round(Count*2.05) per entry; base HP without modifiers.
-- Final-night Count=1 Fen Wraith becomes TWO bosses at 3-4 players under generic scaling.
-- 50,000 HP per boss. TargetSeconds=525 is unchanged metadata, NOT a validated W1 clear time.
blackfen = {
    Id = "blackfen", Display = "Blackfen", Theme = "Fen", Difficulty = "Hard",
    StartGold = 8, UnlockLevel = 10, DifficultyMult = 1.6,
    Model = "Map_Blackfen", HeroLevelCap = 5, TargetSeconds = 525,
    Nights = {
        -- 1: Opening unchanged from accepted baseline.
        -- Solo count/HP 24/1720; four-player 49/3485; last release 5.25s / 11.20s.
        { Night = 1, Entries = {
            { EnemyId = "weakling", Count = 16, SpawnIndex = 1, StartDelay = 0, Interval = 0.35 },
            { EnemyId = "swordsman", Count = 8, SpawnIndex = 1, StartDelay = 1, Interval = 0.4 },
        }},
        -- 2: Northern spiderling pack.
        -- Solo count/HP 30/3130; four-player 61/6385; last release 7.00s / 9.60s.
        { Night = 2, Entries = {
            { EnemyId = "swordsman", Count = 16, SpawnIndex = 1, StartDelay = 0, Interval = 0.3 },
            { EnemyId = "slime", Count = 4, SpawnIndex = 2, StartDelay = 0, Interval = 0.35 },
            { EnemyId = "pikeman", Count = 4, SpawnIndex = 2, StartDelay = 1, Interval = 0.4 },
            { EnemyId = "spiderling", Count = 6, SpawnIndex = 2, StartDelay = 5, Interval = 0.4 },
        }},
        -- 3: One eastern exploder; western ram retained.
        -- Solo count/HP 35/6100; four-player 71/12325; last release 8.00s / 9.60s.
        { Night = 3, Entries = {
            { EnemyId = "ram", Count = 1, SpawnIndex = 1, StartDelay = 0, Interval = 0.5 },
            { EnemyId = "swordsman", Count = 16, SpawnIndex = 1, StartDelay = 0, Interval = 0.3 },
            { EnemyId = "pikeman", Count = 9, SpawnIndex = 2, StartDelay = 0, Interval = 0.35 },
            { EnemyId = "racer", Count = 8, SpawnIndex = 3, StartDelay = 1, Interval = 0.3 },
            { EnemyId = "exploder", Count = 1, SpawnIndex = 3, StartDelay = 8, Interval = 1.2 },
        }},
        -- 4: Southern bloodwing pair.
        -- Solo count/HP 40/7800; four-player 82/15850; last release 6.80s / 9.60s.
        { Night = 4, Entries = {
            { EnemyId = "ram", Count = 2, SpawnIndex = 2, StartDelay = 0, Interval = 0.5 },
            { EnemyId = "swordsman", Count = 16, SpawnIndex = 2, StartDelay = 0, Interval = 0.3 },
            { EnemyId = "pikeman", Count = 12, SpawnIndex = 3, StartDelay = 0, Interval = 0.3 },
            { EnemyId = "wasp", Count = 2, SpawnIndex = 4, StartDelay = 2, Interval = 0.35 },
            { EnemyId = "racer", Count = 6, SpawnIndex = 4, StartDelay = 0, Interval = 0.35 },
            { EnemyId = "bloodwing", Count = 2, SpawnIndex = 4, StartDelay = 6, Interval = 0.8 },
        }},
        -- 5: First western Dark Warrior.
        -- Solo count/HP 41/8025; four-player 84/16300; last release 6.80s / 8.40s.
        { Night = 5, Entries = {
            { EnemyId = "ram", Count = 1, SpawnIndex = 1, StartDelay = 0, Interval = 0.5 },
            { EnemyId = "ram", Count = 1, SpawnIndex = 3, StartDelay = 0, Interval = 0.5 },
            { EnemyId = "swordsman", Count = 12, SpawnIndex = 1, StartDelay = 0, Interval = 0.28 },
            { EnemyId = "pikeman", Count = 14, SpawnIndex = 3, StartDelay = 0, Interval = 0.3 },
            { EnemyId = "wasp", Count = 4, SpawnIndex = 2, StartDelay = 2, Interval = 0.3 },
            { EnemyId = "archer_e", Count = 6, SpawnIndex = 4, StartDelay = 1, Interval = 0.35 },
            { EnemyId = "bloodwing", Count = 2, SpawnIndex = 2, StartDelay = 6, Interval = 0.8 },
            { EnemyId = "darkwarrior", Count = 1, SpawnIndex = 1, StartDelay = 4, Interval = 1 },
        }},
        -- 6: Northern catapult retained; southern mixed air.
        -- Solo count/HP 45/10125; four-player 92/20500; last release 9.00s / 10.20s.
        { Night = 6, Entries = {
            { EnemyId = "ram", Count = 3, SpawnIndex = 2, StartDelay = 0, Interval = 0.5 },
            { EnemyId = "catapult", Count = 1, SpawnIndex = 2, StartDelay = 0, Interval = 0.5 },
            { EnemyId = "swordsman", Count = 12, SpawnIndex = 1, StartDelay = 0, Interval = 0.28 },
            { EnemyId = "pikeman", Count = 16, SpawnIndex = 3, StartDelay = 0, Interval = 0.28 },
            { EnemyId = "wasp", Count = 4, SpawnIndex = 4, StartDelay = 1, Interval = 0.3 },
            { EnemyId = "archer_e", Count = 4, SpawnIndex = 2, StartDelay = 1, Interval = 0.3 },
            { EnemyId = "bloodwing", Count = 3, SpawnIndex = 4, StartDelay = 6, Interval = 0.8 },
            { EnemyId = "darkwarrior", Count = 1, SpawnIndex = 1, StartDelay = 4, Interval = 1 },
            { EnemyId = "exploder", Count = 1, SpawnIndex = 2, StartDelay = 9, Interval = 1.2 },
        }},
        -- 7: Western mobile armour and southern swarm.
        -- Solo count/HP 61/12604; four-player 124/25458; last release 7.60s / 10.25s.
        { Night = 7, Entries = {
            { EnemyId = "ram", Count = 3, SpawnIndex = 3, StartDelay = 0, Interval = 0.5 },
            { EnemyId = "catapult", Count = 1, SpawnIndex = 3, StartDelay = 0, Interval = 0.5 },
            { EnemyId = "ogre", Count = 1, SpawnIndex = 1, StartDelay = 0, Interval = 0.5 },
            { EnemyId = "swordsman", Count = 18, SpawnIndex = 4, StartDelay = 0, Interval = 0.28 },
            { EnemyId = "pikeman", Count = 16, SpawnIndex = 2, StartDelay = 0, Interval = 0.28 },
            { EnemyId = "wasp", Count = 6, SpawnIndex = 1, StartDelay = 1, Interval = 0.3 },
            { EnemyId = "racer", Count = 4, SpawnIndex = 4, StartDelay = 0, Interval = 0.3 },
            { EnemyId = "bloodwing", Count = 3, SpawnIndex = 1, StartDelay = 6, Interval = 0.8 },
            { EnemyId = "darkwarrior", Count = 1, SpawnIndex = 1, StartDelay = 4, Interval = 1 },
            { EnemyId = "spiderling", Count = 8, SpawnIndex = 4, StartDelay = 5, Interval = 0.35 },
        }},
        -- 8: Split siege remains; eastern swarm.
        -- Solo count/HP 64/15179; four-player 130/30608; last release 7.60s / 10.25s.
        { Night = 8, Entries = {
            { EnemyId = "ram", Count = 2, SpawnIndex = 1, StartDelay = 0, Interval = 0.5 },
            { EnemyId = "ram", Count = 2, SpawnIndex = 4, StartDelay = 0, Interval = 0.5 },
            { EnemyId = "catapult", Count = 2, SpawnIndex = 4, StartDelay = 0, Interval = 0.5 },
            { EnemyId = "ogre", Count = 2, SpawnIndex = 2, StartDelay = 0, Interval = 0.5 },
            { EnemyId = "swordsman", Count = 14, SpawnIndex = 3, StartDelay = 0, Interval = 0.27 },
            { EnemyId = "pikeman", Count = 18, SpawnIndex = 1, StartDelay = 0, Interval = 0.28 },
            { EnemyId = "wasp", Count = 6, SpawnIndex = 2, StartDelay = 1, Interval = 0.3 },
            { EnemyId = "racer", Count = 6, SpawnIndex = 3, StartDelay = 0, Interval = 0.3 },
            { EnemyId = "bloodwing", Count = 3, SpawnIndex = 2, StartDelay = 6, Interval = 0.8 },
            { EnemyId = "darkwarrior", Count = 1, SpawnIndex = 3, StartDelay = 4, Interval = 1 },
            { EnemyId = "spiderling", Count = 8, SpawnIndex = 3, StartDelay = 5, Interval = 0.35 },
        }},
        -- 9: Four-front rehearsal with one western exploder.
        -- Solo count/HP 76/18679; four-player 154/37608; last release 9.00s / 11.60s.
        { Night = 9, Entries = {
            { EnemyId = "ram", Count = 3, SpawnIndex = 1, StartDelay = 0, Interval = 0.45 },
            { EnemyId = "ram", Count = 2, SpawnIndex = 3, StartDelay = 0, Interval = 0.45 },
            { EnemyId = "catapult", Count = 2, SpawnIndex = 2, StartDelay = 0, Interval = 0.5 },
            { EnemyId = "ogre", Count = 2, SpawnIndex = 4, StartDelay = 0, Interval = 0.45 },
            { EnemyId = "swordsman", Count = 22, SpawnIndex = 3, StartDelay = 0, Interval = 0.26 },
            { EnemyId = "pikeman", Count = 18, SpawnIndex = 1, StartDelay = 0, Interval = 0.27 },
            { EnemyId = "wasp", Count = 6, SpawnIndex = 4, StartDelay = 1, Interval = 0.28 },
            { EnemyId = "racer", Count = 6, SpawnIndex = 2, StartDelay = 0, Interval = 0.28 },
            { EnemyId = "bloodwing", Count = 4, SpawnIndex = 4, StartDelay = 6, Interval = 0.8 },
            { EnemyId = "darkwarrior", Count = 2, SpawnIndex = 4, StartDelay = 4, Interval = 0.9 },
            { EnemyId = "spiderling", Count = 8, SpawnIndex = 2, StartDelay = 5, Interval = 0.35 },
            { EnemyId = "exploder", Count = 1, SpawnIndex = 1, StartDelay = 9, Interval = 1.2 },
        }},
        -- 10: Fen Wraith north at time zero; reduced siege and escorts. COUNT=1 SCALES TO 2 AT 3-4 PLAYERS under generic scaling.
        -- Solo count/HP 42/58081; four-player 86/116350; last release 11.85s / 16.40s.
        { Night = 10, Entries = {
            { EnemyId = "fenwraith", Count = 1, SpawnIndex = 2, StartDelay = 0, Interval = 1 },
            { EnemyId = "ram", Count = 1, SpawnIndex = 1, StartDelay = 0, Interval = 0.4 },
            { EnemyId = "ram", Count = 1, SpawnIndex = 3, StartDelay = 0, Interval = 0.4 },
            { EnemyId = "catapult", Count = 1, SpawnIndex = 2, StartDelay = 0, Interval = 0.4 },
            { EnemyId = "swordsman", Count = 10, SpawnIndex = 1, StartDelay = 3, Interval = 0.35 },
            { EnemyId = "pikeman", Count = 8, SpawnIndex = 2, StartDelay = 3, Interval = 0.4 },
            { EnemyId = "spiderling", Count = 12, SpawnIndex = 3, StartDelay = 8, Interval = 0.35 },
            { EnemyId = "wasp", Count = 4, SpawnIndex = 4, StartDelay = 7, Interval = 0.5 },
            { EnemyId = "bloodwing", Count = 2, SpawnIndex = 4, StartDelay = 10, Interval = 1 },
            { EnemyId = "darkwarrior", Count = 2, SpawnIndex = 2, StartDelay = 6, Interval = 1.2 },
        }},
    },
},
