![Icon](icon.png)
# ``RVS_RetroLEDDisplay``

Simple, Classic, Customizable Digital Display.

## Overview

This is a UIKit widget that displays a "classic" LED display (seven-segmented, simple digitital display). It does this by displaying a customizable background through a mask that simulates the "look and feel" of an old-fashioned LED display.

### Customizable

The widget subclasses [`UIImageView`](https://developer.apple.com/documentation/uikit/uiimageview), with the [`image`](https://developer.apple.com/documentation/uikit/uiimageview/1621069-image) property being applied to the "off" segments of the display.

You can also supply an image for the "on" segments of the display.

If you do not supply an image, then you can specify colors (including a gradient), to be used behind the display.

The "on" and "off" backgrounds are independent of each other. You could, for example, have a gradient for the "off" segments, and an image for the "on" segments.

It can also have a "skew" applied, that gives it the classic "lean" of LED digital displays.

## Legal

[Attribution usage required for Paisley Patterns, by ilonitta](https://www.freepik.com/free-vector/paisley-pattern-set_8565932.htm)

These patterns are only used in the [Test Harness](), and no attribution is required for use of the package.

### MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,
modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
