// +build go1.7,amd64,!gccgo,!appengine,!nacl

package fastxor

import (
	"unsafe"

	"golang.org/x/sys/cpu"
)

//go:noescape
func xorBytesSSE(dst, a, b []byte, n int)

//go:noescape
func xorBytesAVX2(dst, a, b []byte, n int)

func min(a, b, c int) int {
	if a < b {
		b = a
	}
	if b < c {
		c = b
	}
	return c
}

// Bytes stores (a xor b) in dst, stopping when the end of any slice is
// reached. It returns the number of bytes xor'd.
func Bytes(dst, a, b []byte) int {
	n := min(len(dst), len(a), len(b))
	if n == 0 {
		return 0
	}
	switch {
	case cpu.X86.HasAVX2:
		xorBytesAVX2(dst, a, b, n)
	case cpu.X86.HasSSE2:
		xorBytesSSE(dst, a, b, n)
	default:
		xorBytesGeneric(dst, a, b, n)
	}
	return n
}

const wordSize = int(unsafe.Sizeof(uintptr(0)))

func xorBytesGeneric(dst, a, b []byte, n int) {
	// Assert dst has enough space
	_ = dst[n-1]

	w := n / wordSize
	if w > 0 {
		dw := *(*[]uintptr)(unsafe.Pointer(&dst))
		aw := *(*[]uintptr)(unsafe.Pointer(&a))
		bw := *(*[]uintptr)(unsafe.Pointer(&b))
		_ = aw[w-1]
		_ = bw[w-1]
		_ = dw[w-1]
		for i := 0; i < w; i++ {
			dw[i] = aw[i] ^ bw[i]
		}
	}

	_ = dst[n-1]
	_ = a[n-1]
	_ = b[n-1]
	for i := (n - n%wordSize); i < n; i++ {
		dst[i] = a[i] ^ b[i]
	}
}

// Byte xors each byte in a with b and stores the result in dst, stopping when
// the end of either dst or a is reached. It returns the number of bytes
// xor'd.
func Byte(dst, a []byte, b byte) int {
	n := len(a)
	if len(dst) < n {
		n = len(dst)
	}

	var bw uintptr
	for i := 0; i < wordSize; i += 1 {
		bw |= uintptr(b) << uint(i*8)
	}

	w := n / wordSize
	if w > 0 {
		dw := *(*[]uintptr)(unsafe.Pointer(&dst))
		aw := *(*[]uintptr)(unsafe.Pointer(&a))
		_ = aw[w-1]
		_ = dw[w-1]
		for i := 0; i < w; i++ {
			dw[i] = aw[i] ^ bw
		}
	}

	_ = dst[n-1]
	_ = a[n-1]
	for i := (n - n%wordSize); i < n; i++ {
		dst[i] = a[i] ^ b
	}

	return n
}

// Block stores (a xor b) in dst, where a, b, and dst all have length 16.
func Block(dst, a, b []byte) {
	// profiling indicates that for 16-byte blocks, the cost of a function
	// call outweighs the SSE/AVX speedup
	dw := (*[2]uintptr)(unsafe.Pointer(&dst[0]))
	aw := (*[2]uintptr)(unsafe.Pointer(&a[0]))
	bw := (*[2]uintptr)(unsafe.Pointer(&b[0]))
	dw[0] = aw[0] ^ bw[0]
	dw[1] = aw[1] ^ bw[1]
}
