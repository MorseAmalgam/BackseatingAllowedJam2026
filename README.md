# Twitch Integration for Godot Template Project

This is a template project for integrating Twitch in Godot for the [Backseating Allowed Jam 2026](https://itch.io/jam/backseating-allowed-jam-2026)!

This project uses [Twitcher](https://twitcher.kani.dev/) for Twitch integration, but there are multiple options available.

### [Download Here](https://github.com/SomeRanDev/BackseatingAllowedJam-Godot/releases/download/1.0.0/BackseatingAllowedJam-Godot.7z)

## Setup

To start using this project, you must first obtain your Client ID and input it. To do so, create an application in the [Twitch Developer Console](https://dev.twitch.tv/console). Please add a "OAuth Redirect URL" of `http://localhost:1234` (or whatever port you desire).

Once you have it, return to Godot and open the setup page for Twitcher by going to `Project` -> `Tools` -> `Twitcher` -> `Setup`. Since you're creating a game, select "Game". Next, select "Authorization Code Flow". Enter your Client ID in the "Client ID" field. Finally, click "save" and close the popup.

Now you should be good to go! When you run the game, it will open your browser to authorize it to control your Twitch account to read and create redeems and messages. When a streamer plays your game, they will see this too and must accept for your integration to work!

## Recreation Tutorial

If you'd like to start from scratch, you can recreate this project by doing the following:

1) Create a new Godot project.

2) Enter the "Asset Store" tab at the top of Godot, search for "Twitcher", then download and install the addon. The version of Twitcher used for this project is `2.5.1`.

3) Enable the addon by going to `Project` -> `Project Settings` -> `Plugins` -> clicking "On" for "Twitcher".

4) Restart Godot and reopen your project.

From this point forward I would recommend following the [Quick Start guide for Twitcher](https://twitcher.kani.dev/introduction/getting-started.html). What I personally did is listed below:

5) You will be prompted with a Setup page for Twitcher. Since you're creating a game, select "Game". Next, select "Authorization Code Flow". Enter your Client ID in the "Client ID" field. Finally, click "save" and close the popup.

6) Create a scene for your game. This should be the main scene of your game where Twitch interations are expected to occur.

7) Follow [this guide](https://twitcher.kani.dev/core-nodes/twitch-service.html). Add a `TwitchService` node to the scene. For this project `TwitchAPI`, `TwitchAuth`, `TwitchIRC`, and `TwitchEventsub` nodes were added as children to it.

8) Click on the `TwitchServer` node and create a new `TwitchOAuthScopes` resource in the `Scopes` parameter. In this resource, we want to be able to create and react to redeems, so the `channel:manager:redemptions` and `channel:read:redemptions` boxes are checked. We also want to be able to read/write chat, so `user:read:chat` and `user:write:chat` are checked.

9) Finally, code is added to the "Code" node (listed below `TwitchService` so its `_ready` runs after it!).
