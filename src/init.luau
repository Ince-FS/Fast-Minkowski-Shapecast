--!strict

export type ShapecastParams = {
	FilterDescendantsInstances: {Instance}?,
	FilterType: Enum.RaycastFilterType?,
	MaxParts: number?,
	CollisionGroup: string?,
	RespectCanCollide: boolean?,
	Tolerance: number?,
	DepthContact: boolean?,
}

type ShapecastResult = {
	Distance: number,
	Instance: Instance,
	Material: Enum.Material,
	Position: Vector3,
	Normal: Vector3
}

type World = {
	createShape: (shapeName: string) -> any,
	shapeFromPart: (basePart: Part | BasePart) -> any,
	sweptOOBFromShape: (shapeOrigin: CFrame, shapeMargin: number, shapeLocalSupport: any, dir: Vector3) -> (CFrame, Vector3),

	Shapecast: (self: World, baseShape: any, dir: Vector3, overlapParams: ShapecastParams) -> (ShapecastResult?)
}

return function(): World
	local self: World = {} :: World

	local _shapeConstructors: {[string]: any} = {}
	for _, ModuleScript: ModuleScript in script.Shapes:GetChildren() do
		_shapeConstructors[ModuleScript.Name] = require(ModuleScript) :: any
	end

	local _shapeCache: {[string]: any} = {}
	for n in _shapeConstructors do
		_shapeCache[n] = {}
	end

	function self.createShape(shapeName)
		if _shapeCache[shapeName] then
			local Shape: any? = table.remove(_shapeCache[shapeName])
			if Shape then
				return Shape
			end

			return _shapeConstructors[shapeName]()
		end

		return _shapeConstructors.Block()
	end

	function self.shapeFromPart(basePart)
		local shapeName do
			if basePart:IsA 'Part' or basePart:IsA 'SpawnLocation' then
				shapeName = basePart.Shape.Name
			else
				shapeName = string.gsub(basePart.ClassName, 'Part', '')
			end
		end

		return self.createShape(shapeName).fromPart(basePart)
	end

	@native function self.sweptOOBFromShape(shapeOrigin, shapeMargin, shapeLocalSupport, dir)
		local XVector, YVector, ZVector = Vector3.xAxis, Vector3.yAxis, Vector3.zAxis do
			local dd = dir:Dot(dir)
			if dd ~= 0 then
				local axis = dir/(dd^.5)

				local n do
					local dx2, dy2, dz2 = axis.X*axis.X, axis.Y*axis.Y, axis.Z*axis.Z

					local low = math.min(dx2, dy2, dz2)
					if dx2 == low then
						n = Vector3.new(dy2 + dz2, -axis.X*axis.Y, -axis.X*axis.Z).Unit
					elseif dy2 == low then
						n = Vector3.new(-axis.X*axis.Y, dx2 + dz2, -axis.Y*axis.Z).Unit
					else
						n = Vector3.new(-axis.X*axis.Z, -axis.Y*axis.Z, dx2 + dy2).Unit
					end
				end

				XVector, YVector, ZVector = n:Cross(axis), n, axis
			end
		end

		local rotInv = shapeOrigin.Rotation:Inverse()
		local rotX, rotY, rotZ = rotInv*XVector, rotInv*YVector, rotInv*ZVector

		local highX = (shapeOrigin*shapeLocalSupport( rotX)):Dot(XVector) + shapeMargin
		local highY = (shapeOrigin*shapeLocalSupport( rotY)):Dot(YVector) + shapeMargin
		local highZ = (shapeOrigin*shapeLocalSupport( rotZ)):Dot(ZVector) + shapeMargin

		local lowX  = (shapeOrigin*shapeLocalSupport(-rotX)):Dot(XVector) - shapeMargin
		local lowY  = (shapeOrigin*shapeLocalSupport(-rotY)):Dot(YVector) - shapeMargin
		local lowZ  = (shapeOrigin*shapeLocalSupport(-rotZ)):Dot(ZVector) - shapeMargin

		local DX, DY, DZ = dir:Dot(XVector), dir:Dot(YVector), dir:Dot(ZVector)
		highX, highY, highZ = highX + math.max(0, DX), highY + math.max(0, DY), highZ + math.max(0, DZ)
		lowX,  lowY,  lowZ =  lowX + math.min(0, DX),  lowY + math.min(0, DY),  lowZ + math.min(0, DZ)

		return CFrame.fromMatrix(
			.5*(highX + lowX)*XVector + .5*(highY + lowY)*YVector + .5*(highZ + lowZ)*ZVector,
			XVector, YVector, ZVector
		), Vector3.new(highX - lowX, highY - lowY, highZ - lowZ)
	end

	local linearConvexCast = require(script.Geometry.LinearConvexCast)
	function self:Shapecast(castShape, dir, shapecastParams)
		if not shapecastParams.DepthContact then shapecastParams.DepthContact = false end
		
		local obbCFrame, obbSize = self.sweptOOBFromShape(castShape.Transform, castShape.Margin, castShape.localSupport, dir)
		
		local overlapParams = OverlapParams.new() do
			overlapParams.FilterDescendantsInstances = shapecastParams.FilterDescendantsInstances or overlapParams.FilterDescendantsInstances
			overlapParams.FilterType = shapecastParams.FilterType or overlapParams.FilterType
			overlapParams.MaxParts = shapecastParams.MaxParts or overlapParams.MaxParts
			overlapParams.CollisionGroup = shapecastParams.CollisionGroup or overlapParams.CollisionGroup
			overlapParams.RespectCanCollide = shapecastParams.RespectCanCollide or overlapParams.RespectCanCollide
			overlapParams.Tolerance = shapecastParams.Tolerance or overlapParams.Tolerance
		end
		
		local rayLen = dir.Magnitude
		local rayDir = dir/rayLen

		local bestI, bestT, bestP, bestN = nil, 1/0, nil, nil do
			for _, basePart: BasePart in workspace:GetPartBoundsInBox(obbCFrame, obbSize, overlapParams) do
				local baseShape = self.shapeFromPart(basePart)
				if baseShape then
					local t, p, n = linearConvexCast(
						castShape.Transform, castShape.Margin, castShape.localSupport, rayDir,
						baseShape.Transform, baseShape.Margin, baseShape.localSupport, Vector3.zero
					)

					if t and t <= rayLen then
						if not shapecastParams.DepthContact and t >= 0 then continue end
						
						if t < bestT then
							bestI, bestT, bestP, bestN = basePart, t, p, n
						end
					end

					table.insert(_shapeCache[baseShape.Shape], baseShape)
				end
			end
		end

		if bestI then
			return {
				Distance = bestT,
				Instance = bestI,
				Material = bestI.Material,
				Position = bestP,
				Normal = bestN
			} :: ShapecastResult
		end

		return
	end

	return self
end
