#!/usr/bin/lua
-- Libini, distributed under MIT License, 2016 Zenyth

require 'class'

Ini = class(function(ini,path)
		ini.path = path
		ini.init = false
		ini.values = {}
	end)

function Ini:__findKey(sectionIndex,keyName)
	local section = self.values[sectionIndex]
	local min = 0
	local max = #section
	local pos = math.floor(max/2)
	local found = false
	while not found do
		if keyName == section.keys[pos].name then
			return pos
		elseif keyName > section.keys[pos].name then
			min = pos
			pos = math.floor((min + max)/ 2)
		else
			max = pos
			pos = math.floor((min + max)/2)
		end
		if max - min <= 1 then
			if section.keys[min].name == keyName then
				return min
			elseif section.keys[max].name == keyName then
				return max
			else
				error("libini: key \""..keyName.."\" not found.",2)
			end
		end
	end
end

function Ini:__findSection(sectionName)
	local min = 0
	local max = #self.values
	local pos = math.floor(max/2)
	local found = false
	while not found do
		if sectionName == self.values[pos].name then
			return pos
		elseif sectionName > self.values[pos].name then
			min = pos
			pos = math.floor((min + max)/ 2)
		else
			max = pos
			pos = math.floor((min + max)/2)
		end
		if max - min <= 1 then
			if self.values[min].name == sectionName then
				return min
			elseif self.values[max].name == sectionName then
				return max
			else
				error("libini: section \""..sectionName.."\" not found.",2)
			end
		end
	end
end

function Ini:__parse()
	-- Fist, load the file
	local file = io.open(self.path,"r")
	local rawIni = {}
	local index = 0
	for line in file:lines() do
		rawIni[index] = line
		index = index +1
	end
	file:close()
	-- Then, clear comments and empty lines
	index = 0
	while index < #rawIni do
		if rawIni[index] == "" then
			table.remove(rawIni,index)
			index = index -1
		elseif string.sub(rawIni[index],0,1) == ";" then 
			table.remove(rawIni,index)
			index = index -1
		end
		index = index + 1
	end
	-- Now, time to parse!
	local valueSectionIndex	= -1
	local valueKeyIndex		= 0
	local currentSection	= ""
	for i=0,#rawIni-1 do
		if string.sub(rawIni[i],0,1) == "[" then
			local currentSection = string.sub(rawIni[i],2,-2)
			valueSectionIndex = valueSectionIndex + 1
			self.values[valueSectionIndex] = {name = currentSection, keys = {}, empty = true}
			valueKeyIndex = 0
		else
			local equalIndex	= string.find(rawIni[i],"=")
			local keyName		= string.sub(rawIni[i],0,equalIndex-1)
			local keyValue		= string.sub(rawIni[i],equalIndex+1)
			self.values[valueSectionIndex].keys[valueKeyIndex] = {name = keyName, value= keyValue}
			self.values[valueSectionIndex].empty = false
			valueKeyIndex = valueKeyIndex + 1
		end
	end
	-- Parsing done!
	-- Finally some sorting to speed up reading time for big ini files ( binary search )
	-- first, sort sections
	local sorted = false
	local index = 0
	local lastval = ""
	while not sorted do
		if index == 0 then
			lastval = self.values[0].name
			index = 1
		elseif index > #self.values then
			sorted = true
		else
			if self.values[index].name < lastval then
				local temp = self.values[index]
				self.values[index] = self.values[index - 1]
				self.values[index - 1] = temp
				index = 0
			else
				lastval = self.values[index].name
				index = index + 1
			end
		end
	end
	-- then sort keys
	for i=0, #self.values do
		if not self.values[i].empty then
			local sorted = false
			local index = 0
			local lastval = ""
			while not sorted do
				if index == 0 then
					lastval = self.values[i].keys[index].name
					index = 1
				elseif index > #self.values[i].keys then
					sorted = true
				else
					if self.values[i].keys[index].name < lastval then
						local temp = self.values[i].keys[index]
						self.values[i].keys[index] = self.values[i].keys[index - 1]
						self.values[i].keys[index - 1] = temp
						index = 0
					else
						lastval = self.values[i].keys[index].name
						index = index + 1
					end
				end
			end
		end
	end
	-- Done ~
	-- See ya <3!
end

function Ini:__tostring()
  return "\"" .. self.path .. "\": " .. (self.init and "loaded" or "not loaded")
end

function Ini:Load()
	if self.init then
		error("Ini:Load(): ini already loaded.",2)
	else
		self:__parse()
		self.init = true
	end
end

function Ini:GetKey(sectionName,keyName)
	if self.init then
		local sectionIndex = self:__findSection(sectionName)
		local keyIndex = self:__findKey(sectionIndex,keyName)
		return self.values[sectionIndex].keys[keyIndex].value
	else
		error("Ini:GetKey(): ini not loaded, please use Ini:Load() first.",2)
	end
end

function Ini:AddSection(sectionName)
	self.values[#self.values] = {name=sectionName, keys={}}
end

function Ini:RemoveSection(sectionName)
	if self.init then
		table.remove(self.values,self:__findSection(sectionName))
	else
		error("Ini:RemoveSection(): ini not loaded, please use Ini:Load() first.",2)
	end
end

function Ini:AddKey(sectionName,keyName,value)
	local sectionIndex = self:__findSection(sectionName)
	self.values[sectionIndex].keys[#self.values[sectionIndex.keys]] = {name = keyName, value = value}
end

function Ini:SetKey(sectionName,keyName,value)
	local sectionIndex = self:__findSection(sectionName)
	local keyIndex = self:__findKey(sectionIndex,keyName)
	self.values[sectionIndex].keys[keyIndex].value = value
end

function Ini:SaveAs(outputPath,header)
	local file = io.open(outputPath,"w")
	file:write(";"..header.."\n")
	for i=0,#self.values do
		file:write("["..self.values[i].name.."]\n")
		if not self.values[i].empty then
			for j=0,#self.values[i].keys do
				file:write(self.values[i].keys[j].name .. "=" .. self.values[i].keys[j].value .. "\n")
			end
		end
	end
	file:write("\n")
	file:close()
end

function Ini:Save(header)
	self:SaveAs(self.path,header)
end

