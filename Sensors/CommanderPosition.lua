local sensorInfo = {
	name = "CommanderPosition",
	desc = "Return data of actual position of commander.",
	author = "Patik",
	date = "2018-04-26",
	license = "notAlicense",
}

local EVAL_PERIOD_DEFAULT = 0 -- acutal, no caching

function getInfo()
	return {
		period = EVAL_PERIOD_DEFAULT 
	}
end

-- speedups
local commanderId = nil

-- @description return current wind statistics
return function()
  if (not commanderId == nil) and Spring.ValidUnitID(commanderId) and (not Spring.GetUnitIsDead(commanderId)) then 
    local pointX, pointY, pointZ = Spring.GetUnitPosition(commanderId)
    return Vec3(pointX, pointY, pointZ)
  else 
    -- local allUnits = Spring.GetAllUnits()
    -- local end = table.getn(allUnits) 
    for i = 1, #units  do
      local unitId = units[i]
      local unitDefID = Spring.GetUnitDefID(unitId)
      if UnitDefs[unitDefID].name == "armbcom" then 
        commanderId = unitId
        local pointX, pointY, pointZ = Spring.GetUnitPosition(commanderId)
        return Vec3(pointX, pointY, pointZ)
      end          
    end 
    return nil
  end 
end