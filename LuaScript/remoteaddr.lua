-- Get Client Remote IP Address 

ngx.say("Client IP Addr:")

remoteip = ngx.var.remote_addr

ngx.say(remoteip)

ngx.say("request_uri")

requesturi = ngx.var.request_uri

ngx.say(requesturi)

--[[ Get content_length ]]

ngx.say(ngx.var.content_length)

-- GET REQUEST METHOD

ngx.say(ngx.var.request_method)


-- GET REQUEST METHOD BY OTHER METHOD

ngx.say(ngx.req.get_method())

-- GET REQUEST HEADER

headtable = ngx.req.get_headers()

for k,v in pairs(headtable) do
    ngx.say(k,":",v)
end


