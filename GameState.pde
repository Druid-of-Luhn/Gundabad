/*
 * Copyright 2017 Billy Brown
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

abstract class GameState {
  Class<? extends GameState> nextState;

  public GameState() {
    resetTransition();
  }

  public abstract void onEnter(final Game game);

  public abstract void input(final Game game, final char key);

  public abstract void click(final Game game, final PVector position);

  public abstract void update(final Game game);

  public abstract void draw(final Game game);

  public boolean willTransition() {
    return !nextState.isInstance(this);
  }

  public Class<? extends GameState> transition() {
    return nextState;
  }

  public abstract void resetTransition();
}
