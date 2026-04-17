// File: PointerTest
// pushconstant 3030
@3030
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
@THIS
M=D
// pushconstant 3040
@3040
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
@THAT
M=D
// pushconstant 32
@32
D=A
@SP
A=M
M=D
@SP
M=M+1

@2
D=A
@THIS
D=M+D
@SP
M=M-1
A=M
A=M
A=A+D
D=A-D
A=A-D
M=D
// pushconstant 46
@46
D=A
@SP
A=M
M=D
@SP
M=M+1

@6
D=A
@THAT
D=M+D
@SP
M=M-1
A=M
A=M
A=A+D
D=A-D
A=A-D
M=D
// pushpointer 0
@THIS
D=M
@SP
A=M
M=D
@SP
M=M+1

// pushpointer 1
@THAT
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

// pushthis 2
@2
D=A
@THIS
A=M+D
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

// pushthat 6
@6
D=A
@THAT
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

