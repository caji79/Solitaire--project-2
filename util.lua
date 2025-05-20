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

