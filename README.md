# Introduction
Source of my Battle for Wesnoth Campaign, Journey of a Frost Mage

# Dependencies
* [War of Legends era](https://github.com/knyghtmare/War_of_Legends)
* [WISh, the War of Legends Inventory System](https://github.com/babaissarkar/WISh)

## Weird WML Syntax (CWML files)


Some files in this repository use a **sugared WML syntax** for brevity.


### Basic syntax


* **Self-closing tags** like `[tag ... /]` or `[tag {MACRO} /]` are allowed.
* **Inline expansion**: content after the tag name is split and placed on separate lines.


#### Special shortcuts


- `[specials slow magical]` expands to:

```ini
  [specials]
      {WEAPON_SPECIAL_SLOW}
      {WEAPON_SPECIAL_MAGICAL}
  [/specials]
```

  - `[abilities teleport]` expands to:

```ini
  [abilities]
      {ABILITY_TELEPORT}
  [/abilities]
```


*Note: Macro names are inferred from the token (e.g., `slow` → `{WEAPON_SPECIAL_SLOW}`). The tool does *not** read your macro definitions.


### Advanced syntax (new!)


The expander now supports **quoted arguments** and **nested subtags** using dot notation.


##### Quoted arguments with spaces


Uses `shlex` parsing -- any shell-quoted string is preserved:

`[event name="my event" first_time_only=no /]`

Expands to:

```inip
[event]
    name="my event"
    first_time_only=no
[/event]
```

> [!WARNING]
> `[event name=my event first_time_only=no /]` would not work without the quotes!

##### Dot notation for nested subtags


Write `subtag.key=value` outside a tag to generate a nested structure:

`[filter location.radius=2 location.x=10-20 /]`

Expands to:

```inip
[filter]
    [location]
        radius=2
        x=10-20
    [/location]
[/filter]
```

You can mix direct attributes and nested subtags in one line.


##### Automatic attribute quoting


If a value contains a space, the expander automatically quotes it (e.g., `key="value with spaces``). Otherwise, it remains unquoted.


##### Always-closed tags


`[specials]` and `[abilities]` are **always closed** ( `[/specials]`, `[/abilities]` ), even if you omit the trailing `/`.


### For Contributors


* If you see `.cwml` files or the `/]` self-closing syntax, the **expander is involved**.
* Run the expander tool from repo root to generate valid WML:

  ```bash
  python wml_expand.py
  ```

  This recursively finds any cwml file and generates the cfg file from it. Original `.cwml` files are preserved.

* Always backup before testing or editing `.cwml` files.

* To use this syntax in your own add-on:
  <br/>
  1. Copy `wml_expand.py` to your add-on root.
  2. Rename your `.cfg` files to `.cwml`.
  3. Edit them using the sugared syntax.
  4. Run `wml_expand.py` on each `.cwml` file (or write a batch script) before releasing or testing.
  5. Wesnoth will read the generated `.cfg` files (it does not understand `.cwml`).

The expander noww preserves trailing newlines, handles complex arguments robustly, and supports nested structures -- making WML authoring even more concise.

# Translation commands
From the add-ons directory :
`path/to/wmlxgettext --directory="Frost_Mage" --domain="wesnoth-Frost_Mage" -o Frost_Mage/translations/wesnoth-Frost_Mage --recursive`

Then `cd` to `Frost_Mage/translations/wesnoth-Frost_Mage` and update the po file with the new strings from the pot file :
`msgmerge -vU bn.po wesnoth-Frost_Mage.pot` (change bn.po to the correct name for your po file)
