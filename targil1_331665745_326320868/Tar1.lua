--submitters:
-- Name: Renana Houri ID: 326320868 , tirgul group: 150060.21.5786.43
-- Name: Chani Hoffman ID: 331665745 , tirgul group: 150060.21.5786.41
-- (we got premission to be in different tirgul groups by Adina)

-- read directory path from input
print("Please enter directory path:")
local dirPath = io.read()

-- extract the directory name from the path
local dirName = dirPath:match("([^\\/]+)$") or "Output"

-- craete .asm file with the same name as the directory
local ourFile = io.open(dirPath .. "\\" .. dirName .. ".asm", "w")
-- make sure the file opend succesfuly
if not ourFile then
    print("Error: Could not create file. Check if path is correct.")
    os.exit()
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
}

-- open the directorty
local command = 'dir "' .. dirPath .. '" /b'
local handle = io.popen(command)
if not handle then
    print("ERROR couldn't open the directory")
    os.exit()
end

-- go over each file in the directory
for file in handle:lines() do

    -- check if the file is .vm
    if file:match("%.vm$") then

        -- open the .vm file into reading mode
        local fullPath = dirPath .. "\\" .. file
        local f = io.open(fullPath, "r")

        -- write the name of the .vm file into the .asm file
        -- the name of the .vm file is in indexs 1 to fourth from last
        local fileName = file:sub(1, -4)
        ourFile:write("// File: " .. fileName .. "\n")

        if f then
            for line in f:lines() do

                line = line:gsub("^%s+", ""):gsub("%s+$", "") -- clean spaces from the start of the line
                if line ~= "" and line:sub(1, 2) ~= "//" then -- if the line is not empty or starts with "//"

                    -- break line into words
                    local words = {}
                    for word in line:gmatch("%S+") do    table.insert(words, word)    end

                    local vmCommand = words[1]
                    local func = commandTable[vmCommand]
                    local output = ""

                    if func then
                        if vmCommand == "push" or vmCommand == "pop" then
                            output = func(words[2], words[3], fileName)
                        else
                            output = func()
                        end
                    else
                        output = "// Unknown command: " .. tostring(vmCommand)
                    end

                    ourFile:write(output .. "\n")
                end
            end
        end
        -- close file after reading all the lines
        f:close()
    end
end

-- close all the files and print tha total
handle:close()
ourFile:write("")
ourFile:close()