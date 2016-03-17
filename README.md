# libini
A Lua library to read and write INI files
## License:
Please read the LICENSE file.
Also, the file class.lua comes from lua-users.org: http://lua-users.org/wiki/SimpleLuaClasses
## Installation:
Simply copy the content of this repo in order to have both libini.lua and class.lua next to yout lua script
## Usage:
I recommend you read the wikipedia page about INI files, in order to understand what sections and keys correspond to in a ini file. https://en.wikipedia.org/wiki/INI_file
- First, add `require "libini"` to your script
- Then create a Ini object using `yourIni = Ini("pathToYourIni")`
- Load it: `yourIni:Load()` (you will need it to read anything from the ini file)
- Get the value of some keys! `value = yourIni:GetKey("aSection","aKey")`
## List of all the fuctions:
### `Ini(path)`
Returns an Ini object, linked to the ini file located at `path`.
### `Ini:Load()`
Loads an Ini object. You will need it for most of this functions of this library.
### `Ini:GetKey(sectionName,keyName)`
Returns the value of the key `keyName` inside section `sectionName`.
### `Ini:SetKey(sectionName,keyName,value)`
Change the value of the key `keyName` inside of `sectionName`.
### `Ini:AddKey(sectionName,keyName,value)`
Add the key `keyName` with the value `value` inside of the section `sectionName`.
### `Ini:AddSection(sectionName)`
Add a new section to an Ini object with the name `sectionName`.
### `Ini:Save(header)`
Saves the Ini file at the original path with `header` as the first line comment.
### `Ini:SaveAs(filename,header)`
Saves the Ini file at the path `filename` with `header` as the first line comment.
### `Ini:__tostring()`
Returns a string containing the path of the ini file and if it is loaded or not.
### `Ini:__findSection(sectionName)`
Returns the index of the section `sectionName` inside of `self.values`.
### `Ini:__findKey(sectionIndex,keyName)`
Returns the index of the key `keyName` inside of `self.values[sectionIndex].keys`.
