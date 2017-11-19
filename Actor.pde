/*
 * Copyright 2017 Billy Brown
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

import java.util.Date;
import java.util.Queue;

/*
 * The base character class for the game,
 * for monsters, allies and players alike.
 */
class Actor {
  public static final float ROT_SPEED = PI / 16;

  public final String name;
  public final Race race;
  public final ActorAI ai = new ActorAI();
  public final Inventory inventory;
  Queue<PVector> path;
  public boolean flee = false;
  public long invuln = 0;

  final Stats stats;
  int score = 0;
  int xp = 0;
  int level = 1;
  int health;
  int maxHealth;
  PVector position;
  float rotation = 0;

  Actor(final String name, final Race race, final int health) {
    this.name = name;
    this.race = race;
    stats = new Stats(race);
    inventory = new Inventory(50 + stats.STR() * 10);
    maxHealth = health;
    this.health = health;
  }

  public void update() {
    // The AI might have a new path
    if (ai.path != null) {
      path = ai.path;
      ai.path = null;
    }
    // If there is a path to follow
    if (path != null) {
      // Get the next point
      final PVector next = path.peek();
      // If the actor is in range of the point, pop it
      if (inRange(next)) {
        path.poll();
        // If the path is finished, remove it and do not move
        if (path.isEmpty()) {
          path = null;
          return;
        }
      }
      // Move towards the next point
      final PVector distance = next.get().sub(position);
      // Rotate towards the target orientation
      rotate(atan2(distance.y, distance.x));
      // Move in the correct direction (faster if fleeing)
      distance.normalize();
      final float moveSpeed = speed() + (flee ? 1 : 0);
      position.x += moveSpeed * distance.x;
      position.y += moveSpeed * distance.y;
    }
  }

  private void rotate(final float orientation) {
    // Pointing in a good enough direction
    if (abs(orientation - rotation) <= ROT_SPEED) {
      rotation = orientation;
      return;
    } 
    // Turn
    if (orientation < rotation) {
      rotation += (rotation - orientation < PI) ? -ROT_SPEED : ROT_SPEED;
    } else {
      rotation += (orientation - rotation < PI) ? ROT_SPEED : -ROT_SPEED;
    }
    // Remain in bounds
    if (rotation > PI) {
      rotation -= 2 * PI;
    } else if (rotation < -PI) {
      rotation += 2 * PI;
    }
  }

  public boolean inRange(final PVector pos) {
    // Always in range of no target
    return pos == null ||
      // a^2 + b^2 = c^2
      pow(position.x - pos.x, 2) +
      pow(position.y - pos.y, 2) <=
      // Max allowed distance from target
      pow(race.size.radius, 2);
  }

  public void draw(final PVector offset) {
    drawSelf(offset);
    drawName(offset);
    drawHealth(offset);
  }

  private void drawSelf(final PVector offset) {
    // Draw the actor as a circle
    final float diameter = race.size.radius * 2;
    ellipse(position.x + offset.x, position.y + offset.y, diameter, diameter);
    // Draw an eye to show where it is pointing
    fill(0);
    ellipse(
        position.x + offset.x + race.size.radius / 2 * cos(rotation),
        position.y + offset.y + race.size.radius / 2 * sin(rotation),
        race.size.radius, race.size.radius);
    fill(255);
  }
  
  private void drawName(final PVector offset) {
    // Display the actor's name
    textAlign(CENTER, BOTTOM);
    textSize(FONT_SMALL);
    text(name, position.x + offset.x, position.y - race.size.radius + offset.y);
  }

  private void drawHealth(final PVector offset) {
    textAlign(CENTER, TOP);
    textSize(FONT_SMALL);
    // Health should always be <= maxHealth
    health = min(health, getMaxHealth());
    text(health + "/" + getMaxHealth(),
        position.x + offset.x, position.y + race.size.radius + offset.y);
  }

  public void testLevelUp() {
    if (xp >= getNextXP()) {
      levelUp();
    }
  }

  public void levelUp() {
    // Decrease xp
    xp -= getNextXP();
    // Increase the level
    ++level;
    // Gain additional health
    final int addedHealth = Dice.D12() + getStats().CON();
    maxHealth += addedHealth;
    health += addedHealth;
    // Gain to stats and attack calculated when fetched
  }

  // Get the character's movement speed
  public float speed() {
    float s = race.size.speed;
    // Apply any equipped item effects
    for (final Item item : inventory.getEquipped()) {
      if (item.effect == Item.Modifier.SPEED) {
        s += item.modifier;
      }
    }
    return max(1, s);
  }

  public int getNextXP() {
    // Increase quadratically
    // 1 -> 2: 110xp
    // 2 -> 3: 240xp
    // 3 -> 4: 390xp
    // 4 -> 5: 560xp
    // ...
    return level * 100 + (int) pow(level, 2) * 10;
  }

  public Stats getStats() {
    // Stats increase every 4 levels
    int STR = stats.STR() + level / 4;
    int DEX = stats.DEX() + level / 4;
    int CON = stats.CON() + level / 4;
    // Apply any equipped item effects
    for (final Item item : inventory.getEquipped()) {
      if (item.effect == Item.Modifier.STATS) {
        STR += item.modifiers.STR();
        DEX += item.modifiers.DEX();
        CON += item.modifiers.CON();
      }
    }
    return new Stats(STR, DEX, CON);
  }

  public int getMaxHealth() {
    int h = maxHealth;
    // Apply any equipped item effects
    for (final Item item : inventory.getEquipped()) {
      if (item.effect == Item.Modifier.HEALTH) {
        h += item.modifier;
      }
    }
    return max(0, h);
  }

  public int getHealth() {
    return min(health, getMaxHealth());
  }

  public int getAttack() {
    int attack = level / 2;
    // Apply any equipped item effects
    for (final Item item : inventory.getEquipped()) {
      if (item.effect == Item.Modifier.ATTACK) {
        attack += item.modifier;
      }
    }
    // STR is applied to attack
    attack += getStats().STR();
    // Cannot have negative attack
    return max(0, attack);
  }

  public int getDefence() {
    int defence = 10;
    // Apply any equipped item effects
    for (final Item item : inventory.getEquipped()) {
      if (item.effect == Item.Modifier.DEFENCE) {
        defence += item.modifier;
      }
    }
    // DEX is applied to attack (dodging)
    defence += getStats().DEX();
    // Cannot have negative defence
    return max(0, defence);
  }

  // Damage the character
  public void damage(final int damage) {
    health -= damage;
  }

  // Is the actor alive?
  public boolean alive() {
    return health > 0;
  }

  public void gainXP(final int amount) {
    xp += amount;
    // The total xp achieved is the score
    score += amount;
    // The actor may level up
    testLevelUp();
  }

  public void stop() {
    path = null;
  }

  public boolean hasTarget() {
    return path != null && !path.isEmpty();
  }
  
  public void takePotion(final Item item) {
    if (Inventory.isPotion(item)) {
      // Apply the potion
      health = min(health + item.modifier, getMaxHealth());
      // Consume the potion
      inventory.dropItem(item);
    }
  }

  public List<Item> getPotions() {
    final List<Item> potions = new LinkedList<Item>();
    for (final Item item : inventory.getItems()) {
      if (Inventory.isPotion(item)) {
        potions.add(item);
      }
    }
    return potions;
  }

  public void setPosition(final PVector pos) {
    position = pos.get();
  }

  public PVector getPosition() {
    return position.get();
  }

  public int getXP() {
    return xp;
  }

  public int getLevel() {
    return level;
  }

  public int getScore() {
    return score;
  }

  public float getRotation() {
    return rotation;
  }

  public boolean isInvuln() {
    return millis() <= invuln;
  }
}
