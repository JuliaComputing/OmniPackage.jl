
@enum Fruit apple = 1 orange = 2 kiwi = 3

struct ParametricStruct{T1,T2,T3,T4,T5,T6,T7}
  a::T1
  b::T2
  c::T7
  d::T3
  e::T4
  f::T5
  g::T6
  h::Fruit
  i::Int8
  j::Int8
end

function create_array_of_ps()
  fill(
    fill(
      ParametricStruct(
        1.0,
        2.0,
        3,
        4.0,
        5.0,
        6.0,
        7.0,
        apple,
        Int8(1),
        Int8(2)
      ),
      2
    ),
    2
  )
end
