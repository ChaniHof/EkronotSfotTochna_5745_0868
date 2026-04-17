// File: StaticTest
// pushconstant 111
@111
D=A
@SP
A=M
M=D
@SP
M=M+1

// pushconstant 333
@333
D=A
@SP
A=M
M=D
@SP
M=M+1

// pushconstant 888
@888
D=A
@SP
A=M
M=D
@SP
M=M+1

@SP
M=M-1
A=M
D=M
@StaticTest.8
M=D
@SP
M=M-1
A=M
D=M
@StaticTest.3
M=D
@SP
M=M-1
A=M
D=M
@StaticTest.1
M=D
// pushstatic 3
@StaticTest.3
D=M
@SP
A=M
M=D
@SP
M=M+1

// pushstatic 1
@StaticTest.1
D=M
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

// pushstatic 8
@StaticTest.8
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

