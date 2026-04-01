local RunService = game:GetService("RunService")
local Projectile = {}
Projectile.__index = Projectile

type ProjectileData = {
	origin: vector,
	direction: vector,
	speed: number,
	maxDistance: number?,
	filter: { Instance }?,

	_traveled: number,
	_position: vector,
	_params: RaycastParams?,
	_onUpdate: (position: vector) -> Projectile?,
	_onImpact: (position: vector) -> Projectile?,
	_connection: RBXScriptConnection,
}

export type Projectile = setmetatable<ProjectileData, typeof(Projectile)>

function Projectile.new(settings: ProjectileData): Projectile
	if settings.filter then
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = settings.filter
		settings._params = params
	end

	settings.maxDistance = settings.maxDistance or 400
	settings._traveled = 0
	settings._position = settings.origin

	return setmetatable(settings, Projectile)
end

function Projectile.onUpdate(self: Projectile, fn)
	self._onUpdate = fn
	return self
end

function Projectile.onImpact(self: Projectile, fn)
	self._onImpact = fn
	return self
end

function Projectile._update(self: Projectile, dt: number)
	local step = self.speed * dt
	self._traveled += step

	local spherecastResult = workspace:Spherecast(self._position, 1.75, self.direction * step, self._params)
	if spherecastResult then
		if self._onImpact then
			self._onImpact(self._position)
			self._onImpact = nil
			print("IMPACT")
		end

		self._connection:Disconnect()
		return
	end

	self._position += self.direction * step

	if self._traveled >= self.maxDistance then
		if self._onImpact then
			self._onImpact(self._position)
			self._onImpact = nil
		end

		self._connection:Disconnect()
		return
	end

	if self._onUpdate then
		self._onUpdate(self._position)
	end
end

function Projectile.run(self: Projectile)
	if RunService:IsServer() then
		self._connection = RunService.Heartbeat:Connect(function(dt)
			self:_update(dt)
		end)
	else
		self._connection = RunService.RenderStepped:Connect(function(dt)
			self:_update(dt)
		end)
	end
end

return Projectile
