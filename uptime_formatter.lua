local getCommand = "GET"

 -- called when message is recieved
 
local on_digiline_receive = function (pos, _, channel, msg) 
	local receiveChannel = minetest.get_meta(pos):get_string("channel")
	local formatString = minetest.get_meta(pos):get_string("formatString")
    if channel == receiveChannel then -- check if it is the right message and channel
    	if not (tonumber(msg) == nil) then -- validate input
	    	local time = math.round(msg) -- round to the nearest second
		local uptimeMessage = processString(formatString, time)
		digilines.receptor_send(pos, digilines.rules.default, receiveChannel, uptimeMessage) -- send formatted version
	end
    end
end

minetest.register_node("stats:uptime_formatter_block", { --register the node
	description = "This block takes seconds and converts it to human readable form",
	tiles = {
		"stats_purple.png",
		"stats_black.png",
		"stats_uf.png",
		"stats_uf.png",
		"stats_uf.png",
		"stats_uf.png"
	},
        groups = {dig_immediate=2},
        digilines = -- I don't rememeber why this is
	{
		receptor = {},
		effector = {
			action = on_digiline_receive --on message recieved
		},
	},
    after_place_node = function(pos, placer)
		local meta = minetest.get_meta(pos)
		meta:set_string("channel", "")
		meta:set_string("formatString", "%H:%M")
		meta:set_string("formspec",
				"size[10,10]"..
				"label[4,2;Channel]".. -- this is just a text label
                "field[2,3;6,1;chnl;;${channel}]".. -- this is just the text entry box 
                		"label[4,4;format string]".. -- this is just a text label
                "field[2,5;6,1;formatString;;${formatString}]".. -- this is just the format string
                "button_exit[4,6;2,1;exit;Save]") -- submit button, triggers on_receive_fields
	end,
    on_receive_fields = function(pos, formname, fields, player) -- to do: implement security
        minetest.get_meta(pos):set_string("channel", fields.chnl)
        minetest.get_meta(pos):set_string("formatString", fields.formatString)
    end
})

function processString(formatString, msg)   -- format specifer followed by seconds
	return os.date(formatString, msg)
end
