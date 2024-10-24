# 41013 Lab Assesment 2

## Libraries, and asset credit
To run, the user must have these packages:
- [`rvctoolbox` by Peter Corke, UTS v7](https://github.com/petercorke/robotics-toolbox-matlab)
- [`log4matlab` by Gavin Paul](https://au.mathworks.com/matlabcentral/fileexchange/33532-log4matlab)

Assets used
- [Kitchen Tile Texture](https://seamless-pixels.blogspot.com/2012/09/free-seamless-floor-tile-textures.html)


## Task Notes
wants your group to spend a few weeks investigating the application of a robot, including integrated safety.
SafeCo has made available several real desktop robot manipulators (including their models)
for you to test your design on (see below). 
You need to choose and use one of these. 
Then model a second new industrial robot arm that is not in the Robotics Toolbox


## Project Proposal
A vertical dish indexer system that is interacted through a gantry (custom robot) enclosed with safety fencing.
This storage system has been been build into a cupboard. 
The dishes are clean from a dishwasher and transfer ed from that environment to the cupboard by a UR3e.
The dishes are picked and sorted into the correct section of the cupboard by passing them to the Gantry, through a careful gap in the gantry safety fence


## Robots
### UR3e Cobot:
- reduce speed if human is nearby
	- stop if too close

### Gantry
The second robot is a gantry, with 3 linear degrees of freedom provided by prismatic joints and a spherical joint on the end to give it freedom in handling the dishes. Its workspace is a rectangular parallelepiped, that covers the cupboard area and has intersection with the UR3e's workspace outside of the cupboard.


## What we're modeling:
- UR3e
- Gantry Robot
- Dishwasher
- Kitchen enviroment
- Enviroment
	- Light fence
	- Estop
	- Physical fence
	- Plates, thin cylinders (250d 10h mm)
	- Cups thick cylinders (60d 160w mm)

## General code structure

```txt
@GantryRobot/
├── GantryRobot.m
└── link .ply files
graphical_models/
└── other ply files
out/
└── *.log 
SetupEnviroment.m
```
