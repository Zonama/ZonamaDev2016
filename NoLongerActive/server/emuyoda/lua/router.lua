--
-- router - Route calls to api functions
--
-- Author: Lord Kator <lordkator@swgemu.com>
--
-- Created: Sat Dec 12 18:50:24 EST 2015
--

-- Globals we will want to reference in our module
local api = require "api"
local ngx = ngx or require "ngx"
local cjson = require "cjson"
local setmetatable = setmetatable
local pairs = pairs

module(...)

local routes = {
    ['account']		= api.service_account,
    ['auth']		= api.service_auth,
    ['config']		= api.service_config,
    ['console']		= api.service_console,
    ['control']		= api.service_control,
    ['status']		= api.service_status,
    ['version']		= api.service_version,
}

function init()
end

function process_request()
  -- Set the content type
  ngx.header.content_type = 'application/json';

  -- Our URL base, must match location in nginx config
  local BASE = '/api/'

  for pattern, api_function in pairs(routes) do
      local uri = '^' .. BASE .. pattern
      local match = ngx.re.match(ngx.var.uri, uri, "oj")

      if match then
	  local ret, exit = api_function(match) 

	  -- Detect JSONP
	  local callback = ngx.req.get_uri_args()['callback']
	  if callback then
	      ret = callback .. '(' .. ret .. ');'
	  end

	  -- Allow CORS
	  ngx.header['Access-Control-Allow-Origin'] = '*';

	  -- Print the returned res
	  ngx.print(ret)

	  -- If not given exit, then assume OK
	  if not exit then exit = ngx.HTTP_OK end

	  -- Exit with returned exit value
	  ngx.exit( exit )
      end
  end

  -- no match, return 404
  ngx.exit( ngx.HTTP_NOT_FOUND )
end

local class_mt = {
  -- to prevent use of casual module global variables
  __newindex = function (table, key, val)
    error('attempt to write to undeclared variable "' .. key .. '"')
  end
}

setmetatable(_M, class_mt)

_M.init()

-- vi: set ai sw=2:
