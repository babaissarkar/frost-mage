# Introduction
Source of my Battle for Wesnoth Campaign, Journey of a Frost Mage


# Translation commands
From the add-ons directory :
`path/to/wmlxgettext --directory="Frost_Mage" --domain="wesnoth-Frost_Mage" -o Frost_Mage/translations/wesnoth-Frost_Mage --recursive`

Then `cd` to `Frost_Mage/translations/wesnoth-Frost_Mage` and update the po file with the new strings from the pot file :
`msgmerge -vU bn.po wesnoth-Frost_Mage.pot` (change bn.po to the correct name for your po file)
