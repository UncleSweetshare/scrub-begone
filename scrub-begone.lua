local loginManager = sdk.get_managed_singleton("app.LoginManager")
local playerManager = sdk.get_managed_singleton("app.worldtour.WTPlayerManager")

-- Checks if the short_id (args[4]) refers to a blocked player.
-- If it does, the local player's own ID is passed to MakeDispPlayerList instead.
-- This will cause the function to return without adding the player to the list.
local function pre_MakeDispPlayerList(args)
    -- Parse args[4] as a UInt32
    local short_id = sdk.to_int64(args[4]) & 0xFFFFFFFF
    
    -- Get the app.network.api.Enum.Friendship value for the other player.
    -- A Friendship of 5 means the player is blocked.
    local friendship = loginManager:call("GetFriendshipFromCache", short_id):get_field("Item1")
    
    -- Swap args[4] with the local player's ID if the other player is blocked
    if (friendship == 5) then
        local playerData = playerManager:get_field("<LocalPlayerData>k__BackingField")
        args[4] = playerData:call("get_ShortId")
    end
    
    return sdk.PreHookResult.CALL_ORIGINAL
end

-- Returns from a hooked function as normal
local function post_MakeDispPlayerList(retval)
    return retval
end

sdk.hook(
    sdk.find_type_definition("app.worldtour.WTPlayerManager"):get_method("MakeDispPlayerList"),
    pre_MakeDispPlayerList,
    post_MakeDispPlayerList
)

-- Skips the hooked function entirely
local function pre_SetVisible_AllPlayer(args)
    return sdk.PreHookResult.SKIP_ORIGINAL
end

-- Returns void
local function post_SetVisible_AllPlayer(retval)
end

sdk.hook(
    sdk.find_type_definition("app.worldtour.avatar.AvatarManager"):get_method("SetVisible_AllPlayer"),
    pre_SetVisible_AllPlayer,
    post_SetVisible_AllPlayer
)
