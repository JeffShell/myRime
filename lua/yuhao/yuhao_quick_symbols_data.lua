-- Shared data and helpers for quick symbols
local M = {}

M.mapping = {
    a = "!", b = "——", c = "”", d = "、", e = "（", f = "，",
    i = "·", m = "@", q = "：“", r = "）", s = "……", u = "》",
    v = "。", w = "？", y = "《", z = "“",
}

function M.get_symbol(letter)
    if not letter then return nil end
    return M.mapping[letter]
end

-- Safely get last segmentation back segment or nil
function M.get_last_segment(env)
    local ok, comp = pcall(function() return env.engine.context and env.engine.context.composition end)
    if not ok or not comp then return nil end
    local ok2, segm = pcall(function() return comp:toSegmentation() end)
    if not ok2 or not segm then return nil end
    local ok3, seg = pcall(function() return segm:back() end)
    if not ok3 then return nil end
    return seg
end

return M
