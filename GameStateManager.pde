/*
 * Copyright 2017 Billy Brown
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

class GameStateManager {
  // The different game states
  private GameState[] states;
  // The current game state index
  private int state = 0;

  public GameStateManager(final GameState[] states) {
    this.states = states;
  }

  public void input(final Game game, final char key) {
    // Pass the game and input on to the current state
    states[state].input(game, key);
  }

  public void click(final Game game, final PVector position) {
    // Pass the game and location on to the current state
    states[state].click(game, position);
  }

  public void update(final Game game) {
    // The state may transition
    testTransition(game);
    // Pass the game on to the current state
    states[state].update(game);
  }

  public void draw(final Game game) {
    // Pass the game on to the current state
    states[state].draw(game);
  }

  private void testTransition(final Game game) {
    // Test whether the current state is transitioning
    if (states[state].willTransition()) {
      // Transition to the next state
      setState(states[state].transition());
      // Tell the new state it has been entered
      states[state].onEnter(game);
    }
  }

  private void setState(final Class<? extends GameState> nextState) {
    for (int i = 0; i < states.length; ++i) {
      // Determine whether states[i] is an instance of the nextState class
      if (nextState.isInstance(states[i])) {
        // Reset the current state's transition
        states[state].resetTransition();
        // Set the current state
        state = i;
        return;
      }
    }
    throw new java.util.NoSuchElementException("state not found");
  }
}
