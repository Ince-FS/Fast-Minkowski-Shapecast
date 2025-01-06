--!strict

type Block = {
	Shape: string,
	Margin: number,

	Transform: CFrame,
	Extent: Vector3,

	fromPart: (basePart: BasePart) -> Block,
	localSupport: (n: Vector3) -> Vector3
}

return function(): Block
	local self: Block = {
		Shape = 'Block',
		Margin = 0,
		
		Transform = CFrame.identity,
		Extent = Vector3.zero
	} :: Block
	
	function self.fromPart(basePart)
		self.Transform = basePart.CFrame
		self.Extent = .5*basePart.Size
		
		return self
	end
	
	@native function self.localSupport(n)
		return Vector3.new(
			n.X < 0 and -self.Extent.X or self.Extent.X,
			n.Y < 0 and -self.Extent.Y or self.Extent.Y,
			n.Z < 0 and -self.Extent.Z or self.Extent.Z
		)
	end
	
	return self
end