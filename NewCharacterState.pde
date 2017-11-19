/*
 * Copyright 2017 Billy Brown
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

import java.util.Map;
import java.util.TreeMap;

static enum Typing {
  START, STOP, CLEAR
}

class NewCharacterState extends GameState {
  private static final String NEXT_LABEL = "Next";
  private final String title = "New Character";
  private final Map<String, Race> races = new TreeMap<String, Race>();
  private final Map<String, Typing> typing = new TreeMap<String, Typing>();
  // Race selection is done with buttons
  private final CharacterOption[] options;

  // This state creates the player
  private Race race = null;
  private String name = "";
  private boolean isTyping = false;

  public NewCharacterState() {
    options = new CharacterOption[] {
      makeRaceOption(),
      makeNameOption(),
      new CharacterOption("Done?", new String[] { NEXT_LABEL})
    };
  }

  private CharacterOption makeRaceOption() {
    // Select the races to be used
    races.put("Human", Race.HUMAN);
    races.put("Dwarf", Race.DWARF);
    races.put("Elf", Race.ELF);
    // Get the array of button labels
    final String[] choices = races.keySet().toArray(new String[0]);
    // Make them into a character option choice
    return new CharacterOption("Pick a race:", choices);
  }

  private CharacterOption makeNameOption() {
    // Select the typing options
    typing.put("Start typing", Typing.START);
    typing.put("Stop typing", Typing.STOP);
    typing.put("Clear typing", Typing.CLEAR);
    // Make the choices into character options
    final String[] choices = typing.keySet().toArray(new String[0]);
    return new CharacterOption("Name your character:", choices);
  }

  public void onEnter(final Game game) {

  }

  public void input(final Game game, final char key) {
    if (isTyping) {
      if (key == ENTER || key == RETURN) {
        // Ignore certain keys
      } else if (key == BACKSPACE && name.length() > 0) {
        // Remove the last letter
        name = name.substring(0, name.length() - 1);
      } else {
        // Just add the character to the name
        name += key;
      }
    }
  }

  public void click(final Game game, final PVector position) {
    for (final CharacterOption option : options) {
      // Get the user's choice
      final String choice = option.clicked(position);
      // Was it for this option?
      if (choice == null) {
        continue;
      }
      // Are we dealing with a character race choice?
      if (races.get(choice) != null) {
        // Pick the race
        race = races.get(choice);
        break;
      }
      // Is it for the name?
      if (typing.get(choice) != null) {
        // Set the typing state
        nameAction(typing.get(choice));
        break;
      }
      // Is the character ready?
      if (choice == NEXT_LABEL && isReady()) {
        // Make the character
        // Health = 3D8 + CON
        final int health = Dice.D8() + Dice.D8() + Dice.D8() + race.base.CON();
        final Actor player = new Actor(name, race, health);
        game.setPlayer(player);
        // Give it some starting items
        final Item[] items = new Item[] {
          getItem("Iron Sword"),
          getItem("Chain Mail")
        };
        for (final Item item : items) {
          player.inventory.addItem(item);
          player.inventory.equipItem(item);
        }
        // Start exploring
        nextState = ExploreState.class;
        break;
      }
    }
  }

  private boolean isReady() {
    return race != null && name.length() > 0;
  }

  private void nameAction(final Typing choice) {
    switch (choice) {
      case START:
        isTyping = true;
        break;
      case STOP:
        isTyping = false;
        break;
      case CLEAR:
        name = "";
        break;
    }
  }

  public void update(final Game game) {

  }

  public void draw(final Game game) {
    // Draw in white
    fill(255);
    // Use standard spacing
    float off_x = 50;
    float off_y = 50;

    // Draw the page title
    off_y = drawTitle(off_y);
    // Display the character name
    off_y = drawName(off_x, off_y);
    // Display the current character stats
    off_y = drawStats(off_x, off_y);

    // Draw the available options
    for (final CharacterOption option : options) {
      option.draw(new PVector(off_x, off_y));
      // Draw options in columns beside each other
      off_x += option.optionWidth() + 50;
    }
  }

  private float drawTitle(final float offset) {
    textAlign(CENTER, TOP);
    textSize(FONT_LARGE);
    text(title, displayWidth / 2, offset);
    return offset + FONT_LARGE * 2;
  }

  private float drawName(final float off_x, final float off_y) {
    textAlign(LEFT, TOP);
    textSize(FONT_MEDIUM);
    text("Name: " + name, off_x, off_y);
    return off_y + FONT_MEDIUM * 3;
  }

  private float drawStats(float off_x, float off_y) {
    textAlign(TOP, LEFT);
    textSize(FONT_MEDIUM);
    text("STR: " + (race == null ? "" : race.base.STR()),
        off_x, off_y);
    off_x += 100;
    text("DEX: " + (race == null ? "" : race.base.DEX()),
        off_x, off_y);
    off_x += 100;
    text("CON: " + (race == null ? "" : race.base.CON()),
        off_x, off_y);
    off_x += 100;
    text("Speed: " + (race == null ? "" : race.size.speed),
        off_x, off_y);
    return off_y + FONT_MEDIUM * 1.5;
  }

  public void resetTransition() {
    nextState = NewCharacterState.class;
  }
}

class CharacterOption {
  final String label;
  final String[] choices;
  Button[] buttons;

  public CharacterOption(final String label, final String[] choices) {
    this.label = label;
    this.choices = choices;
    buttons = new Button[choices.length];
  }

  public float optionWidth() {
    // Find the widest element
    textSize(FONT_MEDIUM);
    float max = textWidth(label);
    for (final Button button : buttons) {
      if (button != null) {
        final float buttonWidth = textWidth(button.label);
        max = Math.max(max, buttonWidth);
      }
    }
    return max;
  }

  public void draw(final PVector pos) {
    // Create the buttons the first time
    if (buttons[0] == null) {
      makeButtons(pos);
    }
    fill(255);
    textAlign(LEFT, TOP);
    textSize(FONT_MEDIUM);
    // Draw the label
    text(label, pos.x, pos.y);
    // Draw the buttons
    for (final Button button : buttons) {
      button.draw();
    }
  }

  private void makeButtons(final PVector pos) {
    float offset = pos.y;
    for (int i = 0; i < buttons.length; ++i) {
      // Place the buttons in a column
      offset += FONT_MEDIUM * 2;
      final PVector position = new PVector(pos.x, offset);
      buttons[i] = new Button(choices[i], position, FONT_MEDIUM);
    }
  }

  public String clicked(final PVector pos) {
    // If the buttons don't exist for some reason, do nothing
    if (buttons[0] == null) {
      return null;
    }
    // Check each button for being clicked
    for (final Button button : buttons) {
      if (button.over(pos)) {
        return button.label;
      }
    }
    return null;
  }
}
