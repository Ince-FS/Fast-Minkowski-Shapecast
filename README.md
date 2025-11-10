# Fast Minkowski Shapecast

## Overview
Fast Minkowski Shapecast is a fast linear convex shapecasting algorithm written in LuaU

https://github.com/user-attachments/assets/313bd7fc-8829-4695-80e3-bc6b95493fe2

## Usage

```luau
local ReplicatedStorage = game:GetService 'ReplicatedStorage'

local FMShapecast = require(ReplicatedStorage:WaitForChild 'FMShapecast')
local World = FMShapecast() --// Creates a new geometry world

local sphereShape = World.createShape 'Ball' --// Creates a sphere shape
sphereShape.Transform = CFrame.new(0, 50, 0)
sphereShape.Radius = 1
sphereShape.Margin = .01

local shapecastParams: FMShapecast.ShapecastParams = {}

local shapecastResult = World:Shapecast(sphereShape, Vector3.new(0, -999, 0), overlapParams)
if shapecastResult then
    print('Distance', shapecastResult.Distance)
    print('Instance', shapecastResult.Instance)
    print('Material', shapecastResult.Material)
    print('Position', shapecastResult.Position)
    print('Normal', shapecastResult.Normal)
end
```

## Limitations
- Doesn't work with meshes or union operations
- Doesn't work with terrain

## Example Place
[Bouncy Spheres](https://www.roblox.com/games/140565669830337/FMShapecast-Bouncy-Spheres)
