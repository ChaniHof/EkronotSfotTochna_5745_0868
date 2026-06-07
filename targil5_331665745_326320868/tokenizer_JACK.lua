local JackTokenizer = {}

local keywords = {
    ["class"]=true, ["constructor"]=true, ["function"]=true, ["method"]=true,
    ["field"]=true, ["static"]=true, ["var"]=true, ["int"]=true,
    ["char"]=true, ["boolean"]=true, ["void"]=true, ["true"]=true,
    ["false"]=true, ["null"]=true, ["this"]=true, ["let"]=true,
    ["do"]=true, ["if"]=true, ["else"]=true, ["while"]=true, ["return"]=true
}
local symbols = "{}()[].,;+-*/&|<>=~"

function JackTokenizer.run(inputPath, outputPath)
    local inFile = io.open(inputPath, "r")
    local outFile = io.open(outputPath, "w")

    if not inFile or not outFile then
        print("Error: Could not open files.")
        return false
    end

    outFile:write("<tokens>\n")

    local inBlockComment = false

    for line in inFile:lines() do
        -- ניקוי רווחים לבנים בתחילת וסוף שורה
        line = line:match("^%s*(.-)%s*$")
        
        while #line > 0 do
            -- טיפול בהערות בלוק /* ... */
            if inBlockComment then
                local endComment = line:find("*/", 1, true)
                if endComment then
                    line = line:sub(endComment + 2)
                    inBlockComment = false
                else
                    line = "" -- כל השורה היא חלק מהערה
                end
            elseif line:sub(1, 2) == "/*" then
                inBlockComment = true
                line = line:sub(3)
            -- טיפול בהערות שורה //
            elseif line:sub(1, 2) == "//" then
                line = ""
            -- דילוג על רווחים
            elseif line:match("^%s") then
                line = line:sub(2)
            else
                local token = nil
                local tokenType = nil

                -- סימנים (Symbols)
                if symbols:find(line:sub(1, 1), 1, true) then
                    token = line:sub(1, 1)
                    tokenType = "symbol"
                    line = line:sub(2)
                -- מחרוזות (String Constants)
                -- מחרוזות (String Constants)
                elseif line:sub(1,1) == '"' then
                    -- מחפש את המירכאות הסוגרות בשורה
                    local closingQuotePos = line:find('"', 2) 
                    if closingQuotePos then
                        -- חילוץ הטקסט שבין המירכאות
                        token = line:sub(2, closingQuotePos - 1)
                        tokenType = "stringConstant"
                        -- קידום השורה אל אחרי המירכאות הסוגרות
                        line = line:sub(closingQuotePos + 1)
                    else
                        -- במקרה שאין מירכאות סוגרות (שגיאת תחביר), פשוט מדלגים
                        line = line:sub(2)
                    end
                -- מספרים (Integer Constants)
                elseif line:match('^(%d+)') then
                    token = line:match('^(%d+)')
                    tokenType = "integerConstant"
                    line = line:sub(#token + 1)
                -- מילים/מזהים (Keywords / Identifiers)
                elseif line:match('^([%a_][%w_]*)') then
                    token = line:match('^([%a_][%w_]*)')
                    tokenType = keywords[token] and "keyword" or "identifier"
                    line = line:sub(#token + 1)
                else
                    -- תו לא מזוהה - מדלגים עליו
                    line = line:sub(2)
                end

                -- כתיבה לקובץ בפורמט XML
                if token then
                    local display = token
                    if token == "<" then display = "&lt;"
                    elseif token == ">" then display = "&gt;"
                    elseif token == "&" then display = "&amp;"
                    elseif token == '"' then display = "&quot;"
                    end
                    outFile:write("<" .. tokenType .. "> " .. display .. " </" .. tokenType .. ">\n")
                end
            end
        end
    end

    outFile:write("</tokens>\n")
    outFile:flush() -- חשוב כדי שהקובץ יישמר פיזית
    outFile:close()
    inFile:close()
    return true
end

return JackTokenizer