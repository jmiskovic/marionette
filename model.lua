local l = require('lume')

local me = {name='me'}

adam = {
    name = 'adam',
  state = {
    happy = 0.7,
  },
  responses = {
    ['give water'] = {
      {
        origin = { thirsty = 0.0, respect = 0.2},
        vector = { thirsty = 0.0 },
      },
      {
        origin = { thirsty = 0.5, respect = 0.2},
        vector = { thirsty = -0.3, respect = 0.2,},
      },
    },
    ['time'] = {
      {
        origin = {},
        vector = {thirsty=0.1}
      }
    },
  },
  expressions = {
  },
  lastResponse = {},
}

local function getAvailableResponses(person, source)
  person, source = person or adam, source or me
  local responseList = {} -- build list of all responses (TODO: cache)
  for stimulusName, responses in pairs(person.responses) do
    for i, response in ipairs(responses) do
      local d = 0 -- squared distance of response from current origin
      for name, value in pairs(response.origin) do
        d = d + (value - (space[name] or 0))^2
      end
      table.insert(responseList, {stimulusName, d, response.origin, response.vector})
    end
  end
  table.sort(responseList, function (a, b) return a[2] < b[2] end)
  --for i,v in ipairs(responseList) do print(string.format('%03.0f %s', v[2] * 10, v[1])) end
  return responseList
end

-- get interpolated vector from all vectors in space, with inverse distance weighting
local function interpolatedVector(origin, space)
  local interpolated = {}
  local p = 5
  local w = {} -- weights for origin vector of each response
  local skipNorm = {}
  local sumW = 0
  -- calculate inverse-distance weights and their sum
  for i, response in ipairs(space) do
    local d2 = 0 -- squared distance
    for name, value in pairs(response.origin) do
      d2 = d2 + (value - (origin[name] or 0))^2
    end
    if d2 > 0 then
      w[i] = 1 / d2^(p/2)
      sumW = sumW + w[i]
    else
      -- found perfect match - abort search
      for name, value in pairs(response.vector) do
        interpolated[name] = value
      end
      -- premature return
      return interpolated
    end
  end
  -- apply weights to interpolate between points
  for i, response in ipairs(space) do
    for name, value in pairs(response.vector) do
      interpolated[name] = (interpolated[name] or 0) + value * w[i]
    end
  end
  -- normalize
  for name, value in pairs(interpolated) do
    interpolated[name] = value / sumW
  end
  return interpolated
end

local function getInterpolatedResponse(stimulusName, person, source)
  person, source = person or adam, source or me
  local responses = person.responses[stimulusName]
  -- create new response table with current state as origin
  local response = {origin={}, vector={}}
  for k,v in pairs(person.state) do response.origin[k] = v end
  if responses then
    response.vector = interpolatedVector(response.origin, responses)
  end
  return response
end

local function applyResponse(response, person, source)
  person, source = person or adam, source or me
  for k,v in pairs(response.vector or {}) do
      person.state[k] = (person.state[k] or 0) + v
  end
  --prune zero states
  for k,v in pairs(person.state) do
    if v < 0.05 then
      person.state[k] = nil
    end
  end
end

local destack = {}
local counfusedAbout = ''

-- you could respond happy+ me:recognition+ and say ‘hello’
-- ycf happy+
local COULD_EXPR = 'ycf .+' -- you could respond

function youCouldFeel(s)
  if string.match(s, '%a+[><]+') then
    local feel = string.match(s, '(%a+)[><]+.*')
    s = string.sub(s, #feel)
    local mod = string.match(s, '([><]+).*')
    if #mod > 0 then
      local delta = mod == '<' and -0.2 or 0.2
      response = getAppropriateResponse
      --addResponse(counfusedAbout, {[feel]=delta})
    end
  end
end

function push()
    table.insert(destack, deepcopy(adam))
end

function pop()
    adam = destack[#destack]
    destack[#destack] = nil
end

function interpret(expr)
  if expr == '' then
  elseif expr == '?' then
    inspect()
  elseif expr == 'bye' then
    print('see you..\n')
    os.exit()
  elseif expr == '>' then
    table.insert(destack, l.deepcopy(adam))
    print('#destack ' .. #destack)
  elseif expr == '<' then
    adam = destack[#destack]
    destack[#destack] = nil
    print('#destack ' .. #destack)
  elseif string.match(expr, COULD_EXPR) then
    youCouldFeel(string.match(expr, 'ycf (.*)'))
  elseif expr == 'try' then
    interpret(counfusedAbout)
  else
    local res = getAppropriateResponse(expr)
    if res then
      applyResponse(res)
    else
      counfusedAbout = expr
    end
  end
end

function save(person)
  person = person or adam
  require('savetable')
  print(table.save(person, 'person')) -- watch out for moths
end

function load(person)
  require('savetable')
  local loaded = table.load('person') -- welcome back, buddy
  if loaded then
    person = loaded
  end
end

function inspect(person, source)
  person, source = person or adam, source or me
  local stats = {}
  for key,value in pairs(person.state) do
      local bars = 15
      local v = math.floor(value * bars)
      table.insert(stats, table.concat ({
        string.format('%+10s: %+1.2f ', key, value),
        string.rep(' ', bars + math.min(0, v)),
        string.rep('=', -math.min(0, v)), '|',
        string.rep('=', math.max(0, v)),
        string.rep(' ', bars - math.max(0, v))
      }, ''))
  end
  return table.concat(stats, '\n')
end

function addResponse(stimulusName, response, person)
  person = person or adam
  person.responses[stimulusName] = person.responses[stimulusName] or {}
  table.insert(person.responses[stimulusName], response)
end

function addExpression(pose, person)
  person = person or adam
  table.insert(person.expressions, {origin = l.deepcopy(adam.state), pose = l.deepcopy(pose)})
  print('added', #person.expressions)
end

function respond(stimulusName, person, source)
  person, source = person or adam, source or me
  local response = getInterpolatedResponse(stimulusName)
  applyResponse(response)
  return response
end

local function closestVector(origin, space)
  local d2min, iMin = math.huge, 0
  for i, response in ipairs(space) do
    local d2 = 0 -- squared distance
    for name, value in pairs(response.origin) do
      d2 = d2 + (value - (origin[name] or 0))^2
    end
    if d2 < d2min then
      d2min = d2
      iMin = i
    end
  end
      local serpent = require('serpent')
      if iMin>0 then
    print('space',serpent.block(space))
    print('pose',serpent.block(space[iMin].pose))
  end

  return iMin > 0 and space[iMin].pose or nil
end

function express(person)
  person = person or adam
  return closestVector(person.state, person.expressions)
end

return adam