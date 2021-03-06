jps.suicide = false

-- Recalculates the average heal value to take class specific items into account
function priest_getaverage_heal(spellname)
  local multiplier = 1
  local increaser = 0
  if spellname == "Renew" then
    if GetRangedHaste() < 12.5 then
      multiplier = 4
      else multiplayer = 5;
    end
    increaser =  jps.getaverage_heal("Divine Touch");
  end
  multiplier = (1+ GetMastery()* 0.0125) * multiplier
  return (jps.getaverage_heal(spellname)+increaser) *  multiplier
end



function priest_holy(self)

  --95% to avoid overhealing
   local playerhealth_deficiency = UnitHealthMax("player")*0.94-UnitHealth("player"); --how much health is player missing--
   local focushealth = UnitHealthMax("focus")*0.95-UnitHealth("focus"); --how much health is focus missing--

--return values
      local priest_spell = nil;
      jps.Target = "player";
      local priest_pet_target = nil;
      local priority_debufftarget = nil;
      local priority_debuffspell = nil;


   -- identify if group is a party or raid. This has NOT been tested at all in a raid modus, only 5-man's heroic --

      local group_type;
      group_type="raid";
      nps=1;
      npe=GetNumRaidMembers();

      if npe==0 then
         group_type="party"
         nps=0;
          npe=GetNumPartyMembers();
      end;

      local health_deficiency=0;
      local health_pct = 1;
      local pet_health_deficiency=0;
      local total_health_deficiency = 0;
      local prayerofhealingcount = 0;
      local numberofinjured = 0;
      local focustarget_can_be_dispelled = false;

      for i=nps,npe do
            if i==0 then
               tt="player"
            else
               tt=group_type..i
            end;

   -- identifies the partymember (including focus and self) who is missing most health in absolute terms , or relatively in case left mousebutton is pressed -- checks if a player was not out of visible range just before to avoid repeated casting

            if UnitExists(tt) and UnitInRange(tt) and UnitIsDeadOrGhost(tt)~=1 and (not jps.PlayerIsExcluded(tt)) then
               abshealthdef=UnitHealthMax(tt)*0.95-UnitHealth(tt);
               relhealthdef=UnitHealth(tt)/UnitHealthMax(tt);

               -- this will contain a list of must dispel debuffs
               if UnitDebuff(tt, "Static Cling") ~= nil then
                 jps.Target = tt;
                 return "Dispel Magic"
               end


               if (abshealthdef> health_deficiency and (not IsMouseButtonDown(1))) then
                     health_deficiency=abshealthdef;
                     health_pct = relhealthdef;
                     jps.Target=tt;
               elseif (relhealthdef < health_pct and IsMouseButtonDown(1)) then
                     health_deficiency=abshealthdef;
                     health_pct = relhealthdef;
                     jps.Target=tt;
               end

    -- counts the number of party members having a significant health loss and the combined healthloss these have, used for Circle of Healing and Prayer of Mending--

               if abshealthdef>(priest_getaverage_heal("Prayer of Healing")+priest_getaverage_heal("Renew")) then
                     prayerofhealingcount = prayerofhealingcount + 1;
                     total_health_deficiency = total_health_deficiency +abshealthdef;
               end

            end

   -- identifies the pet which  is missing most health in absolute terms  --

            tt_pet = tt.."pet";
            if UnitExists(tt_pet) and UnitInRange(tt_pet) and UnitIsDeadOrGhost(tt_pet)~=1 then
               b=UnitHealthMax(tt_pet)-UnitHealth(tt_pet);
               if b> pet_health_deficiency then
                     pet_health_deficiency=b;
                priest_pet_target=tt_pet;
               end
            end



      end;


   if UnitExists("focustarget")~=nil then
         for j=1,40 do
            d={UnitBuff("focustarget",j)};
            if d~=nil and d[5]=="Magic" then
               focustarget_can_be_dispelled = true;
            end;
         end;
   end;


   -- how many stacks of serendipity does player have --
   _,_,_,serendipitystacks,_,_,_,_,_ = UnitBuff("player","Serendipity");
   if serendipitystacks == nil then
      serendipitystacks = 0;
   end

   if ub("player", "Spirit of Redemption") and jps.CanCast("Flash Heal", jps.Target) then
     priest_spell = "Flash Heal";


   -- Let's buff --
   elseif not ub("player", "Inner Fire") and jps.CanCast("Inner Fire","player") then
     priest_spell = "Inner Fire";
     jps.Target = "player" ;

   elseif not ub("player", "Power Word: Fortitude") and jps.CanCast("Power Word: Fortitude","player") then
     priest_spell = "Power Word: Fortitude";
     jps.Target = "player" ;

   -- keep fear ward on tank --
   elseif UnitExists("Focus")==1 and jps.CanCast("Fear Ward", "Focus") and not ub("focus","Fear Ward") and not UnitIsDead("focus") then
     priest_spell = "Fear Ward";
     jps.Target = "focus";

   -- Manage Chakra to get Chakra: Serenity --
   elseif not ub("player","Chakra: Serenity") and not ub("player","Chakra") then
     priest_spell = "Chakra";
     jps.Target = "player" ;

   elseif not ub("player","Chakra: Serenity") and ub("player","Chakra") then
   if health_deficiency < (priest_getaverage_heal("Heal")+priest_getaverage_heal("Renew")) then
      priest_spell = "Heal";

    else
     priest_spell = "Flash Heal";
   end;

   -- Guardian Spirit in case tank is very low on health, guardian spirit will never be cast on dps--
   elseif UnitExists("focus") and UnitHealth("focus")/UnitHealthMax("focus") < 0.15 and jps.CanCast("Guardian Spirit", "focus") and not UnitIsDead("focus") then
      SpellStopCasting();
      priest_spell = "Guardian Spirit";
      jps.Target = "focus" ;

   -- Cast Desperate Prayer on self in case of trouble--
   elseif UnitHealth("player")/UnitHealthMax("player") < 0.15 and jps.CanCast("Desperate Prayer","player") and not jps.suicide then
      SpellStopCasting();
      priest_spell = "Desperate Prayer";
      jps.Target = "player" ;

   -- Racial ability in case someone is very low on health--

   elseif UnitHealth(jps.Target)/UnitHealthMax(jps.Target) < 0.15 and jps.CanCast("Gift of the Naaru", jps.Target) then
      SpellStopCasting();
      priest_spell = "Gift of the Naaru";

   -- cast fade in case you are being attacked
   elseif UnitThreatSituation("player")==3 and jps.CanCast("Fade") then
     priest_spell = "Fade";

   -- Renew is top priority on targets who have moderate damage
   elseif jps.CanCast("Renew", jps.Target) and not ub(jps.Target,"renew") and health_deficiency > priest_getaverage_heal("Renew") then
      priest_spell = "Renew";

   -- Prayer of mending in case  at least 2 party members have suffered enough healthloss

   elseif jps.CanCast("Prayer of Mending", jps.Target) and not ub(jps.Target,"Prayer of Mending") and health_pct < 0.8 and health_deficiency > priest_getaverage_heal("Prayer of Mending") and prayerofhealingcount > 1 then
      priest_spell = "Prayer of Mending";

   -- Insta cast flashheal for 0 mana in case surge of light and target is missing enough health to avoid overhealing--

   elseif jps.CanCast("Flash Heal", jps.Target) and health_deficiency > (priest_getaverage_heal("Flash Heal")+priest_getaverage_heal("Renew")) and ub("player", "surge of light") then
      priest_spell = "Flash Heal";

   -- cast flashheal if very high health loss and serendipitystacks < 2  --

   elseif jps.CanCast("Flash Heal", jps.Target) and health_pct < 0.4 and serendipitystacks < 2 and jps.Combat==true then
     priest_spell = "Flash Heal";

   -- main healing spell when high damage  --

   elseif jps.CanCast("Greater Heal", jps.Target) and health_pct < 0.7 and health_deficiency > (priest_getaverage_heal("Greater Heal")+priest_getaverage_heal("Renew")) then
     priest_spell = "Greater Heal";

   -- if at least 4 partymembers around you require at least 8k health, cast prayer of healing--

   elseif jps.CanCast("Prayer of Healing","player") and prayerofhealingcount > 3 then
     priest_spell = "Prayer of Healing";

   -- Cast Holy Word: Serenity - CanCast does not work on this type of spell, has it is an altered version of  Holy Word: Chastise

   elseif GetSpellCooldown("Holy Word: Serenity")==0 and ub("player","Chakra: Serenity") and health_deficiency > (priest_getaverage_heal("Renew")+priest_getaverage_heal("Holy Word: Serenity")) then
      SpellStopCasting();
      priest_spell = "Holy Word: Serenity";

   -- Circle of healing in case at least 4 party members require healing --

   elseif jps.CanCast("Circle of Healing") and prayerofhealingcount > 3 then
      priest_spell = "Circle of Healing";

   elseif jps.CanCast("Binding Heal", jps.Target) and health_deficiency > (priest_getaverage_heal("Binding Heal")+priest_getaverage_heal("Renew")) and playerhealth_deficiency > (priest_getaverage_heal("Binding Heal")+priest_getaverage_heal("Renew")) and (UnitIsUnit("player",priest_target) ~= nil) then
      priest_spell = "Binding Heal";

   -- dispel magic on tanks target, only when right mouse button is pressed--
   elseif focustarget_can_be_dispelled and IsMouseButtonDown(2) and jps.CanCast("Dispel Magic", "focustarget") then
               print("Dispelling: ",GetUnitName("focustarget"));
               priest_spell = "Dispel Magic";
                    jps.Target = "focustarget" ;

   --cleanse if right MouseButtonDown
   elseif IsMouseButtonDown(2)  then
   priest_spell = priest_holy_cleanse();

   elseif priest_pet_target ~= nil and pet_health_deficiency > priest_getaverage_heal("Renew") and jps.CanCast("Renew", priest_pet_target) and not ub(priest_pet_target,"renew") then
        priest_spell = "Renew";
        jps.Target = priest_pet_target ;

   elseif  priest_pet_target ~= nil and UnitHealth(priest_pet_target)/UnitHealthMax(priest_pet_target) < 0.5 and jps.CanCast("Greater Heal", priest_pet_target) and ub(priest_pet_target,"renew") then
      print("Casting Greater Heal on", GetUnitName(priest_pet_target));
        priest_spell = "Greater Heal";
        jps.Target = priest_pet_target ;


   -- main heal spell --
   elseif jps.CanCast("Heal", jps.Target) and health_deficiency > (priest_getaverage_heal("Heal")+priest_getaverage_heal("Renew")) then
     priest_spell = "Heal";
   end;

  return priest_spell ;

end

function priest_holy_cleanse(self)

   local debufftimeleft = 0;
   local debufftype= nil;
   local debufftarget = nil;
   local numberofmagicaffectedunits = 0

-- identify if group is a party or raid. This has NOT been tested at all in a raid modus, only 5-man's normal atm--

      local group_type;
      group_type="raid";
      nps=1;
       npe=GetNumRaidMembers();

      if npe==0 then
         group_type="party"
         nps=0;
          npe=GetNumPartyMembers();
      end;

   for i=nps,npe do
            if i==0 then
               tt="player"
            else
               tt=group_type..i
            end;

   -- identifies the partymember who has the longest running disease or magic running --

          if UnitExists(tt) and UnitInRange(tt) and UnitIsDeadOrGhost(tt)~=1 then
      unit_has_magic = false;
         for j=1,40 do
            d={UnitDebuff(tt,j)};
            if d~=nil and (d[5]=="Magic" or d[5]=="Disease") then
               if unit_has_magic == false and d[5] == "Magic" then
                  numberofmagicaffectedunits = numberofmagicaffectedunits+1;
                  unit_has_magic = true;
               end;
               if d[7]>debufftimeleft then
                  debufftype = d[5];
                  debufftarget=tt;
                  debufftimeleft = d[7] ;
               end;
            end
         end

           end

       end


   if debufftype == "Magic" and debufftype ~= nil then

     jps.Target = debufftarget
     return "Dispel Magic";

   elseif debufftype == "Disease" and debufftype ~= nil then
      jps.Target = debufftarget
      return "Cure Disease";
    end;
    return nil

end