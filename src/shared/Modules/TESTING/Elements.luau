return {
    Fire = {
        Rarity = "Common",
        Color = Color3.new(1, 0, 0),
        Spells = {
            Pyroblast = {
                BaseDamage = 30,
                Cooldown = 5,
                ManaCost = 25,
            },

            Blaze = {
                BaseDamage = 40,
                Cooldown = 12,
                ManaCost = 40
            },

            HeatWave = {
                BaseDamage = 30,
                Cooldown = 8,
                ManaCost = 50
            },

            Ignition = {
                Cooldown = 30,
                ManaCost = 70
            },

            Meltdown = {
                BaseDamage = 200,
                Cooldown = 120,
                ManaCost = 100
            }
        }
    },

    Lightning = {
        Rarity = "Common",
        Color = Color3.fromRGB(0, 210, 210),
        Spells = {
            LightningStrike = {
                BaseDamage = 50,
                Cooldown = 15,
                ManaCost = 50
            },

            LightningDash = {
                Cooldown = 4,
                ManaCost = 5
            },

            LightningStream = {
                BaseDamage = 2,
                Cooldown = 15,
                ManaCost = 60
            },

            LightningCloak = {
                Cooldown = 30,
                ManaCost = 30
            },

            Thunderstorm = {
                Cooldown = 50,
                ManaCost = 100,
            }
        }
    }
}