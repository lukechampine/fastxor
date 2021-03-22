// +build amd64,!gccgo,!appengine,!nacl

#include "textflag.h"

#define Dst DI
#define A R8
#define B R9
#define N R12

// func xorBytesSSE(dst, a, b []byte, n int)
TEXT ·xorBytesSSE(SB), NOSPLIT, $0
	MOVQ dst_data+0(FP), Dst
	MOVQ a_data+24(FP), A
	MOVQ b_data+48(FP), B
	MOVQ n+72(FP), N

XOR_LOOP_64_SSE:
	CMPQ   N, $64
	JB     XOR_LOOP_16_SSE

	MOVOU  0*16(A), X0
	MOVOU  1*16(A), X1
	MOVOU  2*16(A), X2
	MOVOU  3*16(A), X3
	MOVOU  0*16(B), X4
	MOVOU  1*16(B), X5
	MOVOU  2*16(B), X6
	MOVOU  3*16(B), X7

	PXOR   X4, X0
	PXOR   X5, X1
	PXOR   X6, X2
	PXOR   X7, X3

	MOVOU  X0, 0*16(Dst)
	MOVOU  X1, 1*16(Dst)
	MOVOU  X2, 2*16(Dst)
	MOVOU  X3, 3*16(Dst)

	ADDQ   $64, A
	ADDQ   $64, B
	ADDQ   $64, Dst
	SUBQ   $64, N
	JNZ    XOR_LOOP_64_SSE
	RET

XOR_LOOP_16_SSE:
	CMPQ   N, $16
	JB     XOR_LOOP_FINAL_SSE
	MOVOU  (A), X0
	MOVOU  (B), X1
	PXOR   X1, X0
	MOVOU  X0, (Dst)
	ADDQ   $16, A
	ADDQ   $16, B
	ADDQ   $16, Dst
	SUBQ   $16, N
	JNZ    XOR_LOOP_16_SSE
	RET

XOR_LOOP_FINAL_SSE:
	MOVB   (A), AL
	MOVB   (B), BL
	XORB   AL, BL
	MOVB   BL, (Dst)
	INCQ   A
	INCQ   B
	INCQ   Dst
	DECQ   N
	JNZ    XOR_LOOP_FINAL_SSE
	RET


// func xorBytesAVX2(dst, a, b []byte, n int)
TEXT ·xorBytesAVX2(SB), NOSPLIT ,$0
	MOVQ dst_data+0(FP), Dst
	MOVQ a_data+24(FP), A
	MOVQ b_data+48(FP), B
	MOVQ n+72(FP), N

XOR_LOOP_256_AVX:
	CMPQ     N, $256
	JB       XOR_LOOP_128_AVX

	VMOVDQU  0*32(A), Y0
	VMOVDQU  1*32(A), Y1
	VMOVDQU  2*32(A), Y2
	VMOVDQU  3*32(A), Y3
	VMOVDQU  4*32(A), Y4
	VMOVDQU  5*32(A), Y5
	VMOVDQU  6*32(A), Y6
	VMOVDQU  7*32(A), Y7

	VPXOR    0*32(B), Y0, Y0
	VPXOR    1*32(B), Y1, Y1
	VPXOR    2*32(B), Y2, Y2
	VPXOR    3*32(B), Y3, Y3
	VPXOR    4*32(B), Y4, Y4
	VPXOR    5*32(B), Y5, Y5
	VPXOR    6*32(B), Y6, Y6
	VPXOR    7*32(B), Y7, Y7

	VMOVDQU  Y0, 0*32(Dst)
	VMOVDQU  Y1, 1*32(Dst)
	VMOVDQU  Y2, 2*32(Dst)
	VMOVDQU  Y3, 3*32(Dst)
	VMOVDQU  Y4, 4*32(Dst)
	VMOVDQU  Y5, 5*32(Dst)
	VMOVDQU  Y6, 6*32(Dst)
	VMOVDQU  Y7, 7*32(Dst)

	ADDQ     $256, A
	ADDQ     $256, B
	ADDQ     $256, Dst
	SUBQ     $256, N
	JNZ      XOR_LOOP_256_AVX
	RET

XOR_LOOP_128_AVX:
	CMPQ     N, $128
	JB       XOR_LOOP_64_AVX

	VMOVDQU  0*32(A), Y0
	VMOVDQU  1*32(A), Y1
	VMOVDQU  2*32(A), Y2
	VMOVDQU  3*32(A), Y3

	VPXOR    0*32(B), Y0, Y0
	VPXOR    1*32(B), Y1, Y1
	VPXOR    2*32(B), Y2, Y2
	VPXOR    3*32(B), Y3, Y3

	VMOVDQU  Y0, 0*32(Dst)
	VMOVDQU  Y1, 1*32(Dst)
	VMOVDQU  Y2, 2*32(Dst)
	VMOVDQU  Y3, 3*32(Dst)

	ADDQ     $128, A
	ADDQ     $128, B
	ADDQ     $128, Dst
	SUBQ     $128, N
	JNZ      XOR_LOOP_128_AVX
	RET

XOR_LOOP_64_AVX:
	CMPQ     N, $64
	JB       XOR_LOOP_16_AVX

	VMOVDQU  0*32(A), Y0
	VMOVDQU  1*32(A), Y1

	VPXOR    0*32(B), Y0, Y2
	VPXOR    1*32(B), Y1, Y3

	VMOVDQU  Y2, 0*32(Dst)
	VMOVDQU  Y3, 1*32(Dst)

	ADDQ     $64, A
	ADDQ     $64, B
	ADDQ     $64, Dst
	SUBQ     $64, N
	JNZ      XOR_LOOP_64_AVX
	RET

XOR_LOOP_16_AVX:
	CMPQ     N, $16
	JB       XOR_LOOP_FINAL_AVX
	MOVOU    (A), X0
	VPXOR    (B), X0, X1
	VMOVDQU  X1, (Dst)
	ADDQ     $16, A
	ADDQ     $16, B
	ADDQ     $16, Dst
	SUBQ     $16, N
	JNZ      XOR_LOOP_16_AVX
	RET

XOR_LOOP_FINAL_AVX:
	MOVB     (A), AL
	MOVB     (B), BL
	XORB     AL, BL
	MOVB     BL, (Dst)
	INCQ     A
	INCQ     B
	INCQ     Dst
	DECQ     N
	JNZ      XOR_LOOP_FINAL_AVX
	RET

#undef Dst
#undef A
#undef B
#undef N
