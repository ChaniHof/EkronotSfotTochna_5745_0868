// File: BasicTest
// pushconstant 10
@10
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
// pushconstant 21
@21
D=A
@SP
A=M
M=D
@SP
M=M+1

// pushconstant 22
@22
D=A
@SP
A=M
M=D
@SP
M=M+1

@2
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
@1
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
// pushconstant 36
@36
D=A
@SP
A=M
M=D
@SP
M=M+1

@6
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
// pushconstant 42
@42
D=A
@SP
A=M
M=D
@SP
M=M+1

// pushconstant 45
@45
D=A
@SP
A=M
M=D
@SP
M=M+1

@5
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
@2
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
// pushconstant 510
@510
D=A
@SP
A=M
M=D
@SP
M=M+1

@6
D=A
@5
D=D+A
@SP
M=M-1
A=M
A=M
A=A+D
D=A-D
A=A-D
M=D
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

// pushthat 5
@5
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

// pushargument 1
@1
D=A
@ARG
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

// pushthis 6
@6
D=A
@THIS
A=M+D
D=M
@SP
A=M
M=D
@SP
M=M+1

// pushthis 6
@6
D=A
@THIS
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

//sub
@SP
A=M-1
D=M
A=A-1
M=M-D
@SP
M=M-1

// pushtemp 6
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

