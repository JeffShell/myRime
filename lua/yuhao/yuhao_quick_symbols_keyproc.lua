--[[
Name: yuhao_quick_symbols_keyproc.lua
名称: 快符按键处理器（拦截分号）
Version: 20260814
Author: generated
Purpose: 在按下分号时优先上屏首选候选并保留分号为预输入，便于随后输入快符字母。
Usage: 将本文件放入 `lua/yuhao/` 并在 schema 的 engine.processors 中注册：
  - lua_processor@*yuhao.yuhao_quick_symbols_keyproc
]]

local data = require("yuhao.yuhao_quick_symbols_data")

local this = {}

local kRejected = 0 -- 字符不上屏，結束 processors 流程
local kAccepted = 1 -- 字符上屏，結束 processors 流程
local kNoop = 2     -- 字符不上屏，交給下一個 processor

function this.init(env)
    -- no-op
end

---@param key_event KeyEvent
---@param env Env
function this.func(key_event, env)
    -- only handle key down, no modifiers
    if key_event:release() or key_event:alt() or key_event:ctrl() or key_event:shift() or key_event:caps() then
        return kNoop
    end
    -- handle semicolon press
    if key_event.keycode == ((';'):byte()) then
        local context = env.engine.context
        -- 如果当前预输入就是分号, 再按分号则提交分号本身
        local cur_input = context.input or ""
        if cur_input == ";" then
            env.engine:commit_text("；")
            pcall(function() env.engine.context:clear() end)
            return kAccepted
        end
        if not context:has_menu() then
            return kNoop
        end
        -- get current segmentation and last segment
        local ok, comp = pcall(function() return context.composition end)
        if not ok or not comp then return kNoop end
        local segm = comp:toSegmentation()
        if not segm then return kNoop end
        local seg = segm:back()
        if not seg then return kNoop end
        local first = seg:get_candidate_at(0)
        if first then
            -- select first candidate by sending '1'
            pcall(function() env.engine:process_key(KeyEvent('1')) end)
            -- re-insert semicolon for quick-symbol input
            pcall(function() env.engine:process_key(KeyEvent(';')) end)
            return kAccepted
        else
            return kNoop
        end
    end

    -- handle letter after semicolon (quick-symbol trigger)
    if key_event.keycode >= ('a'):byte() and key_event.keycode <= ('z'):byte() then
        local context = env.engine.context
        local input = context.input or ""
        if input == ";" then
            local letter = string.char(key_event.keycode)
            local sym = data.get_symbol(letter)
            if sym then
                env.engine:commit_text(sym)
                pcall(function() env.engine.context:clear() end)
                return kAccepted
            else
                return kNoop
            end
        end
        return kNoop
    end
    return kNoop
end

return this
