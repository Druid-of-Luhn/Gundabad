# Gundabad

Gundabad is a dungeon-crawling game built in Processing for the Video Games module at the University of St&nbsp;Andrews.

![A screenshot of Gundabad, where the player 'wef' is surrounded by enemies, but some treasure lies on the floor nearby.](https://wb33.host.cs.st-andrews.ac.uk/gundabad.png "Gundabad screenshot")

## Character Creation

The game starts with a character creation screen, which uses classic fantasy role-playing game races:

![An elf character called Elladan in Gundabad's character creation screen.](https://wb33.host.cs.st-andrews.ac.uk/gundabad-creation.png "Gundabad character creation")

## Exploration

The player moves their character through caves, trying to reach the stairs down to the next level. Move your character by clicking a location on the ground. Only the area around the player and other monsters is fully lit.

Monsters in the caves will chase you and attack you if they see you.

Pick up loot on the way and manage your inventory to become more powerful

## Inventory and Levelling

Open your inventory with the `i` key. Doing so over a dropped item will allow you to pick it up.

There is a weight restriction on the inventory that depends on strength, and only allows you to carry a certain amount.

Equip and unequip items, and use potions during combat or exploration.

A character levels up as they progress and kill monsters, making them more powerful.

![The character Dante opens their inventory.](https://wb33.host.cs.st-andrews.ac.uk/gundabad-inventory.png "Gundabad inventory")

## Combat

Combat is a simple turn-based system between the player and a monster. Each takes a turn picking an action, whether to attack, flee or use a potion.

Fleeing combat will make the player run towards the entrance to the level, while an enemy will run towards the exit.

Note, there is a bug somewhere in the combat code that will crash the game upon winning combat. It is quite rare however, so have fun.

![The character weg fights a goblin and both are taking damage.](https://wb33.host.cs.st-andrews.ac.uk/gundabad-combat.png "Gundabad combat")

## Death

The player's character dies if their health points reach 0. At this point they will be taken to the results screen, which displays some stats about their run:

- Player score
- Character level
- Depth reached
- Characteristics
- Attack
- Defence

![The character D-Warf has died and their results are displayed on the death screen.](https://wb33.host.cs.st-andrews.ac.uk/gundabad-death.png "Gundabad death")

## License

Copyright 2017 Billy Brown.

This project (Gundabad) is licensed under the Mozilla Public License version 2.0. See LICENSE file.
