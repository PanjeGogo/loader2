# Throw Food for Animals — Mythios Loader Investigation

**Status:** Client-side loader flow identified. The actual game-specific payload has not been recovered or matched to a public source.

## Target identity

- Game: Throw Food for Animals
- PlaceId: `120219252362013`
- UniverseId / GameId: `10766972131`
- Provider: Mythios
- Slug: `@freemium`
- Host: `https://mythios.online`

The IDs are target identifiers from the observed request. The decoded client reads the current PlaceId and GameId at runtime; it does not hardcode these target IDs.

## Local source inspected

A prior Library upload was found and read:

- File: `Mythios_client_decoded.lua`
- Size: 66,812 bytes
- Length: 1,979 lines
- Header says it was statically decoded from `client.txt`.
- The source itself says it was not executed.

This is the Mythios client/loader source, not the downloaded game-specific payload.

## Client-side loader architecture

The decoded client establishes:

1. `SLUG="@freemium"` and `BASE="https://mythios.online"`.
2. It reads `game.PlaceId` and `game.GameId` locally.
3. It gathers client identity fields, including an executor HWID, a generated nonce, timestamp, and optional executor name.
4. For `@freemium` / `@premium`, it first uses a combined request to `/api/start.php`.
5. That request includes the script slug, key, HWID, nonce, timestamp, PlaceId, GameId, and optional executor name. Startup requests also include phase/UI flags.
6. The expected response is a framed `MYTH1\n` response containing JSON game information, an authorization section, and a load section.
7. The client validates the server response and access status. The payload is then checked for integrity, decoded/decrypted locally, compiled, and invoked.
8. The client starts a separate heartbeat request after successful preparation.

If the combined startup response does not contain usable game information, the client falls back to `/api/loader-info.php?place_id=...`. The older staged flow uses `/api/auth.php` and `/api/load.php` when the combined flow is not used or cannot be used.

### Important distinction

The `/api/start.php` response is not necessarily just an authorization result: the client expects it to carry both authorization data and a load payload. In the combined flow, the load section is already present in that response. In the legacy flow, the client requests the load section separately from `/api/load.php`.

The source contains cryptographic integrity and payload-protection logic. This report does not attempt to forge authorization data, derive access secrets, bypass key/HWID checks, or reconstruct a payload without authorized access.

## Repository inspected

Repository: [PanjeGogo/loader2](https://github.com/PanjeGogo/loader2)  
Branch: `main`

Inspected:
- [loader.lua](https://github.com/PanjeGogo/loader2/blob/main/loader.lua)
- [src/config.json](https://github.com/PanjeGogo/loader2/blob/main/src/config.json)
- [src/](https://github.com/PanjeGogo/loader2/tree/main/src)

### Finding: loader2 is a separate Prospecting loader

The current `loader.lua`:
- Uses GitHub raw/jsDelivr CDNs pointing to this repository's `src/` directory.
- Maps only PlaceId `129827112113663` to `prospecting.lua`.
- Sets the UI title to `Prospecting`.
- Downloads `config.json`, prerequisite modules, and then `prospecting.lua`.
- Does not reference `mythios.online`, `@freemium`, PlaceId `120219252362013`, or UniverseId `10766972131`.

The current `src/config.json` identifies the payload as Prospecting! v2.4 and lists `TaskManager` and `ShoppingMart` as prerequisites.

**Conclusion:** the existing `loader.lua` and `src/` files are not the Mythios client and do not contain the Throw Food for Animals payload. No existing file was overwritten.

## Public-source leads found

These are leads for the same game, not proof of a relationship to Mythios.

1. **Catmio corpus sample**  
   [Loader.lua](https://github.com/francyw22/kittyobf/blob/4d61ad1d85951e91c086cc9a2b6b396d97b7c7b3/corpus/Loader.lua) maps PlaceId `120219252362013` to `ThrowFood.lua` and downloads from the Catmio Worker host.  
   [ThrowFood.lua sample](https://github.com/francyw22/kittyobf/blob/4d61ad1d85951e91c086cc9a2b6b396d97b7c7b3/corpus/games/ThrowFood.lua) identifies itself as Catmio - Throw Food and references game remotes such as `Training_Start` and `Training_Stop`. The repository path is a corpus/test fixture, so provenance and current availability need independent confirmation.

2. **NoctarionHub loader mapping**  
   [Loader/list.lua](https://github.com/NoctarionHub/Main/blob/40915ca9cbef4611e392498aada27b3e43904973/Loader/list.lua) maps the target PlaceId to `https://nhmain.vercel.app/Games/food_animal/main.lua`. A public fetch of that path returned heavily obfuscated Lua. This is a third-party candidate, not a verified Mythios source.

3. **Serenity Hub loader mapping**  
   [Public loader](https://github.com/MUshihara/Serenity-hub/blob/main/loader.lua) recognizes the target PlaceId and maps it to `dist/runtime/games/1.lua`. That file is only a bootstrap to a Luarmor loader URL; it does not expose the game-specific source directly.

4. **Other game-specific configuration**  
   [DarkMooN-SYS config](https://github.com/DarkMooN-SYS/Scripts/blob/f8b63dc15ad8a1dc1960c1c3a1ae1ac48c980416/Games/Throw%20Food%20For%20Animals/Config.lua) confirms the same PlaceId, UniverseId, and game title, but the inspected file is configuration only.

5. **Mythios search**  
   GitHub code search for `mythios.online` returned only an unrelated loader reference in an Anime Adventures text file. No public result found so far ties Mythios `@freemium` to a source file for this target game.

## What remains unresolved

- The actual game-specific Lua/Luau source delivered in the `load` section of the Mythios response.
- Whether Mythios uses a unique payload for this game or delegates to another source.
- Whether the user's captured `/api/start.php` response contains a complete load section for an authorized session.
- A source-level match between any public candidate and the Mythios payload.

## Next evidence needed

Provide a sanitized capture of the successful, authorized `/api/start.php` response or a permitted export of the payload. Remove keys, tokens, HWIDs, nonces, cookies, and other session credentials before sharing or committing. If the response contains only a rejection/status message, it cannot establish the payload source.

The next comparison should be static and provenance-focused: compare any legitimately obtained payload's game-specific remotes, module paths, and UI/features with the public candidates. Do not execute untrusted downloaded Lua merely to inspect it.

## Safety and provenance notes

- Do not forge keys, HWIDs, nonces, or authentication responses.
- Do not bypass paid access or server-side authorization.
- Do not label a third-party candidate as the Mythios original without direct evidence.
- Prefer static inspection of authorized source over executing downloaded code.
