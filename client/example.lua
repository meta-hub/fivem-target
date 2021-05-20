local points = {}

RegisterCommand('test_polyzone',function()
  local setInside = exports["fivem-target"]:AddPolyZone({
    name = "test_polyzone",
    label = "PolyZone",
    icon = "fas fa-home",
    inside = false,
    onInteract = onInteract,
    options = {
      {
        name = "enter_house",
        label = "Enter"
      }, 
    },
    vars = {
      whatever = "whatever"
    }
  })

  polyZone:onPointInOut(PolyZone.getPlayerPosition,function(inside)
    setInside(inside)
  end)
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

RegisterCommand('test_entity',function()
  local plyPed = PlayerPedId()
  local pos = GetEntityCoords(plyPed)
  local ents = {}
  local i,ent,_ = FindFirstPed()

  while ent and ent > 0 do
    if ent ~= plyPed then
      table.insert(ents,{
        ent = ent,
        dist = #(GetEntityCoords(ent) - pos)
      })
    end
    _,ent = FindNextPed(i)
  end

  EndFindPed(i)

  table.sort(ents,function(a,b)
    return a.dist < b.dist
  end)

  exports["fivem-target"]:AddTargetEntity({
    name = "test_net_id",
    label = "Random Ped",
    icon = "fas fa-door-open",
    netId = NetworkGetNetworkIdFromEntity(ents[1].ent),
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