using Test, WidthQualifiedFixedPointNumbers

using Aqua

@testset "Aqua" begin
    Aqua.test_all(WidthQualifiedFixedPointNumbers)
end

@testset "examples" begin
    buf = IOBuffer()

    sq7 = SQFixed8{3,7}(1.25)
    @test reinterpret(Int8, sq7) === Int8(0b00001010)
    @test bitstring(sq7) == "0001010"
    @test sq7 isa FixedPoint{Int8,3}
    show(buf, sq7)
    @test String(take!(buf)) == "SQFixed8{3,7}(1.25)"

    uq11 = UQFixed{-1,11}(6)
    @test reinterpret(UInt, uq11) === UInt(3)
    @test bitstring(uq11) == "00000000011"
    @test uq11 isa FixedPoint{UInt,-1}
    show(buf, uq11)
    @test String(take!(buf)) == "UQFixed{-1,11}(6.0)"

    sq16 = SQFixed16{8}(127.0)
    @test reinterpret(Int16, sq16) === Int16(0b0111111100000000)
    @test bitstring(sq16) == "0111111100000000"
    @test sq16 isa FixedPoint{Int16,8}
    show(buf, sq16)
    @test String(take!(buf)) == "SQFixed16{8}(127.0)"
end