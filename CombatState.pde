/*
 * Copyright 2017 Billy Brown
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

import java.util.LinkedList;
import java.util.List;

class CombatState extends GameState {
  private Actor opponent = null;
  private boolean turn; // Is it the player's turn?
  private Button[] buttons = null;
  private List<String> messages;

  public void onEnter(final Game game) {
    opponent = game.opponent;
    game.opponent = null;
    turn = true;
    messages = new LinkedList<String>();
  }

  public void input(final Game game, final char key) {
    if (opponent == null && key == ' ') {
      nextState = ExploreState.class;
    }
  }

  public void click(final Game game, final PVector position) {
    if (!turn) {
      return;
    }
    final Actor player = game.getPlayer();
    for (final Button b : buttons) {
      if (b.over(position)) {
        switch (b.label) {
          case "Attack":
            attack(game, player, opponent);
            break;
          case "Flee":
            actorFlees(player, opponent);
            break;
          default:
            if (b.label.startsWith("Drink Potion")) {
              // Drink a potion if one is available
              final List<Item> potions = player.getPotions();
              if (potions.size() > 0) {
                player.takePotion(potions.get(0));
              }
            }
            break;
        }
      }
    }
  }

  private void addMessage(final String message) {
    if (messages.size() >= 10) {
      // Remove the last message
      messages.remove(messages.size() - 1);
    }
    // Add the message to the beginning
    messages.add(0, message);
  }

  private void actorFlees(final Actor actor, final Actor other) {
    // The actor flees
    actor.flee = true;
    // The actor is invulnerable for a second
    actor.invuln = millis() + 1000;
    // Remove the actor's current path
    actor.stop();
    // Return to the explore state
    nextState = ExploreState.class;
  }

  private void attack(final Game game, final Actor from, final Actor to) {
    // 1d20 + attack vs defence
    final int att = Dice.D20() + from.getAttack();
    addMessage(from.name + " attacks: " + att);
    if (att >= to.getDefence()) {
      addMessage(from.name + " hits!");
      // 1d8 + attack/2 damage
      final int dmg = Dice.D8() + from.getAttack() / 2;
      addMessage(from.name + " deals " + dmg + " damage.");
      to.damage(dmg);
      // If the target was killed
      if (!to.alive()) {
        addMessage(to.name + " died...");
        if (to == game.getPlayer()) {
          // The player dies
          nextState = ExploreState.class;
          return;
        } else {
          // The opponent died
          game.getPlayer().gainXP(10 * opponent.getAttack() + opponent.getDefence());
          opponent = null;
        }
        game.removeActor(to);
      }
    } else {
      addMessage(from.name + " misses...");
    }
    // End the turn
    turn = !turn;
  }

  public void update(final Game game) {
    // Opponent's turn
    if (!turn && opponent != null) {
      // Opponent flees if it doesn't have much health and is losing
      if (opponent.getHealth() <= 5 && game.getPlayer().getHealth() > 5) {
        actorFlees(opponent, game.getPlayer());
        // Get a bit of XP
        game.getPlayer().gainXP(5 * opponent.getAttack());
        opponent = null;
      } else {
        attack(game, opponent, game.getPlayer());
      }
    }
  }

  public void draw(final Game game) {
    // Draw in white
    fill(255);
    final int padding = 50;
    int offset = 30;
    offset = drawTitle(offset);
    drawMessages(offset);
    drawOpponent(padding, offset);
    offset = drawPlayer(game, padding, offset);

    if (buttons == null) {
      makeButtons(new PVector(padding, offset));
    }
    for (final Button b : buttons) {
      if (b.label.startsWith("Drink Potion")) {
        b.label = "Drink Potion (" + game.getPlayer().getPotions().size() + ")";
      }
      b.draw();
    }

    textAlign(CENTER, BOTTOM);
    textSize(FONT_MEDIUM);
    if (opponent == null) {
      text("You win, press SPACE to continue.",
          displayWidth / 2,
          displayHeight - 20);
    } else {
      text("Turn: " + (turn ? game.getPlayer().name : opponent.name),
          displayWidth / 2,
          displayHeight - 20);
    }
  }

  private int drawTitle(final int offset) {
    textAlign(CENTER, TOP);
    textSize(FONT_LARGE);
    text("Combat", displayWidth / 2, offset);
    return offset + FONT_LARGE * 2;
  }

  private void drawMessages(int offset) {
    textAlign(CENTER, TOP);
    textSize(FONT_MEDIUM);
    for (final String message : messages) {
      text(message, displayWidth / 2, offset);
      offset += FONT_MEDIUM * 2;
    }
  }

  private int drawPlayer(final Game game, final int padding, int offset) {
    textAlign(LEFT, TOP);
    textSize(FONT_MEDIUM);
    final Actor player = game.getPlayer();
    offset = drawActor(player, padding, offset);
    // Draw the player's attack and defence values
    text("Attack: +" + player.getAttack(), padding, offset);
    offset += FONT_MEDIUM * 2;
    text("Defence: " + player.getDefence(), padding, offset);
    offset += FONT_MEDIUM * 2;
    return offset;
  }

  private void drawOpponent(final int padding, int offset) {
    if (opponent == null) {
      return;
    }
    textAlign(RIGHT, TOP);
    textSize(FONT_MEDIUM);
    offset = drawActor(opponent, displayWidth - padding, offset);
  }

  private int drawActor(final Actor actor, final int padding, int offset) {
    text("Name: " + actor.name, padding, offset);
    offset += FONT_MEDIUM * 2;
    text("Health: " + actor.getHealth() + "/" + actor.getMaxHealth(), padding, offset);
    offset += FONT_MEDIUM * 2;
    return offset;
  }

  public void resetTransition() {
    nextState = CombatState.class;
  }

  private void makeButtons(final PVector position) {
    buttons = new Button[3];

    buttons[0] = new Button("Attack", position, FONT_MEDIUM);
    position.y += FONT_MEDIUM * 2;

    buttons[1] = new Button("Flee", position, FONT_MEDIUM);
    position.y += FONT_MEDIUM * 2;

    buttons[2] = new Button("Drink Potion", position, FONT_MEDIUM);
  }
}
