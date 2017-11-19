/*
 * Copyright 2017 Billy Brown
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

class Button {
  public static final float PADDING = FONT_MEDIUM / 3;
  public String label;
  private final PVector position;
  private final int fontSize;
  private float width = 0;
  private float height = 0;

  public Button(final String label, final PVector position, final int fontSize) {
    this.label = label;
    this.position = position.get();
    this.fontSize = fontSize;
  }

  private void setDimensions() {
    textSize(fontSize);
    width = textWidth(label) + 2 * PADDING;
    height = fontSize + 2 * PADDING;
  }

  public void draw() {
    textAlign(LEFT, TOP);
    textSize(fontSize);

    // Get the dimensions
    if (width == 0 && height == 0) {
      setDimensions();
    }

    // Button background
    fill(over(mouseX, mouseY) ? 255 : 200);
    rect(position.x, position.y, width, height);

    // Button text
    fill(0);
    text(label, position.x + PADDING, position.y + PADDING);
    fill(255);
  }

  public boolean over(final float x, final float y) {
    return over(new PVector(x, y));
  }

  public boolean over(final PVector point) {
    // Get the dimensions
    if (width == 0 && height == 0) {
      setDimensions();
    }
    return
      point.x >= position.x && point.x <= position.x + width &&
      point.y >= position.y && point.y <= position.y + height;
  }

  public float getWidth() {
    if (width == 0) {
      setDimensions();
    }
    return width;
  }

  public float getHeight() {
    if (height == 0) {
      setDimensions();
    }
    return height;
  }
}
