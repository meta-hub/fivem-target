local points = {}

RegisterCommand('test_polyzone',function()
  local isInsidePolyZone = false
  local pos = GetEntityCoords(PlayerPedId())
  local polyZone = PolyZone:Create({
    vector2(pos.x-5.0,pos.y-5.0),
    vector2(pos.x-5.0,pos.y+5.0),
    vector2(pos.x+5.0,pos.y+5.0),
    vector2(pos.x+5.0,pos.y-5.0)
  },{
    debugPoly=true,
    minZ=pos.z-5.0,
    maxZ=pos.z+1.0
  })

  exports["fivem-target"]:AddPolyZone({
    name = "test_polyzone",
    label = "House",
    icon = "fas fa-home",
    getInside = function()
      return isInsidePolyZone
    end,
    onInteract = onInteract,
    options = {
      {
        name = "open_menu",
        label = "Open Menu"
      },
      {
        name = "open_menu",
        label = "Sell House"
      }
    },
    vars = {
      whatever = "whatever"
    }
  })

  polyZone:onPointInOut(PolyZone.getPlayerPosition, function(isPointInside, point)
    isInsidePolyZone = isPointInside
  end,500)
end)

RegisterCommand('test_point',function()
  local pos = GetEntityCoords(PlayerPedId())

  exports["fivem-target"]:AddTargetPoint({
    name = "test_point",
    label = "Door",
    icon = "fas fa-door-open",
    point = pos,
    interactDist = 2.5,
    onInteract = onInteract,
    options = {
      {
        name = "enter_house",
        label = "Enter"
      },      
      {
        name = "enter_house",
        label = "Unlock"
      },     
    },
    vars = {
      whatever = "whatever"
    }
  })
end)

RegisterCommand('test_model',function()
  local model GetEntityModel(PlayerPedId())

  exports["fivem-target"]:AddTargetModel({
    name = "rottweiler",
    label = "Rottweiler",
    icon = "fas fa-dog",
    model = GetHashKey('a_c_rottweiler'),
    interactDist = 10.0,
    onInteract = onInteract,
    options = {
      {
        name = "distract",
        label = "Distract"
      }
    },
    vars = {
      whatever = "whatever"
    }
  })
end)

onInteract = function(targetName,optionName,vars,entityHit)
  if optionName == "distract" then
    ClearPedTasksImmediately(entityHit)
    TaskWanderStandard(entityHit,10.0,10)
  end
end