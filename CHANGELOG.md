# **1.5.20**

### UPDATE
* Updated gear track ilvls for Season 3
* ToC update for 11.2.0 patch

<hr>

# **1.5.19**

### UPDATE
* ToC update for 11.1.7 patch

<hr>

# **1.5.18**

### UPDATE
* Turbo-Boost ILVL update
* Added Head Enchants: mouseover it for a tooltip info

<hr>

# **1.5.17**

### FIX
* Fixed Character Player and Inspect Frame LUA error

### UPDATE
* ToC update for 11.1.5 patch

<hr>

# **1.5.16**

### FIX
* Fixed "OnDoubleClick" error when using LFG to find a group for the world boss

<hr>

# **1.5.15**

### FIX
* Fixed a rare bug that displayed the assist-leader icon when converting a raid to a party group (forgot to push the change)

<hr>

# **1.5.14**

### FIX
* ~~Fixed a rare bug that displayed the assist-leader icon when converting a raid to a party group~~
* Fixed gear ilvl colors for items that aren't from the active season

### UPDATE
* Updated Season 2 gear track ilvls for the Character Player and Inspect Frame
* ToC update for 11.1.0 patch
* Removed the "NEW" label from several settings in the options

<hr>

# **1.5.13**

### FIX
* Fixed LFG searchResultInfo LUA error caused by structure changes in patch 11.0.7

### UPDATE
* ToC update for 11.0.7 patch

<hr>

# **1.5.12**

### UPDATE
* ToC update for 11.0.5 patch

<hr>

# **1.5.11**

### CHORE
* Added chat option to toggle farewell message when leaving group with "/lg".
* You can toggle this option with chat command: `/lg msg {on/off}`

<hr>

# **1.5.10**

### FIX
* Character Inspect now should show correct ilvl, enchants and gems
* Fixed nan/inf hp values on nameplates with 0hp on interactive elements(those that can use "Interact Key"), like Herbs or Ores

<hr>

# **1.5.9**

### FIX
* Showing wrong primary stat for "Crystalline Radiance" chest enchant fixed

<hr>

# **1.5.8**

### HOTFIX
* Work around INSPECT_READY event triggering 6+ times when inspecting somebody which leads to large memory usage

<hr>

# **1.5.7**

### FIX
* Fixed more rare lua errors and bugs
* Added abbreviations for new TWW enchants

<hr>

# **1.5.6**

### FIX
* Fixed some Character info lua errors

<hr>

# **1.5.5**

### UPDATE
* Character info: added TWW ilvl bonuses

<hr>

# **1.5.4**

### UPDATE
* ToC update for 11.0.2 patch

<hr>

# **1.5.3**

### FIX
* Class colored unit frames /reload bug fixed

<hr>

# **1.5.2**

### FIX
* The event "UNIT_INVENTORY_CHANGED" is triggered when changing zones, which shouldn't happen (Blizzard bug). This caused calling the same function (which updates player character info) a lot, unnecessary. Implemented a workaround solution that uses "ENCHANT_SPELL_COMPLETED" and "SOCKET_INFO_UPDATE" events

<hr>

# **1.5.1**

### \*NEW\*
#### Chat
* After copying the link from chat->popup, the popup automatically closes

<hr>

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

<hr>

# **1.4.4**

### FIX
* Fixed wrong ilvl number for low level items (from old expansions) on Player/Inspect frame

<hr>

# **1.4.3**

### UPDATE
* New Blizzard role icons in chat and LFG Tooltip
* Removed LFG group inspect for dungeons/m+ (Blizzard implemented this in 10.2.7)

<hr>

# **1.4.2**

### UPDATE
* ToC update for 10.2.7 patch

<hr>

# **1.4.1**

### FIX
* Fixed some mouseover/inspect lua errors

<hr>

# **1.4.0**

### \*NEW\*
#### Character info
* Item level on Player character frame and Inspect frame
* Gems and enchants for each equipment slot (***TODO:** I will add checkbox to toggle these. For now it will be always enabled*)
<img src="https://imgur.com/8ukM6o0.png"/>

### FIX
* Disabled HP text on friendly nameplates

<hr>

# **1.3.1**

### UPDATE
* ToC update for 10.2.6 patch

<hr>

# **1.3.0**

### \*NEW\*
#### Chat
* Chat Mouseover tooltips

<img src="https://imgur.com/BJRJBgK.png"/>

### FIX
* Fixed chat link color picker bug caused by 10.2.5 patch changes
* Fixed and improved lfg module logic

<hr>

# **1.2.2**

### UPDATE
* ToC update for 10.2.5 patch

<hr>

# **1.2.1**

### FIX
* Leader, Assist and Raid markers bug fix: Now, when you pass the leader or give somebody an assist and then change the roster, everything should work as intended

<hr>

# **1.2.0**

### \*NEW\*
#### Character Panel upgrades
* Equipped/Max item level
* Class color item level

<img src="https://imgur.com/8l41vXX.png"/>
