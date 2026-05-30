-- ייבוא המודולים (וודאו שהקבצים JackTokenizer.lua ו-CompilationEngine.lua באותה תיקייה)
local tokenizer = require("tokenizer_JACK")
local parser = require("parser_JACK")

print("Please enter the full directory path:")
local dirPath = io.read()

-- פונקציה לבדיקה אם נתיב הוא תיקייה ולסריקת קבצים (מותאם ל-Windows)
-- משתמש ב-dir /b כדי לקבל רשימת קבצים בלבד
local handle = io.popen('dir "' .. dirPath .. '" /b')
if not handle then
    print("Error: Could not access the directory. Make sure the path is correct.")
    return
end

local jackFiles = {}
for fileName in handle:lines() do
    if fileName:match("%.jack$") then
        table.insert(jackFiles, fileName)
    end
end
handle:close()

if #jackFiles == 0 then
    print("No .jack files found in the specified directory.")
    return
end

print("\n--- Starting Compilation Process ---")

for _, fileName in ipairs(jackFiles) do
    -- יצירת שמות הקבצים והנתיבים
    local baseName = fileName:gsub("%.jack$", "")
    
    -- מוודא שהנתיב מסתיים בסלאש
    local formattedDirPath = dirPath
    if not dirPath:match("[\\/]$") then
        formattedDirPath = dirPath .. "\\"
    end
    
    local inputJackPath = formattedDirPath .. fileName
    local outputTPath   = formattedDirPath .. baseName .. "T.xml"
    local outputXMLPath = formattedDirPath .. baseName .. ".xml"

    print("\nFile: " .. fileName)

    -- שלב 1: הרצת ה-Tokenizer
    print("  Step 1: Running Tokenizer...")
    local successT = tokenizer.run(inputJackPath, outputTPath)
    
    if successT then
        print("  [Success] Created " .. baseName .. "T.xml")
        
        -- שלב 2: הרצת ה-Parser (CompilationEngine)
        print("  Step 2: Running Compilation Engine...")
        local successP = parser.run(outputTPath, outputXMLPath)
        
        if successP then
            print("  [Success] Created " .. baseName .. ".xml")
        else
            print("  [Error] Failed to parse " .. outputTPath)
        end
    else
        print("  [Error] Failed to tokenize " .. fileName)
    end
end

print("\n--- All Done! ---")