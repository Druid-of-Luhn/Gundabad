/*
 * Copyright 2017 Billy Brown
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

class Game {
  private Actor player;
  public int dungeonLevel;
  public Actor opponent;
  private List<Actor> actors = new LinkedList<Actor>();
  private Map<Dungeon.Point, List<Item>> itemDrops = new HashMap<Dungeon.Point, List<Item>>();

  public Game() {
    reset();
  }

  public void reset() {
    player = null;
    dungeonLevel = 0;
    actors.clear();
    itemDrops.clear();
    opponent = null;
  }

  public void drawActors(final PVector offset) {
    for (final Actor actor : actors) {
      actor.draw(offset);
    }
  }

  public void addActor(final Actor actor) {
    actors.add(actor);
  }

  public void removeActor(final Actor actor) {
    actors.remove(actor);
  }

  public void addItemDrop(final Item item) {
    addItemDrop(item, toCell(player.getPosition()));
  }

  public void addItemDrop(final Item item, final Dungeon.Point point) {
    // Fetch the items for the given location
    List<Item> items = itemDrops.get(point);
    if (items == null) {
      // Create the list and associate it if there are none
      items = new LinkedList<Item>();
      itemDrops.put(point, items);
    }
    // Add the item to the list for the given location
    items.add(item);
  }

  public Item takeItemDrop(final Item item) {
    return takeItemDrop(item, toCell(player.getPosition()));
  }

  public Item takeItemDrop(final Item item, final Dungeon.Point point) {
    List<Item> items = itemDrops.get(point);
    if (items != null) {
      items.remove(item);
    }
    return item;
  }

  public List<Item> itemsAt(final Dungeon.Point point) {
    List<Item> items = itemDrops.get(point);
    if (items == null) {
      // Return an empty list instead of null
      items = new LinkedList<Item>();
    }
    return items;
  }

  public void setPlayer(final Actor player) {
    if (this.player == null) {
      this.player = player;
      actors.add(player);
    }
  }

  public Actor getPlayer() {
    return player;
  }

  public List<Actor> getActors() {
    return actors;
  }

  public Dungeon.Point toCell(final PVector position) {
    return new Dungeon.Point(
        (int) floor(position.x) / ExploreState.cellSize,
        (int) floor(position.y) / ExploreState.cellSize);
  }

  public PVector toCoord(final Dungeon.Point point) {
    return new PVector(
        point.x * ExploreState.cellSize + ExploreState.cellSize / 2,
        point.y * ExploreState.cellSize + ExploreState.cellSize / 2);
  }
}
