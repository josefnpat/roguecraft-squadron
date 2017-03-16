local disclaimer = {}

function disclaimer:init()

  self.pre = "DISCLAIMER:\nRogueCraft Squadron is still in active development and may not represent the final product."

  self.post = {
    "In the event you are mauled by bears, I am very sorry. Please avoid that if you can.",
    "Please do not try to control the universe with your mind. We've tried that, and it didn't seem to work.",
    "By playing this game we will suggest that you will be \"that person\" who \"thought it was cool before anyone else,\" but we cannot promise that it will bring fame or fortune.",
    "I must not fear. Fear is the mind-killer. Fear is the little-death that brings total obliteration. I will face my fear. I will permit it to pass over me and through me. And when my fear is gone I will turn and face fear's path, and only I will remain.",
    "In case you listen to the new Blank Banshee album please tell @eternalnightpro how much you love it. He is a huge fan of Vaporwave.",
    "If you ever confused Dutch with a drunk version of German, please do not hesitate to contact us. We can help you.",
    "Prolonged exposure to premature assets may cause an irreversible quantity of birthdays for those afflicted.",
    "I have been informed on many occasions that \"this is why you shouldn't be allowed to make decisions.\" Ignore the voices; do the right thing.",
    "In case your artist is exposed to technical details, keep calm. The attackers can be stopped by removing the head, or destroying the brain.",
    "In the event a programmer attempts to substitute art for programmer art in a demonstration or release, proceed to persuade them to seek professional help.",
    "At any point, at our own prerogative, we may decide to replace all of the content in this game with obnoxious pictures of ice cream.",
    "You may find that eating ice cream while playing this game will improve your experience. If the replimat is out of ice cream, on behalf of the owner of the replimat, we are sorry.",
    "01010100 01101000 01101001 01110011 00100000 01101001 01110011 00100000 01101110 01101111 01110100 00100000 01100010 01101001 01101110 01100001 01110010 01111001 00101110",
  }

end

function disclaimer:enter()
  self.post_i = math.random(#self.post)
end

function disclaimer:draw()
  love.graphics.setFont(fonts.menu)
  local px = love.graphics.getWidth()/4
  local py = love.graphics.getHeight()/4
  love.graphics.printf(
    self.pre .. " " .. self.post[self.post_i],
    px,py,px*2,"center")
  love.graphics.setFont(fonts.default)
end

function disclaimer:mousepressed()
  self:getouttahere()
end

function disclaimer:keypressed()
  self:getouttahere()
end

function disclaimer:getouttahere()
  libs.hump.gamestate.switch(states.mission) states.mission:init()
end

return disclaimer
