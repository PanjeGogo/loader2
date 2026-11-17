# Throw Food for Animals — Loader Investigation

**Status:** Partial research; the original Mythios `@freemium` payload has not been identified.

## Target identity

- Game: Throw Food for Animals
- PlaceId: `120219252362013`
- UniverseId / GameId: `10766972131`
- Provider under investigation: Mythios
- Slug: `@freemium`
- Previously observed host: `https://mythios.online`

Treat the IDs above as target identifiers from the investigation. Do not assume a public script using the same PlaceId is the Mythios payload.

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

**Conclusion:** the current files in this repository are not the captured Mythios loader and do not contain the Throw Food for Animals payload. No existing file was overwritten.

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

- The actual Mythios `@freemium` payload URL or server-side route.
- Whether Mythios returns a unique payload or a generic/third-party script.
- Whether the previously captured `/api/start.php` response contains a next-stage URL or only an authorization/status response.
- A source-level match between a candidate payload and Mythios.

## Next evidence needed

Add the original captured Mythios `loader.lua` (not this repository's Prospecting loader) and sanitized HTTP request/response captures for the relevant requests. Remove session tokens, keys, HWIDs, cookies, and other credentials before committing. The investigation can then compare the observed delivery flow with the public leads without bypassing authentication or access controls.

## Safety and provenance notes

- Do not forge keys, HWIDs, nonces, or authentication responses.
- Do not bypass paid access or server-side authorization.
- Do not label a third-party candidate as the Mythios original without direct evidence.
- Do not execute untrusted downloaded Lua merely to inspect it; prefer static analysis.
