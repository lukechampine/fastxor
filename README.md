fastxor
-----

[![GoDoc](https://godoc.org/github.com/lukechampine/fastxor?status.svg)](https://godoc.org/github.com/lukechampine/fastxor)
[![Go Report Card](http://goreportcard.com/badge/github.com/lukechampine/fastxor)](https://goreportcard.com/report/github.com/lukechampine/fastxor)

```
go get github.com/lukechampine/fastxor
```

Is there a gaping hole in your heart that can only be filled by xor'ing byte
streams at 20GB/s? If so, you've come to the right place.

`fastxor` is exactly what it sounds like: a package that xors bytes as fast
as your CPU is capable of. For best results, use a CPU that supports a SIMD
instruction set like SSE or AVX. On other architectures,  performance is much
less impressive, but still faster than a naive byte-wise loop.

I wrote this package to try my hand at writing Go assembly, so please scrutinize
my code and let me know how I could make it faster or cleaner! 


# Benchmarks

```
AVX:

BenchmarkBytes/16-4   	200000000	         8.72 ns/op	 1835.82 MB/s
BenchmarkBytes/1024-4 	 50000000	        38.1 ns/op	26850.41 MB/s
BenchmarkBytes/65k-4  	   500000	      2738 ns/op	23930.93 MB/s

SSE:

BenchmarkBytes/16-4   	200000000	         8.63 ns/op	 1852.98 MB/s
BenchmarkBytes/1024-4 	 50000000	        39.4 ns/op	25993.00 MB/s
BenchmarkBytes/65k-4  	   500000	      2733 ns/op	23975.08 MB/s

Word-wise:

BenchmarkBytes/16-4   	100000000	        10.5 ns/op	1521.66 MB/s
BenchmarkBytes/1024-4 	 10000000	       125 ns/op	8163.59 MB/s
BenchmarkBytes/65k-4  	   200000	      6895 ns/op	9504.62 MB/s

Byte-wise:

BenchmarkBytes/16-4    	100000000	        17.3 ns/op	 925.16 MB/s
BenchmarkBytes/1024-4  	  2000000	       841 ns/op	1216.31 MB/s
BenchmarkBytes/65k-4   	    30000	     54100 ns/op	1211.38 MB/s
```

Conclusions: `fastxor` is 2-25 times faster than a naive `for` loop. AVX and
SSE performance is roughly equivalent, which makes me suspect that I may be
doing something wrong. Lastly, for very small slices, the cost of the function
call starts to outweigh the benefit of AVX/SSE (the Go compiler never inlines
handwritten asm). If you need to xor exactly 16 bytes (common in block
ciphers), the specialized `Block` function outperforms the more generic
`Bytes`:

```
BenchmarkBlock-4   	500000000	         3.69 ns/op	4337.88 MB/s
```