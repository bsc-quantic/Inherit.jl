using Test
using Inherit

struct A
    a::Int
end

struct B
    @inherit(A)
    b::Int
end

struct C{X}
    @inherit(A)
    c::X
end

struct D{U,V}
    @inherit(C{U})
    d::V
end

@testset "@inherit" begin
    @test fieldnames(B) == (:a, :b)
    @test fieldtypes(B) == (Int, Int)

    @test fieldnames(C) == (:a, :c)
    @test fieldtypes(C) == (Int, Any)
    @test fieldnames(C{Char}) == (:a, :c)
    @test fieldtypes(C{Char}) == (Int, Char)

    @test fieldnames(D) == (:a, :c, :d)
    @test_broken fieldtypes(D) == (Int, Any, Any)
    @test fieldnames(D{Char}) == (:a, :c, :d)
    @test_broken fieldtypes(D{Char}) == (Int, Char, Any)
    @test fieldnames(D{Char,Float32}) == (:a, :c, :d)
    @test_broken fieldtypes(D{Char,Float32}) == (Int, Char, Float32)
    @test fieldnames(D{T,Float32} where {T}) == (:a, :c, :d)
    @test_broken fieldtypes(D{T,Float32} where {T}) == (Int, Any, Float32)
end