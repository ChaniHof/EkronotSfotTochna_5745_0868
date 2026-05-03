// File: FibonacciSeries
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

@SP
M=M-1
A=M
D=M
@THAT
M=D
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
// pushconstant 1
@1
D=A
@SP
A=M
M=D
@SP
M=M+1

@1
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

// pushconstant 2
@2
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
(FibonacciSeries.MAIN_LOOP_START)

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
@FibonacciSeries.COMPUTE_ELEMENT
D;JNE

@FibonacciSeries.END_PROGRAM
0;JMP

(FibonacciSeries.COMPUTE_ELEMENT)

// pushthat 0
@0
D=A
@THAT
A=M+D
D=M
@SP
A=M
M=D
@SP
M=M+1

// pushthat 1
@1
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
// pushpointer 1
@THAT
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

//add
@SP
A=M-1
D=M
A=A-1
M=D+M
@SP
M=M-1

@SP
M=M-1
A=M
D=M
@THAT
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
@FibonacciSeries.MAIN_LOOP_START
0;JMP

(FibonacciSeries.END_PROGRAM)

