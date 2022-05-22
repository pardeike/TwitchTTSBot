# TwitchTTSBot
A simple command line twitch bot written in Swift 5 using swift-nio-irc-client

This twitch bot uses swift-nio to connect to twitch with oauth and a given channel. It will speak all messages ending in an exclamation mark and has a configurable cooldown to avoid spaming.

## Dependencies (via Swift Package Manager)
- swift-nio (2.40)
- swift-nio-irc (0.8.2)
- swift-nio-irc-client (main)
- swift-nio-transportation-services (1.12)
- IGIdenticon (naster)

## Usage
```
./TwitchTTSBot CHANNELNAME OAUTHTOKEN
```

To get a OAUTHTOKEN, go to https://twitchapps.com/tmi/ and make sure you are logged in with the account the bot should use (can be your own accout if you like to).

The CHANNELNAME is just the name of your Twitch channel.

## Tested On
- macOS Monterey
- Xcode 13.4

## Simplified Implementation

Great as a starting point for your own bot.

Check out [main.swift](https://github.com/pardeike/TwitchTTSBot/blob/main/TwitchTTSBot/main.swift)


