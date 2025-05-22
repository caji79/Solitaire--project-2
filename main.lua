-- Eli Chen
-- cmpm 121
-- 4/18/25

require "card"
require "grabber"
require "gameBoard"
require "util"

-- draw position
drawOffsetY = 30
drawPilePosX = 25
drawPilePosY = 150
drawCardPos = {
    Vector(drawPilePosX, drawPilePosY),
    Vector(drawPilePosX, drawPilePosY + drawOffsetY),
    Vector(drawPilePosX, drawPilePosY + drawOffsetY*2)
}

-- suit position
stackOffestX = 115
stackX = 495
stackY = 25
stackPilesPos = {
    Vector(stackX, stackY),
    Vector(stackX + stackOffestX, stackY),
    Vector(stackX + stackOffestX*2, stackY),
    Vector(stackX + stackOffestX*3, stackY)
}

-- tableau position
tblPosX, tblPosY = 150, 150
pileSpacing = (CARD_WIDTH * CARD_SCALE_X) + 40
cardOverlap = 30

function initGame()
    gameWon = false
    cardTable = {}
    deckPile = {}
    drawPile = {}  -- table for recording the history of drawn cards
    drawShow = {}  -- temporary table for rendering 3 draw cards on gameboard
    tableauPiles = {}
    -- assign suit index for the stackPiles
    -- [1]spades [2]clubs [3]hearts [4]diamonds
    stackPiles = {}
    for i, suit in ipairs(SUITS) do
        stackPiles[suit] = {}
    end

    grabber = GrabberClass:new(cardTable)

    -- create a shuffled deck when the game starts
    shuffledDeck = CardClass:deckBuilder()
    for _, card in ipairs(shuffledDeck) do
        card.position = Vector(25, 25)
        card.draggable = false
        card.faceUp = false
        table.insert(deckPile, card)
        table.insert(cardTable, card)
    end

    -- 7 column with equal spacing
    tableauPos = {}
    for i = 1, 7 do
        tableauPos[i] = Vector(tblPosX + (i - 1) * pileSpacing, tblPosY)
    end

    -- nested loop to assign each card's position in tableau
    for i = 1, 7 do
        tableauPiles[i] = {}  -- seven tableau piles total, {1}, {2}, {3}, {4}, {5}, {6}, {7}
        for j = 1, i do
            local card = table.remove(deckPile)
            card.position = Vector(tableauPos[i].x, tableauPos[i].y + (j - 1) * cardOverlap)
            card.faceUp = (j == i)      -- only the last card is flipped
            card.draggable =  (j == i)  -- only the last card is draggable
            table.insert(tableauPiles[i], card)
            table.insert(cardTable, card)
        end
    end
end

function love.load()
    love.window.setMode(960, 720)
    love.window.setTitle('Solitaire')

    -- set the default font and create a larger font for the win screen
    defaultFont = love.graphics.getFont()
    winFont = love.graphics.newFont(64)

    initGame()
end

function love.update()
    grabber:update()

    for _, card in ipairs(cardTable) do
        card:checkForMouseOver(grabber)
        card:update()  -- moves card if it's grabbed

        -- let the card follow cursor while being grabbed:
        if card.state == CARD_STATE.GRABBED and grabber.heldObject == card then
            card.position.x = grabber.currentMousePos.x - grabber.mouseOffset.x
            card.position.y = grabber.currentMousePos.y - grabber.mouseOffset.y
        end
    end

end

-- win screen debugging function
function love.keypressed(key)
    print("KEYPRESSED!", key, " before toggle:", gameWon)
    if key == "w" then
        gameWon = not gameWon
        print("→ after toggle:", gameWon)
    end
end

function love.mousepressed(x,y,button)
    if button==1 then
        -- restart button area
        if x >= 825 and x <= 915 and y >= 650 and y <= 680 then
            initGame()
            return
        end
        drawCard(x,y)
    end
end

function drawCard(clickX, clickY)
    local deckX, deckY = 25, 25
    local deckW = CARD_WIDTH * CARD_SCALE_X
    local deckH = CARD_HEIGHT * CARD_SCALE_Y

    -- clicking check box
    if clickX > deckX and clickX < deckX + deckW and clickY > deckY and clickY < deckY + deckH then
        if #deckPile > 0 then
            -- flip 3 (or fewer) cards from the deck pile
            for i = 1, 3 do
                -- cannot draw cards if deck pile is empty
                if #deckPile == 0 then break end

                -- draw cards from deck pile
                local card = table.remove(deckPile)  
                card.faceUp = true

                -- rearrange the card order
                for j = 1, #cardTable do
                    if cardTable[j] == card then
                        table.remove(cardTable, j)
                        break
                    end
                end

                table.insert(cardTable, card)
                table.insert(drawPile, card)   -- drawPile records the draw card history
            end
          
            -- refresh/clear the top‑3 draw cards shown on the gameboard
            updateDrawShow()

        else
            -- put the draw cards back to deck pile
            drawShow = {}  -- temporary table for rendering 3 draw cards on gameboard
            for i = #drawPile, 1, -1 do
                local card = table.remove(drawPile)
                card.faceUp = false
                card.draggable = false
                card.position = Vector(25, 25)
                table.insert(deckPile, card)
            end
            updateDrawShow()
        end
    end
end

-- a related function to drawCard (see drawCard function)
function updateDrawShow()
    -- hide old previous cards under first draw card position
    for _, old in ipairs(drawShow) do
        old.faceUp    = false
        old.draggable = false
        old.position  = Vector(drawCardPos[1].x, drawCardPos[1].y)
    end
    
    -- clear drawShow for new draw cards
    drawShow = {}
  
    -- take the last up to 3 cards from the drawPile
    local newCards = #drawPile
    local start = math.max(1, newCards - 2)
    for i = start, newCards do
        local card = drawPile[i]
        card.faceUp    = true
        -- only top card is draggable
        card.draggable = (i == newCards)
        -- drawCardPos slot [1] [2] [3]
        local slot  = i - start + 1
        card.position  = Vector(drawCardPos[slot].x, drawCardPos[slot].y)
        table.insert(drawShow, card)
    end
end

function love.draw()
    GameBoardClass:draw()

    for _, card in ipairs(cardTable) do
        card:draw()
    end

    -- print("win?" ..tostring(gameWon))

    -- win screen
    if gameWon then
        local w, h = love.graphics.getDimensions()
        -- semi‑transparent black background for win screen
        love.graphics.setColor(0, 0, 0, 0.5)
        love.graphics.rectangle('fill', 0, 0, w, h)
        -- text for win screen
        -- switch to the win font:
        love.graphics.setFont(winFont)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf('YOU WIN!', 0, h*0.4, w, 'center')
        -- switch back to default font (if we need use another font later)
        love.graphics.setFont(defaultFont)
    end

    -- restart button
    love.graphics.setColor(0.8, 0.2, 0.2)
    love.graphics.rectangle("fill", 825, 650, 90, 30, 4, 4)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Restart", 825, 650+8, 90, "center")

end