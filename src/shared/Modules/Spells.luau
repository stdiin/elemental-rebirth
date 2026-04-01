local RunService = game:GetService("RunService")
return {
	Fireball = {
		Element = "Fire",
		Type = "Projectile",
		Damage = 30,
		ManaReq = 30,
		MasteryReq = 1,
		MaxChargeDuration = 5,
		Cooldown = if RunService:IsStudio() then 5 else 10,
		Anchor = false,
		MaxDistance = 500,
		ExpGain = 30,
	},
	FireStomp = {
		Element = "Fire",
		Type = "Explosion",
		Damage = 30,
		ManaReq = 30,
		MasteryReq = 1,
		MaxChargeDuration = 5,
		Cooldown = if RunService:IsStudio() then 5 else 10,
		Anchor = true,
		MaxDistance = 500,
		ExpGain = 30
	},
}
