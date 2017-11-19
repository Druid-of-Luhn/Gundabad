/*
 * Copyright 2017 Billy Brown
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

class DeathState extends GameState {
  public void onEnter(final Game game) {
  }

  public void input(final Game game, final char key) {
    if (key == ' ') {
      nextState = MenuState.class;
      // Reset the game
      game.reset();
    }
  }

  public void click(final Game game, final PVector position) {

  }

  public void update(final Game game) {

  }

  public void draw(final Game game) {
    textAlign(CENTER, TOP);
    textSize(FONT_LARGE);
    final int padding = 50;
    int offset = 30;
    text(game.getPlayer().name + " died...", displayWidth / 2, offset);
    offset += FONT_LARGE * 2;

    textAlign(LEFT, TOP);
    textSize(FONT_MEDIUM);

    final String[] messages = new String[] {
      "Score: " + game.getPlayer().getScore(),
      "Level: " + game.getPlayer().getLevel(),
      "Depth: " + game.dungeonLevel,
      "Stats: " + game.getPlayer().getStats(),
      "Attack: " + game.getPlayer().getAttack(),
      "Defence: " + game.getPlayer().getDefence()
    };
    for (final String message : messages) {
      text(message, padding, offset);
      offset += FONT_MEDIUM * 2;
    }

    textAlign(RIGHT, BOTTOM);
    textSize(FONT_SMALL);
    text("Press SPACE to return to the menu.", displayWidth - padding, displayHeight - padding);
  }

  public void resetTransition() {
    nextState = DeathState.class;
  }
}
