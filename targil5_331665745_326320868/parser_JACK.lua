-- ==========================================================
-- Jack Compiler: Full Code Generation (Unified & Updated)
-- ==========================================================

-- ניהול טבלת סימבולים
SymbolTable = {}
function SymbolTable:new()
    return setmetatable({
        classTable = {},
        subTable = {},
        counts = {
            static = 0,
            field = 0,
            argument = 0,
            lcl = 0
        }
    }, {__index = SymbolTable})
end

function SymbolTable:startSubroutine()
    self.subTable = {}
    self.counts.argument = 0
    self.counts.lcl = 0
end

function SymbolTable:define(name, type, kind)
    local t

    if kind == "static" or kind == "field" then
            t = self.classTable
    else    
        t = self.subTable    
    end
    t[name] = {
        type = type,
        kind = kind,
        index = self.counts[kind]
    }

    self.counts[kind] = self.counts[kind] + 1
end

function SymbolTable:kindOf(name) return (self.subTable[name] and self.subTable[name].kind) or (self.classTable[name] and self.classTable[name].kind) end
function SymbolTable:indexOf(name) return (self.subTable[name] and self.subTable[name].index) or (self.classTable[name] and self.classTable[name].index) end
function SymbolTable:typeOf(name)
    if self.subTable[name] then return self.subTable[name].type end
    if self.classTable[name] then return self.classTable[name].type end
    return nil
end
-- ניהול כתיבת קוד VM
VMWriter = {}
function VMWriter:new(outFile) 
    return setmetatable({file = io.open(outFile, "w")}, {__index=VMWriter}) 

end
function VMWriter:writePush(seg, idx)
    if seg=="lcl" then seg="local" end
    self.file:write("push " .. seg .. " " .. idx .. "\n") 
end
function VMWriter:writePop(seg, idx) 
    if seg=="lcl" then seg="local" end
    self.file:write("pop " .. seg .. " " .. idx .. "\n") 
end
function VMWriter:writeArithmetic(cmd) self.file:write(cmd .. "\n") end
function VMWriter:writeLabel(l) self.file:write("label " .. l .. "\n") end
function VMWriter:writeGoto(l) self.file:write("goto " .. l .. "\n") end
function VMWriter:writeIf(l) self.file:write("if-goto " .. l .. "\n") end
function VMWriter:writeCall(n, a) self.file:write("call " .. n .. " " .. a .. "\n") end
function VMWriter:writeFunction(n, l) self.file:write("function " .. n .. " " .. l .. "\n") end
function VMWriter:writeReturn() self.file:write("return\n") end
function VMWriter:close() 
    if self.file then self.file:close() end
end








-- ==========================================================
-- Jack Analyzer: Tokenizer + Full Compilation Engine
-- Submitters: Renana Houri & Chani Hoffman
-- ==========================================================

local keywords = {
    ["class"]=true, ["constructor"]=true, ["function"]=true, ["method"]=true,
    ["field"]=true, ["static"]=true, ["var"]=true, ["int"]=true,
    ["char"]=true, ["boolean"]=true, ["void"]=true, ["true"]=true,
    ["false"]=true, ["null"]=true, ["this"]=true, ["let"]=true,
    ["do"]=true, ["if"]=true, ["else"]=true, ["while"]=true, ["return"]=true
}
local symbols = "{}()[].,;+-*/&|<>=~"
local ops = {["+"]=true, ["-"]=true, ["*"]=true, ["/"]=true, ["&"]=true, ["|"]=true, ["<"]=true, [">"]=true, ["="]=true}

local function decodeXML(s)
    if not s then return "" end
    return s:gsub("&lt;", "<"):gsub("&gt;", ">"):gsub("&amp;", "&"):gsub("&quot;", '"')
end

local function loadTokens(path)
    local tokens = {}
    local f = io.open(path, "r")
    if not f then return tokens end
    for line in f:lines() do
        -- מחלץ את הסוג והערך מתוך תגיות ה-XML
        local tType, tVal = line:match("<(%w+)>%s*(.-)%s*</%w+>")
        if tType then
            if tType == "stringConstant" then
                table.insert(tokens, {type = tType, value = decodeXML(tVal)})
            else
                table.insert(tokens, {type = tType, value = decodeXML(tVal)})
            end

        end
    end
    f:close()
    return tokens
end

-- ---------------------------------------------------------
-- שלב 2: Compilation Engine (ה-Parser ההיררכי)
-- ---------------------------------------------------------
local Engine = {}
Engine.__index = Engine


function Engine.run(inputTPath, outputVMPath)
    local tokens = loadTokens(inputTPath)
    local engine = Engine.new(tokens, outputVMPath)
    if engine then
        engine:compileClass()
        -- סגירת הקובץ דרך ה-VMWriter
        if engine.vm then
            engine.vm:close()
        end
        return true
    end
    return false
end

function Engine.new(tokens, outPath)
    local self = setmetatable({}, Engine)
    self.tokens = tokens
    self.pos = 1
    --self.outFile = io.open(outPath, "w")
    self.indent = 0
    self.labelCount = 0
    self.st = SymbolTable.new()
    self.vm = VMWriter:new(outPath)
    return self
end

-- פונקציית עזר ליצירת לייבל ייחודי
function Engine:newLabel()
    self.labelCount = self.labelCount + 1
    return "L" .. self.labelCount
end


function Engine:process(expected)
    local t = self.tokens[self.pos]
    self.pos = self.pos + 1
    return t
end

function Engine:peek(offset) return self.tokens[self.pos + (offset or 0)] end

-- --- חוקי התחביר ---

function Engine:compileClass()
    self:process() -- 'class'
    local className = self:process().value -- שומרים את שם המחלקה
    self.className = className
    self:process() -- '{'
    
    -- בזמן ה-Parsing, אנחנו רק ממלאים את ה-SymbolTable
    while self:peek() and (self:peek().value == "static" or self:peek().value == "field") do 
        self:compileClassVarDec() 
    end
    
    while self:peek() and (self:peek().value == "constructor" or self:peek().value == "function" or self:peek().value == "method") do 
        self:compileSubroutine(className) -- מעבירים את שם המחלקה לבניית שם הפונקציה
    end
    
    self:process() -- '}'
end

--[[
function Engine:compileClassVarDec()
    self:writeTag("<classVarDec>")
    repeat self:process() until self.tokens[self.pos-1].value == ";"
    self:writeTag("</classVarDec>", true)
end]]
function Engine:compileClassVarDec()
    -- במקום לכתוב תג XML, נשלוף את המידע עבור ה-SymbolTable:
    
    -- 1. מה הסוג של המשתנה? (static או field)
    local kind = self:process().value 
    
    -- 2. מה ה-Type? (int, boolean, className...)
    local type = self:process().value
    
    -- 3. נמשיך לקרוא את השמות ברשימה (טיפול ב-static int x, y, z;)
    local name = self:process().value
    self.st:define(name, type, kind) -- עדכון טבלת הסימבולים
    
    -- כל עוד יש פסיק, יש עוד משתנה מאותו סוג
    while self:peek().value == "," do
        self:process() -- פסיק
        name = self:process().value
        self.st:define(name, type, kind) -- עדכון המשתנה הבא בטבלה
    end
    
    self:process() -- נקודה-פסיק (;)
end

--[[
function Engine:compileSubroutine()
    self:writeTag("<subroutineDec>")
    self:process() -- kind
    self:process() -- type
    self:process() -- name
    self:process() -- '('
    self:compileParameterList()
    self:process() -- ')'
    self:writeTag("<subroutineBody>")
    self:process() -- '{'
    while self:peek().value == "var" do self:compileVarDec() end
    self:compileStatements()
    self:process() -- '}'
    self:writeTag("</subroutineBody>", true)
    self:writeTag("</subroutineDec>", true)
end]]
function Engine:compileSubroutine(className)
    self.st:startSubroutine() -- מאפס את הטבלה לסקופ של הפונקציה החדשה
    
    -- קריאת הנתונים מהטוקנים
    local kind = self:process().value -- constructor/function/method
    local type = self:process().value -- return type
    local subName = self:process().value -- שם הפונקציה
    
    -- אם זו מתודה (method), נוסיף את ה-'this' לטבלת הסימבולים
    if kind == "method" then
        self.st:define("this", className, "argument")
    end
    
    self:process() -- '('
    self:compileParameterList()
    self:process() -- ')'
    
    -- גוף הפונקציה
    self:process() -- '{'
    
    -- ספירת המשתנים המקומיים כדי להדפיס פקודת function תקנית
    local varCount = 0
    while self:peek().value == "var" do
        -- צריך לספור כמה משתנים יש בכל varDec
        -- למען הפשטות, אפשר להשתמש בטבלה כדי לספור
        self:compileVarDec()
    end
    varCount = self.st.counts["lcl"]
    
    -- כתיבת הפונקציה ל-VM
    self.vm:writeFunction(className .. "." .. subName, varCount)
    
    -- אם זה constructor או method, צריך להוסיף אתחול זיכרון
    if kind == "constructor" then
        self.vm:writePush("constant", self.st.counts["field"]) -- נניח ששמרנו מספר שדות
        self.vm:writeCall("Memory.alloc", 1)
        self.vm:writePop("pointer", 0)
    elseif kind == "method" then
        self.vm:writePush("argument", 0)
        self.vm:writePop("pointer", 0)
    end
    
    self:compileStatements()
    self:process() -- '}'
end

--[[
function Engine:compileParameterList()
    self:writeTag("<parameterList>")
    if self:peek().value ~= ")" then
        self:process() -- type
        self:process() -- name
        while self:peek().value == "," do self:process(); self:process(); self:process() end
    end
    self:writeTag("</parameterList>", true)
end]]
function Engine:compileParameterList()
    -- לא צריך יותר writeTag ל-XML
    
    if self:peek().value ~= ")" then
        -- 1. קריאת הסוג (int, boolean, className...)
        local type = self:process().value
        -- 2. קריאת שם הפרמטר
        local name = self:process().value
        
        -- רישום הפרמטר בטבלת הסימבולים כ-argument
        self.st:define(name, type, "argument")
        
        -- המשך טיפול בפרמטרים נוספים (מופרדים בפסיקים)
        while self:peek().value == "," do
            self:process() -- דילוג על הפסיק
            type = self:process().value -- סוג
            name = self:process().value -- שם
            
            self.st:define(name, type, "argument") -- רישום בטבלה
        end
    end
end

--[[
function Engine:compileVarDec()
    self:writeTag("<varDec>")
    repeat self:process() until self.tokens[self.pos-1].value == ";"
    self:writeTag("</varDec>", true)
end]]
function Engine:compileVarDec()
    self:process() -- 'var'
    
    -- 1. קריאת הטיפוס (Type)
    local type = self:process().value
    
    -- 2. קריאת שמות המשתנים (יכולים להיות כמה מופרדים בפסיק)
    local name = self:process().value
    self.st:define(name, type, "lcl") -- רישום המשתנה הראשון
    
    -- המשך רישום אם יש עוד משתנים מאותו סוג (למשל: var int x, y, z;)
    while self:peek().value == "," do
        self:process() -- פסיק
        name = self:process().value
        self.st:define(name, type, "lcl") -- רישום המשתנה הבא כ-local
    end
    
    self:process() -- ';'
end

--[[
function Engine:compileStatements()
    self:writeTag("<statements>")
    local s = {let=true, ["if"]=true, ["while"]=true, ["do"]=true, ["return"]=true}
    while self:peek() and s[self:peek().value] do
        local v = self:peek().value
        if v == "let" then self:compileLet()
        elseif v == "if" then self:compileIf()
        elseif v == "while" then self:compileWhile()
        elseif v == "do" then self:compileDo()
        elseif v == "return" then self:compileReturn() end
    end
    self:writeTag("</statements>", true)
end]]
function Engine:compileStatements()
    -- אין צורך ב-writeTag("<statements>")
    
    local s = {let=true, ["if"]=true, ["while"]=true, ["do"]=true, ["return"]=true}
    
    -- אנחנו ממשיכים לרוץ כל עוד יש הצהרות (Statements)
    while self:peek() and s[self:peek().value] do
        local v = self:peek().value
        if v == "let" then self:compileLet()
        elseif v == "if" then self:compileIf()
        elseif v == "while" then self:compileWhile()
        elseif v == "do" then self:compileDo()
        elseif v == "return" then self:compileReturn() end
    end
    
    -- אין צורך ב-writeTag("</statements>")
end

--[[
function Engine:compileDo()
    self:writeTag("<doStatement>")
    
    self:process() -- כותב 'do'
    
    -- טיפול ב-subroutineCall (למשל Output.printInt או printInt)
    self:process() -- שם המחלקה או שם הפונקציה (Identifier)
    
    if self:peek() and self:peek().value == "." then
        self:process() -- כותב '.'
        self:process() -- שם הפונקציה (Identifier)
    end
    
    self:process() -- כותב '('
    self:compileExpressionList() -- רשימת הפרמטרים
    self:process() -- כותב ')'
    
    self:process() -- כותב ';'
    
    self:writeTag("</doStatement>", true)
end]]
function Engine:compileDo()
    self:process() -- 'do'
    
    -- 1. זיהוי הפונקציה שנקראת
    local firstPart = self:process().value
    local subName = ""
    local nArgs = 0
    local isMethod = false
    
    -- בדיקה האם זו קריאה למתודה של אובייקט (class.method או instance.method)
    if self:peek().value == "." then
        self:process() -- '.'
        subName = self:process().value -- שם הפונקציה
        
        -- בדיקה אם firstPart הוא אובייקט (נמצא ב-SymbolTable) או מחלקה
        local kind = self.st:kindOf(firstPart)
        if kind then
            -- זו מתודה של אובייקט (למשל: game.run())
            self.vm:writePush(kind == "field" and "this" or kind, self.st:indexOf(firstPart))
            nArgs = 1 -- האובייקט עצמו הוא ארגומנט ראשון
            subName = self.st:typeOf(firstPart) .. "." .. subName
        else
            -- זו פונקציה סטטית (למשל: Math.abs())
            subName = firstPart .. "." .. subName
        end
    else
        -- קריאה למתודה מקומית בתוך אותה מחלקה
        self.vm:writePush("pointer", 0) -- 'this'
        nArgs = 1
        subName = self.className .. "." .. firstPart
    end
    
    self:process() -- '('
    nArgs = nArgs + self:compileExpressionList() -- הוספת מספר הארגומנטים מהביטויים
    self:process() -- ')'
    
    self.vm:writeCall(subName, nArgs) -- הפקודה האמיתית ב-VM
    
    -- פקודת do תמיד זורקת את ערך ההחזרה (כי זו פקודה מסוג void)
    self.vm:writePop("temp", 0) 
    
    self:process() -- ';'
end

--[[
function Engine:compileExpression()
    self:writeTag("<expression>")
    self:compileTerm()
    while self:peek() and ops[self:peek().value] do self:process(); self:compileTerm() end
    self:writeTag("</expression>", true)
end]]

function Engine:compileExpression()
    local opMap = {
    ["+"] = "add",
    ["-"] = "sub",
    ["&"] = "and",
    ["|"] = "or",
    ["<"] = "lt",
    [">"] = "gt",
    ["="] = "eq"
    }

    self:compileTerm()

    while self:peek() and ops[self:peek().value] do
        local op = self:process().value
        self:compileTerm()

        if op == "*" then
            self.vm:writeCall("Math.multiply", 2)
        elseif op == "/" then
            self.vm:writeCall("Math.divide", 2)
        else
            self.vm:writeArithmetic(opMap[op])
        end
    end
end

--[[
function Engine:compileTerm()
    self:writeTag("<term>")
    local t = self:peek()
    if t.type == "integerConstant" or t.type == "stringConstant" or t.type == "keyword" then self:process()
    elseif t.value == "(" then self:process(); self:compileExpression(); self:process()
    elseif t.value == "-" or t.value == "~" then self:process(); self:compileTerm()
    elseif t.type == "identifier" then
        if self:peek(1).value == "[" then self:process(); self:process(); self:compileExpression(); self:process()
        elseif self:peek(1).value == "(" or self:peek(1).value == "." then
            repeat self:process() until self:peek().value == "("
            self:process(); self:compileExpressionList(); self:process()
        else self:process() end
    end
    self:writeTag("</term>", true)
end]]
function Engine:compileTerm()
    local t = self:peek()
    
    -- 1. קבועים (מספרים)
    if t.type == "integerConstant" then
        self.vm:writePush("constant", self:process().value)
        
    elseif t.type == "stringConstant" then
        local str = self:process().value
        self.vm:writePush("constant", #str)
        self.vm:writeCall("String.new", 1)
        for i = 1, #str do
            self.vm:writePush("constant", string.byte(str, i))
            self.vm:writeCall("String.appendChar", 2)
        end

    -- 2. קבועים מיוחדים (true, false, null, this)
    elseif t.type == "keyword" then
        local kw = self:process().value
        if kw == "true" then self.vm:writePush("constant", 0); self.vm:writeArithmetic("not") 
        elseif kw == "false" or kw == "null" then self.vm:writePush("constant", 0)
        elseif kw == "this" then self.vm:writePush("pointer", 0) end
        
    -- 3. ביטוי בסוגריים (expression)
    elseif t.value == "(" then
        self:process() -- '('
        self:compileExpression()
        self:process() -- ')'
        
    -- 4. אופרטורים אונריים (unaries: - או ~)
    elseif t.value == "-" or t.value == "~" then
        local op = self:process().value
        self:compileTerm()
        self.vm:writeArithmetic(op == "-" and "neg" or "not")
        
    -- 5. מזהה (משתנה, מערך, או קריאה לפונקציה)
    elseif t.type == "identifier" then
        local name = self:process().value
        local nextT = self:peek().value
        
        if nextT == "[" then -- מערך: var[exp]
            self:process() -- '['
            self:compileExpression()
            self:process() -- ']'
            -- חישוב הכתובת (base + index) ודחיפה של הערך ב-that
            local kind = self.st:kindOf(name)
            self.vm:writePush(kind == "field" and "this" or kind, self.st:indexOf(name))
            self.vm:writeArithmetic("add")
            self.vm:writePop("pointer", 1)
            self.vm:writePush("that", 0)
            
        elseif nextT == "(" or nextT == "." then -- קריאה לפונקציה
            self:compileSubroutineCall(name) -- פונקציה חיצונית/מתודה
        else -- משתנה רגיל
            local kind = self.st:kindOf(name)
            self.vm:writePush(kind == "field" and "this" or kind, self.st:indexOf(name))
        end
    end
end

function Engine:compileSubroutineCall(firstPart)
    local subName = ""
    local nArgs = 0
    
    -- אם ה-Token הבא הוא '.', זו קריאה למחלקה או לאובייקט חיצוני
    if self:peek().value == "." then
        self:process() -- '.'
        local methodOrFuncName = self:process().value
        
        -- נבדוק אם firstPart הוא שם של משתנה (אובייקט) בטבלת הסימבולים
        local kind = self.st:kindOf(firstPart)
        if kind then
            -- מקרה: object.method()
            -- דוחפים את האובייקט (ה-this) למחסנית
            self.vm:writePush(kind == "field" and "this" or kind, self.st:indexOf(firstPart))
            -- שם הפונקציה יהיה [Type של האובייקט].[שם המתודה]
            local type = self.st:typeOf(firstPart) -- וודאו ש-typeOf קיים ב-SymbolTable שלכן
            subName = type .. "." .. methodOrFuncName
            nArgs = 1 -- האובייקט הוא ארגומנט ראשון
        else
            -- מקרה: Class.function()
            subName = firstPart .. "." .. methodOrFuncName
            nArgs = 0
        end
    else
        -- קריאה למתודה פנימית באותה מחלקה: method()
        self.vm:writePush("pointer", 0) -- 'this'
        nArgs = 1
        subName = self.className .. "." .. firstPart
    end
    
    self:process() -- '('
    nArgs = nArgs + self:compileExpressionList() -- הוספת מספר הארגומנטים מהביטויים
    self:process() -- ')'
    
    self.vm:writeCall(subName, nArgs)
end


--[[
function Engine:compileExpressionList()
    self:writeTag("<expressionList>")
    if self:peek().value ~= ")" then
        self:compileExpression()
        while self:peek().value == "," do self:process(); self:compileExpression() end
    end
    self:writeTag("</expressionList>", true)
end]]
function Engine:compileExpressionList()
    -- במקום לכתוב XML, נחזיר את מספר הביטויים שמצאנו
    local nArgs = 0
    
    if self:peek().value ~= ")" then
        -- חישוב הביטוי הראשון
        self:compileExpression()
        nArgs = 1
        
        -- כל פסיק מסמן ביטוי נוסף
        while self:peek().value == "," do
            self:process() -- דילוג על הפסיק
            self:compileExpression()
            nArgs = nArgs + 1
        end
    end
    
    return nArgs
end

--[[
function Engine:compileWhile()
    self:writeTag("<whileStatement>")
    
    self:process() -- 'while'
    self:process() -- '('
    self:compileExpression()
    self:process() -- ')'
    self:process() -- '{'
    self:compileStatements()
    self:process() -- '}'
    
    self:writeTag("</whileStatement>", true)
end]]
function Engine:compileWhile()
    local expLabel = self:newLabel()
    local endLabel = self:newLabel()
    
    self:process() -- 'while'
    
    -- תחילת הלולאה: הלייבל שאליו חוזרים אחרי כל איטרציה
    self.vm:writeLabel(expLabel)
    
    self:process() -- '('
    self:compileExpression() -- מחשב את הערך ומניח על המחסנית
    self:process() -- ')'
    
    -- אם הביטוי שקרי (0), דלג לסוף הלולאה
    self.vm:writeArithmetic("not")
    self.vm:writeIf(endLabel)
    
    self:process() -- '{'
    self:compileStatements()
    self:process() -- '}'
    
    -- חזרה לבדיקת התנאי
    self.vm:writeGoto(expLabel)
    
    -- סימון סוף הלולאה
    self.vm:writeLabel(endLabel)
end

-- ---------------------------------------------------------
-- compileIf: 'if' '(' expression ')' '{' statements '}' ( 'else' '{' statements '}' )?
-- ---------------------------------------------------------
--[[
function Engine:compileIf()
    self:writeTag("<ifStatement>")
    
    self:process() -- 'if'
    self:process() -- '('
    self:compileExpression()
    self:process() -- ')'
    self:process() -- '{'
    self:compileStatements()
    self:process() -- '}'
    
    -- בדיקה אם קיים חלק של else
    if self:peek() and self:peek().value == "else" then
        self:process() -- 'else'
        self:process() -- '{'
        self:compileStatements()
        self:process() -- '}'
    end
    
    self:writeTag("</ifStatement>", true)
end]]
function Engine:compileIf()
    local elseLabel = self:newLabel()
    local endLabel = self:newLabel()
    
    self:process() -- 'if'
    self:process() -- '('
    self:compileExpression() -- התוצאה כעת על המחסנית
    self:process() -- ')'
    
    -- אם הביטוי שקרי (0), דלג ל-else (או לסוף אם אין else)
    self.vm:writeArithmetic("not")
    self.vm:writeIf(elseLabel)
    
    self:process() -- '{'
    self:compileStatements()
    self:process() -- '}'
    
    -- דלג על ה-else (אם הוא קיים)
    self.vm:writeGoto(endLabel)
    
    -- לייבל ה-else
    self.vm:writeLabel(elseLabel)
    
    if self:peek() and self:peek().value == "else" then
        self:process() -- 'else'
        self:process() -- '{'
        self:compileStatements()
        self:process() -- '}'
    end
    
    -- לייבל הסיום
    self.vm:writeLabel(endLabel)
end


--[[
function Engine:compileReturn()
    self:writeTag("<returnStatement>")
    self:process() -- 'return'
    if self:peek().value ~= ";" then self:compileExpression() end
    self:process() -- ';'
    self:writeTag("</returnStatement>", true)
end]]
function Engine:compileReturn()
    self:process() -- 'return'
    
    -- אם יש ביטוי, מחשבים אותו (התוצאה תישאר על המחסנית)
    if self:peek().value ~= ";" then
        self:compileExpression()
    else
        -- אם זו פונקציית void (אין ביטוי), נדחוף 0 כערך ברירת מחדל
        self.vm:writePush("constant", 0)
    end
    
    self:process() -- ';'
    
    -- פקודת ההחזרה של ה-VM
    self.vm:writeReturn()
end


--[[function Engine:compileLet()
    self:process() -- 'let'
    local name = self:peek().value
    self:process()
    
    if self:peek().value == "[" then
        self:process(); self:compileExpression(); self:process() -- [exp]
        local kind = self.st:kindOf(name)
        self.vm:writePush(kind == "field" and "this" or kind, self.st:indexOf(name))
        self.vm:writeArithmetic("add")
        self:process() -- =
        self:compileExpression()
        self.vm:writePop("that", 0)
    else
        self:process() -- =
        self:compileExpression()
        local kind = self.st:kindOf(name)
        self.vm:writePop(kind == "field" and "this" or kind, self.st:indexOf(name))
    end
    self:process() -- ;
end]]

function Engine:compileLet()
    self:process() -- 'let'

    local name = self:peek().value
    self:process() -- variable name

    local isArray = false

    if self:peek().value == "[" then
        isArray = true

        self:process() -- '['

        -- דוחפים את בסיס המערך
        local kind = self.st:kindOf(name)
        local segment = (kind == "field") and "this" or kind
        self.vm:writePush(segment, self.st:indexOf(name))

        -- מחשבים את האינדקס
        self:compileExpression()

        self:process() -- ']'

        -- מחשבים כתובת: base + index
        self.vm:writeArithmetic("add")
    end

    self:process() -- '='

    -- מחשבים את צד ימין
    self:compileExpression()

    self:process() -- ';'

    if isArray then
        -- בראש המחסנית נמצא הערך שרוצים לשים
        -- מתחתיו נמצאת הכתובת של a[i]
        self.vm:writePop("temp", 0)
        self.vm:writePop("pointer", 1)
        self.vm:writePush("temp", 0)
        self.vm:writePop("that", 0)
    else
        local kind = self.st:kindOf(name)
        local segment = (kind == "field") and "this" or kind
        self.vm:writePop(segment, self.st:indexOf(name))
    end
end


return Engine