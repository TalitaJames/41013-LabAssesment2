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

## Meeting notes
- When is the demo time?
- I propose we ignore glasses, and just consider plates
- Debug Nimmo's gantry issues

### Marking criteria

On the submission day, separate to the videos (submitted the week before), each group needs to actively participate in an online demonstration of their system working both in simulation and, if applicable, on the real robot (students should present video evidence). The simulated system must:

1)  Have two 6dof robots
    - [ ] Mikhail: Move gantry into the "correct position"

2) Include a MATLAB/Python graphical user interface (GUI) to interact with the system. The GUI should have
advanced “teach” functionality that allows jogging the robot. It should include both individual joint
movements (like the Toolbox’s “teach”) plus enable [x,y,z] Cartesian movements. A valid addition is to use
a joystick or gamepad to augment and replace mouse-clicking GUI button presses.
    - [ ] Mikhail: Key Gui function

3) Incorporate a functional e-stop (both simulated and real) that immediately stops operations. Disengaging
the e-stop must not immediately resume the robot system but only permit resuming (meaning two actions
are necessary to resume). For full marks, your system must be able to recover/resume after an e-stop
event. Also, using uiwait, or similar busy “while” loop functionality, to pause everything will be penalised.
    - [ ] Talita: Listen ect 
    - [ ] Mikhail: Button to trigger the GUI Estop

4) Place the system in a simulated environment that includes safety hardware (e.g., barriers, warning
signs/lights/sirens)
    - [ ] Nimmo: Add safety fences, warnings ect


5) Incorporate safety functionality:

    1) To react to an asynchronous stop signal by a user. The system will stop based upon an action from the
    user (e.g. simulated (or real) sensing of something/someone entering an unsafe zone).
        - [ ]

    1) To prevent collisions. When a simulated object (that you make and control) is placed in the path of the
robot, it will stop until there is no predicted collision or move to avoid the collision. Active collision
avoidance will be marked higher than simply detecting a collision and stopping.
        - [ ] Collision of static objects (eg table)
        - [ ] Collision of "added" static objects
        - [ ] Active collision avoidance

6) Have a repo & clean code
    - [x]
    - [ ] Talita: Time permitting, tidy and document each function

Demonstration of the new robot with an existing robot completing a specified task during an online (in class time)
group presentation (10-15 mindeveloped by each group) and the simulated model. Uses:
- RMRC
    - [ ]
- collision avoidance
    - [ ]
- a GUI
    - [ ] Mikhail

Creatively use a real robot that mimics and/or enhances the simulation and application

Safety in Demo:
1) System reacts to user emergency stop action (1) GUI e-stop; (1) Hardware e-stop. (Minus marks if no e-stop).
2) Trajectory reacts to simulated sensor input (e.g. light curtain) (1)
3) Trajectory reacts to a forced simulated upcoming collision (1)
4) Design a simulated environment with a strategically placed models of appropriate safety equipment (1)

On the submission day, separate to the videos (submitted the week before), each group needs to actively participate in an online demonstration of their system working both in simulation and, if applicable, on the real robot (students should present video evidence). The simulated system must:
1) Include 2 robot arms that interact. 1 should be an existing robot arm from the Robotics Toolbox and 1
needs to be a “new” one that you create. It can be a commercially available arm or one which you design
yourself. All groups need to model, in simulation, a 6DOF (or higher) industrial robot arm other than the
ones in the Toolbox. There are many robots with different capabilities, so please propose one that is
suitable for your application and discuss it with a tutor. A gripper, like one in A1 can be included but it is
not worth marks.
2) Include a MATLAB/Python graphical user interface (GUI) to interact with the system. The GUI should have
advanced “teach” functionality that allows jogging the robot. It should include both individual joint
movements (like the Toolbox’s “teach”) plus enable [x,y,z] Cartesian movements. A valid addition is to use
a joystick or gamepad to augment and replace mouse-clicking GUI button presses.
3) Incorporate a functional e-stop (both simulated and real) that immediately stops operations. Disengaging
the e-stop must not immediately resume the robot system but only permit resuming (meaning two actions
are necessary to resume). For full marks, your system must be able to recover/resume after an e-stop
event. Also, using uiwait, or similar busy “while” loop functionality, to pause everything will be penalised.
4) Place the system in a simulated environment that includes safety hardware (e.g., barriers, warning
signs/lights/sirens), and if relevant this may be implemented on the real robot as well and augmented with
active sensors (BONUS) where data or signals (other than the e-stop) are passed back to the main
program.
5) Incorporate safety functionality:

    1) To react to an asynchronous stop signal by a user. The system will stop based upon an action from the
    user (e.g. simulated (or real) sensing of something/someone entering an unsafe zone).
    1) To prevent collisions. When a simulated object (that you make and control) is placed in the path of the
robot, it will stop until there is no predicted collision or move to avoid the collision. Active collision
avoidance will be marked higher than simply detecting a collision and stopping.
6) Ensure the group’s MATLAB/Python code is available on a code repository for tutors to access and
download. The code and your understanding will be closely scrutinised during the individual code viva. You
are expected to still adhere to a particular code standard (either the one provided, or one chosen by your
group).


Demonstration of the new robot with an existing robot completing a specified task during an online (in class time)
group presentation (10-15 minutes per group): Path plan between several poses and the final joint state given a
unique and safe environment (developed by each group) and the simulated model. Use RMRC, visual servoing,
collision avoidance and a GUI where appropriate. Creatively use a real robot that mimics and/or enhances the
simulation and application

Safety in Demo:
1) System reacts to user emergency stop action (1) GUI e-stop; (1) Hardware e-stop. (Minus marks if no e-stop).
2) Trajectory reacts to simulated sensor input (e.g. light curtain) (1)
3) Trajectory reacts to a forced simulated upcoming collision (1)
4) Design a simulated environment with a strategically placed models of appropriate safety equipment (1)


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
