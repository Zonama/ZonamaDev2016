--
-- scandir - Provide scandir function for Lua
--
-- Author: Lord Kator <lordkator@swgemu.com>
--
-- Created: Sat Jan 23 10:02:46 EST 2016
--

local ffi = require "ffi"

module(...)

ffi.cdef[[
typedef long unsigned int size_t;
typedef unsigned long int __ino_t;
typedef long int __off_t;
struct dirent
  {
    __ino_t d_ino;
    __off_t d_off;
    unsigned short int d_reclen;
    char d_type;
    char d_name[256];
  };
typedef struct __dirstream DIR;
extern DIR *opendir (__const char *__name);
extern int closedir (DIR *__dirp);
extern struct dirent *readdir (DIR *__dirp);
extern void rewinddir (DIR *__dirp);
extern void seekdir (DIR *__dirp, long int __pos);
extern long int telldir (DIR *__dirp);
]]

local d_types = { "FIFO", "CHR", "", "DIR", "", "BLK", "", "REG", "", "LNK", "", "SOCK", "", "WHT" }

function scandir(dirname)
  local dfh = ffi.C.opendir(dirname)
  local ret = { }

  if dfh == nil then
    return nil, "opendir(" .. dirname .. ") failed"
  end

  while true do
    local de = ffi.C.readdir(dfh)

    if de == nil then
      break
    end

    local d_name = ffi.string(de.d_name)
    local d_ino  = de.d_name
    local d_type = d_types[de.d_type]

    ret[d_name] = { name = d_name, ino = d_ino, type = d_type }
  end

  ffi.C.closedir(dfh)

  return ret, nil
end
