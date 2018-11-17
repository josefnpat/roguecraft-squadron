--todo: load these dynamically in the lovejam campaign
local vn_images = {
  adj = {
    default = love.graphics.newImage("assets/mp_gamemodes/lovejam/vn/adj/default.png"),
    overlay = {
      love.graphics.newImage("assets/mp_gamemodes/lovejam/vn/adj/shine1.png"),
      love.graphics.newImage("assets/mp_gamemodes/lovejam/vn/adj/shine2.png")
    },
  },
  com = {
    default = love.graphics.newImage("assets/mp_gamemodes/lovejam/vn/com/default.png"),
  }
}

local vn_audio = {
  adj = {
    correct = love.audio.newSource("assets/mp_gamemodes/lovejam/vn/adj/audio/correct.ogg","stream"),
    incorrect = love.audio.newSource("assets/mp_gamemodes/lovejam/vn/adj/audio/incorrect.ogg","stream"),
    warning = love.audio.newSource("assets/mp_gamemodes/lovejam/vn/adj/audio/warning.ogg","stream"),
    line1 = love.audio.newSource("assets/mp_gamemodes/lovejam/vn/adj/audio/line1.ogg","stream"),
    line2 = love.audio.newSource("assets/mp_gamemodes/lovejam/vn/adj/audio/line2.ogg","stream"),
    line3 = love.audio.newSource("assets/mp_gamemodes/lovejam/vn/adj/audio/line3.ogg","stream"),
    line4 = love.audio.newSource("assets/mp_gamemodes/lovejam/vn/adj/audio/line4.ogg","stream"),
    line5 = love.audio.newSource("assets/mp_gamemodes/lovejam/vn/adj/audio/line5.ogg","stream"),
    line6 = love.audio.newSource("assets/mp_gamemodes/lovejam/vn/adj/audio/line6.ogg","stream"),
    line7 = love.audio.newSource("assets/mp_gamemodes/lovejam/vn/adj/audio/line7.ogg","stream"),
    line8 = love.audio.newSource("assets/mp_gamemodes/lovejam/vn/adj/audio/line8.ogg","stream"),
    line9 = love.audio.newSource("assets/mp_gamemodes/lovejam/vn/adj/audio/line9.ogg","stream"),
  },
  com = {
    line1 = love.audio.newSource("assets/mp_gamemodes/lovejam/vn/com/audio/line1.ogg","stream"),
    line2 = love.audio.newSource("assets/mp_gamemodes/lovejam/vn/com/audio/line2.ogg","stream"),
    line3 = love.audio.newSource("assets/mp_gamemodes/lovejam/vn/com/audio/line3.ogg","stream"),
    line4 = love.audio.newSource("assets/mp_gamemodes/lovejam/vn/com/audio/line4.ogg","stream"),
    line5 = love.audio.newSource("assets/mp_gamemodes/lovejam/vn/com/audio/line5.ogg","stream"),
    line6 = love.audio.newSource("assets/mp_gamemodes/lovejam/vn/com/audio/line6.ogg","stream"),
    line7 = love.audio.newSource("assets/mp_gamemodes/lovejam/vn/com/audio/line7.ogg","stream"),
    line8 = love.audio.newSource("assets/mp_gamemodes/lovejam/vn/com/audio/line8.ogg","stream"),
    line9 = love.audio.newSource("assets/mp_gamemodes/lovejam/vn/com/audio/line9.ogg","stream"),
    line10 = love.audio.newSource("assets/mp_gamemodes/lovejam/vn/com/audio/line10.ogg","stream"),
    line11 = love.audio.newSource("assets/mp_gamemodes/lovejam/vn/com/audio/line11.ogg","stream"),
    line12 = love.audio.newSource("assets/mp_gamemodes/lovejam/vn/com/audio/line12.ogg","stream"),
    line13 = love.audio.newSource("assets/mp_gamemodes/lovejam/vn/com/audio/line13.ogg","stream"),
    line14 = love.audio.newSource("assets/mp_gamemodes/lovejam/vn/com/audio/line14.ogg","stream"),
    line15 = love.audio.newSource("assets/mp_gamemodes/lovejam/vn/com/audio/line15.ogg","stream"),
  },
}

return {images=vn_images,audio=vn_audio}
