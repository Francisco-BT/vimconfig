--- Shared Biome project detection for conform formatters and related tooling.
local BiomeConfig = {}

BiomeConfig.config_names = {
  "biome.json",
  "biome.jsonc",
  ".biome.json",
  ".biome.jsonc",
}

---@param ctx conform.Context
---@return boolean
function BiomeConfig.has_config(ctx)
  return vim.fs.find(BiomeConfig.config_names, { path = ctx.filename, upward = true })[1] ~= nil
end

--- Biome when configured, otherwise the given fallback formatter.
---@param fallback string
---@return table
function BiomeConfig.formatter_chain(fallback)
  return { "biome-check", fallback, stop_after_first = true }
end

return BiomeConfig
