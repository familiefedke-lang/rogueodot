## Constants.gd – global game constants, autoloaded as "Constants".
##
## Mirrors src/constants.py exactly.
## Accessible from all scripts as Constants.GRID_W, Constants.TILE, etc.

extends Node

const GRID_W: int = 50
const GRID_H: int = 30
const TILE: int = 32
const WINDOW_W: int = GRID_W * TILE   ## 1600
const WINDOW_H: int = GRID_H * TILE   ## 960

const TITLE: String = "Dungeon"

## Frames-per-second cap
const FPS: int = 60
