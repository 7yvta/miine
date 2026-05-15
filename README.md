# miine

This repo contains your renamed script snapshot as `miine.lua`.

Use this loader after push:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/7yvta/miine/main/loader.lua"))()
```

What I fixed:
- `loader.lua` now retries multiple URLs.
- `loader.lua` validates fetch + compile before running.

Note: `miine.lua` is obfuscated/protected upstream source, so deeper in-script bug fixes require unobfuscated source.
