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