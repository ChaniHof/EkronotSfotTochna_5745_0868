--submitters:
-- Name: Renana Houri ID: 326320868 , tirgul group: 150060.21.5786.43
-- Name: Chani Hoffman ID: 331665745 , tirgul group: 150060.21.5786.41
-- (we got premission to be in different tirgul groups by Adina)



function bootstrapFunc()
    local asm = "// bootstrap\n" ..
                "@256\n" ..
                "D=A\n" ..
                "@SP\n" ..
                "M=D\n" ..
                "// call Sys.init 0\n" ..
                "// push return-address\n" ..
                "@BOOTSTRAP_RETURN\n" ..
                "D=A\n" ..
                "@SP\n" ..
                "A=M\n" ..
                "M=D\n" ..
                "@SP\n" ..
                "M=M+1\n" ..
                "// push LCL\n" ..
                "@LCL\nD=M\n@SP\nA=M\nM=D\n@SP\nM=M+1\n" ..
                "// push ARG\n" ..
                "@ARG\nD=M\n@SP\nA=M\nM=D\n@SP\nM=M+1\n" ..
                "// push THIS\n" ..
                "@THIS\nD=M\n@SP\nA=M\nM=D\n@SP\nM=M+1\n" ..
                "// push THAT\n" ..
                "@THAT\nD=M\n@SP\nA=M\nM=D\n@SP\nM=M+1\n" ..
                "// ARG = SP - 5 - 0\n" ..
                "@SP\nD=M\n@5\nD=D-A\n@ARG\nM=D\n" ..
                "// LCL = SP\n" ..
                "@SP\nD=M\n@LCL\nM=D\n" ..
                "// goto Sys.init\n" ..
                "@Sys.init\n0;JMP\n" ..
                "(BOOTSTRAP_RETURN)\n"
    return asm
end

function addFunc()
    return "//add\n@SP\nA=M-1\nD=M\nA=A-1\nM=D+M\n@SP\nM=M-1\n"
end

function subFunc()
    return "//sub\n@SP\nA=M-1\nD=M\nA=A-1\nM=M-D\n@SP\nM=M-1\n"
end

function andFunc()
    return "//and\n@SP\nA=M-1\nD=M\nA=A-1\nM=D&M\n@SP\nM=M-1\n"
end

function orFunc()
    return "//or\n@SP\nA=M-1\nD=M\nA=A-1\nM=D|M\n@SP\nM=M-1\n"
end

function negFunc()
    local asm=" "
    asm = asm .. "// neg\n"
    asm = asm .. "@SP\n"
    asm= asm .."A=M-1\n"
    asm=asm.."M=-M\n"
    return asm
end

function notFunc()
    local asm = ""
    asm = asm .. "// not\n"
    asm = asm .. "@SP\n"
    asm = asm .. "A=M-1\n"
    asm = asm .. "M=!M\n"
    return asm

end

local labelCounter = 0
function eqFunc()
    local asm = "// eq\n"
    local labelTrue = "EQ_TRUE_" .. labelCounter
    local labelEnd = "EQ_END_" .. labelCounter
    labelCounter = labelCounter + 1
    
    --גישה לאיבר הראשון
    asm = asm .. "@SP\n"
    asm = asm .. "AM=M-1\n"
    asm = asm .. "D=M\n"
    
    -- גישה לאיבר השני 
    asm = asm .. "@SP\n"
    asm = asm .. "A=M-1\n"
    
    -- חישוב אם ההפרש נותן 0
    asm = asm .. "D=M-D\n" -- D = x - y
    asm = asm .. "@" .. labelTrue .. "\n"
    asm = asm .. "D;JEQ\n" 
    
    -- false
    asm = asm .. "@SP\n"
    asm = asm .. "A=M-1\n"
    asm = asm .. "M=0\n"
    asm = asm .. "@" .. labelEnd .. "\n"
    asm = asm .. "0;JMP\n"
    
    --True
    asm = asm .. "(" .. labelTrue .. ")\n"
    asm = asm .. "@SP\n"
    asm = asm .. "A=M-1\n"
    asm = asm .. "M=-1\n"
    

    asm = asm .. "(" .. labelEnd .. ")\n"
    
    return asm
end

function gtFunc() --greater then

    local asm = "// gt\n"
    local labelTrue = "GT_TRUE_" .. labelCounter
    local labelEnd = "GT_END_" .. labelCounter
    labelCounter = labelCounter + 1
    
    --גישה לאיבר הראשון y 
    asm = asm .. "@SP\n"
    asm = asm .. "AM=M-1\n"
    asm = asm .. "D=M\n"
    
    -- גישה לאיבר השני x
    asm = asm .. "@SP\n"
    asm = asm .. "A=M-1\n"
    
    -- חישוב אם ההפרש נותן 0
    asm = asm .. "D=M-D\n" -- D = x - y
    asm = asm .. "@" .. labelTrue .. "\n"
    asm = asm .. "D;JGT\n"  -- אם x>y אז לקפוץ  ל labelTrue
    
    -- false
    asm = asm .. "@SP\n"
    asm = asm .. "A=M-1\n"
    asm = asm .. "M=0\n"
    asm = asm .. "@" .. labelEnd .. "\n"
    asm = asm .. "0;JMP\n"
    
    --True
    asm = asm .. "(" .. labelTrue .. ")\n"
    asm = asm .. "@SP\n"
    asm = asm .. "A=M-1\n"
    asm = asm .. "M=-1\n"
    
   
    asm = asm .. "(" .. labelEnd .. ")\n"
    
    return asm

end

function ltFunc()
    local asm = "// lt\n"
    local labelTrue = "LT_TRUE_" .. labelCounter
    local labelEnd = "LT_END_" .. labelCounter
    labelCounter = labelCounter + 1
    
    --גישה לאיבר הראשון y 
    asm = asm .. "@SP\n"
    asm = asm .. "AM=M-1\n"
    asm = asm .. "D=M\n"
    
    -- גישה לאיבר השני x
    asm = asm .. "@SP\n"
    asm = asm .. "A=M-1\n"
    
    -- חישוב אם ההפרש נותן 0
    asm = asm .. "D=M-D\n" -- D = x - y
    asm = asm .. "@" .. labelTrue .. "\n"
    asm = asm .. "D;JLT\n"  -- אם x<y אז לקפוץ  ל labelTrue
    
    -- false
    asm = asm .. "@SP\n"
    asm = asm .. "A=M-1\n"
    asm = asm .. "M=0\n"
    asm = asm .. "@" .. labelEnd .. "\n"
    asm = asm .. "0;JMP\n"
    
    --True
    asm = asm .. "(" .. labelTrue .. ")\n"
    asm = asm .. "@SP\n"
    asm = asm .. "A=M-1\n"
    asm = asm .. "M=-1\n"
    
   
    asm = asm .. "(" .. labelEnd .. ")\n"
    
    return asm

end

function pushFunc(segment,index,fileName)
    function pushDToStack()
        local asm = ""
        asm = asm .. "@SP\n"
        asm = asm .. "A=M\n"
        asm = asm .. "M=D\n"
        asm = asm .. "@SP\n"
        asm = asm .. "M=M+1\n"
        return asm
    end
    local asm="// push" .. segment .. " " .. index .."\n"
    
    if segment=="constant" then 
        asm=asm .."@" .. index .. "\n"
        asm = asm .. "D=A\n"

    elseif segment == "local" or segment == "argument" or segment == "this" or segment == "that" then
        local segMap = 
            {
             ["local"] = "LCL",
             ["argument"] = "ARG",
             ["this"] = "THIS",
             ["that"] = "THAT"
            }   
        local label = segMap[segment]
        asm = asm .. "@" .. index .. "\n"
        asm = asm .. "D=A\n"
        asm = asm .. "@" .. label .. "\n"
        asm = asm .. "A=M+D\n" 
        asm = asm .. "D=M\n"  
    
    elseif segment == "pointer" then
        local label = (index == "0") and "THIS" or "THAT"
        asm = asm .. "@" .. label .. "\n"
        asm = asm .. "D=M\n"
    
    elseif segment == "static" then
        asm = asm .. "@" .. fileName .. "." .. index .. "\n"
        asm = asm .. "D=M\n"
    end

    asm = asm .. pushDToStack()
    return asm

end

function popFunc(segment, index, fileName)
    local pop_handlers = {
        ["local"] = function(index, fileName) 
            return "@"..index.."\nD=A\n@LCL\nD=M+D\n@SP\nM=M-1\nA=M\nA=M\nA=A+D\nD=A-D\nA=A-D\nM=D" 
        end,
        
        ["argument"] = function(index, fileName) 
            return "@"..index.."\nD=A\n@ARG\nD=M+D\n@SP\nM=M-1\nA=M\nA=M\nA=A+D\nD=A-D\nA=A-D\nM=D" 
        end,
        
        ["this"] = function(index, fileName) 
            return "@"..index.."\nD=A\n@THIS\nD=M+D\n@SP\nM=M-1\nA=M\nA=M\nA=A+D\nD=A-D\nA=A-D\nM=D" 
        end,
        
        ["that"] = function(index, fileName) 
            return "@"..index.."\nD=A\n@THAT\nD=M+D\n@SP\nM=M-1\nA=M\nA=M\nA=A+D\nD=A-D\nA=A-D\nM=D" 
        end,
        
        ["temp"] = function(index, fileName) 
            return "@"..index.."\nD=A\n@5\nD=D+A\n@SP\nM=M-1\nA=M\nA=M\nA=A+D\nD=A-D\nA=A-D\nM=D" 
        end,
        
        ["pointer"] = function(index, fileName)
            local target = (index == "0") and "THIS" or "THAT"
            return "@SP\nM=M-1\nA=M\nD=M\n@" .. target .. "\nM=D"
        end,
        
        ["static"] = function(index, fileName)
            return "@SP\nM=M-1\nA=M\nD=M\n@" .. fileName .. "." .. index .. "\nM=D"
        end
    }

    local handler = pop_handlers[segment]
    if handler then
        return handler(index, fileName)
    end

    return ""
end
function labelFunc(label, fileName)
    return "(" .. fileName .. "." .. label .. ")\n"
end

function gotoFunc(label, fileName)
    return "@" .. fileName .. "." .. label .. "\n0;JMP\n"
end

function ifgotoFunc(label, fileName)
    local asm = "@SP\n" ..
                "AM=M-1\n" .. 
                "D=M\n" ..
                "@" .. fileName .. "." .. label .. "\n" ..
                "D;JNE\n"
    return asm
end

function declarefuncFunc(functionName, numLocals)
    local asm = "(" .. functionName .. ")\n"
    for i = 1, numLocals do
        asm = asm .. "@SP\n" ..
                    "A=M\n" ..
                    "M=0\n" ..   -- אתחול ל-0
                    "@SP\n" ..
                    "M=M+1\n"    -- קידום המחסנית
    end
    return asm
end

local callCounter = 0
function callFunc(functionName, numArgs)
    callCounter = callCounter + 1
    local returnLabel = functionName .. "$ret." .. callCounter
    
    local asm = "@" .. returnLabel .. "\nD=A\n@SP\nA=M\nM=D\n@SP\nM=M+1\n" -- Push returnAddress
    
    -- Push LCL, ARG, THIS, THAT (אותו לוגיקה כמו ה-return address)
    local segments = {"LCL", "ARG", "THIS", "THAT"}
    for _, seg in ipairs(segments) do
        asm = asm .. "@" .. seg .. "\nD=M\n@SP\nA=M\nM=D\n@SP\nM=M+1\n"
    end
    
    -- ARG = SP - 5 - numArgs
    asm = asm .. "@SP\nD=M\n@5\nD=D-A\n@" .. numArgs .. "\nD=D-A\n@ARG\nM=D\n"
    
    -- LCL = SP
    asm = asm .. "@SP\nD=M\n@LCL\nM=D\n"
    
    -- Goto functionName
    asm = asm .. "@" .. functionName .. "\n0;JMP\n"
    
    -- (returnLabel)
    asm = asm .. "(" .. returnLabel .. ")\n"
    
    return asm
end

function returnFunc()
    local asm = ""
    -- R13 = LCL (Frame)
    asm = asm .. "@LCL\nD=M\n@R13\nM=D\n"
    
    -- R14 = *(R13 - 5) (Return Address)
    asm = asm .. "@5\nAD=D-A\nD=M\n@R14\nM=D\n"
    
    -- *ARG = pop()
    asm = asm .. "@SP\nAM=M-1\nD=M\n@ARG\nA=M\nM=D\n"
    
    -- SP = ARG + 1
    asm = asm .. "@ARG\nD=M+1\n@SP\nM=D\n"
    
    -- שחזור THAT, THIS, ARG, LCL (בסדר הפוך)
    local segments = {"THAT", "THIS", "ARG", "LCL"}
    for i, seg in ipairs(segments) do
        asm = asm .. "@R13\nAM=M-1\nD=M\n@" .. seg .. "\nM=D\n"
    end
    
    -- goto R14
    asm = asm .. "@R14\nA=M\n0;JMP\n"
    
    return asm
end


local commandTable = {
    -- Tar1
    ["add"]      = addFunc,
    ["sub"]      = subFunc,
    ["and"]      = andFunc,
    ["or"]       = orFunc,
    ["neg"]      = negFunc,
    ["not"]      = notFunc,
    ["eq"]       = eqFunc,
    ["gt"]       = gtFunc,
    ["lt"]       = ltFunc,
    ["pop"]      = popFunc,
    ["push"]     = pushFunc,
    -- Tar2
    ["label"]    = labelFunc,
    ["goto"]     = gotoFunc,
    ["if-goto"]  = ifgotoFunc,
    ["function"] = declarefuncFunc,
    ["call"]     = callFunc,
    ["return"]   = returnFunc,
}


-- read directory path from input
print("Please enter directory path:")
local dirPath = io.read()

-- extract the directory name from the path
local dirName = dirPath:match("([^\\/]+)$") or "Output"

-- craete .asm file with the same name as the directory
local ourFile = io.open(dirPath .. "\\" .. dirName .. ".asm", "w")
-- make sure the file opend succesfuly
if not ourFile then
    print("Error: Could not create file. Check if path is correct.\n")
    os.exit()
end


-- array thansaves the names of the files that end with .vm 
local vmFiles = {} 
-- open the directorty
local handle = io.popen('dir "' .. dirPath .. '" /b') 

-- make sure the directory opend succefuly
if not handle then
    print("Error: Could not open directory.\n")
    os.exit()
end

-- go over the directory and add the .vm files into the vmFiles array
for file in handle:lines() do
    if file:match("%.vm$") then
        table.insert(vmFiles, file)
    end
end
handle:close()

-- check if there is more than one .vm file in the directory,
-- if there are more two or more, we need to add bootstrap before reading the files
if #vmFiles > 1 then
    ourFile:write("// " .. dirName .. "\n" .. bootstrapFunc() .. "\n")
end

-- go over each file in the directory
for i = 1, #vmFiles do

    local file = vmFiles[i]

    -- open the .vm file into reading mode
    local fullPath = dirPath .. "\\" .. file
    local f = io.open(fullPath, "r")

    -- write the name of the .vm file into the .asm file
    -- the name of the .vm file is in indexs 1 to fourth from last
    local fileName = file:sub(1, -4)
    ourFile:write("// File: " .. fileName .. "\n")

    if f then
        for line in f:lines() do

            -- clean spaces from the start of the line
            line = line:gsub("^%s+", ""):gsub("%s+$", "") 
            -- if the line is not empty or starts with "//"
            if line ~= "" and line:sub(1, 2) ~= "//" then 

                -- break line into words
                local words = {}
                for word in line:gmatch("%S+") do    table.insert(words, word)    end

                -- match the first word in the line to a command 
                local vmCommand = words[1]
                local func = commandTable[vmCommand]
                local output = ""

                -- the command is a leagle VM command:
                if func then
                    if vmCommand == "label" or vmCommand == "goto" or vmCommand == "if-goto" then
                        output = func(words[2],fileName)
                    elseif vmCommand == "push" or vmCommand == "pop" then
                        output = func(words[2], words[3], fileName)
                    elseif vmCommand == "function" or vmCommand == "call" then
                        output = func(words[2], words[3])
                    else
                        output = func()
                    end
                else -- if the first word in the line is not a leagle command 
                    output = "// Unknown command: " .. tostring(vmCommand)
                end
                -- write the translation from VM to ASM into the .asm file
                ourFile:write(output .. "\n")
            end
        end
        -- close file after reading all the lines
        f:close()
    end
end

-- close files and finish
ourFile:write("")
ourFile:close()