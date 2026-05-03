// File: BasicLoop
// pushconstant 0
@0
D=A
@SP
A=M
M=D
@SP
M=M+1

@0
D=A
@LCL
D=M+D
@SP
M=M-1
A=M
A=M
A=A+D
D=A-D
A=A-D
M=D
(BasicLoop.LOOP_START)

// pushargument 0
@0
D=A
@ARG
A=M+D
D=M
@SP
A=M
M=D
@SP
M=M+1

// pushlocal 0
@0
D=A
@LCL
A=M+D
D=M
@SP
A=M
M=D
@SP
M=M+1

//add
@SP
A=M-1
D=M
A=A-1
M=D+M
@SP
M=M-1

@0
D=A
@LCL
D=M+D
@SP
M=M-1
A=M
A=M
A=A+D
D=A-D
A=A-D
M=D
// pushargument 0
@0
D=A
@ARG
A=M+D
D=M
@SP
A=M
M=D
@SP
M=M+1

// pushconstant 1
@1
D=A
@SP
A=M
M=D
@SP
M=M+1

//sub
@SP
A=M-1
D=M
A=A-1
M=M-D
@SP
M=M-1

@0
D=A
@ARG
D=M+D
@SP
M=M-1
A=M
A=M
A=A+D
D=A-D
A=A-D
M=D
// pushargument 0
@0
D=A
@ARG
A=M+D
D=M
@SP
A=M
M=D
@SP
M=M+1

@SP
AM=M-1
D=M
@BasicLoop.LOOP_START
D;JNE

// pushlocal 0
@0
D=A
@LCL
A=M+D
D=M
@SP
A=M
M=D
@SP
M=M+1

