
ngx.req.read_body()

local args = ngx.req.get_post_args()

for key , val in pairs(args) do
    if type(val) == "table" then
       ngx.say(key,":",table.concat(val,","))
    else
       ngx.say(key,":",val)
    end
end 
