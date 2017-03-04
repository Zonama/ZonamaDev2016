local procps = require "procps"

local found = procps.pgrep_pidlist("core3")

if #found > 1 then
    print("Multiple hits found!")
end

local pid = found[1]

print(found[1])

if pid then
    print(procps.etime(pid))
    print(procps.etime_string(pid))

    local fh = io.popen("ps -p " .. pid .. " -ho etime")

    print(fh:read("*a"))

    fh:close()
end

