return function()
  return {
    type = "jump",
    display_name = "Jumpgate Calibrator",
    info = "A jump ship that will allow your fleet to jump to the next system faster.",
    cost = {material=100,crew=10},
    fow = 0.5,
    crew = 10,
    size = 32,
    speed = 50,
    health = {max = 10,},
    repair = false,
    actions = {"salvage","repair","jump","jump_process"},
    jump = 2,--used to be 1
    jump_process = true,
  }
end
