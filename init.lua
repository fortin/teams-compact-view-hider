-- Automatically minimise the Microsoft Teams compact meeting view

local teamsBundleID = "com.microsoft.teams2"
local compactPrefix = "Meeting compact view |"

local function minimiseCompactWindow(element)
    local title = element:attributeValue("AXTitle") or ""
    local subrole = element:attributeValue("AXSubrole")

    if title:sub(1, #compactPrefix) == compactPrefix
        and subrole == "AXSystemDialog" then

        element:setAttributeValue("AXMinimized", true)
        print("[Teams] Compact view minimised")
    end
end

local function watchTeams(app)
    if teamsCompactObserver then
        teamsCompactObserver:stop()
        teamsCompactObserver = nil
    end

    local axApp = hs.axuielement.applicationElement(app)

    teamsCompactObserver = hs.axuielement.observer
        .new(app:pid())
        :callback(function(observer, element, notification)
            if notification == "AXWindowCreated" then
                minimiseCompactWindow(element)
            end
        end)
        :addWatcher(axApp, "AXWindowCreated")
        :start()

    -- Also check existing windows
    for _, window in ipairs(
        axApp:attributeValue("AXWindows") or {}
    ) do
        minimiseCompactWindow(window)
    end

    print("[Teams] Compact view observer started")
end

-- Monitor Teams launching and quitting
teamsCompactAppWatcher = hs.application.watcher.new(
    function(name, event, app)
        if event == hs.application.watcher.launched
            and app:bundleID() == teamsBundleID then

            watchTeams(app)

        elseif event == hs.application.watcher.terminated
            and teamsCompactObserver then

            local teams = hs.application.get(teamsBundleID)
            if not teams then
                teamsCompactObserver:stop()
                teamsCompactObserver = nil
            end
        end
    end
)

teamsCompactAppWatcher:start()

-- Attach immediately if Teams is already running
local teams = hs.application.get(teamsBundleID)
if teams then
    watchTeams(teams)
end
