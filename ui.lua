--- @type Mq
local mq = require 'mq'
local logger = require('utils/logging')
local luaUtils = require('utils/lua')
local debugUtil = require('utils/debug')
local json = require('utils/json')

--- @type ImGui
require 'ImGui'

local configDir = mq.configDir.."/"
local serverName = mq.TLO.MacroQuest.Server()

---@type table<string, table<string, string[]>>
local navmap = json.LoadJSON(configDir..serverName.."/data/autopilot.json")

local destintions={}
for k,_ in pairs(navmap) do
  table.insert(destintions, k)
end

-- GUI Control variables
local openGUI = true
local shouldDrawGUI = true
local terminate = false
local selectedItem = 0

-- ImGui main function for rendering the UI window
local autopilot = function()
  openGUI, shouldDrawGUI = ImGui.Begin('Autopilot', openGUI)
  ImGui.SetWindowSize(430, 257, ImGuiCond.FirstUseEver)
  if shouldDrawGUI then
    selectedItem, _ = ImGui.ListBox("Destination", selectedItem, destintions, #destintions)

    if ImGui.Button("Engage", 62, 22) then
      local navigateTo = destintions[selectedItem]
      mq.cmdf("/bcaa //lua run autopilot/autopilot %s", navigateTo)
    end
  end

  ImGui.End()

  if not openGUI then
      terminate = true
  end
end

mq.imgui.init('autopilot', autopilot)

while not terminate do
  mq.doevents()
  mq.delay(500)
end
