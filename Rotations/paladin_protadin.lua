function jps.CanCastSpell(spellname_or_id,spelltarget)

    if tonumber(spellname_or_id) ~= nil then
      spellname = GetSpellInfo(spellname_or_id);
      spellid = spellname_or_id;
    else
      spellname = spellname_or_id;
      _,spellid = GetSpellBookItemInfo(spellname_or_id);
    end
    _,_,_,_,_,_,casttime,minrange,maxrange = GetSpellInfo(spellname_or_id)

    if spelltarget ~= nil then end

  return IsUsableSpell(spellname) and cd(spellname)==0 and IsSpellKnown(spellid)
end





function paladin_protadin(self)

   local rfury = UnitAura("player","Righteous Fury")

   local myHealth = UnitHealth("player")/UnitHealthMax("player")
   local myMana = UnitMana("player")/UnitManaMax("player")
   local power = UnitPower("player","9")
   local spell = nil


   jps.UpdateThreatTable()

   if jps.CanCastSpell("Divine Plea") and myMana < .75 and power==0 and ub("player","Sacred Duty") then
      spell = "Divine Plea"
      jps.Target = "player"

   elseif jps.CanCastSpell("Seal of Truth") and not ub("player", "Seal of Truth") and myMana > .5 then
      spell ="Seal of Truth","player"
      jps.Target = "player"

   elseif jps.CanCastSpell("Seal of Insight") and not ub("player", "Seal of Insight") and myMana < .2 then
      spell= "Seal of Insight"
      jps.Target ="player"

   elseif  jps.CanCastSpell("Lay on Hands") and myHealth < 0.15  and jps.Interrupts then
      SpellStopCasting()
      spell = "Lay on Hands"
      jps.Target = "player"

  elseif jps.CanCastSpell("Rebuke") and  UnitIsEnemy("player", "target") and jps.should_kick("target") and IsSpellInRange("Rebuke", "target") == 1 then
      SpellStopCasting(); spell = "Rebuke"

  elseif jps.CanCastSpell("Avenging Wrath")  and jps.UseCDs then
  --damage increase 20% 20 sec--
     	spell = "Avenging Wrath"
	    jps.Target = "player"
        print(spell)

  elseif jps.CanCastSpell("Ardent Defender")  and jps.Panic then
    --Reduce damage taken by 20% for 10 sec. While Ardent Defender is active, the next attack that would otherwise kill you will instead cause you to be healed for 15% of your maximum health.--

	SpellStopCasting()
	spell = "Ardent Defender"
	jps.Target = "player"
    print(spell)

--  elseif UnitExists("focus") and UnitHealth("focus")/UnitHealthMax("focus") < 0.2 and UnitThreatSituation("focus") ~= nil and UnitThreatSituation("focus") >= 2 and jps.UseCDs then
  --A targeted ally member is protected from all physical attacks for 8 sec.

	--SpellStopCasting();	spell = "Hand of Protection";	jps.Target="focus"


--  elseif UnitExists("target") and cd("Hand of Reckoning") == 0 and UnitThreatSituation("player","target") ~= nil and UnitThreatSituation("player","target") < 2 then
--Taunts the target to attack you, but has no effect if the target is already attacking you.
--	spell = "Hand of Reckoning"

  elseif jps.CanCastSpell("Righteous Defense") and jps.HiAggroPartyMember then

	spell = "Righteous Defense"
	jps.Target = jps.HiAggroPartyMember
    print(spell," ", jps.Target)
    jps.HiAggroPartyMember = nil

   elseif myHealth < 0.4 and power == 3 and jps.CanCastSpell("Word of Glory") then
     spell = "Word of Glory"
     jps.Target = "player"

   elseif UnitExists("target") and UnitCanAttack("player","target") and (not jps.MultiTarget)   then
      if power==3 and jps.CanCast("Shield of the Righteous", "target") then
         spell = "Shield of the Righteous"
      elseif  jps.CanCastSpell("Avenger's Shield") and ub("player", "Grand Crusader")then
                spell = "Avenger's Shield"
      elseif jps.CanCastSpell("Crusader Strike")   then
          spell = "Crusader Strike"
      elseif jps.CanCastSpell("Judgement")   then
           spell = "Judgement"
      elseif  jps.CanCastSpell("Hammer of Wrath") and UnitHealth("target")/UnitHealthMax("target") < 0.25 then
           spell = "Hammer of Wrath"
      elseif  jps.CanCastSpell("Avenger's Shield")   then
          spell = "Avenger's Shield"
      elseif  jps.CanCastSpell("Consecration") and  myMana > .5   then
          spell = "Consecration"
      elseif  jps.CanCastSpell("Holy Wrath") then
        spell = "Holy Wrath"
      end

   elseif  UnitExists("target") and UnitCanAttack("player","target") and jps.MultiTarget then
      if jps.CanCastSpell("Hammer of the Righteous")  then
        spell = "Hammer of the Righteous"
      elseif jps.CanCastSpell("Avenger's Shield")   and ub("player", "Grand Crusader")then
        spell = "Avenger's Shield"
      elseif jps.CanCastSpell("Consecration")   then
          spell = "Consecration"
      elseif jps.CanCastSpell("Holy Wrath")   then
        spell = "Holy Wrath"
      elseif jps.CanCastSpell("Avenger's Shield")  then
          spell = "Avenger's Shield"
      elseif jps.CanCastSpell("Shield of the Righteous") and power>=3  then
         spell = "Shield of the Righteous"
      elseif jps.CanCastSpell("Judgement") then
           spell = "Judgement"
      end
   end
   return spell

end

function pallybuff()
   if not ub("player", "Seal of Truth") then
      CastSpellByName("Seal of Truth","player")

   elseif not ub("player", "Devotion Aura") then
       CastSpellByName("Devotion Aura","player")

   elseif not ub("player", "Righteous Fury") then
          CastSpellByName("Righteous Fury","player");
   end

end

