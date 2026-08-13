--[[
Name: yuhao_show_shortcode.lua
名称: 在候选后显示单字的简码
Version: 20260814
Author: generated
Purpose: 当输入为某字的全码时, 在候选的备注中显示该字的简码（如 "可 kde"）。
Usage: 放在 lua/yuhao/ 下，并在 schema 的 engine.filters 中启用:
  - lua_filter@*yuhao.yuhao_show_shortcode
]]

local core = require("yuhao.yuhao_core")

local function init(env)
    local config = env.engine.schema.config
    local code_rvdb = config:get_string("schema_name/code")
    if code_rvdb and code_rvdb ~= "" then
        env.code_rvdb = ReverseDb("build/" .. code_rvdb .. ".reverse.bin")
    end
end

local function yield_candidate_with_comment(cand, comment)
    local c = Candidate(cand.type, cand.start, cand._end, cand.text, comment or cand.comment)
    c.preedit = cand.preedit
    c.quality = cand.quality
    yield(c)
end

local function func(input, env)
    local input_text = env.engine.context.input or ""
    for cand in input:iter() do
        local ok, genuine = pcall(function() return cand:get_genuine() end)
        if ok and genuine and type(genuine.text) == "string" and core.is_single_char(genuine.text) and env.code_rvdb then
            local codes = env.code_rvdb:lookup(genuine.text) or ""
            if codes and codes:find("%S") then
                -- check if current input matches one of the codes (i.e., user typed a full code)
                local found_full = false
                for code in codes:gmatch("%S+") do
                    if code == input_text then
                        found_full = true
                        break
                    end
                end
                if found_full then
                    -- find the shortest code shorter than input_text
                    local best = nil
                    for code in codes:gmatch("%S+") do
                        if #code < #input_text then
                            if not best or #code < #best then best = code end
                        end
                    end
                    if best then
                        local comment = tostring(best)
                        yield_candidate_with_comment(cand, comment)
                        goto continue
                    end
                end
            end
        end
        yield(cand)
        ::continue::
    end
end

return { init = init, func = func }
