/*
 * Copyright 2017 Billy Brown
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

class Item implements Cloneable {
  public static enum Slot {
    HEAD,
    HAND,
    BODY,
    BELT,
    FEET,
    USE // Not equipped but used
  }

  public static enum Modifier {
    STATS, HEALTH, SPEED, ATTACK, DEFENCE
  }

  public final String name;
  public final Slot slot;
  public final int weight;
  public final Modifier effect;
  public final Stats modifiers;
  public final int modifier;

  public Item(
      final String name,
      final Slot slot,
      final int weight,
      final Stats mods) {
    this.name = name;
    this.slot = slot;
    this.weight = weight;
    effect = Modifier.STATS;
    modifiers = mods;
    modifier = 0;
  }

  public Item(
      final String name,
      final Slot slot,
      final int weight,
      final Modifier effect,
      final int modifier) {
    this.name = name;
    this.slot = slot;
    this.weight = weight;
    this.effect = effect;
    this.modifier = modifier;
    modifiers = null;
  }

  @Override
  public Item clone() {
    return effect == Modifier.STATS
      ? new Item(name, slot, weight, modifiers)
      : new Item(name, slot, weight, effect, modifier);
  }

  @Override
  public String toString() {
    String result = name;
    result += " [" + slot.toString().toLowerCase();
    result += "] " + weight + "kg";
    if (effect == Modifier.STATS) {
      result += modifiers.STR() != 0 ? " STR: +" + modifiers.STR() : "";
      result += modifiers.DEX() != 0 ? " DEX: +" + modifiers.DEX() : "";
      result += modifiers.CON() != 0 ? " CON: +" + modifiers.CON() : "";
    } else {
      if (modifier > 0) {
        result += " " + effect.toString().toLowerCase();
        result += ": +" + modifier;
      }
    }
    return result;
  }
}
