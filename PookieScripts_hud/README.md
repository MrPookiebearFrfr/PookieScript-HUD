# BLRSP Peacetime & Postal HUD

## Features

- Peacetime toggle with permissions
- Priority status (in progress, on hold, cooldown, reset)
- Area of Patrol (AOP) display and command
- Postal HUD (using nearest postal logic)
- Clean UI (NUI-based)
- Postal map support (see below)

---

## Permissions Setup

To restrict commands (AOP, Peacetime, Priority) to certain users or groups, add these lines to your `server.cfg`:

```ini
# Allow AOP and Peacetime commands for admins using PookieHud permissions
add_ace group.admin command.PookieHud.aop allow
add_ace group.admin command.PookieHud.peacetime allow
add_ace group.admin command.PookieHud.priority allow

# Example: assign a user to admin group by Steam hex
add_principal identifier.steam:yoursteamhex group.admin

# Example: assign by Discord ID (replace with your Discord ID, remove quotes)
add_principal identifier.discord:yourdiscordid group.admin
```

- Replace `yoursteamhex` with your actual Steam hex (no `steam:` prefix).
- Replace `yourdiscordid` with your Discord ID (numbers only, no `discord:` prefix).

**In your server-side command registration, use:**
```lua
RegisterCommand("setaop", function(...) ... end, true) -- true = restricted
RegisterCommand("peacetime", function(...) ... end, true)
RegisterCommand("priority", function(...) ... end, true)
-- Only users with the correct ace permissions can use these commands.
```

---

## Postal Map

This script uses the [nearest-postal](https://github.com/blockba5her/nearest-postal) system and expects a postal map compatible with the codes in `postals.lua`.

**Recommended map:**  
- [Newest Gabz/BlockBa5her Postal Map](https://forum.cfx.re/t/release-nearest-postal-script/293511)
- Download the postal map and place the YTD/YFT files in your server's `stream` folder or as a separate resource.

**Make sure the postal codes in your map match those in `postals.lua`.**

---

## Adding Discord Permissions

To give Discord users permission, add this to your `server.cfg`:

```ini
add_principal identifier.discord:YOUR_DISCORD_ID group.admin
```
- Replace `YOUR_DISCORD_ID` with the user's Discord numeric ID (no quotes, no `discord:` prefix).

---

## Usage

- `/setaop [area]` — Set the Area of Patrol (AOP)
- `/peacetime` — Toggle peacetime on/off
- `/priority` — Manage priority status (see commands in `server.lua`)
- Postal HUD will display automatically on the UI

---

## Troubleshooting

- If postal always says "N/A", make sure:
  - `postals.lua` is loaded before `client.lua` in `fxmanifest.lua`
  - Your postal map matches the codes in `postals.lua`
  - There are no syntax errors in `postals.lua` (should end with a single `}`)

---
