function getInfo()
	return {
		onNoUnits = SUCCESS,
		parameterDefs = {
			{ 
				name = "position",
				variableType = "expression",
				componentType = "editBox",
				defaultValue = "Sensors.nota_pat_task_one.CommanderPosition()"
			}
		}
	}
end

local threshold = 5
local timer = 0
local timeout = 10

function Run(self, unitIds, parameter)
	units = unitIds
	unitsSize = #unitIds
  if parameter.position == nil then 
    return SUCCESS
  end
  
  
  -- initialization, help variables (constants)
  local fullAngle = 2 * math.pi 
  local angle = fullAngle / unitsSize  -- angle between units in cycle
  local isRunning = false -- is command running 
  local k = 0 -- variable for frontlines
  local cycleCount = 12 -- count of units for cycle (1.line = 12 units, 2. line = 24 units)
  local radiusRange = 100 -- radius of cycle (1.line = 100 units, 2. line = 200 units) 
  local actualRadius = (k + 1) * radiusRange
  local start = 1 -- helpers for "for loops"
  local theEnd = 0
  
  -- frontlines
  -- do that until you can create full frontline
  while unitsSize > (theEnd + (k + 1) * cycleCount) do 
    angle = fullAngle / ((k + 1) * cycleCount)
    actualRadius = (k + 1) * radiusRange  
    start = start + (k * cycleCount)
    theEnd = theEnd + (k + 1) * cycleCount
    isRunning = SendSoldiers(angle, actualRadius, start, theEnd, fullAngle, parameter.position, units)
    k = k + 1 
    actualRadius = (k + 1) * radiusRange
  end
  
  -- the rest of units 
  theEnd = unitsSize
  angle = fullAngle / (unitsSize - start + 1)  
  isRunning = SendSoldiers(angle, actualRadius, start, theEnd, fullAngle, parameter.position, units)
  
  -- timeout (units go until they reach the endpoint, but commander is moving, so node has to be reset. sometimes units stuck)
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

-- function for sending commands
function SendSoldiers(angle, actualRadius, start, theEnd, fullAngle, position, units)
  local isRunning = false
  for i = start, theEnd do
    local unitID = units[i]
    local lx, ly, lz = Spring.GetUnitPosition(unitID)
    local relx = actualRadius * math.cos((i * angle) % fullAngle)
    local relz = actualRadius * math.sin((i * angle) % fullAngle)  
    local addVector = Vec3(relx, 0, relz)
    local newVector = position + addVector
    if math.abs(lx - newVector.x) > threshold or math.abs(ly - newVector.y) > threshold or math.abs(lz - newVector.z) > threshold then 
      isRunning = true
      Spring.GiveOrderToUnit(unitID, CMD.MOVE, newVector:AsSpringVector(), {})  
    end      
  end 
  return isRunning
end
  