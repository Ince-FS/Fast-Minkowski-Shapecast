--!strict

type Ball = {
	Shape: string,
	Margin: number,
	
	Transform: CFrame,
	Radius: number,

	fromPart: (basePart: BasePart) -> Ball,
	localSupport: (n: Vector3) -> Vector3
}

return function(): Ball
	local self: Ball = {
		Shape = 'Ball',
		Margin = 0,
		
		Transform = CFrame.identity,
		Radius = 0
	} :: Ball

	function self.fromPart(basePart)
		self.Transform = basePart.CFrame
		self.Radius = .5*math.min(basePart.Size.X, basePart.Size.Y, basePart.Size.Z)

		return self
	end

	@native function self.localSupport(n)
		return n.Unit*self.Radius
	end

	return self
end