# 41013 Lab Assesment 2

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


## What we're modeling:
- UR3e
- Gantry Robot
- Dishwasher
- Kitchen enviroment
- Enviroment
	- Light fence
	- Estop
	- Physical fence
	- Plates (thin cylinders)
	- Cups (thick cylinders)

## General code structure

@GantryRobot/
├── GantryRobot.m
└── link .ply files
Assets/
└── other ply files
out/
└── *.log 

SetupEnviroment.m
