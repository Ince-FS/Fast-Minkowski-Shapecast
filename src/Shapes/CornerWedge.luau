--!strict

type CornerWedge = {
	Shape: string,
	Margin: number,

	Transform: CFrame,
	Extent: Vector3,

	fromPart: (basePart: BasePart) -> CornerWedge,
	localSupport: (n: Vector3) -> Vector3
}

local _vertices: {Vector3} = {
	Vector3.new(1,  1, -1), Vector3.new(-1, -1,  1),
	Vector3.new(1, -1, -1), Vector3.new(-1, -1, -1),
	Vector3.new(1, -1,  1)
}

local _verticesCount: number = #_vertices

return function(): CornerWedge
	local self: CornerWedge = {
		Shape = 'CornerWedge',
		Margin = 0,
		
		Transform = CFrame.identity,
		Extent = Vector3.zero
	} :: CornerWedge

	function self.fromPart(basePart)
		self.Transform = basePart.CFrame
		self.Extent = .5*basePart.Size

		return self
	end

	@native function self.localSupport(n)
		local curP, bestD = _vertices[1], n:Dot(_vertices[1]) do
			for I = 2, _verticesCount do
				local d = n:Dot(_vertices[I])
				if d > bestD then
					curP, bestD = _vertices[I], d
				end
			end
		end

		return curP*self.Extent
	end

	return self
end