/*
 * Copyright 2017 Billy Brown
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

import java.util.HashSet;
import java.util.LinkedList;
import java.util.Queue;
import java.util.Set;
import java.util.SortedSet;
import java.util.Stack;
import java.util.TreeSet;

class AStar {
  private class State implements Comparable<State> {
    public int score;
    public Stack<Dungeon.Point> path;

    public State(final int score, final Stack<Dungeon.Point> path) {
      this.score = score;
      this.path = path;
    }

    public int compareTo(State other) {
      // Sort by score
      final int scoreDiff = score - other.score;
      if (scoreDiff == 0) {
        // Then by path length
        final int lengthDiff = path.size() - other.path.size();
        if (lengthDiff == 0) {
          if (path.equals(other.path)) {
            return 0;
          }
          // Left-biased
          return -1;
        }
        return lengthDiff;
      }
      return scoreDiff;
    }
  }

  final SortedSet<State> states = new TreeSet<State>();
  final Set<Dungeon.Point> visited = new HashSet<Dungeon.Point>();

  public Queue<PVector> calculate(final Dungeon.Point start, final Dungeon.Point end, final Dungeon dungeon) {
    // Start the search
    State current = new State(0, new Stack<Dungeon.Point>());
    current.path.push(start);
    // Keep searching until the target is found
    while (true) {
      final Dungeon.Point pos = current.path.peek();
      // Set the current path end as visited
      visited.add(pos);
      // Can move in the compass directions
      final Dungeon.Point[] directions = new Dungeon.Point[] {
        new Dungeon.Point(pos.x, pos.y - 1),
        new Dungeon.Point(pos.x + 1, pos.y),
        new Dungeon.Point(pos.x, pos.y + 1),
        new Dungeon.Point(pos.x - 1, pos.y)
      };
      for (final Dungeon.Point dir : directions) {
        // If this direction is possible and unvisited
        if (dungeon.cellAt(dir.x, dir.y) != Dungeon.Cell.ROCK && !visited.contains(dir)) {
          // Calculate its cost
          final int cost = current.score + heuristic(dir, end) + 1;
          // Build its path
          final Stack<Dungeon.Point> path = (Stack<Dungeon.Point>) current.path.clone();
          path.push(dir);
          // Make a state of it and add it to the frontier
          final State next = new State(cost, path);
          states.add(next);
          // Finish when we found it
          if (dir.equals(end)) {
            return pathToQueue(path);
          }
        }
      }
      if (states.isEmpty()) {
        return new LinkedList<PVector>();
      }
      // Move to the next state
      current = states.first();
      states.remove(current);
    }
  }

  private Queue<PVector> pathToQueue(final Stack<Dungeon.Point> path) {
    final Queue<PVector> result = new LinkedList<PVector>();
    for (final Dungeon.Point point : path) {
      result.add(new PVector(
            point.x * ExploreState.cellSize + ExploreState.cellSize / 2,
            point.y * ExploreState.cellSize + ExploreState.cellSize / 2
            ));
    }
    return result;
  }

  private int heuristic(final Dungeon.Point point, final Dungeon.Point target) {
    // Use the Manhattan Block Distance calculation
    return Math.abs(target.x - point.x) + Math.abs(target.y - point.y);
  }
}
