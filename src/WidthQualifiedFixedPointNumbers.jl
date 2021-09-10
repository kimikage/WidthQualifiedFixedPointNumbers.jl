module WidthQualifiedFixedPointNumbers

using FixedPointNumbers

import FixedPointNumbers: bitwidth, showtype

# re-export
export FixedPoint

export QFixedPoint
export SignedQFixed, UnsignedQFixed
export SQFixed, SQFixed8, SQFixed16, SQFixed32, SQFixed64
export UQFixed, UQFixed8, UQFixed16, UQFixed32, UQFixed64


#=
The design here is to place the bit width parameter `b` last.
This improves compatibility with `FixedPointNumbers.Fixed` and allows the
omission of `b`.
If `b` is omitted when constructing an instance, `b` is considered to be the
same as the bit width of `T`.
That is, if a type like `Int7` is officially supported in the future,
`SQFixed7{f}` (`b` = `7`) can be used instead of `SQFixed8{f,7}`.
That gives consistency to the aliases.
=#
"""
    QFixedPoint{T<:Integer,f,b} <: FixedPoint{T,f}

An abstract fixed-point number type qualified with the total bit width `b`.
"""
abstract type QFixedPoint{T<:Integer,f,b} <: FixedPoint{T,f} end

"""
    SignedQFixed{T<:Signed,f,b} <: QFixedPoint{T,f,b}

A signed binary fixed-point number type qualified with the total bit width `b`.
Unlike `FixedPointNumbers.Fixed`, this type has no explicit range constraint on
`f`, i.e., more than `b` or negative `f` is allowed.
"""
struct SignedQFixed{T<:Signed,f,b} <: QFixedPoint{T,f,b}
    i::T

    function SignedQFixed{T,f}(i::T, _::Val{true}) where {T<:Signed,f}
        new{T,f,bitwidth(T)}(i)
    end
    function SignedQFixed{T,f,b}(i::T, _::Val{true}) where {T<:Signed,f,b}
        new{T,f,b}(i)
    end
end

"""
    SignedQFixed{T<:Signed,f,b} <: QFixedPoint{T,f,b}

An unsigned binary fixed-point number type qualified with the total bit width
`b`.
"""
struct UnsignedQFixed{T<:Unsigned,f,b} <: QFixedPoint{T,f,b}
    i::T

    function UnsignedQFixed{T,f}(i::T, _::Val{true}) where {T<:Unsigned,f}
        new{T,f,bitwidth(T)}(i)
    end
    function UnsignedQFixed{T,f,b}(i::T, _::Val{true}) where {T<:Unsigned,f,b}
        new{T,f,b}(i)
    end
end

(::Type{QF})(x::Real) where {QF<:QFixedPoint} = _convert(QF, x)
(::Type{QF})(x::QF) where {QF<:QFixedPoint} = x
#=
This package does not provide non-parametric aliases such as `Q0f7`.
This is due to the intuitive specification of negative `f`, in addition to the
wide variations of `f`.
=#
const SQFixed{f,b} = SignedQFixed{Int,f,b}
const SQFixed8{f,b} = SignedQFixed{Int8,f,b}
const SQFixed16{f,b} = SignedQFixed{Int16,f,b}
const SQFixed32{f,b} = SignedQFixed{Int32,f,b}
const SQFixed64{f,b} = SignedQFixed{Int64,f,b}

const UQFixed{f,b} = UnsignedQFixed{UInt,f,b}
const UQFixed8{f,b} = UnsignedQFixed{UInt8,f,b}
const UQFixed16{f,b} = UnsignedQFixed{UInt16,f,b}
const UQFixed32{f,b} = UnsignedQFixed{UInt32,f,b}
const UQFixed64{f,b} = UnsignedQFixed{UInt64,f,b}

bitwidth(::Type{QF}) where {T,f,b,QF<:QFixedPoint{T,f,b}} = b

function _convert(::Type{QF}, x::Real) where {T,f,QF<:QFixedPoint{T,f}}
    i = round(T, x * 2.0^f)
    QF(i, Val(true))
end

function Base.promote_rule(
    ::Type{<:Fixed{T1,f1}},
    ::Type{<:SignedQFixed{T2,f2,b2}}) where {T1<:Signed,f1,T2,f2,b2}
    m1 = bitwidth(T1) - f1
    m2 = b2 - f2
    f = max(f1, f2)
    b = max(max(m1, m2), f)
    if b <= 8
        T = Int8
    elseif b <= 16
        T = Int16
    elseif b <= 32
        T = Int32
    else
        T = Int64
    end
    return SignedQFixed{T,f,b}
end

function Base.convert(::Type{Float32}, x::QFixedPoint{T,f}) where {T,f}
    return x.i * 0.5f0^f
end

function Base.convert(::Type{Float64}, x::QFixedPoint{T,f}) where {T,f}
    return x.i * 0.5^f
end

function Base.print(io::IO, x::QFixedPoint{T,f}) where {T,f}
    compact = get(io, :compact, false)::Bool
    log10_2 = 0.3010299956639812
    digits = min(round(Int, f * log10_2) + 1, compact ? 6 : typemax(Int))
    val = round(convert(Float64, x), digits=digits)
    print(io, val)
end

function Base.show(io::IO, x::QFixedPoint)
    compact = get(io, :compact, false)::Bool
    if compact || get(io, :typeinfo, Any) === typeof(x)
        print(io, x)
    else
        showtype(io, typeof(x))
        print(io, '(', x, ')')
    end
end

function showtype(io::IO, ::Type{QF}) where {T,f,b,QF<:QFixedPoint{T,f,b}}
    print(io, T <: Signed ? 'S' : 'U')
    if T === Int || T === UInt
        print(io, "QFixed{")
    elseif T === Int8 || T === UInt8
        print(io, "QFixed8{")
    elseif T === Int16 || T === UInt16
        print(io, "QFixed16{")
    elseif T === Int32 || T === UInt32
        print(io, "QFixed32{")
    elseif T === Int64 || T === UInt64
        print(io, "QFixed64{")
    else
        QF <: UnsignedQFixed && print(io, "ns")
        print(io, "ignedQFixed{", T, ",")
    end
    print(io, f)
    b != bitwidth(T) && print(io, ",", b)
    print(io, "}")
end

function Base.bitstring(x::QFixedPoint)
    b = bitwidth(typeof(x.i)) - bitwidth(typeof(x))
    return String(bitstring(x.i)[b+1:end])
end

end # module WidthQualifiedFixedPointNumbers
