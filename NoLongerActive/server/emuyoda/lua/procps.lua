--
-- procps - Provide various procs like functions
--
-- Loosely based on https://launchpad.net/ubuntu/+source/procps
--
-- Author: Lord Kator <lordkator@swgemu.com>
--
-- Created: Sat Jan 23 05:01:30 EST 2016
--

local scandir = require "scandir"
local pairs = pairs
local tonumber = tonumber
local print = print
local math = math
local string = string
local io = io

module(...)

function hertz()
    return 100 -- /usr/include/asm-generic/param.h
end

function uptime()
    local fh = io.open("/proc/uptime")
    local ln = fh:read("*all")
    fh:close()
    local up = ln:gmatch("(%S+)")()
    return tonumber(up)
end

function etime(pid)
    local fh = io.open("/proc/" .. pid .. "/stat")

    if not fh then return nil, "invalid pid" end

    local stat = fh:read("*a")

    fh:close()

    value = { }
    for v in stat:gmatch("(%S+)") do
	value[#value+1] = v
    end

    -- TODO Is there a better way to know this? Will break some day when new kernels change /proc etc.
    -- http://lxr.free-electrons.com/source/fs/proc/array.c?v=3.16#L503
    -- start_time in ticks is column 22
    local start_time = value[22] / hertz()

    return uptime() - start_time
end

function etime_string(pid)
    local ss, err = etime(pid)

    if err then return nil, err end

    local dd = math.floor(ss / 86400)
    ss = ss - (dd * 86400)
    local hh = math.floor(ss / 3600)
    ss = ss - (hh * 3600)
    local mm = math.floor(ss / 60)
    ss = math.floor(ss - (mm * 60))

    if dd > 0 then
	return string.format("%d days, %02d:%02d:%02d", dd, hh, mm, ss)
    else
	return string.format("%02d:%02d:%02d", hh, mm, ss)
    end
end

function pgrep(expr)
    local files, err = scandir.scandir("/proc")

    if files == nil then
      return nil, "Failed to open dir: " .. err
    end

    local hits = { }

    for k,v in pairs(files) do
	if tonumber(k) ~= nil and files[k].type == 'DIR' then
	    local fh, err = io.open("/proc/" .. k .. "/status")

	    if fh then
		local ln, err = fh:read("*l")

		if ln then
		    local _, _, field, value = string.find(ln, "(%S+)%s+(%S+)")

		    if not expr or string.find(value, expr) then
			hits[tonumber(k)] = value
		    end
		end
		fh:close()
	    end
	end
    end

    return hits
end

function pgrep_pidlist(expr)
    local hits = pgrep(expr)

    pids = { }
    for k,v in pairs(hits) do
	pids[#pids+1] = k
    end

    return pids
end
