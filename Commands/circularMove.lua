function getInfo()
	return {
		onNoUnits = SUCCESS,
		parameterDefs = {
			{ 
				name = "position",
				variableType = "expression",
				componentType = "editBox",
				defaultValue = "{x = 0, y = 0, z = 0}"
			},
			{ 
				name = "radius",
				variableType = "number",
				componentType = "editBox",
				defaultValue = "20"
			}
		}
	}
end

local threshold = 5
local timer = 0
local timeout = 3

function Run(self, unitIds, parameter)
	units = unitIds
	unitsSize = #unitIds
  local fullAngle = 2 * math.pi 
  local angle = fullAngle / unitsSize
  local isRunning = false 
  for i = 1, unitsSize do
    local unitID = units[i]
    local lx, ly, lz = Spring.GetUnitPosition(unitID)
    local relx = parameter.radius * math.cos((i * angle) % fullAngle)
    local relz = parameter.radius * math.sin((i * angle) % fullAngle)  
    local newX = parameter.position.x + relx
    local newY = ly
    local newZ = parameter.position.z + relz
    if math.abs(lx - newX) > threshold or math.abs(ly - newY) > threshold or math.abs(lz - newZ) > threshold then 
      isRunning = true
      Spring.GiveOrderToUnit(unitID, CMD.MOVE, {newX, newY, newZ}, {})  
    end       
  end 
  if isRunning then 
    if timer == 0 then 
      timer = os.clock()
      return RUNNING
    else
      if os.clock() - timer >= timeout then
        timer = 0
        return FAILURE
      else
        return RUNNING
      end
    end
  else 
    timer = 0
    return SUCCESS
  end 
end