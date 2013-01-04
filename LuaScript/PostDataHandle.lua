
                     local log_dict = ngx.shared.log_dict
                     local redis = require "resty.redis"
                     local json = require "json"

                     local red = redis:new()
                     red:set_timeout(1000)
                     local ok,err = red:connect("127.0.0.1",6379)
                     if not ok then
                        succ, err, forcible = log_dict:set(os.date("%x/%X"),"Fail connect to local redis , Error info "..err)
                        return
                     end

                     -- Every player data,pending list and end list store in "redata" redis server
                     local redata = redis:new()
                     redata:set_timeout(1000)
                     local ok,err = redata:connect("127.0.0.1",6379)
                     if not ok then
                        succ, err, forcible = log_dict:set(os.date("%x/%X"),"Fail connect to remote redis , Error info "..err)
                        return
                     end
 
                     -- Public functions

                     -- Calculate the number of elements for table
                     function htgetn(hashtable)
                        local n = 0
                        for _,v in pairs(hashtable) do
                            n = n + 1
                        end
                        return n
                     end
                     
                     -- To parse user os and browser information from agent
                     function ParseOSandBrowser(agent)
                        -- OS
                        if string.find(agent,"Linux") then
                           os = "linux"
                        elseif string.find(agent,"Windows NT 5.0") or string.find(agent,"Windows 2000") then
                           os = "windows 2000"
                        elseif string.find(agent,"Windows NT 5.1") or string.find(agent,"Windows XP") then
                           os = "windows xp"
                        elseif string.find(agent,"Windows NT 5.2") then
                           os = "windows server 2003"
                        elseif string.find(agent,"Windows NT 6.0") then
                           os = "windows vista"
                        elseif string.find(agent,"Windows NT 6.1") then
                           os = "windows 7"
                        elseif string.find(agent,"Windows NT 6.2") then
                           os = "windows 8"
                        elseif string.find(agent,"Windows ME") then
                           os = "windows me"
                        elseif string.find(agent,"OpenBSD") then
                           os = "openbsd"
                        elseif string.find(agent,"SunOS") then
                           os = "sunos"
                        elseif string.find(agent,"Mac_PowerPC") or string.find(agent,"Macintosh") then
                           os = "macos"
                        else
                           os = "Unknown"
                        end

                        -- Browser
                        if string.find(agent,".*Firefox/([.0-9]+)") then
                           _,_,ver = string.find(agent,".*Firefox/([.0-9]+)")
                           browser = "firefox "..ver
                        elseif string.find(agent,".*MSIE%s+([.0-9]+)") then
                           _,_,ver = string.find(agent,".*MSIE%s+([.0-9]+)")
                           browser = "msie "..ver
                        elseif string.find(agent,".*Chrome/([.0-9]+)") then
                           _,_,ver = string.find(agent,".*Chrome/([.0-9]+)")
                           browser = "chrome "..ver
                        else
                           browser = "Unknown"
                        end

                        return os,browser
                     end

                     
                     -- Handle player load failure
                     function PlayerLoadFail(key,value)
                        local remoteip = ngx.var.remote_addr
                        local useragent = ngx.var.http_user_agent
                        local time = os.time() 
                        local os,browser = ParseOSandBrowser(useragent)

                        value["os"] = os
                        value["browser"] = browser
                        value["ip"] = remoteip
                        value["loadtime"] = time

                        jsonvalue = json.encode(value)
                                           
                        local ok,err = red:set(key,jsonvalue)
                        if not ok then
                           succ, err, forcible = log_dict:set(os.date("%x/%X"),"Fail set to redis , Error info "..err)
                           return
                        end
                     end

                     -- Handle check user remaining flow
                     function CheckFlow(key,value)
                        local remoteip = ngx.var.remote_addr
                        local useragent = ngx.var.http_user_agent
                        local time = os.time()
                        local os,browser = ParseOSandBrowser(useragent)

                        value["os"] = os
                        value["browser"] = browser
                        value["ip"] = remoteip
                        value["loadtime"] = time

                        -- Record client area information
                        value["country"] = ngx.var.geoip_city_country_name
                        value["city"] = ngx.var.geoip_city
                        
                        jsonvalue = json.encode(value)

                        local ok,err = red:set(key,jsonvalue)
                        if not ok then
                           succ, err, forcible = log_dict:set(os.date("%x/%X"),"Fail set to redis , Error info "..err)
                           return
                        end

                        -- Check flow and return result to client
                        -- If the flow surplus,write vid_pid to pending list
                         
                     end
                   
                     -- Handle play video failure in first play
                     function PlayVideoFail(key,value)
                        local time = os.time()
                    
                        value["starttime"] = time
                        jsonvalue = json.encode(value)
 
                        local ok,err = red:set(key,jsonvalue)
                        if not ok then
                           succ, err, forcible = log_dict:set(os.date("%x/%X"),"Fail set to redis , Error info "..err)
                           return
                        end
                     end

                     -- Handle play video success
                     function PlayVideoSuc(key,value)
                        local time = os.time()

                        value["starttime"] = time
                        jsonvalue = json.encode(value)

                        local ok,err = red:set(key,jsonvalue)
                        if not ok then
                           succ, err, forcible = log_dict:set(os.date("%x/%X"),"Fail set to redis , Error info "..err)
                           return
                        end
                     end
                     
                     -- Handle video play window close
                     function PlayWindowClose(vid,pid,value)
                        -- Handle the playback data
                        local res,err = red:get("")
                        -- Write vid_pid to end list
                     end

                     -- Handle receive play information every 10 seconds
                     function RecPlayInfo(key,value)
                        jsonvalue = json.encode(value)

                        local ok,err = red:set(key,jsonvalue)
                        if not ok then
                           succ, err, forcible = log_dict:set(os.date("%x/%X"),"Fail set to redis , Error info "..err)
                           return
                        end
                     end

                     -- Handle video pause,drag,end
                     function VPauseDragEnd(key,value)
                        jsonvalue = json.encode(value)

                        local ok,err = red:set(key,jsonvalue)
                        if not ok then
                           succ, err, forcible = log_dict:set(os.date("%x/%X"),"Fail set to redis , Error info "..err)
                           return
                        end
                     end                     

                     -- Handle video stream switch
                     function VStreamSwitch(key,value)
                        jsonvalue = json.encode(value)

                        local ok,err = red:set(key,jsonvalue)
                        if not ok then
                           succ, err, forcible = log_dict:set(os.date("%x/%X"),"Fail set to redis , Error info "..err)
                           return
                        end
                     end

                     -- Handle video play error
                     function VideoPlayError(key,value)
                        jsonvalue = json.encode(value)

                        local ok,err = red:set(key,jsonvalue)
                        if not ok then
                           succ, err, forcible = log_dict:set(os.date("%x/%X"),"Fail set to redis , Error info "..err)
                           return
                        end
                     end

                     -- Main                     

                     ngx.req.read_body()
                     local args = ngx.req.get_post_args()

                     if htgetn(args) == 2 then

                          for name , value in pairs(args) do
                              if name ~= "key" and name ~= "value" then
                                 succ, err , forcible = log_dict:set(os.date("%x/%X"),"The post parameter name "..name.." is incorrect")
                                 return 
                              end
                          end
                        
                          a,b,vid,pid,flag = string.find(args["key"],"(.*)_(.*)_(.*)")

                          if (string.len(vid) == 7 and string.len(pid) == 4) and (string.len(flag) == 1 or string.len(flag) == 2) then
                                                         
                             UserId = string.sub(vid,1,4)
                             FileId = string.sub(vid,5,-1)
                   
                             lua = "return "..args["value"]
                             local func = loadstring(lua)
                             tablevalue = func()       
  
                             -- Do different according to the different flags 
                             -- Load player failure
                             if flag == "X" then
                                PlayerLoadFail(args["key"],tablevalue)
                             end
                             
                             -- Check user flow
                             if flag == "Y" then
                                CheckFlow(args["key"],tablevalue)
                             end

                             -- Play video failure in play start
                             if flag == "X0" then
                                PlayVideoFail(args["key"],tablevalue)
                             end

                             -- Play video success
                             if flag == "0" then
                                PlayVideoSuc(args["key"],tablevalue)
                             end
                          
                             -- Receive play information every 10 seconds
                             if flag == "P" then
                                RecPlayInfo(args["key"],tablevalue)
                             end

                             -- Video play window close
                             if flag == "C" then
                                PlayWindowClose(vid,pid,tablevalue)
                             end

                             -- Video pause,drag and end 
                             if tonumber(flag) and tonumber(flag) >= 1 then
                                VPauseDragEnd(args["key"],tablevalue)
                             end

                             -- Video stream switch
                             if string.sub(flag,1,1) == "L" then
                                VStreamSwitch(args["key"],tablevalue)
                             end

                             -- Video play error during play
                             if string.sub(flag,1,1) == "X" and string.len(flag) > 1 then
                                PlayVideoError(args["key"],tablevalue) 
                             end
                 
                          else
                             succ, err, forcible = log_dict:set(os.date("%x/%X"),args["key"].." data format is incorrect")
                             return
                          end                        
                           
                     else
                          succ, err, forcible = log_dict:set(os.date("%x/%X"),"the number of parameters be 2,but it is "..htgetn(args))
                          return
                     end

                                          
