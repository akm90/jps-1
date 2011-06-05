-- Lookup Tables
-- Specs
jps.Specs = {
	["Death Knight"] = {[1] = "Blood", [2] = "Frost", [3] = "Unholy"},
	["Druid"] = {[1] = "Balance", [2] = "Feral", [3] = "Restoration"},
	["Warlock"] = {[1] = "Afflication", [2] = "Demonology", [3] = "Destruction"},
	["Priest"] = {[1] = "Discipline", [2] = "Holy", [3] = "Shadow"},
	["Warrior"] = {[1] = "Arms", [2] = "Fury", [3] = "Protection"},
	["Paladin"] = {[1] = "Holy", [2] = "Protection", [3] = "Retribution"},
	["Shaman"] = {[1] = "Elemental", [2] = "Enhancement", [3] = "Restoration"},
	["Rogue"] = {[1] = "Assassination", [2] = "Combat", [3] = "Subtlety"},
	["Hunter"] = {[1] = "Beast Mastery", [2] = "Marksmanship", [3] = "Survival"},
	["Mage"] = {[1] = "Arcane", [2] = "Fire", [3] = "Frost"},
}

-- Functions
function jps.Cast(spell)
	if not jps.Target then jps.Target = "target" end
    if jps.Debug then jps.printflags();  end
    CastSpellByName(spell,jps.Target)
	jps.Target = "target"
	if jps.IconSpell ~= spell then
		jps.set_jps_icon(spell)

	end
end

function jps.printflags()
  print("Enabled: ", jps.Enabled," Combat: ", jps.Combat, " spell: ", jps.ThisCast," target: ", jps.Target, " Casting: ", jps.Casting, " Cooldown: ", cd(jps.ThisCast))
end

function jps.get_cooldown(spell)
	local start,duration,_ = GetSpellCooldown(spell)
	local cd = start+duration-GetTime()-jps.Lag
	if cd < 0 then return 0 end
	return cd
end

function jps.buff_duration(unit,spell)
	local _,_,_,_,_,_,duration,_,_,_,_ = UnitBuff(unit,spell)
	if duration == nil then return 0 end
	duration = duration-GetTime()-jps.Lag
	if duration < 0 then return 0 end
	return duration
end

function jps.debuff_duration(unit,spell)
	local _,_,_,_,_,_,duration,_,_,_,_ = UnitDebuff(unit,spell)
	if duration==nil then return 0 end
	duration = duration-GetTime()-jps.Lag
	if duration < 0 then return 0 end
	return duration
end

function jps.set_jps_icon(spell)
	local _, _, icon, _, _, _, _, _, _ = GetSpellInfo(spell)
	collectgarbage("collect")
	IconFrame:SetBackdrop( {
		bgFile = icon,
		edgeFile = "Interface\DialogFrame\UI-DialogBox-Border", tile = true, tileSize = 41, edgeSize = 13,
		insets = { left = 0, right = 0, top = 0, bottom = 0 }
	})
	jps.IconSpell = spell
end

function jps.get_debuff_stacks(unit,spell)	
	local _, _, _, count, _, _, _, _, _ = UnitDebuff(unit,spell)
	if count == nil then count = 0 end
	return count
end

function jps.get_buff_stacks(unit,spell)	
	local _, _, _, count, _, _, _, _, _ = UnitBuff(unit,spell)
	if count == nil then count = 0 end
	return count
end

function jps.should_kick(unit)
	local target_spell, _, _, _, _, endTime, _, _, unInterruptable = UnitCastingInfo(unit)
  local channelling, _, _, _, _, _, _, notInterruptible = UnitChannelInfo(unit)

  if target_spell and not unInterruptable then
    endTime = endTime - GetTime()*1000
    if endTime < 300+jps.Lag then
      return true
    end 
  elseif chanelling and not notInterruptible then
    return true
  end 

	return false
end

