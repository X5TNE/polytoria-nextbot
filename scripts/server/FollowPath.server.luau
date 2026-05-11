-- npc follow script by me ig
-- licensed under CC-BY please credit me -X5TNE (beanboI223 or beanboi_223)
npc = script.Parent
env = game["Environment"]
env.AutoGenerateNavMesh = true
err = nil
out = nil
debounce = false
spawnhere = npc.Position -- where the NPC spawned originally
closestpos = Vector3.new(0, 0, 0)
lastsafepos = spawnhere
lastpos = spawnhere
currentclosest = 2^30 -- aprox of math.huge() (I thought math.huge was here??)
closest = nil
closestname = ""
lastclosestname = ""
timer = 0

-- Penalities!
-- Stop the "model" from staying in the same position

timeout = 10 -- Default 10 decisecond aka 1 second
-- default penalty
-- Eventually i'll move to some primitive reinforcement learning form (without NNs of course :D)
function returndefaultconsequence()
	return function(npcpos, plrpos)
		local pathbrick = Instance.New("Part")
		pathbrick.Parent = env
		pathbrick.Anchored = true
		pathbrick.Size = Vector3.New(0.01, 0.01, 0.01)
		-- Move somewhere different than the current failure state
		pathbrick.Position = npcpos + (npcpos - plrpos) -- (Position + Linear Direction <- Target) Not the best, but it works. 
		npc.MoveTarget(pathbrick)
	end
end
penalty = returndefaultconsequence() -- Make your own function and share so eventually everyone can have the best pathfinding system!


npc.Died:Connect(function()
    npc.MoveTarget = nil
    npc.Position = spawnhere
    npc:Respawn()
end)

npc.Touched:Connect(function(hit) 
    if hit:IsA("Player") and hit.Health > 0 then
          if debounce ~= true then
              hit.Health = 0
              debounce = true
			  -- whoops roblox syntax again
			  wait(2)
			  debounce = false
          end
    elseif hit:IsA("Part") then
        npc:Jump()
    end
end)

-- Soon, i'm not the best at coding but i will make a better loop.
while wait(0.1) do
	closest = nil
    currentclosest = 2^30
	local players = game["Players"]:GetPlayers()
    local mindis = 1000
    for i=1, #players do
        local plr = players[i]
        if plr.Health > 0 then
            local distance = Vector3.Distance(npc.Position, plr.Position)
            if distance < mindis and distance < currentclosest then
                closest = plr
				closestname = plr.Name
				--closestpos = plr.Position
                currentclosest = distance
            end
        end
    end
	
	--[[
	
	-- ick accidental r*blox syntax for a sec
	local hit = env:Raycast(npc.Position, (closestpos - npc.Position))
    
	out, err = pcall(
        function(closest, closestname)
			if not hit.Instance then
			    if hit.Instance.Name == "decal" then
					npc:SetNavDestination(env:GetPointOnNavMesh(closestpos))
					print("I don't see ".. closestname.. " -".. script.Parent.Parent.Name) 
					return
				end
		        npc.MoveTarget = closest
				print("I see ".. closestname.. " -".. script.Parent.Parent.Name)
		    else
		        npc:SetNavDestination(env:GetPointOnNavMesh(closestpos))
				print("I don't see ".. closestname.. " -".. script.Parent.Parent.Name)
			end
		end,
		closest,
		closestname
	) -- OMG I FORGOT THE FREAKING PASS ON THINGS eaufsnhdihy3wesfng
	
	-- very unlikely unless you've got a hacker or your game has spots that are inaccessible.
	if err ~= nil then
		local ignore, err2 = pcall(function() 
		warn("Error: ".. err)
		end)
		if ignore or err2 then
		print("SOMEHOW MY  PROGRAMMING SKILLS MADE WARN() ERROR AGAIN.")
		end
		
		print("Fallback: MoveTarget")
		npc.MoveTarget = closest -- walk linearly and try to get as close as possible ig 
	end
	]]
	-- Too hard, just gonna do this for now, way better system in my opinion + easier contribution, just find the best reinforcment method, reminds me of my old days of experimenting with NNs:
	if not closest then 
		print("NO TARGET FOUND")
		repeat
			local players = game["Players"]:GetPlayers()
			if #players == 0 then wait(9) end
			wait(0.1)
			for i=1, #players do
		        local plr = players[i]
		        if plr.Health > 0 then
		            local distance = Vector3.Distance(npc.Position, plr.Position)
		            if distance < mindis and distance < currentclosest then
		                closest = plr
						closestname = plr.Name
						--closestpos = plr.Position
		                currentclosest = distance
		            end
		        end
		    end
		until closest
		
	end -- force wait for players
	npc:SetNavDestination(env:GetPointOnNavMesh(closest.Position))
	-- for debugging
	if closestname ~= lastclosestname then print("Hunting: ".. closestname.. script.Parent.Parent.Name) lastclosestname = closestname end
	if Vector3.Distance(npc.Position, lastpos) < 0.9 and timer >= timeout then
		timer = 0
		local yesproceedwiththisrepeatingprint = false
		pcall(function(dothisplease) 
		if dothisplease then print("Calling penalty with: ", npc.Position, " | ", closest.Position) end
		end,yesproceedwiththisrepeatingprint)
		pcall(penalty, npc.Position, closest.Position)
	end
	if Vector3.Distance(npc.Position, lastpos) < 0.9 and timer < timeout then
		timer = timer + 1
	end
	if Vector3.Distance(npc.Position, lastpos) > 0.9 then
		lastpos = npc.Position
		timer = 0
	end
end

-- I miss VS Code, it actually indented correctly :/, nobody likes tabs
-- Partially-restored script from github commit 4b934bc
-- github.com/X5TNE/polytoria-nextbot/
-- tried fixing an issue but it's just really hard to solve, please contribute