-- npc follow script by me ig
local npc = script.Parent
local debounce = false
local spawnhere = npc.Position -- start position, no need for var

npc.Died:Connect(function()
    npc.MoveTarget = nil
    npc.Position = spawnhere
    npc:Respawn()
end)

npc.Touched:Connect(function(hit) 
    if hit:IsA("Player") and hit.Health > 0 then
          if debounce ~= true then
              hit.Health = hit.Health - 1
              debounce = true
          else
              wait(0.1)
              debounce = false
          end
    elseif hit:IsA("Part") then
        npc:Jump()
    end
end)

while wait(1.26) do
    local players = game["Players"]:GetPlayers()
    local closest = nil
    local currentclosest = 2^30 -- close enough to 2,147,483,647
    local mindis = 1000
    for i=1, #players do
        local plr = players[i]
        if plr.Health > 0 then
            local distance = Vector3.Distance(npc.Position, plr.Position)
            if distance < mindis and distance < currentclosest then
                closest = plr
                currentclosest = distance
            end
        end
    end
    npc.MoveTarget = closest
end