@initGUI = (parameters) ->
  gui = new dat.GUI
  gui.add(parameters, "speed", 0, 0.1).name("Pattern Speed")
  gui.add(parameters, "feedbackAmount", 0.0, 1.0)
  gui.add(parameters, "rotateSpeed", 0.0, 1.0).step(0.01).listen()
  gui.add(parameters, "share").name("Share")
  parameters.rotateSpeed = 0
  gui.add(parameters, "run")
