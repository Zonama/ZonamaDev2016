local scandir = require "scandir"

local files, err = scandir.scandir(".")

if files == nil then
  print("Failed to open dir: " .. err)
  os.exit(1)
end

local keys = { }
for k,v in pairs(files) do table.insert(keys, k) end
table.sort(keys)

for _,k in pairs(keys) do
    print(k)
    -- print(k .. " type " .. files[k].type)
end

os.exit(0)
