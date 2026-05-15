# miine

This repo contains your renamed script snapshot as `miine.lua`.

Use this loader after push:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/7yvta/miine/main/loader.lua"))()
```

What I fixed:
- `loader.lua` now retries multiple URLs.
- `loader.lua` validates fetch + compile before running.
- `loader.lua` forces common language vars to English before start.
- `loader.lua` force-translates Vietnamese/Indonesian/branding text to English at runtime instantly (new and existing UI).
- `loader.lua` adds creator tag: `Created by 7yvta`.

Note: `miine.lua` is obfuscated/protected upstream source, so deeper in-script bug fixes require unobfuscated source.
