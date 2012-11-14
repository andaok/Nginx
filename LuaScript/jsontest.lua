local redis = require "resty.redis"
local json = require "json"
local red = redis:new()

red:set_timeout(1000)

test = {
  one='first',two='second',three={2,3,5}
}

jsonTest = json.encode(test)


                local ok, err = red:connect("127.0.0.1", 6379)
                if not ok then
                    ngx.say("failed to connect: ", err)
                    return
                end

                ok, err = red:set("json", jsonTest)
                if not ok then
                    ngx.say("failed to set json: ", err)
                    return
                end

                ngx.say("set result: ", ok)

                local res, err = red:get("json")
                if not res then
                    ngx.say("failed to get json: ", err)
                    return
                end

                if res == ngx.null then
                    ngx.say("json not found.")
                    return
                end

                ngx.say("json: ", res)


