head = {}
head.__index = head

local l = require('lume')
local persist = require('persist')

local colors = {
  skin = {l.hsl(0.06, 1.00, 0.89)},
  skinShade = {l.hsl(0.06, 0.50, 0.70)},
  blush = {l.hsl(0.00, 0.57, 0.48, 0.20)},
  iris = {l.hsl(0.75, 1.00, 0.00)},
  teeth = {l.hsl(1.00, 1.00, 1.00)},
  mouth  = {l.hsl(0.00, 1.00, 0.15)},
  lips  = {l.hsl(0.00, 0.31, 0.67)},
  tongue = {l.hsl(0.00, 0.70, 0.5)},
  brows = {l.hsl(0.08, 0.20, 0.20)},
  hair = {l.hsl(0.08, 0.20, 0.35)},
  hairShade = {l.hsl(0.08, 0.20, 0.20)},
  sclera = {l.hsl(0.17, 0.75, 0.98)},
}

function head.new(name)
  return setmetatable({
    pose   = l.deftable({0, 0}),
    form   = l.deftable({0, 0}),
    curves = setmetatable({}, {__serialize = function(t) return {} end}),
  }, head)
end

function head:loadForm(name)
  -- 'head' should have 'pose' and 'form' subtables
  -- they are accessed through metatables, so underlaying tables can
  --  be swapped, manipulated by handles or animated from outside
  name = name or 'adam'
  local form = persist.load('headform_'..name)
  if form then
    self.form = l.deftable({0,0}, form)
  else
    print('nope')
  end
end

function head:draw()
  love.graphics.setLineWidth(10)
  --isolateTransformations(head.drawHairBack, self)
  isolateTransformations(head.drawEars, self)
  isolateTransformations(head.drawFace, self)
  isolateTransformations(head.drawMouth, self)
  isolateTransformations(head.drawEyes, self)
  isolateTransformations(head.drawNose, self)
  --isolateTransformations(head.drawHairFront, self)
end

function isolateTransformations(f, ...)
  love.graphics.push()
  f(...)
  love.graphics.pop()
end


function head:drawEars()
  for i=1,2 do
    love.graphics.push()
    love.graphics.translate(1, self.form.temple[2])
    love.graphics.translate(unpack(self.form.earPos))


    local earShape = self.form.earShape
    love.graphics.rotate(-earShape[1] * 3)
    love.graphics.setColor(colors.skin)
    love.graphics.ellipse('fill', 0, 0, earShape[2], earShape[2] * 1.4)
    love.graphics.setColor(colors.skinShade)
    love.graphics.ellipse('fill', 0, 0, earShape[2] * 0.85, earShape[2] * 1.4 * 0.85)
    love.graphics.pop()
    love.graphics.scale(-1, 1)
  end
end

function head:drawFace()
  love.graphics.push()
    love.graphics.translate(unpack(self.form.jawPos))
    local jaw = self.pose.jaw
  love.graphics.pop()
  self.curves.jawL = self.curves.jawL or love.math.newBezierCurve(0,0, 0,0, 0,0, 0,0)
  self.curves.jawL:setControlPoint(1, -1, self.form.temple[2])
  self.curves.jawL:setControlPoint(2, -1, self.form.temple[2] + self.form.jawCurve[2] + 0.5)
  self.curves.jawL:setControlPoint(3, self.form.jawPos[1] + jaw[1] - self.form.jawCurve[1], self.form.jawPos[2] + jaw[2] + 0.2)
  self.curves.jawL:setControlPoint(4, self.form.jawPos[1] + jaw[1], self.form.jawPos[2] + jaw[2] + 0.2)

  self.curves.jawR = self.curves.jawR or love.math.newBezierCurve(0,0, 0,0, 0,0, 0,0)
  self.curves.jawR:setControlPoint(4, 1, self.form.temple[2])
  self.curves.jawR:setControlPoint(3, 1, self.form.temple[2] + self.form.jawCurve[2] + 0.5)
  self.curves.jawR:setControlPoint(2, self.form.jawPos[1] + jaw[1] + self.form.jawCurve[1], self.form.jawPos[2] + jaw[2] + 0.2)
  self.curves.jawR:setControlPoint(1, self.form.jawPos[1] + jaw[1], self.form.jawPos[2] + jaw[2] + 0.2)

  self.curves.foreheadR = self.curves.foreheadR or love.math.newBezierCurve(0,0, 0,0, 0,0, 0,0)
  self.curves.foreheadR:setControlPoint(1, 1, self.form.temple[2])
  self.curves.foreheadR:setControlPoint(2, 1, self.form.temple[2] - self.form.temple[1])
  self.curves.foreheadR:setControlPoint(3, self.form.forehead[1], self.form.forehead[2] - 0.2)
  self.curves.foreheadR:setControlPoint(4, 0, self.form.forehead[2] - 0.2)

  self.curves.foreheadL = self.curves.foreheadL or love.math.newBezierCurve(0,0, 0,0, 0,0, 0,0)
  self.curves.foreheadL:setControlPoint(4, -1, self.form.temple[2])
  self.curves.foreheadL:setControlPoint(3, -1, self.form.temple[2] - self.form.temple[1])
  self.curves.foreheadL:setControlPoint(2, -self.form.forehead[1], self.form.forehead[2] - 0.2)
  self.curves.foreheadL:setControlPoint(1, 0, self.form.forehead[2] - 0.2)

  love.graphics.setColor(colors.skin)
  drawBezierShape('fill', self.curves.jawL, self.curves.jawR, self.curves.foreheadR, self.curves.foreheadL)
  --love.graphics.setColor(colors.blush)
  --love.graphics.translate(self.form.blushPos[1], self.form.blushPos[2])
  --love.graphics.ellipse('fill',  0, 0, self.form.blushSize[1], self.form.blushSize[2])
  --love.graphics.translate(- 2 * self.form.blushPos[1], 0)
  --love.graphics.ellipse('fill', 0, 0, self.form.blushSize[1], self.form.blushSize[2])
end

function head:drawEyes()
  local time = love.timer.getTime()
  local blink = (time) % math.pi
  local pos = self.form.eyePos
  local focus = self.pose.eyeFocus
  love.graphics.push()
  love.graphics.translate(unpack(pos))
    local size = self.form.eyeSize
    local open = {unpack(self.pose.eyeOpen)}
    open[2] = 0.5 * (-1 + open[2]) * (1 - math.abs(math.sin(blink)^100))
  love.graphics.pop()
  love.graphics.scale(-1, 1)
  isolateTransformations(head.drawEye, self, 'left',  pos, size, focus, open, browPos, browSize)
  love.graphics.scale(-1, 1)
  isolateTransformations(head.drawEye, self, 'right', pos, size, focus, open, browPos, browSize)
end

function head:drawEye(lr, pos, size, focus, open)
  love.graphics.translate(unpack(pos))
  love.graphics.stencil(function ()
      love.graphics.setColorMask(true, true, true, true)
      love.graphics.setColor(colors.sclera)
      love.graphics.arc('fill', 0, 0, 0.1 + size[1]/5, 0, -math.pi)
      love.graphics.push()
      love.graphics.scale(1, -0.5 * open[2])
      love.graphics.arc('fill', 0, 0, 0.1 + size[1]/5, 0, math.pi)
      love.graphics.pop()
    end, 'replace', 1, false)
  love.graphics.setStencilTest("greater", 0)
  love.graphics.setColor(colors.iris)
  local focusX = lr == 'left' and -focus[1] / 4 or focus[1] / 4
  local focusY = focus[2] / 10
  love.graphics.circle('fill', focusX, focusY, 0.1 + size[2]/5)
  love.graphics.setColor(colors.skinShade)
  love.graphics.ellipse('fill', 0, -0.15 + 0.7 * open[2], 0.8, 0.3)
  love.graphics.setStencilTest()
  self:drawBrow(lr)
end

function head:drawBrow(lr, pos, size)
  self.curves.browCurve = self.curves.browCurve or love.math.newBezierCurve(0,0, 0,0, 0,0)
  love.graphics.translate(unpack(self.form.browPos))
  local browThickness =  self.form.browSize[1] / 15
  local skinThickness = -self.form.browSize[2] / 2
  love.graphics.push()
    local sx, sy = unpack(self.pose[lr..'BrowStart'])
    love.graphics.translate(-0.25, -0.1)
    local mx, my = unpack(self.pose[lr..'BrowMid'])
    mx, my = mx - 0.25, my - 0.1
    love.graphics.translate(-0.25,  0.1)
    local ex, ey = unpack(self.pose[lr..'BrowEnd'])
    ex, ey = ex - 0.5, ey
  love.graphics.pop()
  self.curves.browCurve:setControlPoint(1, sx, sy)
  self.curves.browCurve:setControlPoint(2, mx, my)
  self.curves.browCurve:setControlPoint(3, ex, ey)
  love.graphics.setColor(colors.skin)
  love.graphics.setLineWidth(skinThickness)
  love.graphics.setLineJoin('bevel')
  love.graphics.line(self.curves.browCurve:render())
  love.graphics.circle('fill', ex, ey, skinThickness / 2)
  love.graphics.circle('fill', sx, sy, skinThickness / 2)
  love.graphics.setLineWidth(browThickness)
  love.graphics.setColor(colors.brows)
  drawBezierStroke(self.curves.browCurve, function (x) return browThickness/3 + browThickness * (1 - x) end)
  --love.graphics.line(browCurve:render())
  --for i= 0, 1, 0.03 do
  --  local thickness = browThickness / 3 + browThickness * 2 / 3 * (1 - i)
  --  local x, y = self.curves.browCurve:evaluate(i)
  --  love.graphics.circle('fill', x, y, thickness/2)
  --end
  --love.graphics.circle('fill', sx, sy, browThickness / 2)
end

function head:drawNose()
  love.graphics.translate(unpack(self.form.nosePos))
  love.graphics.setColor(colors.skinShade)
  love.graphics.ellipse('fill', 0.0, 0.15 * self.form.noseSize[2], self.form.noseSize[1], self.form.noseSize[2])
  love.graphics.circle('fill', -0.65 * self.form.noseSize[1], 0.35 * self.form.noseSize[2], self.form.noseSize[1] * 0.5)
  love.graphics.circle('fill',  0.65 * self.form.noseSize[1], 0.35 * self.form.noseSize[2], self.form.noseSize[1] * 0.5)
  love.graphics.setColor(colors.skin)
  love.graphics.ellipse('fill', 0, 0, self.form.noseSize[1] * 1.02, self.form.noseSize[2] * 1.02)
end

function head:drawLock(length, wave)
  local a = math.random() * 2 * math.pi
  self.curves.lock = self.curves.lock or love.math.newBezierCurve(0,0, 0,0, 0,0)
  self.curves.lock:setControlPoint(1, math.random() - 0.25, 0)
  self.curves.lock:setControlPoint(2, length * math.cos(a)/2, length * math.sin(a)/2)
  local dx, dy = length * math.cos(a), length * math.sin(a) + 0.6
  self.curves.lock:setControlPoint(3, dx - wave, dy + math.random() * 0.3)
  love.graphics.setColor(colors.hairShade)
  --love.graphics.setColor(colors.hair)
  love.graphics.setLineWidth(0.02)
  love.graphics.line(unpack(self.curves.lock:render(4)))

end

function head:drawHairBack()
  love.graphics.setColor(colors.hairShade)
  love.graphics.ellipse('fill', 0, self.form.temple[2] * 1.01 + self.form.temple[1] * 2 * 0.2, 1.1, self.form.temple[1] * 2 * 1.45)
end

function head:drawHairFront()
  love.graphics.stencil(function ()
  love.graphics.ellipse('fill', 0, self.form.temple[2] * 1.01 + self.form.temple[1] * 2 * 0.2, 1.1, self.form.temple[1] * 2 * 1.45)
      love.graphics.setColor(colors.sclera)
    end, 'replace', 1, false)
  love.graphics.setStencilTest("greater", 0)
  love.graphics.translate(unpack(self.form.hairPos))
  love.graphics.rotate(math.pi/8)
  local a = colors.hairShade[4]
  colors.hairShade[4] = 0.995
  love.graphics.setColor(colors.hairShade)
  colors.hairShade[4] = a
  love.graphics.ellipse('fill', 0, 0, self.form.hairSize[1] * 2, self.form.hairSize[2])
  love.graphics.setStencilTest()
end

---[[ lips + mouth version, that looked broken all the time
function head:drawMouth()
  love.graphics.translate(unpack(self.form.jawPos))
  love.graphics.translate(unpack(self.pose.jaw))
  love.graphics.translate(unpack(self.form.mouthPos))
  local lipThickness, lipBow = unpack(self.form.lipThickness)
  lipThickness = lipThickness / 20
  lipBow = -lipBow * 10
  love.graphics.push()
    local upperLip = {unpack(self.pose.upperLip)}
    love.graphics.translate(0, 0.07)
    local lowerLip = {unpack(self.pose.lowerLip)}
    lowerLip[2] = lowerLip[2] + 0.07
    love.graphics.translate(-0.2, -0.07)
    local leftLip = {unpack(self.pose.leftLip)}
    leftLip[1] = leftLip[1] - 0.2
    love.graphics.translate(0.4, 0)
    local rightLip = {unpack(self.pose.rightLip)}
    rightLip[1] = rightLip[1] + 0.2
  love.graphics.pop()
  self.curves.lipUR = self.curves.lipUR or love.math.newBezierCurve(0,0, 0,0, 0,0)
  self.curves.lipUL = self.curves.lipUL or love.math.newBezierCurve(0,0, 0,0, 0,0)
  self.curves.lipLL = self.curves.lipLL or love.math.newBezierCurve(0,0, 0,0, 0,0)
  self.curves.lipLR = self.curves.lipLR or love.math.newBezierCurve(0,0, 0,0, 0,0)
  -- upper right part
  self.curves.lipUR:setControlPoint(1, rightLip[1], rightLip[2])
  self.curves.lipUR:setControlPoint(2, rightLip[1], upperLip[2])
  self.curves.lipUR:setControlPoint(3, upperLip[1], upperLip[2])
  -- upper left part
  self.curves.lipUL:setControlPoint(1, upperLip[1], upperLip[2])
  self.curves.lipUL:setControlPoint(2, leftLip[1],  upperLip[2])
  self.curves.lipUL:setControlPoint(3, leftLip[1],  leftLip[2])
  -- lower left part
  self.curves.lipLL:setControlPoint(1, leftLip[1],  leftLip[2])
  self.curves.lipLL:setControlPoint(2, leftLip[1],  lowerLip[2])
  self.curves.lipLL:setControlPoint(3, lowerLip[1], lowerLip[2])
  -- lower right part
  self.curves.lipLR:setControlPoint(1, lowerLip[1], lowerLip[2])
  self.curves.lipLR:setControlPoint(2, rightLip[1], lowerLip[2])
  self.curves.lipLR:setControlPoint(3, rightLip[1], rightLip[2])
  love.graphics.setColor(colors.mouth)
  love.graphics.stencil(function ()
      love.graphics.setColorMask(true, true, true, true)
      love.graphics.setLineWidth(0.03)
      love.graphics.setColor(colors.lips)
      love.graphics.setLineJoin('none')
      --drawBezierShape('line', self.curves.lipUR, self.curves.lipUL, self.curves.lipLL, self.curves.lipLR)
      love.graphics.setColor(colors.mouth)
      drawBezierShape('fill', self.curves.lipUR, self.curves.lipUL, self.curves.lipLL, self.curves.lipLR)
    end, 'replace', 1, false)
  --love.graphics.setStencilTest("greater", 0)
  --love.graphics.setColor(colors.teeth)
  --love.graphics.setColor(colors.tongue)
  --love.graphics.ellipse('fill', 0, 0 + 0.05, 0.3, 0.1)
  --love.graphics.setStencilTest()
  --love.graphics.setColor(colors.lips)
end
---]]

function drawBezierStroke(curve, thickness)
  local i = 0
  while i < 1 do
    local t
    if type(thickness) == 'function' then
      t = math.abs(thickness(i))
    else
      t = thickness
    end
    local x, y = curve:evaluate(i)
    love.graphics.circle('fill', x, y, t)
    i = i + t + 0.01
  end
end

function drawBezierShape(mode, ...)
  local curves = {...}
  local points = {}
  for i, curve in ipairs(curves) do
    local cp = curve:render(4)
    for i = 3, #cp - 4, 2 do
        table.insert(points, cp[i])
        table.insert(points, cp[i+1])
    end
  end
  --love.graphics.setPointSize(10); for i, curve in ipairs(curves) do for i = 1, curve:getDegree() do love.graphics.points(curve:getControlPoint(i)) end end
  --if not once then for i=1,#points,2 do print(points[i], points[i+1]) end; once = true end
  --love.graphics.setPointSize(5); love.graphics.points(points)
  --love.graphics.setLineWidth(0.01); love.graphics.line(points)
  if mode == 'fill' then
    status, triangles = pcall(love.math.triangulate, points)
    if status then
      for i,v in ipairs(triangles) do
        love.graphics.polygon('fill', v)
      end
    end
  else
    love.graphics.line(points)
  end
end

return head
