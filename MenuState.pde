/*
 * Copyright 2017 Billy Brown
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

class MenuState extends GameState {
  public final String title;
  private final MenuOption[] options = new MenuOption[] {
    new MenuOption("New Character", NewCharacterState.class)
  };

  public MenuState(final String title) {
    super();
    this.title = title;
  }

  public void onEnter(final Game game) {

  }

  public void input(final Game game, final char key) {
    // There is no keyboard input
  }


  public void click(final Game game, final PVector position) {
    // Check the options
    for (final MenuOption option : options) {
      // If one was clicked
      if (option.clicked(position)) {
        // Transition
        nextState = option.next;
        break;
      }
    }
  }

  public void update(final Game game) {
    // There is no live updating
  }

  public void draw(final Game game) {
    // Draw in white
    fill(255);
    // Use standard spacing
    float offset = 30;
    final float padding = 50;

    offset = drawTitle(offset);
    offset += padding;
    drawHelp(offset, padding);
    drawOptions(offset, padding);

    drawInfo(padding);
  }

  private float drawTitle(final float offset) {
    textAlign(CENTER, TOP);
    textSize(FONT_LARGE);
    text(title, displayWidth / 2, offset);
    return offset + FONT_LARGE * 2;
  }

  private void drawHelp(float offset, final float padding) {
    textAlign(LEFT, TOP);
    textSize(FONT_MEDIUM);
    final String[] lines = new String[] {
      "Exploring: click to move.",
      "Exploring: press I for inventory.",
      "Exploring: open inventory over dropped items.",
      "Exploring: run into monster to fight it.",
      "Exploring: fight monsters for xp.",
      "Inventory: use a health potion to gain health.",
      "Inventory: putting an item of health away removes health.",
      "Combat: flee to survive and run away.",
      "Enough xp -> level up -> more health."
    };
    for (final String line : lines) {
      text(line, padding, offset);
      offset += FONT_MEDIUM * 2;
    }
  }

  private float drawOptions(float offset, final float padding) {
    final float lineHeight = FONT_MEDIUM * 2;
    textAlign(LEFT, TOP);
    textSize(FONT_MEDIUM);
    for (final MenuOption option : options) {
      option.draw(new PVector(displayWidth - padding - 200, offset));
      offset += lineHeight;
    }
    return offset;
  }

  private void drawInfo(final float padding) {
    textAlign(RIGHT, BOTTOM);
    textSize(FONT_SMALL);
    text("Press ESC to exit at any time (will not save).",
        displayWidth - padding,
        displayHeight - padding);
  }

  public void resetTransition() {
    nextState = MenuState.class;
    // Reset the game
    if (game != null) {
      game.reset();
    }
  }
}

class MenuOption {
  // The option's name
  public final String name;
  // The option's button
  public Button button = null;
  // The class that the option will transition to
  public final Class<? extends GameState> next;

  public MenuOption(final String name, final Class<? extends GameState> next) {
    this.name = name;
    this.next = next;
  }

  public void draw(final PVector pos) {
    if (button == null) {
      button = new Button(name, pos, FONT_MEDIUM);
    }
    button.draw();
  }

  public boolean clicked(final PVector pos) {
    if (button == null) {
      return false;
    }
    return button.over(pos);
  }
}
