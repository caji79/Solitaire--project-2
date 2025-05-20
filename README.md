# Project 1 - Solitaire

## Programming Pattern

1. Class Pattern

    - Creating a file for each entity (Card, Grabber,GameBoard) by using metatable
    - Using Class to store/add/organize object's properties and behaviors

2. State Pattern

    - Defining 3 different card states (IDLE, MOUSE_OVER, GRABBED) for cards
    - Card states determine how cards respond to mouse input
    - Good for debugging

3. Observer Pattern (?)

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

- Visual design (maybe)

### What should improve

- Code structure

    - add state pattern for moving card in/out from pile
    - maybe break down that long long long "If Statement"

- Clearer in-code comments

    - explain what happens in code, especially in "For Loop"

- Move some function to util.lua or build more files

    - try to reduce the length of file

- Menu scene or Win scene

## Assets

- I mad the card assets in the game by using Aseprite
