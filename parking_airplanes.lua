redis = require "redis"

function assign_airplane(airplane_id, parking)
	-- Local variables for loading the array of available parking_ids to choose one randomly if one isn't assigned
	local j = 1
	local rand_list = {}
	
	-- Loop for all 99 parking spots
	for i = 1, 99, 1 do
		-- If a element from "parking" list matches airplane_id it is already assigned and parking_id is returned
		if redis.call("LINDEX", parking, i) == airplane_id then
			return i
		-- Each time airplane_id is not found in "parking" list that parking_id is loaded into an array
		elseif redis.call("LINDEX", parking, i) == "unassigned" then
			rand_list[j] = i
			j = j + 1
		end
	end
	
	-- Current time as seed for randomizer 
	math.randomseed(os.time())
	-- One available parking spot is selected by random
	local parking_id = rand_list[math.random(#rand_list)]
	-- "unassigned" element is rewritten by airplane_id
	redis.call("LSET", parking, parking_id, airplane_id)
	
	return parking_id
end

return assign_airplane(ARGV[1], KEY[1])


-- One key is required from redis - "parking" which is a list that contains 99 elements, either "unassigned",
-- or value of airplane_id where list index represents parking space id. 
-- Key for "parking" is passed from redis when calling the script, along with one argument - airplane_id.
-- List must be initialised to all 99 elements as "unassigned".
--
-- Redis command to call the script: --eval parking_airplanes.lua parking , airplane_id
