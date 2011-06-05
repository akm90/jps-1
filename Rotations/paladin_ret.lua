function paladin_ret(self)
	-- Credit (and thanks!) to Gocargo.
	local hpower = UnitPower("player",SPELL_POWER_HOLY_POWER)
	local zea_cd = jps.get_cooldown("zealotry")
	local inq_duration = jps.buff_duration("player","inquisition")
	local execute_phase = UnitHealth("target")/UnitHealthMax("target") <= 0.20
	local spell = nil
   
	--ACTION GOES DOWN HERE--

	--INTERRUPT LOGIC--
   	if IsUsableSpell("Rebuke") and UnitIsEnemy("player", "target") and (UnitCastingInfo("target") or UnitChannelInfo("target")) and cd("Rebuke") == 0 and IsSpellInRange("Rebuke", "target") == 1 then
		SpellStopCasting() spell = "Rebuke"


    elseif IsUsableSpell("Seal of Insight") and (UnitHealth("player")/UnitHealthMax("player") < 0.35 or UnitMana("player")/UnitManaMax("player") < .35) and not ub("player", "Seal of Insight") then
         spell = "Seal of Insight"

    elseif IsUsableSpell("Seal of Truth") and (UnitHealth("player")/UnitHealthMax("player") > 0.6 and UnitMana("player")/UnitManaMax("player") > .6) and not ub("player", "Seal of Truth") then
         spell = "Seal of Truth"


	--HEAL ME BRO--
   	elseif IsUsableSpell("Word of Glory") and UnitHealth("player")/UnitHealthMax("player") < 0.40 and hpower > 0  and cd("Word of Glory") == 0 then
		spell = "Word of Glory"
         jps.Target="player"

    elseif IsUsableSpell("Flash of Light") and UnitHealth("player")/UnitHealthMax("player") < 0.20 and cd("Flash of Light") == 0 then
		spell = "Flash of Light"
         jps.Target="player"

	-- INQUISITION LOGIC--
--	elseif not ub("player", "Inquisition") and ub("player", "Divine Purpose") then
--		spell = "Inquisition"
--	elseif ub("player", "Divine Purpose") and inq_duration < 2 then
--		spell = "Inquisition"
--	elseif not ub("player", "Inquisition") and hpower > 2 then
--		spell = "Inquisition"
--	elseif hpower > 0 and inq_duration < 2 then
--		spell = "Inquisition"


    elseif IsUsableSpell("Blessing of Might") and not ub("player", "Blessing of Might") and cd("Blessing of Might") == 0 then
		spell = "Blessing of Might"
         jps.Target = "player"


    elseif IsUsableSpell("Divine Plea") and UnitMana("player")/UnitManaMax("player") < 0.50 and cd("Divine Plea")==0 then
         spell = "Divine Plea"
         jps.Target="player"
	--ZEALOTRY LOGIC--
	elseif IsUsableSpell("Zealotry") and ub("player", "Divine Purpose") and cd("Zealotry") == 0 then
		spell = "Zealotry"
	elseif IsUsableSpell("Zealotry") and  hpower == 3 and cd("Zealotry") == 0 then
		spell = "Zealotry"

	--CS LOGIC--
	elseif IsUsableSpell("Crusader Strike") and cd("Crusader Strike") == 0 and IsSpellInRange("crusader strike", "target") then
		spell = "Crusader Strike"

	--TEMPLAR'S VERDICT LOGIC--
	elseif IsUsableSpell("Templar's Verdict") and ub("player", "Divine Purpose") then
		spell = "Templar's Verdict"
	elseif IsUsableSpell("Templar's Verdict") and hpower == 3 then
		spell = "Templar's Verdict"
   	
	--HAMMER LOGIC--
	elseif IsUsableSpell("Hammer of Wrath") and execute_phase and cd("Hammer of Wrath") == 0 then
		spell = "Hammer of Wrath"
	elseif IsUsableSpell("Hammer of Wrath") and ub("player", "Avenging Wrath") and cd("Hammer of Wrath") == 0 then
		spell = "hammer of wrath"

	--EXORCISM LOGIC--
   	elseif IsUsableSpell("exorcism") and ub("player", "the art of war") and cd("Exorcism")==0 then
		spell = "exorcism"

	--JUDGEMENT LOGIC--
  	elseif IsUsableSpell("Judgement") and cd("Judgement") == 0 then
		spell = "Judgement"

   	--HOLY WRATH--
	elseif IsUsableSpell("Holy Wrath") and cd("Holy wrath") == 0 then
		spell = "Holy Wrath"

   	--TIME TO GO OOM--
	elseif IsUsableSpell("Consecration") and  cd("Consecration") == 0 then
		spell = "Consecration"

	end

 return spell
end
