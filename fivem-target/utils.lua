Utils = {}

Utils.TableCount = function(t)
  local c = 0
  for k,v in pairs(t) do
    c = c + 1
  end
  return c
end

Utils.ScreenToWorld = function(iter)
  local entityType,entitySubType
  local camRot = GetGameplayCamRot(0)
  local camPos = GetGameplayCamCoord()
  local posX = 0.5
  local posY = 0.5
  local cursor = vector2(posX, posY)
  local cam3DPos, forwardDir = Utils.ScreenRelToWorld(camPos, camRot, cursor)
  local direction = camPos + forwardDir * 50.0
  local rayHandle = StartShapeTestRay(cam3DPos.x,cam3DPos.y,cam3DPos.z, direction.x,direction.y,direction.z, (iter and -1 or 30), 0, 0)
  local _, hit, endCoords, surfaceNormal, entityHit = GetShapeTestResult(rayHandle)
  if entityHit <= 0 and not iter then
    return Utils.ScreenToWorld(true)
  end
  return hit, endCoords, entityHit
end
 
Utils.ScreenRelToWorld = function(camPos, camRot, cursor)
  local camForward = Utils.RotationToDirection(camRot)
  local rotUp = vector3(camRot.x + 1.0, camRot.y, camRot.z)
  local rotDown = vector3(camRot.x - 1.0, camRot.y, camRot.z)
  local rotLeft = vector3(camRot.x, camRot.y, camRot.z - 1.0)
  local rotRight = vector3(camRot.x, camRot.y, camRot.z + 1.0)
  local camRight = Utils.RotationToDirection(rotRight) - Utils.RotationToDirection(rotLeft)
  local camUp = Utils.RotationToDirection(rotUp) - Utils.RotationToDirection(rotDown)
  local rollRad = -(camRot.y * math.pi / 180.0)
  local camRightRoll = camRight * math.cos(rollRad) - camUp * math.sin(rollRad)
  local camUpRoll = camRight * math.sin(rollRad) + camUp * math.cos(rollRad)
  local point3DZero = camPos + camForward * 1.0
  local point3D = point3DZero + camRightRoll + camUpRoll
  local point2D = Utils.World3DToScreen2D(point3D)
  local point2DZero = Utils.World3DToScreen2D(point3DZero)
  local scaleX = (cursor.x - point2DZero.x) / (point2D.x - point2DZero.x)
  local scaleY = (cursor.y - point2DZero.y) / (point2D.y - point2DZero.y)
  local point3Dret = point3DZero + camRightRoll * scaleX + camUpRoll * scaleY
  local forwardDir = camForward + camRightRoll * scaleX + camUpRoll * scaleY
  return point3Dret, forwardDir
end
 
Utils.RotationToDirection = function(rotation)
  local x = rotation.x * math.pi / 180.0
  local z = rotation.z * math.pi / 180.0
  local num = math.abs(math.cos(x))
  return vector3((-math.sin(z) * num), (math.cos(z) * num), math.sin(x))
end
 
Utils.World3DToScreen2D = function(pos)
  local _, sX, sY = GetScreenCoordFromWorldCoord(pos.x, pos.y, pos.z)
  return vector2(sX, sY)
end