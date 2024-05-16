# Roomba

The robot's intelligence.

## What is Roomba?

Roomba is a term that refers to a series of autonomous robotic vacuum cleaners made by the company iRobot, and was first introduced in September 2002. Roombas have a set of sensors used to help them navigate the floor area of a home. Roomba robotic vacuum cleaners have become popular household appliances, offering convenience and efficiency in maintaining clean floors with minimal effort from the user.

## What exactly a Roomba does?

Roomba is an autonomous vacuum and one of the most popular consumer robots in existence. It navigates around clutter and under furniture cleaning your floors, and returns to its charging dock when finished.

## How is this project related to Roomba?

This project showcases how a Roomba-like robot operates, mimicking its movement to clean a dirty floor. It's built using Flutter and employs algorithms to replicate the navigation patterns of a Roomba vacuum cleaner


## How it works

We have the below input

* Grid Dimensions: 8x8 grid.

* Starting Position: Bottom-left corner, coordinates (8,1).

* Initial Roomba Position: Starting station (bottom-left corner).

* Final Roomba Position: Must return to the starting station.

* Initial Battery Charge: 1000 units.

* Initial Score: 0 points.

* Initial Dirty Tiles: 0 tiles.

* Battery Consumption and Scoring:

    * Each movement consumes 10 units of battery charge.
    *  Each movement looses 1 point.

Our goal is to create a program that mimics the Roomba's movement to effectively clean all the dirty tiles on the floor.

* When the program launches, trigger a function to randomly mark 18 tiles as dirty.

* The Roomba starts at its staring station and must navigate to clean all dirty tiles before returning to its starting point.

* It must accomplish this task within the constraints of its battery charge capacity.

* We need to develop a function that helps determine the nearest dirty tile to the Roomba's current position. This function will aid the Roomba in navigating efficiently.

## Our workflow

We have to first understand that an 8x8 grid will have 64 positions. In terms of array positions it will start from 0 and will go till 63. Also we have to understand that the roomba can move up, down, left or right. 

We have to create a funciton to randomly create 18 dirty tiles. 

Then we will create a function to calculate the shortest path from the dirty tile to the current position and store it in the map. This will help us to calculate the nearest 

For this we have create d









## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
