local allTargets = {}
local activeTargets = {}
local focusActive = false
local selecting = false
local updateTargets = false

Citizen.CreateThread(function()
  while true do
    local waitTime = 500
    if focusActive then
      DisableControlAction(0,24,true)

      HandleFocus()

      if not selecting and (IsControlJustPressed(0,24) or IsDisabledControlJustPressed(0,24)) then
        HandleClick()
      end

      waitTime = 0
    end
    
    Wait(waitTime)
  end
end)

function HandleFocus()
  local pos = GetEntityCoords(PlayerPedId())
  local hit,endCoords,entityHit = Utils.ScreenToWorld()

  local hitValidModel = false
  if entityHit > 0 and GetEntityType(entityHit) > 0 then
    hitValidModel = true
  end

  local targets = {}

  for k,v in ipairs(allTargets) do
    if v.typeof == "point" then
      if #(v.point - endCoords) <= v.interactDist and #(v.point - pos) <= v.interactDist then
        targets[v.name] = v
        if not activeTargets[v.name] then
          updateTargets = true
        end
      else
        if activeTargets[v.name] then
          activeTargets[v.name] = nil
          updateTargets = true
        end
      end
    elseif v.typeof == "model" then
      if hitValidModel then 
        local model = GetEntityModel(entityHit)
        if v.model then
          if v.model == model then
            local dist = #(GetEntityCoords(entityHit) - endCoords)
            if dist <= v.interactDist and #(pos - GetEntityCoords(entityHit)) <= v.interactDist then
              targets[v.name] = v
              v.entityHit = entityHit
              if not activeTargets[v.name] then
                updateTargets = true
              end
            else
              if activeTargets[v.name] then
                activeTargets[v.name] = nil
                updateTargets = true
              end
            end
          else
            if activeTargets[v.name] then
              activeTargets[v.name] = nil
              updateTargets = true
            end
          end
        elseif v.models then
          local found = false
          for _,_model in ipairs(v.models) do
            if _model == model then
              found = true
              break
            end
          end

          if found then
            local dist = #(GetEntityCoords(entityHit) - endCoords)
            if dist <= v.interactDist and #(pos - GetEntityCoords(entityHit)) <= v.interactDist then
              targets[v.name] = v
              v.entityHit = entityHit
              if not activeTargets[v.name] then
                updateTargets = true
              end
            else
              if activeTargets[v.name] then
                activeTargets[v.name] = nil
                updateTargets = true
              end
            end
          else
            if activeTargets[v.name] then
              activeTargets[v.name] = nil
              updateTargets = true
            end
          end
        end
      end
    elseif v.typeof == "entity" then
      if entityHit > 0 then
        if v.entId and v.entId == entityHit
        or v.netId and v.netId == NetworkGetNetworkIdFromEntity(entityHit) 
        then
          local dist = #(GetEntityCoords(entityHit) - endCoords)
          if dist <= v.interactDist and #(pos - GetEntityCoords(entityHit)) <= v.interactDist then
            targets[v.name] = v
            v.entityHit = entityHit
            if not activeTargets[v.name] then
              updateTargets = true
            end
          else
            if activeTargets[v.name] then
              activeTargets[v.name] = nil
              updateTargets = true
            end
          end
        else
          if activeTargets[v.name] then
            activeTargets[v.name] = false
            updateTargets = true
          end
        end
      else
        if activeTargets[v.name] then
          activeTargets[v.name] = false
          updateTargets = true
        end
      end
    elseif v.typeof == "polyzone" then
      if v.inside then
        targets[v.name] = v
        if not activeTargets[v.name] then
          updateTargets = true
        end
      else
        if activeTargets[v.name] then
          activeTargets[v.name] = false
          updateTargets = true
        end
      end
    end
  end

  activeTargets = targets

  if updateTargets then
    updateTargets = false
    if Utils.TableCount(activeTargets) == 0 then
      SendNUIMessage({
        type = "leftTarget"
      })
    else
      UpdateMenu(activeTargets)
    end
  end
end

function UpdateMenu(targets)
  local arr = {}
  for k,v in pairs(targets) do arr[#arr+1] = v end
  table.sort(arr,function(a,b) return a.label < b.label end)
  SendNUIMessage({
    type = "validTarget",
    data = arr
  })
end

function HandleClick()    
  if Utils.TableCount(activeTargets) > 0 then
    selecting = true                                            
    SetNuiFocus(true, true)
    SetCursorLocation(0.5, 0.5)
    SendNUIMessage({
      type = "onClick"
    })
  end
end

exports('AddTargetEntity',function(opts)
  if not opts or not opts.name or not opts.label or not opts.netId or not opts.options then error("Invalid opts for AddTargetEntity",1) return end
  table.insert(allTargets,{
    typeof        = "entity",
    name          = opts.name,
    label         = opts.label,
    icon          = opts.icon or "fas fa-question",
    netId         = opts.netId,
    interactDist  = opts.interactDist or 2.5,
    onInteract    = opts.onInteract,
    options       = opts.options,
    vars          = opts.vars,
    resource      = GetInvokingResource()
  })  
end)

exports('AddTargetLocalEntity',function(opts)
  if not opts or not opts.name or not opts.label or not opts.entId or not opts.options then error("Invalid opts for AddTargetEntity",1) return end
  table.insert(allTargets,{
    typeof        = "entity",
    name          = opts.name,
    label         = opts.label,
    icon          = opts.icon or "fas fa-question",
    entId         = opts.entId,
    interactDist  = opts.interactDist or 2.5,
    onInteract    = opts.onInteract,
    options       = opts.options,
    vars          = opts.vars,
    resource      = GetInvokingResource()
  })  
end)

exports('AddTargetPoint',function(opts) 
  if not opts or not opts.name or not opts.label or not opts.point or not opts.options then error("Invalid opts for AddTargetPoint",1) return end
  table.insert(allTargets,{
    typeof        = "point",
    name          = opts.name,
    label         = opts.label,
    icon          = opts.icon or "fas fa-question",
    point         = opts.point,
    interactDist  = opts.interactDist or 2.5,
    onInteract    = opts.onInteract,
    options       = opts.options,
    vars          = opts.vars,
    resource      = GetInvokingResource()
  })  
end)

exports('AddTargetModel',function(opts) 
  if not opts or not opts.name or not opts.label or not opts.model or not opts.options then error("Invalid opts for AddTargetModel",1) return end
  table.insert(allTargets,{
    typeof        = "model",
    name          = opts.name,
    label         = opts.label,
    icon          = opts.icon or "fas fa-question",
    model         = opts.model,
    interactDist  = opts.interactDist or 2.5,
    onInteract    = opts.onInteract,
    options       = opts.options,
    vars          = opts.vars,
    resource      = GetInvokingResource()
  })  
end)

exports('AddTargetModels',function(opts) 
  if not opts or not opts.name or not opts.label or not opts.models or not opts.options then error("Invalid opts for AddTargetModels",1) return end
  table.insert(allTargets,{
    typeof        = "model",
    name          = opts.name,
    label         = opts.label,
    icon          = opts.icon or "fas fa-question",
    models        = opts.models,
    interactDist  = opts.interactDist or 2.5,
    onInteract    = opts.onInteract,
    options       = opts.options,
    vars          = opts.vars,
    resource      = GetInvokingResource()
  })  
end)

exports('AddPolyZone',function(opts)
  if not opts or not opts.name or not opts.label or not opts.options then error("Invalid opts for AddPolyZone",1) return end

  local name = opts.name
  local index = #allTargets+1
  local isInside = opts.isInside or false

  allTargets[index] = {
    typeof        = "polyzone",
    name          = opts.name,
    label         = opts.label,
    icon          = opts.icon or "fas fa-question",
    inside        = opts.inside or false,
    onInteract    = opts.onInteract,
    options       = opts.options,
    vars          = opts.vars,
    resource      = GetInvokingResource()
  }

  return (function(inside)
    if not allTargets[index] then
      return
    end
    
    if allTargets[index].name == name then
      allTargets[index].inside = inside
    end
  end)
end)

exports('RemoveTargetPoint',function(name)
  for k,v in ipairs(allTargets) do
    if v.name == name then
      table.remove(allTargets,k)
      updateTargets = true
      return
    end
  end
end)

AddEventHandler("onClientResourceStop",function(res)
  for i=#allTargets,1,-1 do
    local v = allTargets[i]
    if v.resource == res then
      if activeTargets[v.name] then
        activeTargets[v.name] = nil
      end
      table.remove(allTargets,i)
    end
  end
end)

RegisterCommand('+openTargetMenu', function()
  if not focusActive then
    if selecting then
      selecting = false
    else
      focusActive = true
      SendNUIMessage({type = 'openTarget'})
    end
  end
end)

RegisterCommand('-openTargetMenu', function()
  if focusActive and not selecting then
    activeTargets = {}
    focusActive = false
    SendNUIMessage({type = 'closeTarget'})
  end
end)

RegisterKeyMapping("+openTargetMenu", "Focus Target", "keyboard", "TAB")

RegisterNUICallback('closed',function()
  SetNuiFocus(false,false)
  focusActive = false
  selecting = false
  activeTargets = {}
end)

RegisterNUICallback('select',function(d)
  SetNuiFocus(false,false)
  focusActive = false
  activeTargets = {}

  for k,v in ipairs(allTargets) do
    if v.name == d.parentName then
      if v.onInteract then
        for i,j in ipairs(v.options) do
          if j.name == d.name then
            v.onInteract(v.name,j.name,v.vars,v.entityHit)
          end
        end
      else
        break
      end
    end
  end

  selecting = false
end)
