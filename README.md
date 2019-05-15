fastxor
-----

[![GoDoc](https://godoc.org/github.com/lukechampine/fastxor?status.svg)](https://godoc.org/github.com/lukechampine/fastxor)
[![Go Report Card](http://goreportcard.com/badge/github.com/lukechampine/fastxor)](https://goreportcard.com/report/github.com/lukechampine/fastxor)

```
go get github.com/lukechampine/fastxor
```

Is there a gaping hole in your heart that can only be filled by xor'ing byte
streams at 60GB/s? If so, you've come to the right place.

`fastxor` is exactly what it sounds like: a package that xors bytes as fast
as your CPU is capable of. For best results, use a CPU that supports a SIMD
instruction set like SSE or AVX. On other architectures,  performance is much
less impressive, but still faster than a naive byte-wise loop.

I wrote this package to try my hand at writing Go assembly, so please scrutinize
my code and let me know how I could make it faster or cleaner! 


# Benchmarks

```
AVX:

BenchmarkBytes/16-4   	200000000	         6.20 ns/op	 2579.65 MB/s
BenchmarkBytes/1024-4 	100000000	        15.5 ns/op	66089.39 MB/s
BenchmarkBytes/65k-4  	  2000000	       974 ns/op	67217.99 MB/s

SSE:

BenchmarkBytes/16-4   	200000000	         6.31 ns/op	 2536.64 MB/s
BenchmarkBytes/1024-4 	 50000000	        27.2 ns/op	37609.69 MB/s
BenchmarkBytes/65k-4  	  1000000	      2009 ns/op	32619.21 MB/s

Word-wise:

BenchmarkBytes/16-4   	200000000	         7.37 ns/op	 2170.17 MB/s
BenchmarkBytes/1024-4 	 20000000	        89.4 ns/op	11455.33 MB/s
BenchmarkBytes/65k-4  	   300000	      4963 ns/op	13203.25 MB/s

Byte-wise:

BenchmarkBytes/16-4    	100000000	        12.7 ns/op	 1263.77 MB/s
BenchmarkBytes/1024-4  	  2000000	       610 ns/op	 1677.18 MB/s
BenchmarkBytes/65k-4   	    50000	     38906 ns/op	 1684.45 MB/s
```

Conclusions: `fastxor` is 2-40 times faster than a naive `for` loop. AVX is
roughly twice as fast as SSE, which is unsurprising since it can operate on
twice as many bits per cycle. Lastly, for very small slices, the cost of the
function call starts to outweigh the benefit of AVX/SSE (the Go compiler never
inlines handwritten asm). If you need to xor exactly 16 bytes (common in block
ciphers), the specialized `Block` function is about 6 times faster than the
more generic `Bytes`:

```
BenchmarkBlock-4      	2000000000	        1.18 ns/op	13546.30 MB/s
```
