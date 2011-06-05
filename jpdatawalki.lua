-- Only call following functions:
          -- jps.getaverage_heal(spellname)
          -- jps.PlayerIsExcluded(playerName)
          -- jps.NumberOfMobsInCombatWith()

-- walki eventhandlers

function jps.WalkiCombatLogEventHandler(...)
    jps.UpdateOutOfSightPlayers()
    jps.update_EnemyUnitsInCombat()
    local eventtable =  {... }
    if (eventtable[2] == "SPELL_HEAL" or eventtable[2] == "SPELL_PERIODIC_HEAL") and eventtable[15]==0 and eventtable[5]== GetUnitName("player")then
      jps.update_healtable(eventtable);
    elseif eventtable[2] == "SPELL_CAST_FAILED" and eventtable[5]== GetUnitName("player") and eventtable[13]== "Target not in line of sight" then
      jps.ExcludePlayer(jps.Target)
    elseif eventtable[2] == "UNIT_DIED" then
      jps.add_RecentlyKilledUnits(eventtable[7])
      jps.remove_EnemyUnitsInCombat(eventtable[7])
    else
      jps.add_EnemyUnitsInCombat(eventtable[4],eventtable[5])
      jps.add_EnemyUnitsInCombat(eventtable[7],eventtable[8])

    end
end

function jps.WalkiUIErrorEventHandler(...)

end



-- contains the average value of non critical healing spells
-- walkistalki healing functions
jps.HealValues = {}


-- used to debug, shows all spells in the table
function print_healtable(self)
  for k,v in pairs(jps.HealValues) do
    print(k,":  ", jps.HealValues[k]["healtotal"],"  ", jps.HealValues[k]["healcount"],"  ", jps.HealValues[k]["averageheal"]);
  end
end

-- updates the HealValues table with the most recent healing spell
function jps.update_healtable(healevent)
    	if jps.HealValues[healevent[11]]== nil then
			jps.HealValues[healevent[11]]= {["healtotal"]= healevent[13],["healcount"]= 1,["averageheal"]= healevent[13]}
		else
			jps.HealValues[healevent[11]]["healtotal"]= jps.HealValues[healevent[11]]["healtotal"]+healevent[13]
			jps.HealValues[healevent[11]]["healcount"]= jps.HealValues[healevent[11]]["healcount"]+1
			jps.HealValues[healevent[11]]["averageheal"]= jps.HealValues[healevent[11]]["healtotal"]/jps.HealValues[healevent[11]]["healcount"]
        end
end

--resets the healtable, setting count to 1 for each spell, and maintaining average heal. This allows for the healvalues to be quickly recalculated in case of changed stats

function jps.reset_healtable(self)
  for k,v in pairs(jps.HealValues) do
    jps.HealValues[k]["healtotal"]= jps.HealValues[k]["averageheal"]
    jps.HealValues[k]["healcount"]= 1
  end
end


-- returns the average heal value of given spell. Each healingclass rotation needs to recalculate the returned value

function jps.getaverage_heal(spellname)
  if jps.HealValues[spellname] ~= nil then
    return jps.HealValues[spellname]["averageheal"]
  else
    return 0
  end
end


--out of sight fucntions - used to temporarily ignore a friendly unti for healing if he was in range but out of sight

jps.OutOfSightPlayers =  {}

-- checks if the it was at least 2 seconds ago since the unit was last got out of sight error
function jps.UpdateOutOfSightPlayers(self)
   if #jps.OutOfSightPlayers > 0 then
      for i = #jps.OutOfSightPlayers, 1, -1 do
         if GetTime() - jps.OutOfSightPlayers[i][2] > 2 then
            table.remove(jps.OutOfSightPlayers,i)
         end
      end
   end
end

--queries if a player is out of sight
function jps.PlayerIsExcluded(playerName)
   for i = 1, #jps.OutOfSightPlayers do
      if jps.OutOfSightPlayers[i][1] ==  playerName then
         return true
      end
   end
   return false
end

--adds a player to out of sight queue
function jps.ExcludePlayer(playername)
   if playername == nil then
      playername = "nil"
   end
   local playerexclude = {}
   table.insert(playerexclude, playername)
   table.insert(playerexclude, GetTime())
   table.insert(jps.OutOfSightPlayers,playerexclude)
end


-- threattable
jps.ThreatTable = {}

function jps.PlayerHasThreat(playerName)
   for i = 1, #jps.ThreatTable do
      if jps.ThreatTable[i][1] ==  playerName then
         return true
      end
   end
   return false
end

function jps.UpdateThreatTable()
  local partymember_to_save = nil
  local  partymember_to_save_health = 1
   if #jps.ThreatTable > 0 then
      for i = #jps.ThreatTable, 1, -1 do
         if not UnitExists(jps.ThreatTable[i][1]) or UnitThreatSituation(jps.ThreatTable[i][1]) ~= 3  then
            table.remove(jps.ThreatTable,i)
         elseif GetTime() - UnitThreatSituation(jps.ThreatTable[i][2]) > 2 then
           if UnitHealth(jps.ThreatTable[i][1])/UnitHealthMax(jps.ThreatTable[i][1]) < partymember_to_save_health then
             partymember_to_save = jps.ThreatTable[i][1]
             partymember_to_save_health = UnitHealth(jps.ThreatTable[i][1])/UnitHealthMax(jps.ThreatTable[i][1])
           end

         end
      end
   end

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
            if tt ~= "player" and  not jps.PlayerHasThreat(tt) and UnitExists(tt) and UnitThreatSituation(tt) == 3 then
                local playerthreatitem = {}
                table.insert(playerthreatitem, tt)
                table.insert(playerthreatitem, GetTime())
                table.insert(jps.ThreatTable,playerthreatitem)
            end

   end

end

function jps.PrintThreatTable()
     for i = 1, #jps.ThreatTable do
      print(jps.ThreatTable[i][1]," ", GetTime()-jps.ThreatTable[i][2])
     end
end




-- EnemyUnitsInCombat

jps.EnemyUnitsInCombat  =  {}
jps.RecentlyKilledUnits  =  {}

-- still experimental
function jps.NumberOfMobsInCombatWith()
  return #jps.EnemyUnitsInCombat
end


function jps.update_EnemyUnitsInCombat()
 if #jps.EnemyUnitsInCombat > 0 then
      for i = #jps.EnemyUnitsInCombat, 1, -1 do
        --if for 5 seconds there was no activity around a mob we can consider no longer to be in combat with it anymore
         if GetTime() - jps.EnemyUnitsInCombat[i][2] > 2 then
            table.remove(jps.EnemyUnitsInCombat,i)
         end
      end
 end
 if #jps.RecentlyKilledUnits > 0 then
      for i = #jps.RecentlyKilledUnits, 1, -1 do
        --after 60 seconds all curses and dots cast by a dead mob should have disappeared
         if GetTime() - jps.RecentlyKilledUnits[i][2] > 60 then
            table.remove(jps.RecentlyKilledUnits,i)
         end
      end
 end

end

function jps.add_EnemyUnitsInCombat(guid,unitname)
   --check if GUID is mob
   local first3 = tonumber("0x"..strsub(guid, 3,5))
   local unitType = bit.band(first3,0x00f)
   if (unitType == 0x003) and not jps.is_RecentlyKilled(guid) then
      jps.remove_EnemyUnitsInCombat(guid)
      local temptable = {}
      table.insert(temptable, guid)
      table.insert(temptable, GetTime())
      table.insert(temptable, unitname)

      table.insert(jps.EnemyUnitsInCombat, temptable)
   end
end

function jps.remove_EnemyUnitsInCombat(mob)
   if #jps.EnemyUnitsInCombat > 0 then
      for i = #jps.EnemyUnitsInCombat, 1, -1 do
         if jps.EnemyUnitsInCombat[i][1] == mob then
            table.remove(jps.EnemyUnitsInCombat,i)
            break
         end
      end
 end
end

function jps.add_RecentlyKilledUnits(guid)
      local temptable = {}
      table.insert(temptable, guid)
      table.insert(temptable, GetTime())
      table.insert(jps.RecentlyKilledUnits, temptable)
end

function jps.is_RecentlyKilled(mob)
   if #jps.RecentlyKilledUnits > 0 then
      for i = #jps.RecentlyKilledUnits, 1, -1 do
         if jps.RecentlyKilledUnits[i][1] == mob then
            return true
         end
      end
      return false
 end
end



function jps.debug_EnemyUnitsInCombat()
  print (jps.NumberOfMobsInCombatWith())
  for i = #jps.EnemyUnitsInCombat, 1, -1 do
         print(jps.EnemyUnitsInCombat[i][1], " ",jps.EnemyUnitsInCombat[i][2], " ",jps.EnemyUnitsInCombat[i][3])
   end
end


-- Early version and still quite unpredictable - i'd net yet recommend to use


function jps.CanCast(spellname_or_id, spelltarget, ignore_speed, ignore_range, ignore_isusable, ignore_isspellknown)

    if ignore_speed ~= 1 then ignore_speed = 0 end;
    if ignore_range ~= 1 then ignore_range = 0 end;
    if ignore_isusable ~= 1 then ignore_isusable = 0 end;
    if ignore_isspellknown  ~= 1 then ignore_isspellknown = 0 end ;


    if tonumber(spellname_or_id) ~= nil then
      spellname = GetSpellInfo(spellname_or_id);
      spellid = spellname_or_id;
    else
      spellname = spellname_or_id;
      _,spellid = GetSpellBookItemInfo(spellname_or_id);
    end
    _,_,_,_,_,_,casttime,minrange,maxrange = GetSpellInfo(spellname_or_id)

--    if jps.Class == "Mage" and jps.Spec == "Fire" and spellname ~= "Fireball"


    if spelltarget == nil then
         if GetUnitName("target") == nil then
           spelltarget = "player"
         else
           spelltarget = "target"
         end;
    end;

--   print(GetSpellCooldown(spellname_or_id)==0);
   -- print(IsUsableSpell(spellid) or ignore_isusable);
   -- print(IsSpellInRange(spellname,spelltarget)==1 or maxrange==0);
   -- print(IsSpellKnown(spellid) or ignore_isspellknown);
   -- print((casttime == 0 or GetUnitSpeed("player") == 0) or ignore_speed);



    return GetSpellCooldown(spellname_or_id)==0 and (IsUsableSpell(spellid) or ignore_isusable) and (IsSpellInRange(spellname,spelltarget)==1 or maxrange==0 or ignore_range) and (IsSpellKnown(spellid) or ignore_isspellknown) and ((casttime == 0 or GetUnitSpeed("player") == 0) or ignore_speed) and not UnitIsDeadOrGhost(spelltarget)and not jps.Casting;
end
