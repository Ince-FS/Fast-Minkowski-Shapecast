--!strict

type Cylinder = {
	Shape: string,
	Margin: number,

	Transform: CFrame,
	Height: number,
	Radius: number,

	fromPart: (basePart: BasePart) -> Cylinder,
	localSupport: (n: Vector3) -> Vector3
}

return function(): Cylinder
	local self: Cylinder = {
		Shape = 'Cylinder',
		Margin = 0,
		
		Transform = CFrame.identity,
		Height = 0,
		Radius = 0
	} :: Cylinder

	function self.fromPart(basePart)
		self.Transform = basePart.CFrame
		self.Height = .5*basePart.Size.X
		self.Radius = .5*math.min(basePart.Size.Y, basePart.Size.Z)

		return self
	end

	@native function self.localSupport(n)
		local S = n.Y*n.Y + n.Z*n.Z
		if S == 0 then
			return Vector3.new(n.X < 0 and -self.Height or self.Height, self.Radius, 0)
		end

		local D = self.Radius/S^.5
		return Vector3.new(n.X < 0 and -self.Height or self.Height, n.Y*D, n.Z*D)
	end

	return self
end