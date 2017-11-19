/*
 * Copyright 2017 Billy Brown
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;

class InventoryState extends GameState {
  public static final char KEY = 'i';

  private final List<InventoryOption> items = new LinkedList<InventoryOption>();
  private final List<ItemDropOption> drops = new LinkedList<ItemDropOption>();

  public void onEnter(final Game game) {
    makeInventoryOptions(game);
  }

  public void input(final Game game, final char key) {
    // Leave the inventory
    if (key == KEY) {
      nextState = ExploreState.class;
    }
  }

  public void click(final Game game, final PVector position) {
    for (final InventoryOption item : items) {
      item.click(position, game);
    }
    for (final ItemDropOption drop : drops) {
      drop.click(position, game);
    }
    // Update the inventory
    makeInventoryOptions(game);
  }

  public void update(final Game game) {

  }

  public void draw(final Game game) {
    final int padding = 50;
    int offset = 50;
    offset = drawTitle(game.getPlayer(), offset);
    drawItems(game.getPlayer().inventory, offset, padding);
    offset = drawPlayerInfo(game.getPlayer(), padding, offset);
    drawDrops(offset, padding);
  }

  private int drawTitle(final Actor player, final int offset) {
    textAlign(CENTER, TOP);
    textSize(FONT_LARGE);
    text(game.getPlayer().name + "'s Inventory", displayWidth / 2, offset);
    return offset + FONT_LARGE * 2;
  }

  private int drawPlayerInfo(final Actor player, final int padding, int offset) {
    textAlign(RIGHT, TOP);
    textSize(FONT_MEDIUM);

    final String[] messages = new String[] {
      "Score: " + player.getScore(),
      "Stats: " + player.getStats(),
      "Health: " + player.getHealth() + "/" + player.getMaxHealth(),
      "Level: " + player.getLevel(),
      "XP: " + player.getXP() + "/" + player.getNextXP(),
      "Speed: " + player.speed(),
      "Attack: " + player.getAttack(),
      "Defence: " + player.getDefence()
    };

    for (final String message : messages) {
      text(message, displayWidth - padding, offset);
      offset += FONT_MEDIUM * 2;
    }
    offset += FONT_MEDIUM * 2;

    return offset;
  }

  private int drawItems(final Inventory inventory, int offset, final int padding) {
    textAlign(LEFT, TOP);
    textSize(FONT_MEDIUM);

    text("Weight: " + inventory.getWeight() + "kg/" +
        inventory.maxWeight + "kg", padding, offset);
    offset += FONT_MEDIUM * 2;

    textSize(FONT_SMALL);
    text("Items marked with + are equipped.", padding, offset);
    offset += FONT_SMALL * 2;
    textSize(FONT_MEDIUM);

    for (final InventoryOption item : items) {
      item.draw(new PVector(padding, offset));
      offset += FONT_MEDIUM * 4;
    }
    return offset;
  }

  private int drawDrops(int offset, final int padding) {
    textAlign(RIGHT, TOP);
    textSize(FONT_MEDIUM);

    text("Items at this position", displayWidth - padding, offset);
    offset += FONT_MEDIUM * 2;

    for (final ItemDropOption drop : drops) {
      textAlign(RIGHT, TOP);
      drop.draw(new PVector(displayWidth - padding, offset));
      offset += FONT_MEDIUM * 4;
    }
    return offset;
  }

  public void resetTransition() {
    nextState = InventoryState.class;
  }

  private void makeInventoryOptions(final Game game) {
    // Get the inventory
    final Inventory inventory = game.getPlayer().inventory;
    // Clear the current item and drop options
    items.clear();
    drops.clear();
    // Get the equipped items
    final Set<Item> equipped = inventory.getEquipped();
    // Get the inventory items
    for (final Item item : inventory.getItems()) {
      items.add(new InventoryOption(inventory, item, equipped.contains(item)));
    }
    // Get the item drops at the current position
    final Dungeon.Point location = game.toCell(game.getPlayer().getPosition());
    for (final Item drop : game.itemsAt(location)) {
      drops.add(new ItemDropOption(inventory, drop));
    }
  }

  class InventoryOption {
    final Inventory inventory;
    final Item item;
    final boolean equipped;
    Button[] buttons = null;

    public InventoryOption(final Inventory inventory, final Item item, final boolean equipped) {
      this.inventory = inventory;
      this.item = item;
      this.equipped = equipped;
    }

    private void makeButtons(final PVector position) {
      // The buttons appear beneath the inventory entry
      final PVector buttonPos = position.get();
      buttonPos.y += FONT_MEDIUM * 2;
      // Name the buttons
      final String[] labels = new String[] {
        "drop", "equip/use", "put away"
      };
      buttons = new Button[labels.length];
      // Place them one next to the other
      int offX = 30;
      for (int i = 0; i < labels.length; ++i) {
        buttonPos.x += offX;
        buttons[i] = new Button(labels[i], buttonPos, FONT_MEDIUM);
        offX += buttons[i].getWidth() + 30;
      }
    }

    public void draw(final PVector position) {
      if (buttons == null) {
        makeButtons(position);
      }
      // Show whether it is equipped or not
      text((equipped ? " + " : " - ") + item, position.x, position.y);
      for (final Button b : buttons) {
        b.draw();
      }
    }

    public void click(final PVector pos, final Game game) {
      for (final Button b : buttons) {
        if (b == null) {
          return;
        }
        if (b.over(pos)) {
          switch(b.label) {
            case "drop":
              inventory.dropItem(item);
              game.addItemDrop(item);
              break;
            case "equip/use":
              if (item.slot == Item.Slot.USE) {
                // Apply its effect, which consumes it
                game.getPlayer().takePotion(item);
              } else {
                inventory.equipItem(item);
                // If it has a health effect, apply it
                if (item.effect == Item.Modifier.HEALTH) {
                  // Use a one-time potion
                  game.getPlayer().takePotion(
                      new Item("health item",
                        Item.Slot.USE,
                        1,
                        Item.Modifier.HEALTH,
                        item.modifier));
                }
              }
              break;
            case "put away":
              inventory.putAway(item);
              // If it had a health effect, remove it
              if (item.effect == Item.Modifier.HEALTH) {
                game.getPlayer().damage(item.modifier);
              }
              break;
          }
        }
      }
    }
  }

  class ItemDropOption {
    final Inventory inventory;
    final Item item;
    Button takeButton = null;

    public ItemDropOption(final Inventory inventory, final Item item) {
      this.inventory = inventory;
      this.item = item;
    }

    private void makeButton(final PVector position) {
      // The button appears beneath the inventory entry
      final PVector buttonPos = position.get();
      buttonPos.x -= 60;
      buttonPos.y += FONT_MEDIUM * 2;
      takeButton = new Button("take", buttonPos, FONT_MEDIUM);
    }

    public void draw(final PVector position) {
      if (takeButton == null) {
        makeButton(position);
      }
      // Show whether it is equipped or not
      text(" - " + item, position.x, position.y);
      takeButton.draw();
    }

    public void click(final PVector pos, final Game game) {
      if (takeButton != null & takeButton.over(pos)) {
        final Item item = game.takeItemDrop(this.item);
        // If the item cannot be added, drop it again
        if (!inventory.addItem(item)) {
          game.addItemDrop(item);
        }
      }
    }
  }
}
