require "vector"

GrabberClass = {}

function GrabberClass:new(cardTable)
    local grabber = {}
    local metadata = {__index = GrabberClass}
    setmetatable(grabber, metadata)

    grabber.cards = cardTable
    grabber.currentMousePos = nil
    grabber.grabPos = nil
    grabber.mouseOffset = nil
    grabber.heldObject = nil

    return grabber
end

function GrabberClass:update()
    self.currentMousePos = Vector(love.mouse.getX(), love.mouse.getY())
    if self.heldCards then
        for k, card in ipairs(self.heldCards) do
            card.position.x = self.currentMousePos.x - self.mouseOffset.x
            card.position.y = self.currentMousePos.y - self.mouseOffset.y + (k - 1) * cardOverlap
        end
    end
    
    -- Click
    if love.mouse.isDown(1) and self.grabPos == nil then
        local mx,my = self.currentMousePos.x, self.currentMousePos.y
        local deckX, deckY = 25, 25
        local deckW = CARD_WIDTH * CARD_SCALE_X
        local deckH = CARD_HEIGHT * CARD_SCALE_Y
        -- don't grab any cards inside the deck pile area
        if mx >= deckX and mx <= deckX + deckW and my >= deckY and my <= deckY + deckH then
            return
        end
        self:grab()
    end
    -- Release
    if not love.mouse.isDown(1) and self.grabPos ~= nil then
        self:release()
    end  
end

function GrabberClass:grab()
    -- grab the topmost card under the cursor
    local grabbedCard = nil
    for i = #self.cards, 1, -1 do
        local card = self.cards[i]
        if card.state == CARD_STATE.MOUSE_OVER and card.draggable then
            grabbedCard = card
            break
        end
    end
    if not grabbedCard then return end

    -- determine origin
    local origin = {}

    -- tableau check
    for col = 1, 7 do
        for idx = 1, #tableauPiles[col] do
            if tableauPiles[col][idx] == grabbedCard then
                origin = { type = "tableau", col = col, idx = idx }
                break
            end
        end
        if origin.type then break end
    end

    -- draw check
    if not origin.type then
        for i = #drawPile, 1, -1 do
            if drawPile[i] == grabbedCard then
                origin = { type = "draw" }
            end
        end
    end

    -- suit foundations check
    if not origin.type then
        for _, suit in ipairs(SUITS) do
            local pile = stackPiles[suit]
            if pile[#pile] == grabbedCard then
                origin = { type = "foundation", suit = suit }
                break
            end
        end
    end

    -- deck check
    if not origin.type then
        for i = #deckPile, 1, -1 do
            if deckPile[i] == grabbedCard then
                origin = { type = "deck" }
                break
            end
        end
    end

    local held = {}
    if origin.type == "tableau" then
        local pile = tableauPiles[origin.col]
        for j = origin.idx, #pile do
            table.insert(held, pile[j])
        end

        for j = #pile, origin.idx, -1 do
            table.remove(pile, j)
        end
    else
        held = { grabbedCard }
        for j = #drawPile, 1, -1 do
            if drawPile[j] == grabbedCard then
                table.remove(drawPile, j)
                break
            end
        end
    end

    self.origin = origin
    self.heldCards = held
    self.heldObject = grabbedCard
    grabbedCard.state = CARD_STATE.GRABBED
    self.mouseOffset = {
        x = self.currentMousePos.x - grabbedCard.position.x,
        y = self.currentMousePos.y - grabbedCard.position.y
    }
    grabbedCard.originalPos = Vector(grabbedCard.position.x, grabbedCard.position.y)
    self.grabPos = self.currentMousePos

    -- move the card to the top 
    -- for i, c in ipairs(cardTable) do
    --     if c == grabbedCard then
    --         table.remove(cardTable, i)
    --         table.insert(cardTable, grabbedCard)
    --         break
    --     end
    -- end

    -- bring them to front in draw order
    for _, card in ipairs(held) do
        for k, c in ipairs(cardTable) do
            if c == card then
                table.remove(cardTable, k)
                break
            end
        end
        table.insert(cardTable, card)
    end            
end

function GrabberClass:release()

    if self.heldCards == nil then -- we have nothing to release
        return
    end

    
    local basedCard = self.heldCards[1]
    local cw, ch = CARD_WIDTH * CARD_SCALE_X, CARD_HEIGHT * CARD_SCALE_Y
    local moved = false

    local card = self.heldObject
    for i, pos in ipairs(stackPilesPos) do
        if checkOverlaps(card.position.x, card.position.y, cw, ch, pos.x, pos.y, cw, ch) 
            and validStackPileAdding(card, i) 
        then
            card.position = Vector(pos.x, pos.y)
            removeCardFromOrigin(card, self.origin)
        
            -- add it to the stackPile table
            table.insert(stackPiles[ SUITS[i] ], card)
            moved = true
            break
        end
    end

    -- tableau
    if not moved then
        for i, pos in ipairs(tableauPos) do
            local dropX, dropY
            local pile = tableauPiles[i]
            if #pile > 0 then
                local top = pile[#pile]
                dropX =  top.position.x
                dropY = top.position.y + cardOverlap

                if checkOverlaps(basedCard.position.x, basedCard.position.y, cw, ch, dropX, dropY, cw, ch)
                    and self:tableauMove(basedCard, top)
                then
                    for k, c in ipairs(self.heldCards) do
                        if self.origin.type == "foundation" then
                            removeCardFromOrigin(card, self.origin)
                        end
                        c.position = Vector(dropX, dropY + (k-1)*cardOverlap)
                        c.draggable = true
                        table.insert(pile, c)
                    end
                    moved = true
                    break
                end
            else
                dropX = pos.x
                dropY = pos.y

                if checkOverlaps(basedCard.position.x, basedCard.position.y, cw, ch, dropX, dropY, cw, ch)
                    and rankValueMap[basedCard.rank] == 13
                then
                    for k, c in ipairs(self.heldCards) do
                        if self.origin.type == "foundation" then
                            removeCardFromOrigin(card, self.origin)
                        end
                        c.position = Vector(dropX, dropY + (k - 1) * cardOverlap)
                        c.draggable = true
                        table.insert(pile, c)
                    end
                    moved = true
                    break
                end
            end
        end
    end

    if not moved then
        -- card.position = card.originalPos
        for k, card in ipairs(self.heldCards) do
            -- reconstruct original positions in the source pile
            if self.origin.type=="tableau" then
                local col = self.origin.col
                local y0 = tableauPos[col].y + (self.origin.idx + k - 2)*cardOverlap
                card.position = Vector(tableauPos[col].x, y0)
                table.insert(tableauPiles[col], self.origin.idx + k - 1, card)

            elseif self.origin.type == "foundation" then
                local s = self.origin.suit
                local suitIdx
                for i, v in ipairs(SUITS) do
                    if v == s then
                        suitIdx = i
                        break
                    end
                end
                card.position = Vector(stackPilesPos[suitIdx].x, stackPilesPos[suitIdx].y)
                table.insert(stackPiles[s], card)
            
            else
                -- drawPile or others
                card.position = Vector(drawPilePos.x, drawPilePos.y)
                table.insert(drawPile, card)
            end
        end
    end

    -- flip the last card in tableau column pile
    if self.origin.type == "tableau" then
        local pile = tableauPiles[self.origin.col]
        if #pile > 0 then
            local top = pile[#pile]
            if not top.faceUp then
                top.faceUp    = true
                top.draggable = true
            end
        end
    end

    -- local isValidRealse = true
    -- if not isValidRealse then
    --     self.heldObject.position = self.grabPos
    -- end

    for _, card in ipairs(self.heldCards) do
        card.state = CARD_STATE.IDLE
    end
    self.heldCards = nil
    self.origin = nil
    -- self.heldObject.state = 0 -- it's no longer grabbed
    self.heldObject = nil
    self.grabPos    = nil
end

function GrabberClass:tableauMove(movingCard, targetCard)
    if suitColor[movingCard.suit] == suitColor[targetCard.suit] then
        return false
    end

    local moveValue = rankValueMap[movingCard.rank]
    local targeValue = rankValueMap[targetCard.rank]

    return moveValue == targeValue - 1
end