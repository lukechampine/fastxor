// +build amd64,!gccgo,!appengine,!nacl

#include "textflag.h"

#define Dst DI
#define A R8
#define B R9
#define N R12

// func xorBytesSSE(dst, a, b []byte, n int)
TEXT ·xorBytesSSE(SB), NOSPLIT ,$0
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

	PXOR      (B), X0
	PXOR    16(B), X1
	PXOR    32(B), X2
	PXOR    48(B), X3
	PXOR    64(B), X4
	PXOR    80(B), X5
	PXOR    96(B), X6
	PXOR   112(B), X7

	MOVOU  X0,    (Dst)
	MOVOU  X1,  16(Dst)
	MOVOU  X2,  32(Dst)
	MOVOU  X3,  48(Dst)
	MOVOU  X4,  64(Dst)
	MOVOU  X5,  80(Dst)
	MOVOU  X6,  96(Dst)
	MOVOU  X7, 112(Dst)

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
	MOVOU  16(A), X1
	MOVOU  32(A), X2
	MOVOU  48(A), X3

	PXOR     (B), X0
	PXOR   16(B), X1
	PXOR   32(B), X2
	PXOR   48(B), X3

	MOVOU  X0,   (Dst)
	MOVOU  X1, 16(Dst)
	MOVOU  X2, 32(Dst)
	MOVOU  X3, 48(Dst)

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
	PXOR   (B), X0
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


// func xorBytesAVX(dst, a, b []byte, n int)
TEXT ·xorBytesAVX(SB), NOSPLIT ,$0
	MOVQ dst_data+0(FP), Dst
	MOVQ a_data+24(FP), A
	MOVQ b_data+48(FP), B
	MOVQ n+72(FP), N

XOR_LOOP_256_AVX:
	CMPQ     N, $256
	JB       XOR_LOOP_128_AVX

	VMOVDQU     (A), Y0
	VMOVDQU   32(A), Y1
	VMOVDQU   64(A), Y2
	VMOVDQU   96(A), Y3
	VMOVDQU  128(A), Y4
	VMOVDQU  160(A), Y5
	VMOVDQU  192(A), Y6
	VMOVDQU  224(A), Y7

	VPXOR       (B), Y0, Y0
	VPXOR     32(B), Y1, Y1
	VPXOR     64(B), Y2, Y2
	VPXOR     96(B), Y3, Y3
	VPXOR    128(B), Y4, Y4
	VPXOR    160(B), Y5, Y5
	VPXOR    192(B), Y6, Y6
	VPXOR    224(B), Y7, Y7

	VMOVDQU  Y0,    (Dst)
	VMOVDQU  Y1,  32(Dst)
	VMOVDQU  Y2,  64(Dst)
	VMOVDQU  Y3,  96(Dst)
	VMOVDQU  Y4, 128(Dst)
	VMOVDQU  Y5, 160(Dst)
	VMOVDQU  Y6, 192(Dst)
	VMOVDQU  Y7, 224(Dst)

	ADDQ     $256, A
	ADDQ     $256, B
	ADDQ     $256, Dst
	SUBQ     $256, N
	JNZ      XOR_LOOP_256_AVX
	RET

XOR_LOOP_128_AVX:
	CMPQ   N, $128
	JB     XOR_LOOP_64_AVX

	VMOVDQU    (A), Y0
	VMOVDQU  32(A), Y1
	VMOVDQU  64(A), Y2
	VMOVDQU  96(A), Y3

	VPXOR      (B), Y0, Y0
	VPXOR    32(B), Y1, Y1
	VPXOR    64(B), Y2, Y2
	VPXOR    96(B), Y3, Y3

	VMOVDQU  Y0,   (Dst)
	VMOVDQU  Y1, 32(Dst)
	VMOVDQU  Y2, 64(Dst)
	VMOVDQU  Y3, 96(Dst)

	ADDQ     $128, A
	ADDQ     $128, B
	ADDQ     $128, Dst
	SUBQ     $128, N
	JNZ      XOR_LOOP_128_AVX
	RET

XOR_LOOP_64_AVX:
	CMPQ     N, $64
	JB       XOR_LOOP_16_AVX

	VMOVDQU    (A), Y0
	VMOVDQU  32(A), Y1

	VPXOR      (B), Y0, Y2
	VPXOR    32(B), Y1, Y3

	VMOVDQU  Y2,   (Dst)
	VMOVDQU  Y3, 32(Dst)

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
