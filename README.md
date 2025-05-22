# Project 2 - Solitaire

## Programming Pattern

1. Class Pattern

    - Creating a file for each entity (Card, Grabber,GameBoard) by using metatable
    - Using Class to store/add/organize object's properties and behaviors

2. State Pattern

    - Defining 3 different card states (IDLE, MOUSE_OVER, GRABBED) for cards
    - Card states determine how cards respond to mouse input
    - Good for debugging

3. Game Loop/Update Method Pattern

    - main.lua has 1) init() 2) update() 3) draw()
    - card.lua and grabber.lua have their own update method and they're called in main.lua

## Postmortem 

### What went well

- Class Pattern Prototype

    ```lua
    ExampleClass = {}

    function ExampleClass:new()
        local example = {}
        local metadata = {__index = ExampleClass}
        setmetatable(example, metadata)
        return example
    end
    ```

- Clear function naming

- Clear in-code comments
    - I restructured and polished the code in main file and grabber file, removing some testing comments and adding some explanation

- Visual design (maybe)

- Helper function re-organizing
    - I moved some helper function from main.lua to util.lua

- New draw pile mechanism and logic
    - The original draw pile logic is weak and doesn't work for draw-3 mode of solitaire
    - I rebuild the draw pile mechanism by adding the card refilling feature. One table for recording draw card history, another one for displaying 3 draw cards

### What should improve

- Weak code structure and model

    - add state pattern for moving card in/out from pile
    - create functions for 4 differnt types of cards, not in grab()

- Lengthy grabber functions

    - add more helper function to shrink grab() and release() complexity
    - create 3 function for suit pile mechanism, draw pile mechanism, and tableau mechanism

- Include Event Pattern
    - introduce an event bus to emit player action functions, making debugging and extension much easier

- Winning state bug

    - bug is still not fixed

- Audio

## Question to think about

- Which programming pattern will best fit for solitaire?
- What code structions or logics can helo you build solitaire?

## Special Thanks (Feedback)

    - Chengkun
        - missing comment, unclear structure ✅
        - optimizing suit pattern ✅

## Assets

- I mad the card assets in the game by using Aseprite

## References

- collision detection: https://love2d.org/forums/viewtopic.php?t=81957
- love.graphics.newQuad(): https://youtu.be/BCp7_n-L-tc
- card shuffle: CMPM121 lecture slide

