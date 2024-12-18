Nui = {}
LocalPlayer = { state = { openLogistic = false, openTaskLogistic = false, openDialog = false } }
local State = LocalPlayer.state

function Nui.ShowNui(action, data)
  local state = data.Visible
  if state and State[action] then state = false end

  if action == "openLogistic" then
    SetNuiFocus(data.Visible, data.Visible)
    SendNUIMessage({ action = action, data = { Visible = data.Visible, Tasks = data.Tasks, PlayerData = data.PlayerData } })
  elseif action == "openTaskLogistic" then
    SendNUIMessage({ action = action, data = { Visible = data.Visible, Tasks = data.Tasks } })
  elseif action == "openDialog" then
    SetNuiFocus(data.Visible, data.Visible)
    SendNUIMessage({ action = action, data = { Visible = data.Visible, npcData = data.npcData } })
  end

  if State[action] ~= nil then State[action] = state end
end

RegisterNuiCallback("LGF_TruckSystem:CloseUiByIndex", function(data, cb)
  if data.name == "openLogistic" and LocalPlayer.state["openLogistic"] then
    Nui.ShowNui("openLogistic", {
      Visible = false,
      Tasks = Functions.getAllTasks(CurrentZone),
      PlayerData = Functions.getPlayerData(),
    })
    SendNUIMessage({ action = "updateParent" })
  elseif data.name == "openTaskLogistic" and LocalPlayer.state["openTaskLogistic"] then
    Nui.ShowNui("openTaskLogistic", {
      Visible = false,
      Tasks = {},
    })
  elseif data.name == "openDialog" and LocalPlayer.state["openDialog"] then
    Nui.ShowNui("openDialog", {
      Visible = false,
      npcData = {},
    })
  end
  cb(true)
end)
