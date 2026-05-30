
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

-- פונקציות עזר ל-XML
local function encodeXML(s)
    if not s then return "" end
    return s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;")
end

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



function Engine.run(inputTPath, outputXMLPath)
    local tokens = loadTokens(inputTPath)
    local engine = Engine.new(tokens, outputXMLPath)
    if engine then
        engine:compileClass()
        if engine.outFile then
            engine.outFile:close()
        end
        return true
    end
    return false
end

function Engine.new(tokens, outPath)
    local self = setmetatable({}, Engine)
    self.tokens = tokens
    self.pos = 1
    self.outFile = io.open(outPath, "w")
    self.indent = 0
    return self
end

function Engine:writeTag(tag, close)
    if close then self.indent = self.indent - 1 end
    self.outFile:write(string.rep("  ", self.indent) .. tag .. "\n")
    if not close and not tag:match("/") then self.indent = self.indent + 1 end
end

function Engine:process(expected)
    local t = self.tokens[self.pos]
    if not t then return end
    local val = encodeXML(t.value)
    --if t.type == "stringConstant" then val = val .. " " end
    self.outFile:write(string.rep("  ", self.indent) .. "<" .. t.type .. "> " .. val .. " </" .. t.type .. ">\n")
    self.pos = self.pos + 1
end

function Engine:peek(offset) return self.tokens[self.pos + (offset or 0)] end

-- --- חוקי התחביר ---

function Engine:compileClass()
    self:writeTag("<class>")
    self:process() -- 'class'
    self:process() -- className
    self:process() -- '{'
    while self:peek() and (self:peek().value == "static" or self:peek().value == "field") do 
        self:compileClassVarDec() 
    end
    while self:peek() and (self:peek().value == "constructor" or self:peek().value == "function" or self:peek().value == "method") do 
        self:compileSubroutine() 
    end
    self:process() -- '}'
    self:writeTag("</class>", true)
    --self.outFile:close()
end

function Engine:compileClassVarDec()
    self:writeTag("<classVarDec>")
    repeat self:process() until self.tokens[self.pos-1].value == ";"
    self:writeTag("</classVarDec>", true)
end

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
end

function Engine:compileParameterList()
    self:writeTag("<parameterList>")
    if self:peek().value ~= ")" then
        self:process() -- type
        self:process() -- name
        while self:peek().value == "," do self:process(); self:process(); self:process() end
    end
    self:writeTag("</parameterList>", true)
end

function Engine:compileVarDec()
    self:writeTag("<varDec>")
    repeat self:process() until self.tokens[self.pos-1].value == ";"
    self:writeTag("</varDec>", true)
end

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
end

function Engine:compileLet()
    self:writeTag("<letStatement>")
    self:process() -- 'let'
    self:process() -- varName
    if self:peek().value == "[" then self:process(); self:compileExpression(); self:process() end
    self:process() -- '='
    self:compileExpression()
    self:process() -- ';'
    self:writeTag("</letStatement>", true)
end

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
end

function Engine:compileExpression()
    self:writeTag("<expression>")
    self:compileTerm()
    while self:peek() and ops[self:peek().value] do self:process(); self:compileTerm() end
    self:writeTag("</expression>", true)
end

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
end

function Engine:compileExpressionList()
    self:writeTag("<expressionList>")
    if self:peek().value ~= ")" then
        self:compileExpression()
        while self:peek().value == "," do self:process(); self:compileExpression() end
    end
    self:writeTag("</expressionList>", true)
end

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
end

-- ---------------------------------------------------------
-- compileIf: 'if' '(' expression ')' '{' statements '}' ( 'else' '{' statements '}' )?
-- ---------------------------------------------------------
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
end

function Engine:compileReturn()
    self:writeTag("<returnStatement>")
    self:process() -- 'return'
    if self:peek().value ~= ";" then self:compileExpression() end
    self:process() -- ';'
    self:writeTag("</returnStatement>", true)
end


return Engine