/*
 * Copyright 2017 Billy Brown
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

import java.util.HashSet;
import java.util.Set;
import java.util.Random;

class Dungeon {
  public static enum Cell {
    GROUND, ROCK
  }

  public static class Point {
    public final int x;
    public final int y;
    public Point(final int x, final int y) {
      this.x = x;
      this.y = y;
    }
    @Override
    public boolean equals(final Object point) {
      if (point instanceof Point) {
        return ((Point) point).x == x && ((Point) point).y == y;
      }
      return false;
    }
    @Override
    public int hashCode() {
      // Source: http://stackoverflow.com/questions/682438/hash-function-providing-unique-uint-from-an-integer-coordinate-pair
      return (x * 0x0f0f0f0f) ^ y;
    }
  }

  private final Random rand = new Random();
  private static final int STRENGTH = 10;

  public final int width;
  public final int height;
  // Represent the map as a 2D array of cells
  private final Cell[][] cells;
  // Set start and end points
  public final Point entry;
  public final Point exit;

  public Dungeon(final int w, final int h) {
    width = w;
    height = h;
    // Place the entrance and the exit, always far from each other
    entry = new Point(
        rand.nextInt(width / 4),
        rand.nextInt(height / 4));
    exit = new Point(
        width - 1 - rand.nextInt(width / 4),
        height - 1 - rand.nextInt(height / 4));
    // Generate the dungeon's cells
    cells = generate();
  }

  private Cell[][] generate() {
    // Fill the dungeon with rock
    final Cell[][] cells = new Cell[width][height];
    fillCells(cells, Cell.ROCK);
    // Perform a biased random walk from the entry to the exit
    final Set<Point> walk = randomWalk(entry, exit);
    // Set the ground cells from the walk
    for (final Point cell : walk) {
      if (inBounds(cell)) {
        cells[cell.x][cell.y] = Cell.GROUND;
      }
    }
    return cells;
  }

  private Set<Point> randomWalk(final Point in, final Point out) {
    final Set<Point> walk = new HashSet<Point>();
    Point next = new Point(in.x, in.y);
    walk.add(next);
    // Loop until the path has been made
    while (next.x != out.x || next.y != out.y) {
      // Might make a biased step
      if (rand.nextInt(STRENGTH) == 0) {
        // Make a step towards the end
        next = biasedStep(next, out);
      } else {
        // Make a random step
        next = randomStep(next);
      }
      // Add the point to the path
      walk.add(next);
    }
    return walk;
  }

  private Point biasedStep(final Point from, final Point target) {
    Point to;
    // What's the difference between the two?
    final int diffX = target.x - from.x;
    final int diffY = target.y - from.y;
    // Step randomly in the x or y direction, towards the target
    if (diffY == 0 || (diffX != 0 && rand.nextBoolean())) {
      to = new Point(diffX > 0 ? from.x + 1 : from.x - 1, from.y);
    } else {
      to = new Point(from.x, diffY > 0 ? from.y + 1 : from.y - 1);
    }
    return to;
  }

  private Point randomStep(final Point from) {
    Point to = new Point(from.x, from.y);
    do {
      switch(rand.nextInt(4)) {
        case 0: // NORTH
          to = new Point(from.x, from.y - 1);
          break;
        case 1: // EAST
          to = new Point(from.x + 1, from.y);
          break;
        case 2: // SOUTH
          to = new Point(from.x, from.y + 1);
          break;
        case 3: // WEST
          to = new Point(from.x - 1, from.y);
          break;
      }
    } while (!inBounds(to));
    return to;
  }

  private boolean inBounds(final Point point) {
    return
      point.x >= 0 && point.x < width &&
      point.y >= 0 && point.y < height;
  }

  public Cell cellAt(final int x, final int y) {
    if (inBounds(new Point(x, y))) {
      return cells[x][y];
    }
    return Cell.ROCK;
  }

  private static void fillCells(final Cell[][] cells, final Cell type) {
    for (int x = 0; x < cells.length; ++x) {
      for (int y = 0; y < cells[x].length; ++y) {
        cells[x][y] = type;
      }
    }
  }

  public static int distance(final Point from, final Point to) {
    return (int) Math.sqrt(
      Math.pow(from.x - to.x, 2) +
      Math.pow(from.y - to.y, 2));
  }

  // Is the straight line path between from and to clear?
  public boolean isClearPath(final Point start, final Point end) {
    // Vertical special case
    if (start.y == end.y) {
      for (int y = Math.min(start.y, end.y); y < Math.max(start.y, end.y); ++y) {
        if (cellAt(end.x, y) == Cell.ROCK) {
          return false;
        }
      }
      return true;
    }
    // Use Bresenham's line algorithm
    // Source: https://en.wikipedia.org/wiki/Bresenham%27s_line_algorithm
    final int dx = start.x - end.x;
    final int dy = start.y - end.y;
    final float derr = Math.abs((float) dy / (float) dx);
    float err = -1;
    int y = Math.min(start.x, end.x) == start.x ? start.y : end.x;
    for (int x = Math.min(start.x, end.x); x < Math.max(start.x, end.x) - 1; ++x) {
      if (cellAt(x, y) == Cell.ROCK) {
        return false;
      }
      err += derr;
      if (err >= 0) {
        y += Math.min(start.y, end.y) == start.y ? 1 : -1;
        --err;
      }
    }
    return true;
  }
}
