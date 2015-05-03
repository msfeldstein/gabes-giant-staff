shader = null
EDITOR_WIDTH = 400
SPEED = 0.01

$ ->

  parameters = {
    run: true,
    speed: 0.01,
    feedbackAmount: 0.1,
    rotateSpeed: 0.01,
    translate: false,
    Share: () ->
      prompt "Share this link", window.location + "/#" + encodeURIComponent(JSON.stringify(editor.value))
  }
  gui = new dat.GUI
  gui.add(parameters, "speed", 0, 0.1).name("Pattern Speed")
  gui.add(parameters, "feedbackAmount", 0.0, 1.0)
  gui.add(parameters, "rotateSpeed", 0.0, 1.0).step(0.01).listen()
  gui.add(parameters, "Share")
  parameters.rotateSpeed = 0
  gui.add(parameters, "run")

  canvas = document.getElementById("canvas")
  editor = document.getElementById("editor")
  selector = $(".code-selector")
  for name, src of Codes
    selector.append($("<option></option>")
         .attr("value",src)
         .text(name));
  selector.on "change", () ->
    load(selector.val())

  resize = () ->
    $("#editor-column").css('width', EDITOR_WIDTH)
    $("#canvas-column").css('width', window.innerWidth - EDITOR_WIDTH)
    canvas.width = (window.innerWidth - EDITOR_WIDTH) * window.devicePixelRatio;
    canvas.height = window.innerHeight * window.devicePixelRatio;
    canvas.style.width = "100%"
    canvas.style.height = "100%"

  $(window).on "resize", resize
  resize()


  # canvas.style.webkitFilter = "blur(1px)";
  # 107 px each strip
  # 6 total strips (you can only see 3)
  ctx = canvas.getContext("2d");

  LEDS_HIGH = 107;
  LED_SIZE = Math.floor(canvas.height / LEDS_HIGH - 1);
  LED_WIDTH = 3;

  window.HEIGHT = LEDS_HIGH
  window.WIDTH = LED_WIDTH

  noise.seed(Math.random());

  drawCircle = (x, y, r, g, b) ->
    ctx.beginPath()
    ctx.lineWidth = 2
    color = "rgb(#{parseInt(r)}, #{parseInt(g)}, #{parseInt(b)})"
    ctx.fillStyle = color;
    ctx.arc(x * LED_SIZE, y * LED_SIZE, LED_SIZE * 0.4, 0, Math.PI * 2, false);
    ctx.fill();

  drawArc = (x, y, c1, c2, rot1Deg, rot2Deg) ->
    xpos = (x - WIDTH / 2) * LED_SIZE
    ypos =  (y - HEIGHT / 2) * LED_SIZE
    r = Math.sqrt(xpos * xpos + ypos * ypos)
    theta = Math.atan2(ypos, xpos) + rot1Deg
    thetaDelta = rot2Deg - rot1Deg

    rot1 = rot1Deg / 360 * Math.PI * 2
    rot2 = rot2Deg / 360 * Math.PI * 2
    ctx.beginPath()

    color = "rgb(#{parseInt(c1[0] * 255)}, #{parseInt(c1[1] * 255)}, #{parseInt(c1[2] * 255)})"
    if parameters.rotateSpeed != 0

      ctx.strokeStyle = color
      ctx.lineWidth = LED_SIZE / 2
      ctx.arc(0, 0, r, theta, theta + thetaDelta)
      ctx.stroke()
    else
      ctx.beginPath()
      ctx.fillStyle = color
      ctx.arc(r * Math.cos(theta), r * Math.sin(theta), LED_SIZE * 0.25, 0, Math.PI * 2, false)
      ctx.fill()


  time = 0
  rotation = 0

  createFunction = (src) ->
    str = """
    function __shader(x, y, WIDTH, HEIGHT, time) {
      #{src}
    }
    """
    console.log str
    eval str
    __shader

  animate = () ->
    requestAnimationFrame(animate);
    if !parameters.run then return
    ctx.save()
    time += parameters.speed;
    rotation += parameters.rotateSpeed * 0.5
    try
      ctx.globalCompositeOperation = "normal"
      ctx.fillStyle = "rgba(0,0,0,#{1.0 - Math.pow(parameters.feedbackAmount, .25)})"
      ctx.fillRect(0, 0, canvas.width, canvas.height);
      ctx.translate(canvas.width / 2, canvas.height / 2)


      # ctx.translate(LED_SIZE * LED_WIDTH / 2, LED_SIZE * LEDS_HIGH / 2)
      # ctx.rotate(rotation)
      # ctx.translate(-LED_SIZE * LED_WIDTH / 2, -LED_SIZE * LEDS_HIGH / 2)

      ctx.globalCompositeOperation = "lighter"

      for x in [0..LED_WIDTH-1]
        for y in [0..LEDS_HIGH]
          [r,g,b] = color1 = shader(x,y, LED_WIDTH, LEDS_HIGH, time)
          color2 = shader(x,y, LED_WIDTH, LEDS_HIGH, time + parameters.speed)
          rotation1 = rotation
          rotation2 = rotation + parameters.rotateSpeed * 0.5
          drawArc(x, y, color1, color2, rotation1, rotation2)
          # drawCircle(x, y, clamp(round(255 * r), 0, 255), clamp(round(255 * g), 0, 255), clamp(round(255 * b), 0, 255))
    catch e
      console.log e
      # nothin
    ctx.restore()

  requestAnimationFrame(animate);

  load = (code) ->
    editor.value = code
    update()


  update = () ->
    try
      shader = createFunction editor.value
      localStorage.setItem("lastSketch", editor.value)
    catch e
      console.log e
  debounceTimer = null
  $(editor).on "change keyup paste", () ->
    console.log "change"
    clearTimeout debounceTimer
    debounceTimer = setTimeout update, 500
  if window.location.hash
    lastSketch = JSON.parse(decodeURIComponent(window.location.hash.substring(1)))
  lastSketch ||= localStorage.getItem("lastSketch")
  load(lastSketch || Codes["2D noise"])
