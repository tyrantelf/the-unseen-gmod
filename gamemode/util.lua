--[[
    _______ _            _    _                           
   |__   __| |          | |  | |                          
      | |  | |__   ___  | |  | |_ __  ___  ___  ___ _ __  
      | |  | '_ \ / _ \ | |  | | '_ \/ __|/ _ \/ _ \ '_ \ 
      | |  | | | |  __/ | |__| | | | \__ \  __/  __/ | | |
      |_|  |_| |_|\___|  \____/|_| |_|___/\___|\___|_| |_|                                                   
   Utility Functions                                Shared                                                                                               
]]--

function util.GetNextAlivePlayer(ply)
   local alive = util.GetLivingPlayers( TEAM_IRIS )

   if #alive < 1 then return nil end

   local prev = nil
   local choice = nil

   if IsValid(ply) then
      for k,p in pairs(alive) do
         if prev == ply then
            choice = p
         end

         prev = p
      end
   end

   if not IsValid(choice) then
      choice = alive[1]
   end

   return choice
end


function util.GetLivingPlayers(class)
   local count = 0
   
   for k, v in ipairs(team.GetPlayers(class)) do
      if (v:Alive() and v:GetObserverMode() == OBS_MODE_NONE) then
         count = count + 1
      end
   end
   
   return count
end