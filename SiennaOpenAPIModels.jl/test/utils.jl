
# Used in cases where there is a floating point error in IS.compare_values()

custom_isequivalent(x, y) = isequal(x, y) || (x == y)
custom_isequivalent(x::AbstractFloat, y::AbstractFloat) = isequal(x, y) || (x == y) || x ≈ y
