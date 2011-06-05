function priest_shadow(self)
	local playermana = UnitMana("player")/UnitManaMax("player");
	local targethealth = UnitHealth("target")/UnitHealthMax("target")
	local priest_spell = nil;

	local vt_duration = jps.debuff_duration("target","vampiric touch");
	local swp_duration = jps.debuff_duration("target","shadow word: pain");
	local dp_duration = jps.debuff_duration("target","devouring plague");
	local shadoworbs = nil;

	if not ub("player", "Inner Fire") and jps.CanCast("Inner Fire","player") then
		priest_spell = "Inner Fire";
		jps.Target = "player" ;

    elseif not ub("player", "Power Word: Fortitude") and jps.CanCast("Power Word: Fortitude","player") then
		priest_spell = "Power Word: Fortitude";
		jps.Target = "player" ;


	elseif not ub("player", "Vampiric Embrace") and jps.CanCast("Vampiric Embrace","player") then
		priest_spell = "Vampiric Embrace";
		jps.Target = "player" ;

	elseif not ub("player", "Shadowform") and jps.CanCast("Shadowform","player") then
		priest_spell = "Shadowform";
		jps.Target = "player" ;

	elseif shadoworbs > 0 and jps.CanCast("Mind Blast", "target") then
		priest_spell = "Mind Blast";

	elseif swp_duration < 2 and jps.CanCast("Shadow Word: Pain", "target")
		priest_spell = "Shadow Word: Pain"

	elseif dp_duration < 2 and jps.CanCast("Devouring Plague", "target") then
		priest_spell = "Devouring Plague"

	elseif vt_duration < 2.5 and jps.CanCast("Vampiric Touch", "target") then
		priest_spell = "Vampiric Touch"

	elseif targethealth < 0.25 and jps.CanCast("Shadow Word: Death", "target") then
		priest_spell = "Shadow Word: Death"

	elseif jps.CanCast("Shadow Fiend", "target") then
		priest_spell = "Shadow Fiend"

	elseif  jps.CanCast("Mind Blast", "target") then
		priest_spell = "Mind Blast"

	elseif  jps.CanCast("Mind Flay", "target") then
		priest_spell = "Mind Flay"
	end

	return priest_spell;

end

