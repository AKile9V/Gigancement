# **1.5.3**

### FIX
* Class colored unit frames /relaod bug fixed



# **1.5.2**

### FIX
* The event "UNIT_INVENTORY_CHANGED" is triggered when changing zones, which shouldn't happen (Blizzard bug). This caused calling the same function (which updates player character info) a lot, unnecessary. Implemented a workaround solution that uses "ENCHANT_SPELL_COMPLETED" and "SOCKET_INFO_UPDATE" events



# **1.5.1**

### \*NEW\*
#### Chat
* After copying the link from chat->popup, the popup automatically closes



# **1.5.0**

### Overall
* Improved, optimized and revamped the code. Now it is more efficient, the addon doesn't track events that the user disabled in the addon option
* A lot of new things are implemented and changed, maybe some things won't work as expected, but I'll give my best to fix all the bugs when I get access to the prepatch
* All the new features are displayed on the Curseforge page of the addon [Gigancement](https://www.curseforge.com/wow/addons/gigancement)

### Character info
* Revamped and refactored a lot of code, many things are optimized
* A new way to display gems (similar to WoW:Remix)
* You can now toggle settings if you want to disable gems/enchants/item level
### Chat
* **NEW:** You can enter /kb in chat to instantly open Quick Keybind Mode
* Fixed bugs caused by new TWW API changes
* /lg now sends the goodbye message to the /party and you leave the party after a few seconds
* Changed the role icons for chat to the new Blizzard TWW textures
### LFG
* **NEW:** Show applicant race in LFG Tooltip under the name of the applicant
* **NEW:** Sort applicants by their M+ score
* Group inspect is disabled for M+ groups in the Group Finder because Blizzard implemented this feature, but it is still enabled for any other type of group like Raids, Custom Groups, Quest Groups, Delves
* Added option for auto accepting the role check popup when a party leader is applying your group to a Raid/M+ group and skip the note popup (this means you can go AFK while your group leader is applying you to the groups). If you want to sign up with a note, hold Shift when signing up
### Nameplates
* **NEW:** Added option to toggle HP text on friendly nameplates
* **NEW:** Added option to choose the format of HP text: Numeric Value, Percentage or Both
* The code has improved by a lot for displaying HP text on enemy nameplates. Now it barely uses any CPU/memory resources
### UI
* **NEW:** Added option to choose where you want to position castbar timer: Left, Center, Right
* Fixed bugs caused by new TWW API changes
* Optimized the way of coloring Player/Target/Focus/Pet frames
* Changed the leader/assist icons for Raid frames to the new Blizzard TWW textures



# **1.4.4**

### FIX
* Fixed wrong ilvl number for low level items (from old expansions) on Player/Inspect frame



# **1.4.3**

### UPDATE
* New Blizzard role icons in chat and LFG Tooltip
* Removed LFG group inspect for dungeons/m+ (Blizzard implemented this in 10.2.7)



# **1.4.2**

### UPDATE
* ToC update for 10.2.7 patch



# **1.4.1**

### FIX
* Fixed some mouseover/inspect lua errors



# **1.4.0**

### \*NEW\*
#### Character info
* Item level on Player character frame and Inspect frame
* Gems and enchants for each equipment slot (***TODO:** I will add checkbox to toggle these. For now it will be always enabled*)
<img src="https://imgur.com/8ukM6o0.png"/>

### FIX
* Disabled HP text on friendly nameplates



# **1.3.1**

### UPDATE
* ToC update for 10.2.6 patch



# **1.3.0**

### \*NEW\*
#### Chat
* Chat Mouseover tooltips

<img src="https://imgur.com/BJRJBgK.png"/>

### FIX
* Fixed chat link color picker bug caused by 10.2.5 patch changes
* Fixed and improved lfg module logic



# **1.2.2**

### UPDATE
* ToC update for 10.2.5 patch



# **1.2.1**

### FIX
* Leader, Assist and Raid markers bug fix: Now, when you pass the leader or give somebody an assist and then change the roster, everything should work as intended



# **1.2.0**

### \*NEW\*
#### Character Panel upgrades
* Equipped/Max item level
* Class color item level

<img src="https://imgur.com/8l41vXX.png"/>
