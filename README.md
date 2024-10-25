# 41013 Lab Assesment 2

## Libraries, and asset credit
To run, the user must have these packages downloaded and properly pathed:
- [`rvctoolbox` by Peter Corke, UTS v7](https://github.com/petercorke/robotics-toolbox-matlab)
    - run `startup_rvc` to initialise this package
- [`log4matlab` by Gavin Paul](https://au.mathworks.com/matlabcentral/fileexchange/33532-log4matlab)

Assets used
- [Kitchen Tile Texture](https://seamless-pixels.blogspot.com/2012/09/free-seamless-floor-tile-textures.html)
- [Kitchen Model from GrabCAD](https://grabcad.com/library/kitchen-full-assembly-1)

## Overview and how to run
You must have an `out/` file, run `mkdir out` to create one.

The robot-kitchen-dishsorting system is made in the `DishPackerRobot` class.
Create an object of that type with `foo = DishPackerRobot`
To run certain methods and do things in the simulation, call methods on the object you created.

## `DishPackerRobot` methods
- SetupEnviroment(self)
    - This method is called once in the constructor. You can't call it yourself because its private
    - it initialises the `.ply` files, and key variables
- DishPackerRobot()
    - The constructor
- CanReachPose(self, robot, endEffectorPose)
    - Called within other functions to check if a position is reachable
- AnimateRobot(self, robot, endEffectorPose, steps)
    - If reachable, the given robot is animated to there
- AnimateRobotWithObj(self, robot, endEffectorPose, steps, handle)
    - The given robot is animated there with a handle (ply) file at its end effector
- MovePlate(self, plateID)
    - Picks up a given plate (ID based on position in array, plates are numbered top down)
    - Animates the movement of the plate to the cupboard
- Reset(self)
    - Called to reset the enviroment without recreating the object
- Teach(self)
    - Brings up the teaching pane (**STUB**)
- EStop
    - halts the robot and all proscesses (**WIP on other branch**)
- delete(self)
    - called when `clear` or `delete(foo)` is called
- GeneratePlatePositions(startPos, height, count)
    - this static method returns an array of `count` positions [x,y,z] of plates to locate the plates


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
The second robot is a gantry, with 3 linear degrees of freedom provided by
prismatic joints and a spherical joint on the end to give it freedom in
handling the dishes. Its workspace is a rectangular parallelepiped,
that covers the cupboard area and has intersection with the UR3e's
workspace outside of the cupboard.


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
```
