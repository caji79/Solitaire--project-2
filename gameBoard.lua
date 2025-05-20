GameBoardClass = {}

GameBoardClass.spadeSymbol = love.graphics.newImage('assets/spade.png')
GameBoardClass.clubSymbol = love.graphics.newImage('assets/club.png')
GameBoardClass.heartSymbol = love.graphics.newImage('assets/heart.png')
GameBoardClass.diamondSymbol = love.graphics.newImage('assets/diamond.png')

function GameBoardClass:new()
    local gameBoard = {}
    local metadata = {__index = GameBoardClass}
    setmetatable(gameBoard, metadata)

    return gameBoard
end

function GameBoardClass:tableauLayout()

end

function GameBoardClass:draw()
    self:drawGrid()

    
end

function GameBoardClass:drawGrid()
    -- stack placeholders
    love.graphics.rectangle('line', 495, 25, CARD_WIDTH * CARD_SCALE_X, CARD_HEIGHT * CARD_SCALE_Y, 5)
    love.graphics.rectangle('line', 610, 25, CARD_WIDTH * CARD_SCALE_X, CARD_HEIGHT * CARD_SCALE_Y, 5)
    love.graphics.rectangle('line', 725, 25, CARD_WIDTH * CARD_SCALE_X, CARD_HEIGHT * CARD_SCALE_Y, 5)
    love.graphics.rectangle('line', 840, 25, CARD_WIDTH * CARD_SCALE_X, CARD_HEIGHT * CARD_SCALE_Y, 5)

    -- placeholder suit symbols
    love.graphics.draw(GameBoardClass.spadeSymbol, 468 + (CARD_WIDTH * CARD_SCALE_X)/2, (CARD_HEIGHT * CARD_SCALE_Y)/2)
    love.graphics.draw(GameBoardClass.clubSymbol, 585 + (CARD_WIDTH * CARD_SCALE_X)/2, (CARD_HEIGHT * CARD_SCALE_Y)/2)
    love.graphics.draw(GameBoardClass.heartSymbol, 698 + (CARD_WIDTH * CARD_SCALE_X)/2, (CARD_HEIGHT * CARD_SCALE_Y)/2 + 5)
    love.graphics.draw(GameBoardClass.diamondSymbol, 813 + (CARD_WIDTH * CARD_SCALE_X)/2, (CARD_HEIGHT * CARD_SCALE_Y)/2 + 3)

    -- stock & draw
    love.graphics.rectangle('line', 25, 25, CARD_WIDTH * CARD_SCALE_X, CARD_HEIGHT * CARD_SCALE_Y, 5)
    love.graphics.rectangle('line', 25, 150, CARD_WIDTH * CARD_SCALE_X, CARD_HEIGHT * CARD_SCALE_Y, 5)

    -- tableaus
    love.graphics.rectangle('line', 150, 150, CARD_WIDTH * CARD_SCALE_X, CARD_HEIGHT * CARD_SCALE_Y, 5)
    love.graphics.rectangle('line', 265, 150, CARD_WIDTH * CARD_SCALE_X, CARD_HEIGHT * CARD_SCALE_Y, 5)
    love.graphics.rectangle('line', 380, 150, CARD_WIDTH * CARD_SCALE_X, CARD_HEIGHT * CARD_SCALE_Y, 5)
    love.graphics.rectangle('line', 495, 150, CARD_WIDTH * CARD_SCALE_X, CARD_HEIGHT * CARD_SCALE_Y, 5)
    love.graphics.rectangle('line', 610, 150, CARD_WIDTH * CARD_SCALE_X, CARD_HEIGHT * CARD_SCALE_Y, 5)
    love.graphics.rectangle('line', 725, 150, CARD_WIDTH * CARD_SCALE_X, CARD_HEIGHT * CARD_SCALE_Y, 5)
    love.graphics.rectangle('line', 840, 150, CARD_WIDTH * CARD_SCALE_X, CARD_HEIGHT * CARD_SCALE_Y, 5)
end