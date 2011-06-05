function mage_frost(self)
  --leveling spec by walki: regen and buffs managed by pg

	local mana = UnitMana("player")/UnitManaMax("player")
	local spell = nil
    jps.Target = "target"

	if not ub("player","Mana Shield") and jps.CanCast("Mana Shield", "player") then
		spell = "Mana Shield"
    elseif not ub("player","Frost Armor") and jps.CanCast("Frost Armor", "player") then
                spell = "Frost Armor"
    elseif not ub("player","Arcane Brilliance") and jps.CanCast("Arcane Brilliance", "player") then
                   spell = "Arcane Brilliance"

    elseif not ub("player","Ice Barrier") and jps.CanCast("Ice Barrier", "player") then
        spell = "Ice Barrier"
    elseif jps.CanCast("counterspell", jps.Target) and jps.should_kick(jps.Target) then
		spell = "counterspell"
    elseif cd("Flame Orb")==0 then
		spell = "Flame Orb"
    elseif cd("Frostfire Bolt")==0 and ub("player","Brain Freeze") then
        spell = "Frostfire Bolt"
    elseif jps.CanCast("Ice Lance") and ub("player","Fingers of Frost")  then
        spell = "Ice Lance"
    elseif jps.CanCast("Frostbolt") then
        spell = "Frostbolt"
    elseif cd("mirror image") == 0 and jps.UseCDs then
		spell = "mirror image"

    end

   return spell
end
