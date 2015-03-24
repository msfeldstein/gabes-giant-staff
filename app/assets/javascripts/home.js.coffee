Codes = {}

Codes["1D noise"] = """
v = noise.simplex3(0, y / 50 + .5 * time, time);
return [v,v,v];
"""

Codes.smoke = """
v = noise.simplex3(x, y / 50 + .5 * time, time);
return [v,v,v];
"""

Codes["2D noise"] = """
r = noise.simplex3(x / 10, y / 50 + .5 * time, time);
g = noise.simplex3(x / 10, y / 50 + .5 * time, time + 100);
b = noise.simplex3(x / 100, y / 40, time / 10 + 300);
return [r,g,b];
"""

Codes.Barber = """
v = Math.abs(Math.sin(x / 2 - y / 2 + time * 10)) % 1;
return [1, 1-v, 1-v]
"""

Codes.Pulser = """
size = 0.5 + 0.5 * Math.sin(time * 10)
dist =1 - Math.abs(HEIGHT / 2 - y) * size / 2
return [0, dist,dist];
"""

Codes["Digital"] = """
r = noise.simplex3(x / 10, y / 50 + .5 * time, time);
g = noise.simplex3(x * 1000, y * 50 + .5 * time, time + 100);
b = noise.simplex3(x * 1000, y * 40, time / 10 + 300);
return [r,g,b];
"""

Codes["Heat (buggy)"] = """
r = noise.simplex3(x / 10, y / 50 + .5 * time, time);
return heatColor(r * 8000);
"""

bound = (v) ->
  Math.min(Math.max(v, 0), 255)
pow = Math.pow
log = Math.log
heatRed = (t) ->
  if t < 800
    d = 5
    if t / d >= 10 
      return bound(t / d)
    else
      return 10
  if t < 6600
    return 255
  return bound(329.698727 * pow(t / 100 - 60, -0.1332))

heatGreen = (t) ->
  if t <= 6600
    return bound(99.4708 * log(t / 100) - 161.11995)
  return bound(288.122 * pow(t / 100 - 60, -0.075514))

heatBlue = (t) ->
  if t >= 6600
    return 255
  if t <= 1900
    return 0

  return bound(138.51773 * log(t / 100 - 10) - 305.044)

window.heatColor = (t) ->
  [heatRed(t) / 255, heatBlue(t) / 255, heatGreen(t) / 255]

shader = null

$ ->
  canvas = document.getElementById("canvas")
  editor = document.getElementById("editor")
  selector = $(".code-selector")
  for name, src of Codes
    selector.append($("<option></option>")
         .attr("value",src)
         .text(name));
  selector.on "change", () ->
    load(selector.val())
  canvas.width = window.innerWidth / 2;
  canvas.height = window.innerHeight;


  canvas.style.webkitFilter = "blur(1px)";
  # 107 px each strip
  # 6 total strips (you can only see 3)
  ctx = canvas.getContext("2d");

  LEDS_HIGH = 107;
  LED_SIZE = Math.floor(canvas.height / LEDS_HIGH - 1);
  LED_WIDTH = 3;
  ctx.translate(canvas.width / 2 - LED_SIZE * LED_WIDTH / 2, 20)
  noise.seed(Math.random());

  drawCircle = (x, y, r, g, b) ->
    ctx.beginPath()
    ctx.lineWidth = 2;
    color = "rgba(" + parseInt(r) + ", " + parseInt(g) + ", " + parseInt(b) + ",255);"
    ctx.fillStyle = color;
    ctx.arc(x * LED_SIZE, y * LED_SIZE, LED_SIZE * 0.4, 0, Math.PI * 2, false);
    ctx.fill();

  time = 0;

  createFunction = (src) ->
    str = """
    function __shader(x, y, WIDTH, HEIGHT) {
      #{src}
    }
    """
    console.log str
    eval str
    __shader

  animate = () ->
    try
      ctx.clearRect(0, 0, canvas.width, canvas.height);
      time += 0.01;
      for x in [0..LED_WIDTH]
        for y in [0..LEDS_HIGH]
          [r,g,b] = shader(x,y, LED_WIDTH, LEDS_HIGH)
          drawCircle(x, y, 255 * r, 255 * g, 255 * b)
    catch e
      # nothin
    requestAnimationFrame(animate);
  requestAnimationFrame(animate);

  load = (code) ->
    editor.value = code
    update()
  

  update = () ->
    try
      shader = createFunction editor.value
    catch e
      console.log e
  debounceTimer = null
  $(editor).on "change keyup paste", () ->
    console.log "change"
    clearTimeout debounceTimer
    debounceTimer = setTimeout update, 500
  load(Codes["2D noise"])
