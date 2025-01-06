# Fast Minkowski Shapecast

## Overview
Fast Minkowski Shapecast is a fast linear convex shapecasting algorithm written in LuaU

## Usage

```luau
local ReplicatedStorage = game:GetService 'ReplicatedStorage'

local World = require(ReplicatedStorage:WaitForChild 'FMShapecast')() --// Creates a new geometry world

local sphereShape = World.createShape 'Ball' --// Creates a sphere shape
sphereShape.Transform = CFrame.new(0, 50, 0)
sphereShape.Radius = 1
sphereShape.Margin = .01

local overlapParams = OverlapParams.new()
local shapecastResult = World:Shapecast(sphereShape, Vector3.new(0, -999, 0), overlapParams)
if shapecastResult then
    print('Distance', shapecastResult.Distance)
    print('Instance', shapecastResult.Instance)
    print('Material', shapecastResult.Material)
    print('Position', shapecastResult.Position)
    print('Normal', shapecastResult.Normal)
end
```

## Example Place
(Place Link)[https://www.roblox.com/games/140565669830337/FMShapecast-Bouncy-Spheres]