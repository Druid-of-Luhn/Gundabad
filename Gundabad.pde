/*
 * Copyright 2017 Billy Brown
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

import java.util.Map;
import java.util.HashMap;

final GameState[] states = new GameState[] {
  new MenuState("Gundabad"),
  new NewCharacterState(),
  new ExploreState(),
  new InventoryState(),
  new CombatState(),
  new DeathState()
};
final GameStateManager stateManager = new GameStateManager(states);
final Game game = new Game();
PImage[] tiles;
PImage[] stairs;
PImage rockEdge;
final Map<Item.Slot, PImage> itemImages = new HashMap<Item.Slot, PImage>();

static final int FONT_LARGE = 72;
static final int FONT_MEDIUM = 24;
static final int FONT_SMALL = 16;

void setup() {
  fullScreen();
  strokeWeight(1);
  tiles = new PImage[4];
  for (int i = 0; i < tiles.length; ++i) {
    tiles[i] = loadImage("tiles/floor-" + (i + 1) + ".jpg");
  }
  stairs = new PImage[] {
    loadImage("tiles/up.jpg"),
    loadImage("tiles/down.jpg")
  };
  rockEdge = loadImage("tiles/rock-edge.jpg");
  final Item.Slot[] drops = new Item.Slot[] {
    Item.Slot.HEAD, Item.Slot.HAND, Item.Slot.BODY,
    Item.Slot.BELT, Item.Slot.FEET, Item.Slot.USE
  };
  for (final Item.Slot type : drops) {
    final String name = type.toString().toLowerCase();
    itemImages.put(type, loadImage("items/" + name + ".png"));
  }
  buildItemsIndex();
}

void draw() {
  // Update the game state
  stateManager.update(game);

  // Clear the screen
  background(0);
  // Draw the game
  stateManager.draw(game);
}

void keyPressed() {
  stateManager.input(game, key);
}

void mouseReleased() {
  stateManager.click(game, new PVector(mouseX, mouseY));
}
