// File: StackTest
// pushconstant 17
@17
D=A
@SP
A=M
M=D
@SP
M=M+1

// pushconstant 17
@17
D=A
@SP
A=M
M=D
@SP
M=M+1

// eq
@SP
AM=M-1
D=M
@SP
A=M-1
D=M-D
@EQ_TRUE_0
D;JEQ
@SP
A=M-1
M=0
@EQ_END_0
0;JMP
(EQ_TRUE_0)
@SP
A=M-1
M=-1
(EQ_END_0)

// pushconstant 17
@17
D=A
@SP
A=M
M=D
@SP
M=M+1

// pushconstant 16
@16
D=A
@SP
A=M
M=D
@SP
M=M+1

// eq
@SP
AM=M-1
D=M
@SP
A=M-1
D=M-D
@EQ_TRUE_1
D;JEQ
@SP
A=M-1
M=0
@EQ_END_1
0;JMP
(EQ_TRUE_1)
@SP
A=M-1
M=-1
(EQ_END_1)

// pushconstant 16
@16
D=A
@SP
A=M
M=D
@SP
M=M+1

// pushconstant 17
@17
D=A
@SP
A=M
M=D
@SP
M=M+1

// eq
@SP
AM=M-1
D=M
@SP
A=M-1
D=M-D
@EQ_TRUE_2
D;JEQ
@SP
A=M-1
M=0
@EQ_END_2
0;JMP
(EQ_TRUE_2)
@SP
A=M-1
M=-1
(EQ_END_2)

// pushconstant 892
@892
D=A
@SP
A=M
M=D
@SP
M=M+1

// pushconstant 891
@891
D=A
@SP
A=M
M=D
@SP
M=M+1

// lt
@SP
AM=M-1
D=M
@SP
A=M-1
D=M-D
@LT_TRUE_3
D;JLT
@SP
A=M-1
M=0
@LT_END_3
0;JMP
(LT_TRUE_3)
@SP
A=M-1
M=-1
(LT_END_3)

// pushconstant 891
@891
D=A
@SP
A=M
M=D
@SP
M=M+1

// pushconstant 892
@892
D=A
@SP
A=M
M=D
@SP
M=M+1

// lt
@SP
AM=M-1
D=M
@SP
A=M-1
D=M-D
@LT_TRUE_4
D;JLT
@SP
A=M-1
M=0
@LT_END_4
0;JMP
(LT_TRUE_4)
@SP
A=M-1
M=-1
(LT_END_4)

// pushconstant 891
@891
D=A
@SP
A=M
M=D
@SP
M=M+1

// pushconstant 891
@891
D=A
@SP
A=M
M=D
@SP
M=M+1

// lt
@SP
AM=M-1
D=M
@SP
A=M-1
D=M-D
@LT_TRUE_5
D;JLT
@SP
A=M-1
M=0
@LT_END_5
0;JMP
(LT_TRUE_5)
@SP
A=M-1
M=-1
(LT_END_5)

// pushconstant 32767
@32767
D=A
@SP
A=M
M=D
@SP
M=M+1

// pushconstant 32766
@32766
D=A
@SP
A=M
M=D
@SP
M=M+1

// gt
@SP
AM=M-1
D=M
@SP
A=M-1
D=M-D
@GT_TRUE_6
D;JGT
@SP
A=M-1
M=0
@GT_END_6
0;JMP
(GT_TRUE_6)
@SP
A=M-1
M=-1
(GT_END_6)

// pushconstant 32766
@32766
D=A
@SP
A=M
M=D
@SP
M=M+1

// pushconstant 32767
@32767
D=A
@SP
A=M
M=D
@SP
M=M+1

// gt
@SP
AM=M-1
D=M
@SP
A=M-1
D=M-D
@GT_TRUE_7
D;JGT
@SP
A=M-1
M=0
@GT_END_7
0;JMP
(GT_TRUE_7)
@SP
A=M-1
M=-1
(GT_END_7)

// pushconstant 32766
@32766
D=A
@SP
A=M
M=D
@SP
M=M+1

// pushconstant 32766
@32766
D=A
@SP
A=M
M=D
@SP
M=M+1

// gt
@SP
AM=M-1
D=M
@SP
A=M-1
D=M-D
@GT_TRUE_8
D;JGT
@SP
A=M-1
M=0
@GT_END_8
0;JMP
(GT_TRUE_8)
@SP
A=M-1
M=-1
(GT_END_8)

// pushconstant 57
@57
D=A
@SP
A=M
M=D
@SP
M=M+1

// pushconstant 31
@31
D=A
@SP
A=M
M=D
@SP
M=M+1

// pushconstant 53
@53
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

// pushconstant 112
@112
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

 // neg
@SP
A=M-1
M=-M

//and
@SP
A=M-1
D=M
A=A-1
M=D&M
@SP
M=M-1

// pushconstant 82
@82
D=A
@SP
A=M
M=D
@SP
M=M+1

//or
@SP
A=M-1
D=M
A=A-1
M=D|M
@SP
M=M-1

// not
@SP
A=M-1
M=!M

