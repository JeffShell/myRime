-- Auto clear input when reaching 5-code with no candidates.
--
-- This matches the user's desired behavior:
-- - When input length reaches 5
-- - And there is no candidate menu
-- - Clear the composing input immediately (no need to press the next key)
--
-- Note: We hook `context.update_notifier` so we can observe the state after
-- translators/filters update the menu.

local M = {}

local function safe_has_menu(ctx)
  local ok, v = pcall(function()
    return ctx:has_menu()
  end)
  return ok and v or false
end

function M.init(env)
  local ctx = env.engine.context
  local clearing = false

  local function handler(context)
    if clearing then
      return
    end

    local input = context.input or ""
    -- Only apply to normal 4+ letter codes; avoid affecting special prefixes.
    if #input ~= 5 or not input:match("^[a-z]+$") or input:match("^z") then
      return
    end
    if safe_has_menu(context) then
      return
    end

    clearing = true
    context:clear()
    clearing = false
  end

  -- Rime updates menu/composition asynchronously; use update notifier.
  if ctx.update_notifier then
    ctx.update_notifier:connect(handler)
  else
    -- Fallback: older builds may not have update_notifier.
    ctx.option_update_notifier:connect(function() handler(ctx) end)
  end
end

function M.func(key, env)
  -- No-op processor; logic runs in notifier.
  return 2
end

return M

