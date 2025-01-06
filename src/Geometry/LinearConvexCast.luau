--!native
--!strict

local MAX_ITERATIONS: number = 256

local function getABV(
	originA: CFrame, marginA: number, invA: CFrame, localSupportA: any,
	originB: CFrame, marginB: number, invB: CFrame, localSupportB: any,
	n: Vector3
): (Vector3, Vector3, Vector3)
	local rA, rB = invA*n, invB*-n
	local SA, SB = originA*localSupportA(rA) + rA*marginA, originB*localSupportB(rB) + rB*marginB
	return SA, SB, SA - SB
end

local function fastLinearConvexCast(
	originA: CFrame, marginA: number, localSupportA: any, directionA: Vector3,
	originB: CFrame, marginB: number, localSupportB: any, directionB: Vector3
): (number?, Vector3?, Vector3?)
	local rayDir = (directionA - directionB).Unit
	if rayDir:Dot(rayDir) == 0 then return end

	local invA, invB = originA.Rotation:Inverse(), originB.Rotation:Inverse()

	local SA0, SB0, V0 = originA.Position, originB.Position, originA.Position - originB.Position
	
	local SA1, SB1, V1 = getABV(originA, marginA, invA, localSupportA, originB, marginB, invB, localSupportB, V0:Cross(rayDir):Cross(rayDir).Unit)
	if V0:Dot(V1:Cross(rayDir)) > 0 then
		SA0, SB0, V0, SA1, SB1, V1 = SA1, SB1, V1, SA0, SB0, V0
	end

	local SA2, SB2, V2 do
		for _ = 0, MAX_ITERATIONS do
			local n = (V1 - V0):Cross(rayDir).Unit

			SA2, SB2, V2 = getABV(originA, marginA, invA, localSupportA, originB, marginB, invB, localSupportB, n)
			if n:Dot(V2) < 0 then return end
			
			local uv = V2:Cross(rayDir)
			if V0:Dot(uv) < 0 then
				SA1, SB1, V1 = SA2, SB2, V2
			elseif V1:Dot(uv) > 0 then
				SA0, SB0, V0 = SA2, SB2, V2
			else
				break
			end
		end
	end

	local SA3, SB3, V3 do
		for I = 0, MAX_ITERATIONS do
			local n = (V2 - V0):Cross(V1 - V0).Unit
			
			SA3, SB3, V3 = getABV(originA, marginA, invA, localSupportA, originB, marginB, invB, localSupportB, n)
			if (V3 - V0):Dot(n) < 1e-7*I then
				local t = -V0:Dot(n)/rayDir:Dot(n)
				
				local rd = rayDir*t
				local s0, s1, s2 = V0 + rd, V1 + rd, V2 + rd
				local u, v, w, x = s0:Cross(s1):Dot(s2), s2:Cross(s1):Dot(rayDir), rayDir:Cross(s0):Dot(s2), s1:Cross(s0):Dot(rayDir)

				local s = u + v + w + x
				if s <= 0 then
					u, v, w, x = 0, s1:Cross(s2):Dot(n), s2:Cross(s0):Dot(n), s0:Cross(s1):Dot(n)
					s = v + w + x
				end
				
				return t, (u*originB.Position + v*SB0 + w*SB1 + x*SB2)/s, -n
			end

			local uv = V3:Cross(rayDir)
			if V0:Dot(uv) > 0 then
				if V1:Dot(uv) > 0 then
					SA0, SB0, V0 = SA3, SB3, V3
				else
					SA2, SB2, V2 = SA3, SB3, V3
				end
			else
				if V2:Dot(uv) > 0 then
					SA1, SB1, V1 = SA3, SB3, V3
				else
					SA0, SB0, V0 = SA3, SB3, V3
				end
			end
		end
	end
	
	return
end

return fastLinearConvexCast