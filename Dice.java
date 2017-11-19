/*
 * Copyright 2017 Billy Brown
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

import java.util.Random;

class Dice {
  private static final Random gen = new Random();

  private static int roll(final int sides) {
    return gen.nextInt(sides) + 1;
  }

  public static int D3() {
    return roll(3);
  }

  public static int D4() {
    return roll(4);
  }

  public static int D6() {
    return roll(6);
  }

  public static int D8() {
    return roll(8);
  }

  public static int D10() {
    return roll(10);
  }

  public static int D12() {
    return roll(12);
  }

  public static int D20() {
    return roll(20);
  }

  public static int D100() {
    return roll(100);
  }
}
