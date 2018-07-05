// +build 386 amd64,!go1.7 ppc64 ppc64le s390x

package fastxor

import (
	"unsafe"
)

const wordSize = int(unsafe.Sizeof(uintptr(0)))

// Bytes stores (a xor b) in dst, stopping when the end of any slice is
// reached. It returns the number of bytes xor'd.
func Bytes(dst, a, b []byte) int {
	n := len(a)
	if len(b) < n {
		n = len(b)
	}
	if n == 0 {
		return 0
	}
	// Assert dst has enough space
	_ = dst[n-1]

	w := n / wordSize
	if w > 0 {
		dw := *(*[]uintptr)(unsafe.Pointer(&dst))
		aw := *(*[]uintptr)(unsafe.Pointer(&a))
		bw := *(*[]uintptr)(unsafe.Pointer(&b))
		for i := 0; i < w; i++ {
			dw[i] = aw[i] ^ bw[i]
		}
	}

	for i := (n - n%wordSize); i < n; i++ {
		dst[i] = a[i] ^ b[i]
	}

	return n
}

// Byte xors each byte in a with b and stores the result in dst, stopping when
// the end of either dst or a is reached. It returns the number of bytes
// xor'd.
func Byte(dst, a []byte, b byte) int {
	n := len(a)
	if len(dst) < n {
		n = len(dst)
	}
	for i := 0; i < n; i++ {
		dst[i] = a[i] ^ b
	}
	return n
}

// Block stores (a xor b) in dst, where a, b, and dst all have length 16.
func Block(dst, a, b []byte) {
	dw := *(*[]uintptr)(unsafe.Pointer(&dst))
	aw := *(*[]uintptr)(unsafe.Pointer(&a))
	bw := *(*[]uintptr)(unsafe.Pointer(&b))
	dw[0] = aw[0] ^ bw[0]
	dw[1] = aw[1] ^ bw[1]
}
