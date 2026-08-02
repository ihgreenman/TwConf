# TwConf

This is a utility written by me several years ago. It's designed to manipulate configuration files for the
[Twiddler](https://www.mytwiddler.com/) one handed chording keyboard. It allows you to easily transform the
configuration between binary, json, and CSV formats. It currently supports only the V5 version of the file format
as later versions are not currently publicly documented.

While there exists an online tool for use with generating the configuration files, I found it tedious to use for
anything other than minor tweaks. This tool is the result of wanting to completely remap the keyboard.

## The Problem

The Twiddler is a keyboard. It works by transforming chords (combined keypresses) into HID codes. You can re-map the
chords to different HID codes and even multiple characters (HID codes).

Therein lies the problem. Keyboards translate key presses to HID codes and then those HID codes are translated by the
computer into the final input. If you are not using QWERTY, this is a problem.

In addition, if you want to increase your keying speed by having the most commonly used letters with the easiest
chords, then you are again completely transforming what needs to be placed where.

## The Solution

I created this script to solve both problems.

In the forward direction, it takes the text description of the desired keypress and uses the keyboard mapping to turn
those into the appropriate HID keycodes and attaches those to the proper chord.

In the reverse direction, it takes the HID keycodes and chords in the binary file and uses the keyboard mapping to turn
the HID codes to a text description of the HID codes.

You can change the desired HID codes by editing the CSV or JSON. You can convert the device to using different keyboard
mappings by, for example, loading using the QWERTY keymap and saving in the Dvorak keymap.

## Technical details

The file format can be found [here](https://www.mytwiddler.com/doc/doku.php?id=twiddler_config_format).

When creating a new keymap, it is often easiest to start with an existing binary keymap. This gives you
an idea of the possible configurations and also your current settings for the options. The script makes an
attempt to provide sane defaults, but you will probably want to customize them for your use.

You should consult the documentation if you want an explanation of the various options.

#### Twiddler Keys Side (As labeled)

|       | Left    | Middle  | Right   |
|-------|---------|---------|---------|
| Row 0 | Mouse L | Mouse M | Mouse R |
| Row 1 | SP      | E       | A       |
| Row 2 | Del     | F       | B       |
| Row 3 | BS      | G       | C       |
| Row 4 | ENT     | H       | D       |

#### Twiddler Keys Top, from Left to Right (As labeled)

| L   | ML  | M         | MR   | R     |
|-----|-----|-----------|------|-------|
|     |     | Joystick  |      |       |
| Num |     |           |      | Shift |
|     | Alt |           | Ctrl |       |

#### Notes

* Strings or clicks can be assigned to the three mouse keys, but they can't be part of a chord
* The joystick doubles as either a left or a right click (can be configured to either)

## Key names (as mapped to)

#### Modifiers

| Name        | Escaped    | Alternate(s)                       |
|-------------|------------|-------------------------------------|
| Left Ctrl   | `<LCtrl>`  | `<Ctrl>`                            |
| Left Shift  | `<LShift>` |                                      |
| Left Alt    | `<LAlt>`   | `<Alt>`, `<LOpt>`, `<LOption>`      |
| Left GUI    | `<LGUI>`   | `<LMeta>`, `<LCommand>`, `<Meta>`   |
| Right Ctrl  | `<RCtrl>`  |                                      |
| Right Shift | `<RShift>` | `<Shift>`                           |
| Right Alt   | `<RAlt>`   | `<ROpt>`, `<ROption>`               |
| Right GUI   | `<RGUI>`   | `<RMeta>`, `<RCommand>`             |

#### Notes
* The "GUI" key is referred to as "Win" key on Windows keyboards and "Command" on Mac keyboards
* The "Alt" key is referred to as "Option" on Mac keyboards
* The escaped names are case-insensitive

A chord result can be either a modifier + character (e.g. `<LCtrl>a`) or a plain character string.

## Special keys

| Description       | HID Code | Escaped         |
|-------------------|----------|-----------------|
| Return            | 40       | `<Return>`      |
| Escape            | 41       | `<Escape>`      |
| Backspace         | 42       | `<Backspace>`   |
| Tab               | 43       | `<Tab>`         |
| Caps Lock         | 57       | `<CapsLock>`    |
| F1                | 58       | `<F1>`          |
| F2                | 59       | `<F2>`          |
| F3                | 60       | `<F3>`          |
| F4                | 61       | `<F4>`          |
| F5                | 62       | `<F5>`          |
| F6                | 63       | `<F6>`          |
| F7                | 64       | `<F7>`          |
| F8                | 65       | `<F8>`          |
| F9                | 66       | `<F9>`          |
| F10               | 67       | `<F10>`         |
| F11               | 68       | `<F11>`         |
| F12               | 69       | `<F12>`         |
| Print Screen      | 70       | `<PrintScreen>` |
| Scroll Lock       | 71       | `<ScrollLock>`  |
| Pause             | 72       | `<Pause>`       |
| Insert            | 73       | `<Insert>`      |
| Home              | 74       | `<Home>`        |
| Page Up           | 75       | `<PageUp>`      |
| Delete (Forward)  | 76       | `<Delete>`      |
| End               | 77       | `<End>`         |
| Page Down         | 78       | `<PageDown>`    |
| Right Arrow       | 79       | `<RightArrow>`  |
| Left Arrow        | 80       | `<LeftArrow>`   |
| Down Arrow        | 81       | `<DownArrow>`   |
| Up Arrow          | 82       | `<UpArrow>`     |
| NumLock           | 83       | `<NumLock>`     |
| Key Pad /         | 84       | `<KP/>`         |
| Key Pad *         | 85       | `<KP*>`         |
| Key Pad -         | 86       | `<KP->`         |
| Key Pad +         | 87       | `<KP+>`         |
| Key Pad Enter     | 88       | `<KPEnter>`     |
| Key Pad 1         | 89       | `<KP1>`         |
| Key Pad 2         | 90       | `<KP2>`         |
| Key Pad 3         | 91       | `<KP3>`         |
| Key Pad 4         | 92       | `<KP4>`         |
| Key Pad 5         | 93       | `<KP5>`         |
| Key Pad 6         | 94       | `<KP6>`         |
| Key Pad 7         | 95       | `<KP7>`         |
| Key Pad 8         | 96       | `<KP8>`         |
| Key Pad 9         | 97       | `<KP9>`         |
| Key Pad 0         | 98       | `<KP0>`         |
| Key Pad .         | 99       | `<KP.>`         |
| Application       | 101      | `<Application>` |
| Power             | 102      | `<Power>`       |
| Key Pad =         | 103      | `<KP=>`         |
| F13               | 104      | `<F13>`         |
| F14               | 105      | `<F14>`         |
| F15               | 106      | `<F15>`         |
| F16               | 107      | `<F16>`         |
| F17               | 108      | `<F17>`         |
| F18               | 109      | `<F18>`         |
| F19               | 110      | `<F19>`         |
| F20               | 111      | `<F20>`         |
| F21               | 112      | `<F21>`         |
| F22               | 113      | `<F22>`         |
| F23               | 114      | `<F23>`         |
| F24               | 115      | `<F24>`         |

Example JSON file:

```json
{
    "comment": "Top-level 'comment' keys are ignored",

    "header": {
        "version": 5,
        "enableKeyRepeat": true,
        "enableDirectKeyMode": false,
        "joystickMouseClick": true,
        "disableBluetooth": true,
        "enableStickNumKey": false,
        "enableStickShiftKey": false,
        "sleepTimeout": 1500,
        "leftClick": null,
        "middleClick": null,
        "rightClick": null,
        "mouseAcceleration": 10,
        "keyRepeatDelay": 100,
        "hapticFeedbackEnable": false
    },
    "chords": {
        "A B": "<LCtrl>a",
        "C": "A test",
        "D": "<Return>"
    }
}
```

Each key under `header` corresponds directly to an attribute of `TwidV5::Header` (see `lib/TwidV5.rb`). `leftClick`/`middleClick`/`rightClick` are `null` to fall back to a plain mouse click, or a chord string (like the `chords` values) to remap that mouse button to a keystroke.

Each key under `chords` is a chord (see `lib/Chord.rb` for the chord naming syntax) mapped to either a plain character string or an escaped key name from the tables above.
