local sensorInfo = {
	name = "CommanderPosition",
	desc = "Return data of actual position of commander.",
	author = "Palvatik",
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
    local lx, ly, lz = Spring.GetUnitPosition(commanderId)
    return {
      posX = lx,
      posY = ly,
      posZ = lz
    }
  else 
    local allUnits = Spring.GetAllUnits()
    for i = 1, table.getn(allUnits) do
      local unitId = allUnits[i]
      local unitDefID = Spring.GetUnitDefID(unitId)
      if UnitDefs[unitDefID].name == "armbcom" then 
        commanderId = unitId
        local lx, ly, lz = Spring.GetUnitPosition(commanderId)
        return {
          x = lx,
          y = ly,
          z = lz
        }
      end          
    end 
  end 
end