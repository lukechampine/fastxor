// +build !386,!amd64,!ppc64,!ppc64le,!s390x

package fastxor

// Bytes stores (a xor b) in dst, stopping when the end of any slice is
// reached. It returns the number of bytes xor'd.
func Bytes(dst, a, b []byte) int {
	n := len(a)
	if len(b) < n {
		n = len(b)
	}
	if len(dst) < n {
		n = len(dst)
	}
	if n == 0 {
		return n
	}
	_ = dst[n-1]
	_ = a[n-1]
	_ = b[n-1]
	for i := 0; i < n; i++ {
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
	if n == 0 {
		return n
	}
	_ = dst[n-1]
	_ = a[n-1]
	for i := 0; i < n; i++ {
		dst[i] = a[i] ^ b
	}
	return n
}

// Block stores (a xor b) in dst, where a, b, and dst all have length 16.
func Block(dst, a, b []byte) {
	_ = dst[15]
	_ = a[15]
	_ = b[15]

	dst[0] = a[0] ^ b[0]
	dst[1] = a[1] ^ b[1]
	dst[2] = a[2] ^ b[2]
	dst[3] = a[3] ^ b[3]
	dst[4] = a[4] ^ b[4]
	dst[5] = a[5] ^ b[5]
	dst[6] = a[6] ^ b[6]
	dst[7] = a[7] ^ b[7]
	dst[8] = a[8] ^ b[8]
	dst[9] = a[9] ^ b[9]
	dst[10] = a[10] ^ b[10]
	dst[11] = a[11] ^ b[11]
	dst[12] = a[12] ^ b[12]
	dst[13] = a[13] ^ b[13]
	dst[14] = a[14] ^ b[14]
	dst[15] = a[15] ^ b[15]
}
