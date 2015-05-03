EDITOR_WIDTH = 400

$ ->
  canvas = document.getElementById("canvas")
  resize = () ->
    $("#editor-column").css('width', EDITOR_WIDTH)
    $("#canvas-column").css('width', window.innerWidth - EDITOR_WIDTH)
    canvas.width = (window.innerWidth - EDITOR_WIDTH) * window.devicePixelRatio;
    canvas.height = window.innerHeight * window.devicePixelRatio;
    canvas.style.width = "100%"
    canvas.style.height = "100%"

  $(window).on "resize", resize
  resize()
