-- file name should be <author>_<creatername> for simplicity, so it should be "gungorenu_example1.lua"
-- it is best to create this file with command and then alter properties but it is really not recommended to touch "cliffs" list
local crater = {
  name = "example1", -- give a name for the crater
  author = "gungorenu", -- author of the pattern
  id = "gungorenu_example1", -- generally author_name to identify craters
  version = "1.2.3", -- just a version value in case there were updates
  variance = { -- <optional, defaults to 0 all> this is variance of the furnace position (reference point), not cliffs
    -- the values here are all tile count, how much the reference point can move towards those directions
    north = 1,
    west = 2,
    south = 9,
    east = 0
  },
  cliffs = { -- list of cliffs, visual variance shall be checked automatically
    -- positions are relative to the reference point but if generated by the command then it is already handled
    -- for best look, try to put the reference point to center, like a center of circle, not so important as variance might shift the crater
    -- the X is always "even", Y is always "even" +0.5, that is how cliffs work
    -- orientation is the list of cliffs, and can be multiple because some shaped cliffs overlap
    ["cl_-4/2.5"] = { x = -4, y = 2.5, cliffs = { "east-to-west",  } }
  },
  -- the area to clear the regular cliffs from before putting our cliffs
  clearance = {
    center = { x = 3, y = 3}, -- theoretical center point, the reference used by command does not need to be center, so this is another point calculated by command in case radius shall be used
    radius = 64, -- the radius needed to clear from center point, might be unnecessarily large if the shape is elipsis
    box = { -- the boxed area which is calculated by min/max of x/y of cliffs with some slack
      left_top = { x = -50, y = -50 }, 
      right_bottom = { x = 25, y = 75 }
    }
  }
}

return crater