-- Eli Chen
-- cmpm 121
-- 4/18/25

require "card"
require "grabber"
require "gameBoard"

local DRAW_OFFSET_Y = 30
local drawPilePosX = 25
local drawPilePosY = 150
local deckShowCount = 3

function love.load()
    love.window.setMode(960, 720)
    love.graphics.setBackgroundColor(0, 0.6, 0.2, 1)
    love.window.setTitle('Solitaire')

    cardTable = {}
    -- table.insert(cardTable, CardClass:new(52, 100, 100))
    -- table.insert(cardTable, CardClass:new(1, 0, 0))
    grabber = GrabberClass:new(cardTable)

    deckPile = {}
    tableauPiles = {}

    drawPile = {}
    drawShow = {}
    drawCardPos = {
        Vector(drawPilePosX, drawPilePosY),
        Vector(drawPilePosX, drawPilePosY + DRAW_OFFSET_Y),
        Vector(drawPilePosX, drawPilePosY + DRAW_OFFSET_Y*2)
    }

    stackPiles = {}
    stackPilesPos = {
        Vector(495, 25),
        Vector(610, 25),
        Vector(725, 25),
        Vector(840, 25)
    }

    local suitStack = { "spades", "clubs", "hearts", "diamonds" }
    for i, suit in ipairs(suitStack) do
        stackPiles[suit] = {}
    end

    shuffledDeck = CardClass:deckBuilder()
    for _, card in ipairs(shuffledDeck) do
        card.position = Vector(25, 25)
        card.draggable = false
        card.faceUp = false
        table.insert(deckPile, card)
        table.insert(cardTable, card)
    end

    tblPosX, tblPosY = 150, 150
    pileSpacing = (CARD_WIDTH * CARD_SCALE_X) + 40
    cardOverlap = 30

    tableauPos = {}
    for i = 1, 7 do
        tableauPos[i] = Vector(tblPosX + (i - 1) * pileSpacing, tblPosY)
    end

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

function love.update()
    grabber:update()

    for _, card in ipairs(cardTable) do
        card:checkForMouseOver(grabber)
        card:update()   -- moves it if grabbed
        -- let the card follow while grabbed:
        if card.state == CARD_STATE.GRABBED and grabber.heldObject == card then
            card.position.x = grabber.currentMousePos.x - grabber.mouseOffset.x
            card.position.y = grabber.currentMousePos.y - grabber.mouseOffset.y
        end
    end

end

function love.mousepressed(x, y, button)
    if button == 1 then drawCard(x, y) end
end

function drawCard(clickX, clickY)
    local deckX, deckY = 25, 25
    local deckW = CARD_WIDTH * CARD_SCALE_X
    local deckH = CARD_HEIGHT * CARD_SCALE_Y
    if clickX > deckX and clickX < deckX + deckW and clickY > deckY and clickY < deckY + deckH then
        -- method 1 alpha
        if #deckPile > 0 then
            local toShow = math.min(deckShowCount, #deckPile)
            local toKeep = 0

            if toShow < 3 and #drawShow > 0 then
                -- Calculate how many previous cards to keep (to ensure a total of 3 visible cards)
                toKeep = math.min(3 - toShow, #drawShow)
            end

            if #drawShow > 0 then
                for i = 1, #drawShow - toKeep do
                  local card = drawShow[i]
                  card.position = drawCardPos[1]
                  card.draggable = false  -- Ensure stacked cards cannot be dragged
                end
            end

            local drawUpdate = {}
            if toKeep > 0 then
                for i = #drawShow - toKeep + 1, #drawShow do
                    local card = drawShow[i]
                    table.insert(drawUpdate, card)
                end
            end

            drawShow = {}

            for i = 1, toShow do
                local card = table.remove(deckPile)
                if card then
                    card.faceUp, card.draggable = true, true
                    -- Ensure new cards are at the top of rendering order
                    for j, c in ipairs(cardTable) do
                        if c == card then
                            table.remove(cardTable, j)
                            table.insert(cardTable, card) -- Reinsert at the end (top)
                            break
                        end
                    end
                    table.insert(drawPile, card)
                    table.insert(drawUpdate, card)
                end
            end

            for i, card in ipairs(drawUpdate) do
                card.position = drawCardPos[i]
                table.insert(drawShow, card)
            end
            
        elseif #drawPile > 0 then
            drawShow = {}
            for i = #drawPile, 1, -1 do
                local card = table.remove(drawPile)
                card.faceUp = false
                card.draggable = false
                card.position = Vector(25, 25)
                table.insert(deckPile, card)
                -- table.insert(cardTable, card)
            end
        end

        --method 1
        -- if #deckPile > 0 then
        --     for i = 1, 3 do
        --         if #deckPile == 0 then break end
        --         -- remove top card from stock
        --         local card = table.remove(deckPile)
        --         card.faceUp = true
        --         card.draggable = true

        --         -- move it to your draw‐pile position
        --         table.insert(drawPile, card)
        --         table.insert(cardTable, card)
        --     end
            
        -- elseif #drawPile > 0 then
        --     for i = #drawPile, 1, -1 do
        --         local card = table.remove(drawPile)
        --         card.faceUp = false
        --         card.draggable = false
        --         card.position = Vector(25, 25)
        --         table.insert(deckPile, card)
        --         table.insert(cardTable, card)
        --     end
        -- end

        --method 2
        -- for i = #drawPile, 1, -1 do
        --     local card = table.remove(drawPile, i)
        --     card.faceUp    = false
        --     card.draggable = false
        --     card.position  = Vector(deckX, deckY)
        --     -- insert at the bottom so next draws come after these
        --     table.insert(deckPile, 1, card)
        --     table.insert(cardTable, card)
        -- end

        -- -- 2) draw up to three new cards from the top of the deck
        -- for i = 1, 3 do
        --     if #deckPile == 0 then break end
        --     local card = table.remove(deckPile)  -- top of deck
        --     card.faceUp = true
        --     card.draggable = true
        --     card.position = Vector(drawPilePos.x, drawPilePos.y)
        --     table.insert(drawPile, card)
        --     table.insert(cardTable, card)
        -- end

        --method 3
        -- if #deckPile > 0 then
        --     -- === CASE 1: Still cards in stock, so draw up to 3 ===
        --     for i = 1, 3 do
        --         if #deckPile == 0 then break end
        --         local c = table.remove(deckPile)  -- take from top
        --         c.faceUp    = true
        --         c.draggable = true
        --         table.insert(drawPile, c)
        --     end
    
        -- elseif #drawPile > 0 then
        --     -- === CASE 2: Stock is empty, recycle the waste ===
        --     for i = #drawPile, 1, -1 do
        --         local c = table.remove(drawPile, i)
        --         c.faceUp    = false
        --         c.draggable = false
        --         c.position  = Vector(deckX, deckY)
        --         table.insert(deckPile, 1, c)     -- send to bottom of deck
        --     end
        -- end

        -- for i, card in ipairs(drawPile) do
        --     card.draggable = (i == #drawPile)
        -- end

    end
end

function love.draw()
    GameBoardClass:draw()

    for _, card in ipairs(cardTable) do
        card:draw()
    end

    -- card state debug
    love.graphics.setColor(1,1,1)
    local debugState = CARD_STATE.IDLE
    if grabber.heldObject then
        debugState = CARD_STATE.GRABBED
    else
        -- if any card is in MOUSE_OVER state, show 1
        for _,c in ipairs(cardTable) do
            if c.state == CARD_STATE.MOUSE_OVER then
                debugState = CARD_STATE.MOUSE_OVER
                break
            end
        end
    end
    love.graphics.print("State: "..debugState, 10, 10)
    love.graphics.setColor(1,1,1)

end

-- collision detection
-- https://love2d.org/forums/viewtopic.php?t=81957
function checkOverlaps(ax,ay,aw,ah, bx,by,bw,bh)
    return ax < bx + bw and 
           ax + aw > bx and 
           ay < by + bh and 
           ay + ah > by
end

function validStackPileAdding(card, suitIdx)
    local targetSuit = SUITS[suitIdx]
    if card.suit ~= targetSuit then return false end

    local suitPile = stackPiles[targetSuit]
    local rankVal = rankValueMap[card.rank]

    if #suitPile == 0 then
        return rankVal == 1   -- only A goes on an empty foundation
    else
        local topCard = suitPile[#suitPile]
        return rankVal == rankValueMap[topCard.rank] + 1
    end
end

function removeCardFromOrigin(card, origin)
    if origin.type == "tableau" then
        table.remove(tableauPiles[origin.col], origin.idx)

    elseif origin.type == "draw" then
        for i = #drawPile, 1, -1 do
            if drawPile[i] == card then
                table.remove(drawPile, i)
                break
            end
        end

    elseif origin.type == "deck" then
        for i = #deckPile, 1, -1 do
            if deckPile[i] == card then
                table.remove(deckPile, i)
                break
            end
        end

    elseif origin.type == "foundation" then
        local pile = stackPiles[ origin.suit ]
        for i = #pile, 1, -1 do
            if pile[i] == card then
                table.remove(pile, i)
                break
            end
        end
    end
end