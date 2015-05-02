@bound = (v) ->
  Math.min(Math.max(v, 0), 255)

@pow = Math.pow
@log = Math.log
@cos = Math.cos
@sin = Math.sin
@tan = Math.tan
@round = Math.round
@min = Math.min
@max = Math.max
@clamp = (v, minimum, maximum) ->
  max(min(v, maximum), minimum)

@heatRed = (t) ->
  if t < 800
    d = 5
    if t / d >= 10
      return bound(t / d)
    else
      return 10
  if t < 6600
    return 255
  return bound(329.698727 * pow(t / 100 - 60, -0.1332))

@heatGreen = (t) ->
  if t <= 6600
    return bound(99.4708 * log(t / 100) - 161.11995)
  return bound(288.122 * pow(t / 100 - 60, -0.075514))

@heatBlue = (t) ->
  if t >= 6600
    return 255
  if t <= 1900
    return 0

  return bound(138.51773 * log(t / 100 - 10) - 305.044)

@heatColor = (t) ->
  [heatRed(t) / 255, heatBlue(t) / 255, heatGreen(t) / 255]

@componentToHex = (c) ->
    hex = c.toString(16);
    hex.length == 1 ? "0" + hex : hex;

@rgbToHex = (r, g, b) ->
    return "#" + componentToHex(r) + componentToHex(g) + componentToHex(b)
