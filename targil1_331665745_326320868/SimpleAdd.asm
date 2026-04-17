// File: SimpleAdd
// pushconstant 7
@7
D=A
@SP
A=M
M=D
@SP
M=M+1

// pushconstant 8
@8
D=A
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

