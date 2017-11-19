/*
 * Copyright 2017 Billy Brown
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

class ExploreState extends GameState {
  final static int cellSize = 50;
  Dungeon dungeon;
  int difficulty = 0;
  boolean generated = false;

  public void onEnter(final Game game) {
    if (!generated) {
      setup(game);
    }
  }

  public void input(final Game game, final char key) {
    // Open the inventory
    if (key == InventoryState.KEY) {
      nextState = InventoryState.class;
    }
  }

  public void click(final Game game, final PVector position) {
    // The actor is no longer fleeing
    game.getPlayer().flee = false;
    // Convert the screen coordinates to game coordinates
    final PVector actual = new PVector(mouseX, mouseY).sub(getCameraOffset(game));
    // Send the player to the clicked position
    game.getPlayer().ai.setTarget(game.getPlayer().getPosition(), actual, dungeon);
  }

  public void reset() {
    difficulty = 0;
    generated = false;
  }

  public void update(final Game game) {
    final Actor player = game.getPlayer();
    // The player may have died
    if (!player.alive()) {
      // Reset the dungeon
      reset();
      // And transition to the death state
      nextState = DeathState.class;
      return;
    }
    // Update monsters and player
    for (final Actor actor : game.getActors()) {
      // An actor may be fleeing
      if (actor.flee) {
        // The actor flees to the entry, monsters flee to the exit
        final Dungeon.Point fleeTo = actor == player ? dungeon.entry : dungeon.exit;
        // The actor may have stopped fleeing
        if (game.toCell(actor.getPosition()).equals(fleeTo)) {
          actor.flee = false;
        } else if (!actor.hasTarget()) {
          actor.ai.setTarget(actor.getPosition(), game.toCoord(fleeTo), dungeon);
        }
      } else if (actor instanceof Monster) {
        // Monsters may spot the player
        if (actor.ai.sees(actor, player, dungeon)) {
          actor.ai.setTarget(actor.getPosition(), player.getPosition(), dungeon);
        } else {
          // Keep the monster patrolling if need-be
          if (!actor.hasTarget()) {
            final Monster monster = (Monster) actor;
            if (monster.patrolPoints.length > 1) {
              monster.nextTarget(dungeon);
            }
          }
        }
      }
      actor.update();
    }
    // Might have collided with an enemy
    testCollision(game);
    // Might go down to next floor
    if (game.toCell(player.getPosition()).equals(dungeon.exit)) {
      // Stop the player
      player.stop();
      // The player gains xp
      player.gainXP(difficulty * 5);
      // Set up a new level
      setup(game);
    }
  }

  public void draw(final Game game) {
    // Centre the view on the player
    final PVector offset = getCameraOffset(game);
    drawDungeon(game, offset);
    fill(255);
    game.drawActors(offset);
    // Display the current depth
    textAlign(LEFT, TOP);
    textSize(FONT_MEDIUM);
    text("Dungeon Depth " + game.dungeonLevel, 50, 50);
  }

  public void resetTransition() {
    nextState = ExploreState.class;
  }

  public void setup(final Game game) {
    // Clear the path cache
    pathCache.clear();
    // Increase the difficulty
    difficulty += random(15);
    // Generate this level's dungeon
    dungeon = new Dungeon(60, 35);
    // Clear the game's state
    final Actor player = game.getPlayer();
    final int level = game.dungeonLevel;
    game.reset();
    game.dungeonLevel = level + 1;
    // Place the player at the entrance
    placePlayer(game, player);
    // The player receives a health potion at each level
    player.inventory.addItem(index.get((level > 5 ? "Greater " : "") + "Potion of Healing"));
    // Randomly place monsters
    placeMonsters(game);
    // Randomly place item drops
    placeItems(game);
    // The state is now ready
    generated = true;
  }

  public void placePlayer(final Game game, final Actor player) {
    game.setPlayer(player);
    player.setPosition(game.toCoord(dungeon.entry));
  }

  public void placeMonsters(final Game game) {
    // Place a number of monsters
    for (int i = 0; i < difficulty / 5 + 1; ++i) {
      // Get a free cell far enough from the entrance
      Dungeon.Point point = freeCell();
      while (Dungeon.distance(dungeon.entry, point) < 6) {
        point = freeCell();
      }
      // Choose a random type
      Race race = null;
      switch ((int) random(4)) {
        case 0:
          race = Race.ORC;
          break;
        case 1:
          race = Race.GOBLIN;
          break;
        case 2:
          race = Race.WARG;
          break;
        case 3:
          race = Race.URUK;
          break;
      }
      // Might make a troll
      if (random(200) < difficulty) {
        race = Race.TROLL;
      }
      final PVector[] patrol = new PVector[(int) random(1, 5)];
      patrol[0] = game.toCoord(point);
      // Make it patrol to nearby cells
      for (int j = 1; j < patrol.length; ++j) {
        Dungeon.Point other = freeCell();
        while (Dungeon.distance(point, other) > 6) {
          other = freeCell();
        }
        patrol[j] = game.toCoord(other);
      }
      // Health = 2D8 + CON
      final int health = Dice.D8() + Dice.D8() + race.base.CON();
      // Create and position it
      final Monster monster = new Monster(race, health, patrol);
      monster.setPosition(game.toCoord(point));
      // Level the monster up for dungeon level / 2
      for (int j = 0; j < game.dungeonLevel / 2; ++j) {
        monster.levelUp();
      }
      // The monster may receive and equip an item (more likely later on)
      if (random(max(1, 100 - difficulty)) < 5) {
        final Item item = getRandomItem();
        monster.inventory.addItem(item);
        monster.inventory.equipItem(item);
      }
      // Add the monster to the game
      game.addActor(monster);
    }
  }

  public void placeItems(final Game game) {
    // Randomly pick some items to add, and add them to free cells
    for (int i = 0; i < (int) floor(random(1, 5)); ++i) {
      game.addItemDrop(getRandomItem(), freeCell());
    }
  }

  private Dungeon.Point freeCell() {
    Dungeon.Point point = null;
    do {
      // Pick a random cell
      point = new Dungeon.Point(
          (int) floor(random(dungeon.width)),
          (int) floor(random(dungeon.height)));
      // Keep picking until it is a free cell
    } while (dungeon.cellAt(point.x, point.y) == Dungeon.Cell.ROCK);
    return point;
  }

  private PVector getCameraOffset(final Game game) {
    final PVector offset = game.getPlayer().getPosition();
    offset.x = displayWidth / 2 - offset.x - cellSize / 2;
    offset.y = displayHeight / 2 - offset.y - cellSize / 2;
    return offset;
  }

  private void testCollision(final Game game) {
    final Actor player = game.getPlayer();
    if (player.isInvuln()) {
      return;
    }
    final PVector pos = player.getPosition();
    for (final Actor monster : game.getActors()) {
      if (monster == player || monster.isInvuln()) {
        continue;
      }
      final PVector mon = monster.getPosition();
      // Are the circles the sum of their radii from each other?
      if (pow(player.race.size.radius - monster.race.size.radius, 2) <=
          pow(pos.x - mon.x, 2) + pow(pos.y - mon.y, 2) &&
          pow(pos.x - mon.x, 2) + pow(pos.y - mon.y, 2) <=
          pow(player.race.size.radius + monster.race.size.radius, 2)) {
        // Set the opponent
        game.opponent = monster;
        // Collision, enter combat
        nextState = CombatState.class;
        // Only fight one monster at a time
        break;
      }
    }
  }

  private void drawDungeon(final Game game, final PVector offset) {
    randomSeed(0);
    // Darkens cells
    fill(0, 0, 0, 200);
    stroke(0, 0, 0, 200);
    for (int x = 0; x < dungeon.width; ++x) {
      for (int y = 0; y < dungeon.height; ++y) {
        final float xCoord = x * cellSize + offset.x;
        final float yCoord = y * cellSize + offset.y;
        boolean light = false;
        // If an actor is near, the square is lit up
        for (final Actor actor : game.getActors()) {
          if (Dungeon.distance(game.toCell(actor.getPosition()), new Dungeon.Point(x, y)) < 5) {
            light = true;
            break;
          }
        }
        switch (dungeon.cellAt(x, y)) {
          case ROCK:
            // Make it look slightly 3D
            if (dungeon.cellAt(x, y + 1) == Dungeon.Cell.GROUND) {
              image(rockEdge, xCoord, yCoord);
            }
            break;
          case GROUND:
            PImage tile = null;
            // Draw entry stairs
            if (dungeon.entry.x == x && dungeon.entry.y == y) {
              tile = stairs[0];
            // Draw exit stairs
            } else if (dungeon.exit.x == x && dungeon.exit.y == y) {
              tile = stairs[1];
            // Draw a random ground tile
            } else {
              tile = tiles[(int) floor(random(tiles.length))];
            }
            image(tile, xCoord, yCoord);
            break;
        }
        // Draw any item drops
        final List<Item> drops = game.itemsAt(new Dungeon.Point(x, y));
        for (final Item item : drops) {
          image(itemImages.get(item.slot), xCoord, yCoord);
        }
        if (!light &&
            (dungeon.exit.x != x || dungeon.exit.y != y) &&
            (dungeon.entry.x != x || dungeon.entry.y != y)) {
          rect(xCoord, yCoord, cellSize, cellSize);
        }
      }
    }
  }
}
