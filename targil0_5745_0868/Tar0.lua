
--submitters:
--  Name: Renana Houri  ID: 326320868 , tirgul group: 150060.21.5786.43
--  Name: Chani Hoffman ID: 331665745 , tirgul group: 150060.21.5786.41
--  (we got premission to be in different tirgul groups by Adina)

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


function HandleBuy(ProductName, amount, price)
    ourFile:write("### BUY " .. ProductName .. " ###\n" .. tonumber(amount) * tonumber(price) .. "\n")
    return tonumber(amount) * tonumber(price)
end

function HandleCell(ProductName, amount, price)
    ourFile:write("$$$ CELL " .. ProductName .. " $$$\n" .. tonumber(amount) * tonumber(price) .. "\n")
    return tonumber(amount) * tonumber(price)
end

-- recive the line from the .vm file and extract the ProductName, the amount, and the price
function breakLine(line)
    -- the line stracture is thus: cell/buy (first space) <product> (second space) <amount> (third space) <price>
    -- we are findind the spaces in the line, and use them to know from to take each element
    -- (find returns the first show of the string we are looking for, and has a parameter that tells it from where to start searching)
    local s1 = string.find(line, " ")
    local s2 = string.find(line, " ", s1 + 1)
    local s3 = string.find(line, " ", s2 + 1)

    local product = string.sub(line, s1 + 1, s2 - 1)
    local amount  = string.sub(line, s2 + 1, s3 - 1)
    local price   = string.sub(line, s3 + 1)
    
    return product, amount, price
end

-- open the directorty
local command = 'dir "' .. dirPath .. '" /b'
local handle = io.popen(command)
if not handle then
    print("ERROR couldn't open the directory")
    os.exit()
end

-- initiate the sums for buys and cells 
local sumBuy = 0
local sumCell = 0

-- go over each file in the directory
for file in handle:lines() do

    -- check if the file is .vm
    if file:match("%.vm$") then

        -- open the .vm file into reading mode
        local fullPath = dirPath .. "\\" .. file
        local f = io.open(fullPath, "r")
        
        -- write the name of the .vm file into the .asm file
        -- the name of the .vm file is in indexs 1 to fourth from last
        ourFile:write("File: " .. file:sub(1, -4) .. "\n")

        if f then
            for line in f:lines() do 
                -- for every line in the file, break it into <product> <amount> <price>
                local product, amount, price = breakLine(line)
                -- check if the is a buy or cell line, and add the total buy/cell amount to the right sum
                if string.sub(line, 1 , 4):lower()=="buy " then
                    sumBuy = sumBuy + HandleBuy(product, amount, price)
                elseif string.sub(line, 1 , 4):lower()=="cell" then
                    sumCell = sumCell + HandleCell(product, amount, price)
                end
            end
            -- close file after reading all the lines
            f:close()
        end
    end
end

-- close all the files and print tha total
handle:close()
total = "TOTAL BUY: "..sumBuy.."\nTOTAL CELL: "..sumCell.."\n"
ourFile:write(total)
print(total)
ourFile:close()
