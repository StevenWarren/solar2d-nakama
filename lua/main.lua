-- 
-- Abstract: Nakama Library Plugin Test Project
-- 
-- Sample code is MIT licensed, see http://www.coronalabs.com/links/code/license
-- Copyright (C) 2015 Corona Labs Inc. All Rights Reserved.
--
------------------------------------------------------------

-------------------------------------------------------------------------------
-- Helper methods
-------------------------------------------------------------------------------
local divider = string.rep('=', 50)
local function header(text)
    print(divider)
    print('= ',text)
    print(divider)
end
local function footer()
    print(divider)
    print('')
end

local function printTable( t )
 
    local printTable_cache = {}
 
    local function sub_printTable( t, indent )
 
        if ( printTable_cache[tostring(t)] ) then
            print( indent .. "*" .. tostring(t) )
        else
            printTable_cache[tostring(t)] = true
            if ( type( t ) == "table" ) then
                for pos,val in pairs( t ) do
                    if ( type(val) == "table" ) then
                        print( indent .. "[" .. pos .. "] => " .. tostring( t ).. " {" )
                        sub_printTable( val, indent .. string.rep( " ", string.len(pos)+8 ) )
                        print( indent .. string.rep( " ", string.len(pos)+6 ) .. "}" )
                    elseif ( type(val) == "string" ) then
                        print( indent .. "[" .. pos .. '] => "' .. val .. '"' )
                    else
                        print( indent .. "[" .. pos .. "] => " .. tostring(val) )
                    end
                end
            else
                print( indent..tostring(t) )
            end
        end
    end
 
    if ( type(t) == "table" ) then
        print( tostring(t) .. " {" )
        sub_printTable( t, "  " )
        print( "}" )
    else
        sub_printTable( t, "  " )
    end
end

-------------------------------------------------------------------------------
-- BEGIN (Insert your sample test starting here)
-------------------------------------------------------------------------------


-- Include plugin
local nakama = require "plugin.nakama"
-- Create configuration
local config = {
    host = "127.0.0.1",
    port = 7350,
    use_ssl = false,
    username = "defaultkey",
    password = ""
}
-- init client
local client = nakama.create_client(config)

-- Create a session VIA email
local email = "super@heroes.com"
local password = "batsignal"
local body = nakama.create_api_account_email(email, password)
local session = {}

-- if run from within a coroutine
local function getAccount()
    header('Get Account called')
    local account = nakama.get_account(client)
    print("Coroutine-User ID:",account.user.id);
    print("Coroutine-Username:",account.user.username);
    print("Coroutine-Wallet:",account.wallet);
    footer()
end
local co = coroutine.create ( getAccount )

local function joinChat()
    -- create socket
    local socket = nakama.create_socket(client)

    nakama.sync(function()
        header("Socket")
        -- connect
        local ok, err = nakama.socket_connect(socket)
        print("Connect:",ok,err)
        -- add socket listeners
        nakama.on_disconnect(socket, function(message)
            print("Disconnected!")
        end)
        nakama.on_channelpresence(socket, function(message)
            print(message)
        end)
    
        -- send channel join message
        local channel_id = "pineapple-pizza-lovers-room"
        local channel_join_message = {
            channel_join = {
                type = 1, -- 1 = room, 2 = Direct Message, 3 = Group
                target = channel_id,
                persistence = false,
                hidden = false,
            }
        }
        local result = nakama.socket_send(socket, channel_join_message)
        printTable(result)

    end)
end

local function sessionCallback(event)
    header('sessionCallback called')
    session = event
    print("Token:",session.token) -- raw JWT token
    print("User ID:",session.user_id)
    print("Username:",session.username)
    print("Expiry:",session.expires)
    print("Created:",session.created)
    footer()
    -- The Nakama client provides a convenience function for creating and starting a coroutine 
    -- to run multiple requests synchronously one after the other
    nakama.sync(function()
        -- Use the token to authenticate future API requests
        nakama.set_bearer_token(client, session.token)

        -- get account details
        local account = nakama.get_account(client)
        print("nakama.sync Initial-User ID:",account.user.id);
        print("nakama.sync Initial-Username:",account.user.username);
        print("nakama.sync Initial-Wallet:",account.wallet);
        print("nakama.sync Initial-DisplayName:",account.user.display_name);
        print("nakama.sync Initial-AvatarUrl:",account.user.avatar_url);
        print("nakama.sync Initial-Location:",account.user.location);

        -- update account
        local result = nakama.update_account(client, {
            display_name = "User"..math.random(1000),
            avatar_url = "http://graph.facebook.com/avatar_url",
            location = "San Francisco"
          })
          
        local account = nakama.get_account(client)
        printTable(account)
        print("nakama.sync AfterUpdate-User ID:",account.user.id);
        print("nakama.sync AfterUpdate-Username:",account.user.username);
        print("nakama.sync AfterUpdate-Wallet:",account.wallet);
        print("nakama.sync AfterUpdate-DisplayName:",account.user.display_name);
        print("nakama.sync AfterUpdate-AvatarUrl:",account.user.avatar_url);
        print("nakama.sync AfterUpdate-Location:",account.user.location);

        joinChat()

    end)

    -- test standalone coroutine
end

nakama.authenticate_email(client, body, true, nil, sessionCallback)


-- create socket
local socket = nakama.create_socket(client)


-------------------------------------------------------------------------------
-- END
-------------------------------------------------------------------------------
