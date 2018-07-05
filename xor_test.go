package fastxor

import (
	"bytes"
	"testing"
	"testing/quick"
)

func refBytes(dst, a, b []byte) int {
	n := len(a)
	if len(b) < n {
		n = len(b)
	}
	if len(dst) < n {
		n = len(dst)
	}
	for i := 0; i < n; i++ {
		dst[i] = a[i] ^ b[i]
	}
	return n
}

func refByte(dst, a []byte, b byte) int {
	n := len(a)
	if len(dst) < n {
		n = len(dst)
	}
	for i := 0; i < n; i++ {
		dst[i] = a[i] ^ b
	}
	return n
}

func refBlock(dst, a, b []byte) {
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

func TestBytes(t *testing.T) {
	err := quick.Check(func(a, b []byte) bool {
		// double size to increase chances of reaching 64 bytes
		a = append(a, a...)
		b = append(b, b...)
		if len(a) < 8 {
			return true
		}
		// shift alignment randomly
		a = a[(a[0] % 8):]

		dst1 := make([]byte, len(a))
		dst2 := make([]byte, len(a))
		Bytes(dst1, a, b)
		refBytes(dst2, a, b)
		return bytes.Equal(dst1, dst2)
	}, &quick.Config{MaxCount: 10000})
	if err != nil {
		t.Fatal(err)
	}
}

func TestByte(t *testing.T) {
	err := quick.Check(func(a []byte, b byte) bool {
		if len(a) < 8 {
			return true
		}
		// shift alignment randomly
		a = a[(a[0] % 8):]

		dst1 := make([]byte, len(a))
		dst2 := make([]byte, len(a))
		Byte(dst1, a, b)
		refByte(dst2, a, b)
		return bytes.Equal(dst1, dst2)
	}, &quick.Config{MaxCount: 10000})
	if err != nil {
		t.Fatal(err)
	}
}

func TestBlock(t *testing.T) {
	err := quick.Check(func(a, b [16]byte) bool {
		dst1 := make([]byte, len(a))
		dst2 := make([]byte, len(a))
		Block(dst1, a[:], b[:])
		refBlock(dst2, a[:], b[:])
		return bytes.Equal(dst1, dst2)
	}, &quick.Config{MaxCount: 10000})
	if err != nil {
		t.Fatal(err)
	}
}

func BenchmarkBytes(b *testing.B) {
	benchN := func(n int) func(*testing.B) {
		return func(b *testing.B) {
			buf := make([]byte, n)
			b.SetBytes(int64(len(buf)))
			for i := 0; i < b.N; i++ {
				Bytes(buf, buf, buf)
			}
		}
	}
	b.Run("16", benchN(16))
	b.Run("1024", benchN(1024))
	b.Run("65k", benchN(65536))
}

func BenchmarkRefBytes(b *testing.B) {
	benchN := func(n int) func(*testing.B) {
		return func(b *testing.B) {
			buf := make([]byte, n)
			b.SetBytes(int64(len(buf)))
			for i := 0; i < b.N; i++ {
				refBytes(buf, buf, buf)
			}
		}
	}
	b.Run("16", benchN(16))
	b.Run("1024", benchN(1024))
	b.Run("65k", benchN(65536))
}

func BenchmarkByte(b *testing.B) {
	benchN := func(n int) func(*testing.B) {
		return func(b *testing.B) {
			buf := make([]byte, n)
			b.SetBytes(int64(len(buf)))
			for i := 0; i < b.N; i++ {
				Byte(buf, buf, 'b')
			}
		}
	}
	b.Run("16", benchN(16))
	b.Run("1024", benchN(1024))
	b.Run("65k", benchN(65536))
}

func BenchmarkRefByte(b *testing.B) {
	benchN := func(n int) func(*testing.B) {
		return func(b *testing.B) {
			buf := make([]byte, n)
			b.SetBytes(int64(len(buf)))
			for i := 0; i < b.N; i++ {
				refByte(buf, buf, 'b')
			}
		}
	}
	b.Run("16", benchN(16))
	b.Run("1024", benchN(1024))
	b.Run("65k", benchN(65536))
}

func BenchmarkBlock(b *testing.B) {
	buf := make([]byte, 16)
	b.SetBytes(16)
	for i := 0; i < b.N; i++ {
		Block(buf, buf, buf)
	}
}

func BenchmarkRefBlock(b *testing.B) {
	buf := make([]byte, 16)
	b.SetBytes(16)
	for i := 0; i < b.N; i++ {
		refBlock(buf, buf, buf)
	}
}
