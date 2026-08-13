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

local data = require("yuhao.yuhao_quick_symbols_data")

local function filter(input, env)
    local input_text = env.engine.context.input
    -- 如果输入以分号结尾但不是以分号开头（例如 "abc;"），
    -- 则把前面的编码对应的首选候选上屏；如果没有候选则上屏原始编码（去掉分号）。
    if input_text:match("^[^;].-;$") then
        local prefix = input_text:sub(1, -2)
        -- 尝试取第一个候选并上屏
        -- try to get the first candidate via current composition segmentation
        local seg = data.get_last_segment(env)
        if seg then
            local first_candidate = seg:get_candidate_at(0)
            if first_candidate then
                pcall(function() env.engine:process_key(KeyEvent('1')) end)
                pcall(function() env.engine:process_key(KeyEvent(';')) end)
                return
            end
        end
        -- no candidate available: commit raw prefix and re-insert semicolon
        env.engine:commit_text(prefix)
        pcall(function() env.engine.context:clear() end)
        pcall(function() env.engine:process_key(KeyEvent(';')) end)
        return
    end

    -- 匹配分号加单个字母, 如 ;a
    local letter = input_text:match("^;([a-z])$")
    if letter then
        local sym = data.get_symbol(letter)
        if sym then
            env.engine:commit_text(sym)
            pcall(function() env.engine.context:clear() end)
            return
        end
    end
    -- 否则原样透传候选
    for cand in input:iter() do
        yield(cand)
    end
end

return { func = filter }
