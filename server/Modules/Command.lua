lib.addCommand(Config.Commands.updateLevel, {
    help = LANG.CoreLang("updatePlayerLevelHelp"), 
    params = {
        {
            name = 'target',
            type = 'playerId',
            help = LANG.CoreLang("updatePlayerLevelTargetHelp"), 
        },
        {
            name = 'level',
            type = 'number',
            help = LANG.CoreLang("updatePlayerLevelLevelHelp"), 
        },
        {
            name = 'type',
            type = 'string',
            help = LANG.CoreLang("updatePlayerLevelTypeHelp"),
        },
    },
}, function(source, args)
    local PlayerGroup = LGF.Core:GetGroup(source)

    if Config.AllowedGroupsCommand[PlayerGroup] then
        local success, updatedLevel = Functions.updatePlayerLevel(args.target, args.level, args.type)

        if success then
            Shared.Notification(
                LANG.CoreLang("levelUpdated"),                       
                LANG.CoreLang("levelUpdatedDescription"):format(updatedLevel), 
                "top-right",
                "success",
                source
            )
        else
            Shared.Notification(
                LANG.CoreLang("levelUpdateError"),        
                LANG.CoreLang("levelUpdateErrorDescription"),
                "top-right",
                "error",
                source
            )
        end
    else
        Shared.Notification(
            LANG.CoreLang("permissionDenied"),         
            LANG.CoreLang("permissionDeniedDescription"),
            "top-right",
            "error",
            source
        )
    end
end)

lib.addCommand(Config.Commands.clearReward, {
    help = LANG.CoreLang("clearRewardHelp"), 
    params = {
        {
            name = 'target',
            type = 'playerId',
            help = LANG.CoreLang("clearRewardTargetHelp"), 
        },
    },
}, function(source, args)
    local PlayerGroup = LGF.Core:GetGroup(source)

    if Config.AllowedGroupsCommand[PlayerGroup] then
        local success, message = Functions.clearRewardRedeemed(args.target)

        if success then
            Shared.Notification(
                LANG.CoreLang("rewardsCleared"),          
                LANG.CoreLang("rewardsClearedDescription"),
                "top-right",
                "success",
                source
            )
        else
            Shared.Notification(
                LANG.CoreLang("clearRewardsError"),          
                LANG.CoreLang("clearRewardsErrorDescription"),
                "top-right",
                "error",
                source
            )
        end
    else
        Shared.Notification(
            LANG.CoreLang("permissionDenied"),         
            LANG.CoreLang("permissionDeniedDescription"),
            "top-right",
            "error",
            source
        )
    end
end)