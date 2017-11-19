/*
 * Copyright 2017 Billy Brown
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

class Monster extends Actor {
  public final PVector[] patrolPoints;
  int target = 0;

  public Monster(final Race race, final int health, final PVector[] patrol) {
    super(race.toString(), race, health);
    patrolPoints = patrol;
  }

  public void nextTarget(final Dungeon dungeon) {
    // Set the next target in the patrol pattern
    ai.setTarget(position, patrolPoints[++target % patrolPoints.length], dungeon);
  }
}
