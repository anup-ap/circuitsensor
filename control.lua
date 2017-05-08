-- Begin Options ----------------------------------------------------

-- Interval in seconds between logistic networks (default: 2)
   interval = 2

-- Cycle trough all signales for each wire color (default: true):
   cycle = true

-- Unused TODO delete
-- Show logistic network with following id, if cycle is false (default: 1):
--   network_id = 1

-- Minimum amount of logistic robots in the network to be displayed (default: 0):
   minimum_logistic_robots = 0

------------------------------------------------------ End Options --

require "util"

last_network = 0
networks = {}

function _init()
	remote.call("EvoGUI", "create_remote_sensor", { mod_name = "circuit_sensor",
													name = "dahn_cs1",
													text = "Signal red detected: none",
													caption = "Red Signals"
												}
	)
	remote.call("EvoGUI", "create_remote_sensor", { mod_name = "circuit_sensor",
													name = "dahn_cs2",
													text = "Signal green detected: none",
													caption = "Green Signals"
												}
	)
end

--Register a callback to be run on module init.
script.on_init(
	function()
		_init()
	end
)

--Register a function to be run on module load.
script.on_load(
	function()
		_init()
	end
)

--It is fired once every tick. Since this event is fired every tick, its handler shouldn't include performance heavy code.
script.on_event(defines.events.on_tick,
	function()
		if game.tick % (interval * 60) ~= 0 then return end

		local logistic_networks 			= game.forces.player.logistic_networks
		local available_logistic_networks 	= 0
		local text1 						= "none"
		local text2 						= "none"

		for surface, surface_networks in pairs(logistic_networks) do
			for network_id, network in pairs(surface_networks) do
				if network.valid and network.all_logistic_robots >= minimum_logistic_robots then
					available_logistic_networks = available_logistic_networks + 1
					networks[available_logistic_networks] = {
						available_logistic_robots 		= network.available_logistic_robots,
						all_logistic_robots 			= network.all_logistic_robots,
						available_construction_robots 	= network.available_construction_robots,
						all_construction_robots 		= network.all_construction_robots
					}
				end
			end
		end


		if available_logistic_networks > 0 then
			if cycle == true then
				if last_network + 1 > available_logistic_networks then
					last_network = 1
				else
					last_network = last_network + 1
				end

				text1 = "[#" .. last_network .. "/" .. available_logistic_networks .. "] " .. networks[last_network].available_logistic_robots .. "/" .. networks[last_network].all_logistic_robots
				text2 = "[#" .. last_network .. "/" .. available_logistic_networks .. "] " .. networks[last_network].available_construction_robots .. "/" .. networks[last_network].all_construction_robots
			else
				if network_id < 1 or network_id > available_logistic_networks then
					last_network = 1
				end

				text1 = "[#" .. last_network .. "/" .. available_logistic_networks .. "] " .. networks[last_network].available_logistic_robots .. "/" .. networks[last_network].all_logistic_robots
				text2 = "[#" .. last_network .. "/" .. available_logistic_networks .. "] " .. networks[last_network].available_construction_robots .. "/" .. networks[last_network].all_construction_robots
			end
		end

		remote.call(
			"EvoGUI",
			"update_remote_sensor",
			"dahn_cs1",
			"L bots: " .. text1
		)
		remote.call(
			"EvoGUI",
			"update_remote_sensor",
			"dahn_cs2",
			"C bots: " .. text2
		)
	end
)
