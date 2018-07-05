// +build amd64,!gccgo,!appengine,!nacl

#include "textflag.h"

#define Dst DI
#define A R8
#define B R9
#define N R12

// func xorBytesSSE(dst, a, b []byte, n int)
TEXT ·xorBytesSSE(SB),NOSPLIT,$0
	MOVQ dst_data+0(FP), Dst
	MOVQ a_data+24(FP), A
	MOVQ b_data+48(FP), B
	MOVQ n+72(FP), N

XOR_LOOP_128_SSE:
	CMPQ   N, $128
	JB     XOR_LOOP_64_SSE

	MOVOU     (A), X0
	MOVOU   16(A), X1
	MOVOU   32(A), X2
	MOVOU   48(A), X3
	MOVOU   64(A), X4
	MOVOU   80(A), X5
	MOVOU   96(A), X6
	MOVOU  112(A), X7

	PXOR     (B), X0
	PXOR   16(B), X1
	PXOR   32(B), X2
	PXOR   48(B), X3
	PXOR   64(B), X4
	PXOR   80(B), X5
	PXOR   96(B), X6
	PXOR  112(B), X7

	MOVOU   X0,    (Dst)
	MOVOU   X1,  16(Dst)
	MOVOU   X2,  32(Dst)
	MOVOU   X3,  48(Dst)
	MOVOU   X4,  64(Dst)
	MOVOU   X5,  80(Dst)
	MOVOU   X6,  96(Dst)
	MOVOU   X7, 112(Dst)

	ADDQ   $128, A
	ADDQ   $128, B
	ADDQ   $128, Dst
	SUBQ   $128, N
	JNZ    XOR_LOOP_128_SSE
	RET

XOR_LOOP_64_SSE:
	CMPQ   N, $64
	JB     XOR_LOOP_16_SSE

	MOVOU    (A), X0
	MOVOU    (B), X1
	MOVOU  16(A), X2
	MOVOU  16(B), X3
	MOVOU  32(A), X4
	MOVOU  32(B), X5
	MOVOU  48(A), X6
	MOVOU  48(B), X7

	PXOR   X0, X1
	PXOR   X2, X3
	PXOR   X4, X5
	PXOR   X6, X7

	MOVOU  X1,   (Dst)
	MOVOU  X3, 16(Dst)
	MOVOU  X5, 32(Dst)
	MOVOU  X7, 48(Dst)

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
	PXOR   X0, X1
	MOVOU  X1, (Dst)
	ADDQ   $16, A
	ADDQ   $16, B
	ADDQ   $16, Dst
	SUBQ   $16, N
	JNZ    XOR_LOOP_16_SSE
	RET

XOR_LOOP_FINAL_SSE:
	MOVB  (A), AL
	MOVB  (B), BL
	XORB  AL, BL
	MOVB  BL, (Dst)
	INCQ  A
	INCQ  B
	INCQ  Dst
	DECQ  N
	JNZ   XOR_LOOP_FINAL_SSE
	RET


// func xorBytesAVX(dst, a, b []byte, n int)
TEXT ·xorBytesAVX(SB),NOSPLIT,$0
	MOVQ dst_data+0(FP), Dst
	MOVQ a_data+24(FP), A
	MOVQ b_data+48(FP), B
	MOVQ n+72(FP), N

XOR_LOOP_128_AVX:
	CMPQ   N, $128
	JB     XOR_LOOP_64_AVX

	VMOVDQU     (A), X0
	VMOVDQU   16(A), X1
	VMOVDQU   32(A), X2
	VMOVDQU   48(A), X3
	VMOVDQU   64(A), X4
	VMOVDQU   80(A), X5
	VMOVDQU   96(A), X6
	VMOVDQU  112(A), X7

	VPXOR     (B), X0, X0
	VPXOR   16(B), X1, X1
	VPXOR   32(B), X2, X2
	VPXOR   48(B), X3, X3
	VPXOR   64(B), X4, X4
	VPXOR   80(B), X5, X5
	VPXOR   96(B), X6, X6
	VPXOR  112(B), X7, X7

	VMOVDQU   X0,    (Dst)
	VMOVDQU   X1,  16(Dst)
	VMOVDQU   X2,  32(Dst)
	VMOVDQU   X3,  48(Dst)
	VMOVDQU   X4,  64(Dst)
	VMOVDQU   X5,  80(Dst)
	VMOVDQU   X6,  96(Dst)
	VMOVDQU   X7, 112(Dst)

	ADDQ   $128, A
	ADDQ   $128, B
	ADDQ   $128, Dst
	SUBQ   $128, N
	JNZ    XOR_LOOP_128_AVX
	RET

XOR_LOOP_64_AVX:
	CMPQ   N, $64
	JB     XOR_LOOP_16_AVX

	MOVOU    (A), X0
	MOVOU  16(A), X1
	MOVOU  32(A), X2
	MOVOU  48(A), X3

	VPXOR    (B), X0, X4
	VPXOR  16(B), X1, X5
	VPXOR  32(B), X2, X6
	VPXOR  48(B), X3, X7

	VMOVDQU  X4,   (Dst)
	VMOVDQU  X5, 16(Dst)
	VMOVDQU  X6, 32(Dst)
	VMOVDQU  X7, 48(Dst)

	ADDQ   $64, A
	ADDQ   $64, B
	ADDQ   $64, Dst
	SUBQ   $64, N
	JNZ    XOR_LOOP_64_AVX
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
	MOVB  (A), AL
	MOVB  (B), BL
	XORB  AL, BL
	MOVB  BL, (Dst)
	INCQ  A
	INCQ  B
	INCQ  Dst
	DECQ  N
	JNZ   XOR_LOOP_FINAL_AVX
	RET

#undef Dst
#undef A
#undef B
#undef N
