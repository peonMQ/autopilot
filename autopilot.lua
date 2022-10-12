--- @type Mq
local mq = require('mq')
local logger = require('utils/logging')
local configLoader = require('utils/configloader')

local args = {...}

---@type table<string, table<string, string[]>>
local navmapType = nil
local navmap = configLoader('', navmapType, "data/autopilot.json")

---@param waypoints string[]
local function navigateZoneWayPoints(waypoints)
  for i=1,#waypoints do
    local waypoint = waypoints[i]
    if mq.TLO.Navigation.PathExists("wp "..waypoint) then
      mq.cmdf("/nav wp %s", waypoint)
      mq.delay(10)
      while mq.TLO.Navigation.Active() do
        mq.delay(50)
      end
    else
      logger.Error("Could not find nav path to waypoint <%s>", waypoint)
      mq.cmd("/beep")
    end
  end
end

---@param destination string
local function engangeAutopilot(destination)
  if not destination then
    logger.Warn("You must supply a destination to travel too.")
    return
  end

  local destinationNavMap = navmap[destination]
  if not destination then
    logger.Warn("Route <%s> has no entry in the navmap. Unable to find a route, exiting.", destination)
    return
  end

  repeat
    local currentZone = mq.TLO.Zone.ShortName()
    local zoneWayPoints = destinationNavMap[currentZone]
    navigateZoneWayPoints(zoneWayPoints)
  until currentZone == mq.TLO.Zone.ShortName()

  logger.Info("Arrived at destination or missing waypoints for <%s>.", mq.TLO.Zone.ShortName())
end

engangeAutopilot(args[1])