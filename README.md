# Introduction
Source of my Battle for Wesnoth Campaign, Journey of a Frost Mage

# Dependencies
* [War of Legends era](https://github.com/knyghtmare/War_of_Legends)
* [WISh, the War of Legends Inventory System](https://github.com/babaissarkar/WISh)

## Weird WML Syntax

Some files in this repository use a **sugared WML syntax** for brevity.

* **Self-closing tags** like `[tag ... /]` or `[tag {MACRO} /]` are allowed.
* Special shortcuts: 
Something like `[specials slow magical]` expands to
```ini
[specials]
	{WEAPON_SPECIAL_SLOW}
	{WEAPON_SPECIAL_MAGICAL}
[/specials]
```
and something like `[abilities teleport]` exapnds to
```init
[abilities]
    {ABILITY_TELEPORT}
[/abilities]
```
This is by **macro name** and not by **macro id**, the tool doesn't read your macro!

Before Wesnoth can read them, these files must be **syntax-expanded** to standard WML. This repository includes a **expander tool** (`wml_expand.py`) that handles this conversion.

### For Contributors

* If you see `.cwml` files or unusual `/]` syntax, the **expander is involved**.
* Run the expander tool to generate valid WML:

```bash
python wml_expand.py
```

* **Original `.cwml` files are preserved**; output is written as `.cfg`.
* Always backup before testing or editing `.cwml` files.
* If you want to make use of the new syntax, be my guest! Just rename the file from `.cfg` to `.cwml` and use new syntax. That's it! If you want to use it in your repo, I'm more than happy to lend my support. Just copy the two python scripts to your Add-on root, convert files to `.cwml`, and run the `wml_expand.py` script before you run/publish your addon. (Wesnoth doesn't understand what `.cwml` is.)

This ensures that **Wesnoth-ready WML** is generated from the concise, wacky syntax used for development.


# Translation commands
From the add-ons directory :
`path/to/wmlxgettext --directory="Frost_Mage" --domain="wesnoth-Frost_Mage" -o Frost_Mage/translations/wesnoth-Frost_Mage --recursive`

Then `cd` to `Frost_Mage/translations/wesnoth-Frost_Mage` and update the po file with the new strings from the pot file :
`msgmerge -vU bn.po wesnoth-Frost_Mage.pot` (change bn.po to the correct name for your po file)
