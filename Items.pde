/*
 * Copyright 2017 Billy Brown
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

/*
 * Provide a static index of items to be used in the game.
 */

import java.util.HashMap;
import java.util.Map;
import java.util.Random;

static final Map<String, Item> index = new HashMap<String, Item>();

static void buildItemsIndex() {
  final Item[] items = new Item[] {
    new Item(
        "Iron Sword",           // Name
        Item.Slot.HAND,         // Slot
        6,                      // Weight
        Item.Modifier.ATTACK,   // Effect
        1),                     // Modifier
    new Item(
        "Chain Mail",
        Item.Slot.BODY,
        12,
        Item.Modifier.DEFENCE,
        2),
    new Item(
        "Fleet Boots",
        Item.Slot.FEET,
        2,
        Item.Modifier.SPEED,
        1),
    new Item(
        "Cold Steel Mace",
        Item.Slot.HAND,
        10,
        Item.Modifier.ATTACK,
        2),
    new Item(
        "Mithril Shirt",
        Item.Slot.BODY,
        6,
        Item.Modifier.DEFENCE,
        4),
    new Item(
        "Headband of Strength",
        Item.Slot.HEAD,
        1,
        new Stats(1, 0, 0)),    // Stats modifiers
    new Item(
        "Potion of Healing",
        Item.Slot.USE,
        1,
        Item.Modifier.HEALTH,
        8),
    new Item(
        "Greater Potion of Healing",
        Item.Slot.USE,
        1,
        Item.Modifier.HEALTH,
        16),
    new Item(
        "Belt of Health",
        Item.Slot.BELT,
        1,
        Item.Modifier.HEALTH,
        8),
    new Item(
        "Boots of Dodge",
        Item.Slot.FEET,
        2,
        new Stats(0, 2, 0)),
    new Item(
        "Boots of Dodge",
        Item.Slot.FEET,
        2,
        new Stats(0, 2, 0)),
    new Item(
        "Punching Cape",
        Item.Slot.BODY,
        4,
        Item.Modifier.ATTACK,
        2),
    new Item(
        "Cestus of Fury",
        Item.Slot.HAND,
        3,
        new Stats(2, 0, 0)),
    new Item(
        "Bashing Shield",
        Item.Slot.HAND,
        8,
        new Stats(1, 1, 0)), // This is a way of increasing attack and defence
    new Item(
        "Anduril",
        Item.Slot.HAND,
        7,
        Item.Modifier.ATTACK,
        5)
  };
  for (final Item item : items) {
    insertItem(item);
  }
}

static void insertItem(final Item item) {
  index.put(item.name, item);
}

static Item getItem(final String name) {
  return index.get(name).clone();
}

static Item getRandomItem() {
  final int choice = new Random().nextInt(index.size());
  int counter = 0;
  for (final Item item : index.values()) {
    if (choice == counter++) {
      return item;
    }
  }
  return null;
}
