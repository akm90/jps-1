function rogue_combat(self)
   local spell = nil
   local playerHealth = UnitHealth("player")/UnitHealthMax("player")
   local targetHealth = UnitHealth("target")/UnitHealthMax("target")
   local energy = UnitPower("player",3)
   local combopoints = GetComboPoints("player")


   if jps.debuff_duration("target",spell) < 4 and targetHealth > 0.3 and combopoints > 2 then
      spell = "Eviscerate"
   elseif cd("Adrenaline Rush") == 0 then
             spell = "Adrenaline Rush"
   elseif jps.debuff_duration("target",spell) < 4 and targetHealth > 0.3 and combopoints > 0 then
       spell = "Slice and Dice"
   elseif combopoints == 4 and not ud("Revealing Strike", "target")then
             spell = "Revealing Strike"
   elseif combopoints == 5 then
          spell = "Eviscerate"
   end
   return spell
end
