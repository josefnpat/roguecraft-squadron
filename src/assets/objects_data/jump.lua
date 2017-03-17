return function()
  return {
    type = "jump",
    display_name = "Jumpgate Calibrator",
    info = "A jump ship that will allow your fleet to jump to the next system faster.",
    cost = {material=200,crew=10},
    fow = 0.5,
    crew = 10,
    size = 32,
    speed = 75,
    health = {max = 10,},
    repair = false,
    actions = {"salvage","repair","jump","jump_process","upgrade_jump"},
    jump = 2,--used to be 1
    jump_process = true,
    build_time = 5,
  }
end
