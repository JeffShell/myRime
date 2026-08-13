--[[
Name: yuhao_quick_symbols.lua
名称: 快符（分号+字母）映射
Version: 20260813
Author: generated
Purpose: 通过输入 `;` + 字母 快速候选常用符号。
使用方法:
1. 将此文件放在 `lua/yuhao/` 下（已完成）。
2. 在你的 `rime.lua`（若使用）中加入:
   `yuhao_quick_symbols = require("yuhao.yuhao_quick_symbols")`
3. 在所用 schema 的 `engine/filters` 中添加一项:
   `- lua_filter@yuhao_quick_symbols`
示例（schema.yaml）:
engine:
  filters:
    - lua_filter@yuhao_quick_symbols

说明:
当输入框内容完全匹配 `;` 后接一个字母（如 `;a`）时，
本过滤器会优先给出对应的符号候选。
其它情况下不改变候选顺序。
]]

local mapping = {
    a = "!",
    b = "——",
    c = "”",
    d = "、",
    e = "（",
    f = "，",
    i = "·",
    m = "@",
    q = "：“",
    r = "）",
    s = "……",
    u = "》",
    v = "。",
    w = "？",
    y = "《",
    z = "“",
}

local function filter(input, env)
    local input_text = env.engine.context.input
    -- 匹配分号加单个字母, 如 ;a
    local letter = input_text:match("^;([a-z])$")
    if letter then
        local sym = mapping[letter]
        if sym then
            -- 直接上屏符号并结束输入
            env.engine:commit_text(sym)
            if env.engine.context and env.engine.context.clear then
                pcall(function() env.engine.context:clear() end)
            end
            return
        end
    end
    -- 否则原样透传候选
    for cand in input:iter() do
        yield(cand)
    end
end

return { func = filter }
