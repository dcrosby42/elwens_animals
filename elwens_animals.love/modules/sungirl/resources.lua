local R = require 'resourceloader'

local Res = {}

local PicPrefix = "data/images/sungirl"
-- local SoundPrefix = "data/sounds/sungirl"

local function addPic(res, name, path)
  if not path then
    path = PicPrefix .. "/" .. name .. ".png"
  end
  res.pics[name] = R.makePic(path)
end


-- cached resources object, populated after Res.load()
local resources

function Res.load()
  if resources then return resources end

  resources = {
    pics={},
    sounds={},
  }

  addPic(resources, "background01")

  return resources
end

return Res
