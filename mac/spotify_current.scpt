if application "Spotify" is running then
    tell application "Spotify"
        set status to the player state
        set ct to the current track

        return status & "SDUNCAN" & artist of ct & "SDUNCAN" & name of ct
    end tell
end if
