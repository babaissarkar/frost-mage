# Journey of a Frost Mage

A Battle for Wesnoth campaign. This repository contains the campaign source files, including unit definitions, scenarios, and translations.

## Dependencies

* [War of Legends era](https://github.com/knyghtmare/War_of_Legends)
* [WISh, the War of Legends Inventory System](https://github.com/babaissarkar/WISh)

---

## For Contributors: the CWML syntax

Some files in this repository use the `.cwml` extension instead of `.cfg`. These are written in a **compact, shorthand version of WML** that gets automatically converted to standard `.cfg` files by the included `wml_expand.py` tool. Wesnoth itself only reads the generated `.cfg` files — it does not understand `.cwml` directly.

If you see a `.cwml` file, don't edit the corresponding `.cfg` by hand. Edit the `.cwml` and regenerate.

### Running the expander

From the repository root:

```bash
python wml_expand.py
```

This walks the directory tree, finds all `.cwml` files, and writes a corresponding `.cfg` next to each one. The original `.cwml` is preserved.

To run the built-in tests:

```bash
python wml_expand.py test
```

---

### What the shorthand looks like

#### Self-closing tags

Instead of:
```ini
[resistance]
    arcane=90
[/resistance]
```

You can write:
```ini
[resistance arcane=90 /]
```

Any attributes you put inside the tag are expanded onto their own lines automatically.

---

#### Brace-block syntax

Instead of:
```ini
[attack]
    name=staff
    damage=5
    number=3
[/attack]
```

You can write:
```ini
attack [
    name=staff
    damage=5
    number=3
]
```

The closing `]` must be at the same indentation level as the opening line.

---

#### Specials and abilities shorthand

Instead of:
```ini
[specials]
    {WEAPON_SPECIAL_SLOW}
    {WEAPON_SPECIAL_MAGICAL}
[/specials]
```

You can write:
```ini
[specials slow magical]
```

The same works for abilities:
```ini
[abilities leadership]
```

The macro names are inferred from the tokens (`slow` → `{WEAPON_SPECIAL_SLOW}`, `leadership` → `{ABILITY_LEADERSHIP}`). The tool does **not** read your macro definitions — the naming convention must match.

---

#### Dot notation for nested sub-tags

Some tags contain a sub-tag purely to hold a filter value, like:

```ini
[attack_anim]
    [filter_attack]
        name=staff
    [/filter_attack]
    ...
[/attack_anim]
```

You can collapse the sub-tag onto the opening line using dot notation:

```ini
[attack_anim filter_attack.name=staff]
```

This works with quoted values too:

```ini
[attack_anim filter_attack.name="natural essence"]
```

---

#### Quoted values

Values containing spaces must be quoted, or the expander will misread them:

```ini
[event name="village attacked" first_time_only=no /]
```

> **Note:** `[event name=village attacked first_time_only=no /]` will not work — quote any value that contains a space.

Values without spaces do not need quotes and will be left as-is.

---

### Quick reference

| Shorthand | Expands to |
|---|---|
| `[tag key=val /]` | `[tag]\n    key=val\n[/tag]` |
| `tag [` ... `]` | `[tag]` ... `[/tag]` |
| `[specials slow]` | `[specials]\n    {WEAPON_SPECIAL_SLOW}\n[/specials]` |
| `[abilities teleport]` | `[abilities]\n    {ABILITY_TELEPORT}\n[/abilities]` |
| `[tag sub.key=val]` | `[tag]\n    [sub]\n        key=val\n    [/sub]` |

---

## Translation

From the add-ons directory:

```bash
path/to/wmlxgettext --directory="Frost_Mage" --domain="wesnoth-Frost_Mage" -o Frost_Mage/translations/wesnoth-Frost_Mage --recursive
```

Then `cd` into `Frost_Mage/translations/wesnoth-Frost_Mage` and update the `.po` file with new strings from the `.pot` file:

```bash
msgmerge -vU bn.po wesnoth-Frost_Mage.pot
```

Replace `bn.po` with the correct filename for your language.
