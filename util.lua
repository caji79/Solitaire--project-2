-- https://love2d.org/wiki/love.graphics.newQuad
-- https://youtu.be/BCp7_n-L-tc
-- https://medium.com/@matteo.a.ricci/generating-quads-for-l%C3%B6ve2d-140054bb99fe
function generateQuads(image, cardWidth, cardHeight)
    local quads = {}
    local sheetWidth, sheetHeight = image:getDimensions()
    local cols = sheetWidth / cardWidth
    local rows = sheetHeight / cardHeight

    for row = 0, rows - 1 do
        for col = 0, cols - 1 do
            local x = col * cardWidth
            local y = row * cardHeight

            table.insert(quads, love.graphics.newQuad(x, y, cardWidth, cardHeight, sheetWidth, sheetHeight))
        end
    end

    return quads
end

-- win condition function (if all the suit piles are full, the player wins)
function checkForWin()
    for _, suit in ipairs(SUITS) do
        if #stackPiles[suit] < 13 then
            return false
        end
    end
    return true
end

-- collision detection
-- https://love2d.org/forums/viewtopic.php?t=81957
function checkOverlaps(ax,ay,aw,ah, bx,by,bw,bh)
    return ax < bx + bw and 
           ax + aw > bx and 
           ay < by + bh and 
           ay + ah > by
end

-- function for checking correct suit pile adding rule (same suit, rank in order from Ace to King)
function validStackPileAdding(card, suitIdx)
    local targetSuit = SUITS[suitIdx]
    if card.suit ~= targetSuit then return false end

    local suitPile = stackPiles[targetSuit]
    local rankVal = rankValueMap[card.rank]

    -- only Ace can be placed on an empty suit pile
    if #suitPile == 0 then
        return rankVal == 1
    else
        local topCard = suitPile[#suitPile]
        return rankVal == rankValueMap[topCard.rank] + 1  -- only the card with next rank (+1) can be placed
    end
end

-- a helper function for detecting which pile the grabbed card is from and removing it from that pile
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

        for i = #drawShow, 1, -1 do
            if drawShow[i] == card then
              table.remove(drawShow, i)
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

-- a helper function to snap each card back into its draw card slot
function snapBackDrawCard()
    for i, card in ipairs(drawShow) do
        card.position  = Vector(drawCardPos[i].x, drawCardPos[i].y)
    end
end