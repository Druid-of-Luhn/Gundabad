/*
 * Copyright 2017 Billy Brown
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Set;

class Inventory {
  private final List<Item> items;
  private final Set<Item> equipped;
  public final int maxWeight;
  private int weight;

  public Inventory(final int maxWeight) {
    items = new LinkedList<Item>();
    equipped = new HashSet<Item>();
    this.maxWeight = maxWeight;
    this.weight = 0;
  }

  public boolean addItem(final Item item) {
    if (item != null && weight + item.weight <= maxWeight) {
      items.add(item);
      weight += item.weight;
      return true;
    }
    return false;
  }

  public boolean equipItem(final Item item) {
    if (item == null) {
      return false;
    }
    // Is this type of slot already filled?
    boolean filled = false;
    for (final Item e : equipped) {
      if (e.slot == item.slot) {
        filled = true;
        break;
      }
    }
    // If it is filled, cannot add
    if (filled) {
      return false;
    }
    // Otherwise, equip it
    equipped.add(item);
    return true;
  }

  public void dropItem(final Item item) {
    if (item != null) {
      weight -= item.weight;
      items.remove(item);
      equipped.remove(item);
    }
  }

  public void putAway(final Item item) {
    if (item != null) {
      equipped.remove(item);
    }
  }

  public List<Item> getItems() {
    return items;
  }

  public Set<Item> getEquipped() {
    return equipped;
  }

  public Item get(final String name) {
    for (final Item item : items) {
      if (item.name.equals(name)) {
        return item;
      }
    }
    return null;
  }

  public int getWeight() {
    return weight;
  }

  public static boolean isPotion(final Item item) {
    return item.slot == Item.Slot.USE &&
      item.effect == Item.Modifier.HEALTH;
  }
}
