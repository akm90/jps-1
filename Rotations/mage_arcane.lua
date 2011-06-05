function mage_arcane(self)
  -- Credits to Trixo
   local spell = nil;
   local hp = UnitHealth("player")/UnitHealthMax("player");
   local mana = UnitMana("player")/UnitManaMax("player");
   local speed = GetUnitSpeed("player");
   local magearmor = jps.buff_duration("player","mage armor");
   local arcaneb = jps.buff_duration("player","arcane brilliance");
   local abCount = jps.get_debuff_stacks("player","arcane blast");
   local abDuration = jps.debuff_duration("player","arcane blast");

   if cd("lifeblood") == 0 and UnitHealthMax("target") > 1000000 and UnitHealth("target") > 500000 then
      spell = "lifeblood";
   elseif cd("arcane power") == 0 and UnitHealthMax("target") > 1000000 and UnitHealth("target") > 500000 then
      spell = "arcane power";
   elseif cd("mirror image") == 0 and UnitHealthMax("target") > 2000000 and UnitHealth("target") > 1000000 then
      spell = "mirror image";
   elseif cd("berserking") == 0 and ub("player","arcane power") then
      spell = "berserking";
   elseif magearmor < 60 then
      spell = "mage armor";
   elseif arcaneb < 60 then
      spell = "arcane brilliance";
   elseif hp < 1 and cd("mage ward") == 0 then
      spell = "mage ward";
   elseif abDuration < 2 and ud("player","arcane blast") then
      spell = "arcane barrage";
   elseif speed > 0 then
      spell = "arcane barrage";
   elseif cd("evocation") == 0 and mana < 0.3 and speed == 0 then
      spell = "evocation";
   elseif ub("player","arcane missile!") and mana < 0.5 then
      spell = "arcane missiles";
   elseif abCount == 4 and    mana < 0.8 and ub("player","arcane missiles!") then
      spell = "arcane missiles";
   else
      spell = "arcane blast";
   end
   return spell;

end   
