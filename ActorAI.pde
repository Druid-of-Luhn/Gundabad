/*
 * Copyright 2017 Billy Brown
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

import java.util.LinkedList;
import java.util.Queue;

static Map<PathCacheItem, Queue<PVector>> pathCache = new HashMap<PathCacheItem, Queue<PVector>>();

class PathCacheItem {
  final public Dungeon.Point from;
  final public Dungeon.Point to;
  public PathCacheItem(final Dungeon.Point f, final Dungeon.Point t) {
    from = f;
    to = t;
  }
  @Override
  public int hashCode() {
    return from.hashCode() * to.hashCode();
  }
  @Override
  public boolean equals(Object other) {
    if (other instanceof PathCacheItem) {
      final PathCacheItem o = (PathCacheItem) other;
      return from.x == o.from.x && from.y == o.from.y &&
             to.x == o.to.x && to.y == o.to.y;
    }
    return false;
  }
}

/*
 * The AI component in an actor.
 */
class ActorAI {
  private Dungeon.Point origin = null;
  private Dungeon.Point target = null;
  public Queue<PVector> path = null;

  public void setTarget(final PVector from, final PVector to, final Dungeon dungeon) {
    origin = toCell(from);
    target = toCell(to);
    // Empty path if it doesn't move
    if (target.equals(origin)) {
      path = null;
      return;
    }
    // Check the cache first
    final PathCacheItem descriptor = new PathCacheItem(origin, target);
    path = pathCache.get(descriptor);
    if (path != null && path.size() > 0) {
      return;
    }
    // Do nothing if the target is not reachable
    if (dungeon.cellAt(target.x, target.y) == Dungeon.Cell.ROCK) {
      origin = null;
      target = null;
      return;
    }
    // Build the new path
    if (origin == null || target == null) {
      return;
    }
    // Use A* to build the path to the target
    path = new AStar().calculate(origin, target, dungeon);
    if (path != null) {
      // Make the path less grid-like
      beautifyPath(dungeon);
      // Cache the path
      final Queue<PVector> cacheItem = new LinkedList<PVector>();
      cacheItem.addAll(path);
      pathCache.put(descriptor, cacheItem);
    }
  }

  private void beautifyPath(final Dungeon dungeon) {
    // Beautify the path by making it less grid-based
    final List<PVector> path = (List<PVector>) this.path;
    int from = 0;
    int to = 1;
    while (to < path.size()) {
      // If there is a clear line between the two points
      final boolean isClear = dungeon.isClearPath(toCell(path.get(from)), toCell(path.get(to)));
      if (isClear) {
        // Check the next one
        ++to;
      }
      // Arrived at the end, or not a straight path
      if (to == path.size() || !isClear) {
        // Otherwise, remove all points up to the previous one
        for (int i = from + 1; i < to - 1; ++i) {
          if (i < path.size() - 1) {
            path.remove(i);
          }
        }
        // Move the anchor points along
        from = to - 1;
      }
    }
  }

  public Dungeon.Point toCell(final PVector position) {
    return new Dungeon.Point(
        (int) floor(position.x) / ExploreState.cellSize,
        (int) floor(position.y) / ExploreState.cellSize);
  }

  public boolean sees(final Actor from, final Actor to, final Dungeon dungeon) {
    final PVector position = from.getPosition();
    final PVector target = to.getPosition();
    final float rotation = from.getRotation();
    // If the actor is close enough
    if (position.dist(target) <= 400) {
      // Check the angle
      final PVector diff = position.get().sub(target);
      final float angle = PI - atan2(diff.y, diff.x);
      if (angle >= rotation - PI / 4 && angle <= rotation + PI / 4) {
        return true;
      }
    }
    return false;
  }
}
