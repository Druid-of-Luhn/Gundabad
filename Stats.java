/*
 * Copyright 2017 Billy Brown
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

// Size determines movement speed
enum Size {
//SIZE    SPEED RADIUS
  SMALL  (2.5f, 10),
  MEDIUM (3,    16),
  LARGE  (5,    24);

  // Speed in game units
  public final float speed;
  // Actors are represented as circles
  public final float radius;

  private Size(final float speed, final float radius) {
    this.speed = speed;
    this.radius = radius;
  }
}

// A race has a size and some base stats
enum Race {
//RACE    SIZE                   STR DEX CON
  HUMAN  (Size.MEDIUM, new Stats( 1,  1,  1)),
  DWARF  (Size.SMALL,  new Stats( 2, -1,  2)),
  ELF    (Size.MEDIUM, new Stats( 0,  3,  1)),
  GOBLIN (Size.SMALL,  new Stats(-1,  1,  0)),
  ORC    (Size.MEDIUM, new Stats( 1,  0,  1)),
  WARG   (Size.MEDIUM, new Stats( 0,  2,  0)),
  URUK   (Size.MEDIUM, new Stats( 2,  1,  1)),
  TROLL  (Size.LARGE,  new Stats( 4, -3,  4));

  // A race has a size
  public final Size size;
  // And some base stats
  public final Stats base;

  private Race(final Size size, final Stats base) {
    this.size = size;
    this.base = base;
  }
}

class Stats {
  private int STR; // Strength
  private int DEX; // Dexterity
  private int CON; // Constitution

  public Stats(final int STR, final int DEX, final int CON) {
    this.STR = STR;
    this.DEX = DEX;
    this.CON = CON;
  }

  public Stats(final Race race) {
    STR = race.base.STR();
    DEX = race.base.DEX();
    CON = race.base.CON();
  }

  public int STR() {
    return STR;
  }

  public int DEX() {
    return DEX;
  }

  public int CON() {
    return CON;
  }

  @Override
  public String toString() {
    return "STR: " + STR() + " DEX: " + DEX() + " CON: " + CON;
  }
}
