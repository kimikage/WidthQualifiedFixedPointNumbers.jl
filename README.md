# WidthQualifiedFixedPointNumbers.jl
This package is an *experimental* add-on to
[FixedPointNumbers.jl](https://github.com/JuliaMath/FixedPointNumbers.jl).

This package is intended to support fixed-point numbers with the total bit width specified.

## Examples
```julia
julia> using WidthQualifiedFixedPointNumbers

julia> sq7 = SQFixed8{3,7}(1.25) # a signed fixed-point number scaled by 2^3 with bit width of 7
SQFixed8{3,7}(1.25)

julia> bitstring(sq7) # 1.25 (dec) = 1.010 (bin)
"0001010"

julia> sq7 isa FixedPoint{Int8,3} # The raw type is `Int8`.
true

julia> uq11 = UQFixed{-1,11}(6) # an unsigned fixed-point number scaled by 2^(-1) with bit width 11
UQFixed{-1,11}(6.0)

julia> bitstring(uq11) # 6 = 3 / 2^(-1)
"00000000011"

julia> uq11 isa FixedPoint{UInt,-1} # The raw type is `UInt`.
true

julia> sq16 = SQFixed16{8}(127.0) # You may omit specifying the bit width.
SQFixed16{8}(127.0)

julia> bitstring(sq16) # The bit width is 16 as the raw type is `Int16`.
"0111111100000000"
```
