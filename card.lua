require "util"
require "vector"

CardClass = {}

CARD_STATE = {
    IDLE = 0,
    MOUSE_OVER = 1,
    GRABBED = 2
  }

SUITS = { "spades", "clubs", "hearts", "diamonds" }
RANKS = { 'A', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K' }

suitColor = {
    hearts   = "red",
    diamonds = "red",
    spades   = "black",
    clubs    = "black",
  }

rankValueMap = {
    A = 1, ["2"] = 2, ["3"] = 3, ["4"] = 4, ["5"] = 5,
    ["6"] = 6, ["7"] = 7, ["8"] = 8, ["9"] = 9, ["10"] = 10,
    J = 11, Q = 12, K = 13
}

CardClass.cardFront = love.graphics.newImage('assets/cards.png')
CardClass.cardFront:setFilter('nearest', 'nearest')
CardClass.cardBack = love.graphics.newImage('assets/cardBack.png')
CardClass.cardBack:setFilter('nearest', 'nearest')
CARD_WIDTH = 25
CARD_HEIGHT = 38
CARD_SCALE_X = 3
CARD_SCALE_Y =3
CardClass.quads = generateQuads(CardClass.cardFront, CARD_WIDTH, CARD_HEIGHT)

function CardClass:new(quadIndex, xPos, yPos, rank, suit, faceUp)
    local card = {}
    local metadata = {__index = CardClass}
    setmetatable(card, metadata)

    card.position = Vector(xPos, yPos)
    card.scaleX = CARD_SCALE_X
    card.scaleY = CARD_SCALE_Y
    card.state = CARD_STATE.IDLE
    card.quad = CardClass.quads[quadIndex]
    card.rank = rank
    card.suit = suit
    card.faceUp = faceUp or false
    card.draggable = false

    return card
end

function CardClass:update()
    if self.state == CARD_STATE.GRABBED and grabber.heldObject == self then
        self.position.x = grabber.currentMousePos.x
        self.position.y = grabber.currentMousePos.y
    end
end

function CardClass:draw()
    if self.faceUp then
        love.graphics.draw(CardClass.cardFront, self.quad, self.position.x, self.position.y, 0, self.scaleX, self.scaleY)
    else
        love.graphics.draw(CardClass.cardBack, self.position.x, self.position.y, 0, self.scaleX, self.scaleY)
    end
end

function CardClass:checkForMouseOver(grabber)
    if self.state == CARD_STATE.GRABBED then
        return
    end
      
    local mousePos = grabber.currentMousePos
    local isMouseOver = 
      mousePos.x > self.position.x and
      mousePos.x < self.position.x + (CARD_WIDTH * self.scaleX) and
      mousePos.y > self.position.y and
      mousePos.y < self.position.y + (CARD_HEIGHT * self.scaleY)
    
    self.state = isMouseOver and CARD_STATE.MOUSE_OVER or CARD_STATE.IDLE
  end

function CardClass:deckBuilder()
    local deck = {}

    for suitIdx, suit in ipairs(SUITS) do
        for rankIdx, rank in ipairs(RANKS) do
            local quadIdx = (suitIdx - 1) * #RANKS + rankIdx
            table.insert(deck, CardClass:new(quadIdx, 0, 0, rank, suit, true))
        end
    end

    self:shuffle(deck)
    return deck
end

function CardClass:shuffle(deck)
    -- lecture slides modern shuffling method
    local cardCount = #deck
    for i = 1, cardCount do
        local randIndex = love.math.random(cardCount)
        deck[randIndex], deck[cardCount] = deck[cardCount], deck[randIndex]
        cardCount = cardCount - 1
    end
    return deck
end