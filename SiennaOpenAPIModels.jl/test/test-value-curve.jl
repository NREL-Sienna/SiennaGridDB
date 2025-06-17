using InfrastructureSystems

@testset "Function evaluation" begin
    @testset "Step Data" begin
        stepdata = InfrastructureSystems.PiecewiseStepData([0.25, 0.5, 1.0], [1.0, 2.0])
        @test stepdata(0.25) == 0.0
        @test_throws "DomainError" stepdata(0.2)
        @test stepdata(0.0) == 0.0
        @test stepdata(0.375) ≈ 0.125
        @test stepdata(0.5) ≈ 0.25
        @test stepdata(0.75) ≈ 0.25 + 0.5
        @test stepdata(1) ≈ 0.25 + 1.0
        @test_throws "DomainError" stepdata(1.1)
    end

    @testset "Linear Curve" begin
        linear_curve = zero(InfrastructureSystems.InputOutputCurve)
        @test linear_curve(0.0) == 0.0
        @test linear_curve(100000.0) == 0.0
        @test linear_curve(-5.0) == 0.0
    end

    @testset "LinearFunctionData" begin
        # Test basic linear function: f(x) = 2x + 3
        linear_func = InfrastructureSystems.LinearFunctionData(2.0, 3.0)
        @test linear_func(0.0) == 3.0
        @test linear_func(1.0) == 5.0
        @test linear_func(2.5) == 8.0
        @test linear_func(-1.0) == 1.0

        # Test zero function
        zero_func = InfrastructureSystems.LinearFunctionData(0.0, 0.0)
        @test zero_func(0.0) == 0.0
        @test zero_func(10.0) == 0.0
        @test zero_func(-5.0) == 0.0

        # Test constant function
        const_func = InfrastructureSystems.LinearFunctionData(0.0, 5.0)
        @test const_func(0.0) == 5.0
        @test const_func(100.0) == 5.0
        @test const_func(-10.0) == 5.0

        # Test negative slope
        neg_slope = InfrastructureSystems.LinearFunctionData(-1.5, 10.0)
        @test neg_slope(0.0) == 10.0
        @test neg_slope(2.0) == 7.0
        @test neg_slope(6.0) == 1.0
    end

    @testset "QuadraticFunctionData" begin
        # Test basic quadratic function: f(x) = x^2 + 2x + 1
        quad_func = InfrastructureSystems.QuadraticFunctionData(1.0, 2.0, 1.0)
        @test quad_func(0.0) == 1.0
        @test quad_func(1.0) == 4.0
        @test quad_func(2.0) == 9.0
        @test quad_func(-1.0) == 0.0
        @test quad_func(-2.0) == 1.0

        # Test quadratic with no linear term: f(x) = 2x^2 + 5
        quad_no_linear = InfrastructureSystems.QuadraticFunctionData(2.0, 0.0, 5.0)
        @test quad_no_linear(0.0) == 5.0
        @test quad_no_linear(1.0) == 7.0
        @test quad_no_linear(2.0) == 13.0
        @test quad_no_linear(-1.0) == 7.0

        # Test quadratic with no constant term: f(x) = 0.5x^2 + 3x
        quad_no_const = InfrastructureSystems.QuadraticFunctionData(0.5, 3.0, 0.0)
        @test quad_no_const(0.0) == 0.0
        @test quad_no_const(2.0) == 8.0
        @test quad_no_const(4.0) == 20.0

        # Test negative quadratic coefficient: f(x) = -x^2 + 4x + 2
        neg_quad = InfrastructureSystems.QuadraticFunctionData(-1.0, 4.0, 2.0)
        @test neg_quad(0.0) == 2.0
        @test neg_quad(1.0) == 5.0
        @test neg_quad(2.0) == 6.0
        @test neg_quad(3.0) == 5.0
        @test neg_quad(4.0) == 2.0
    end

    @testset "PiecewiseLinearData" begin
        # Test simple piecewise linear function with 3 points
        points = [(x=0.0, y=0.0), (x=1.0, y=2.0), (x=2.0, y=3.0)]
        pwl_func = InfrastructureSystems.PiecewiseLinearData(points)

        # Test at exact points
        @test pwl_func(0.0) == 0.0
        @test pwl_func(1.0) == 2.0
        @test pwl_func(2.0) == 3.0

        # Test interpolation between points
        @test pwl_func(0.5) ≈ 1.0  # midpoint between (0,0) and (1,2)
        @test pwl_func(1.5) ≈ 2.5  # midpoint between (1,2) and (2,3)

        # Test boundary checks
        @test_throws DomainError pwl_func(-0.1)
        @test_throws DomainError pwl_func(2.1)

        # Test more complex piecewise function
        complex_points = [(x=0.0, y=1.0), (x=2.0, y=5.0), (x=3.0, y=4.0), (x=5.0, y=8.0)]
        complex_pwl = InfrastructureSystems.PiecewiseLinearData(complex_points)

        @test complex_pwl(0.0) == 1.0
        @test complex_pwl(1.0) ≈ 3.0  # linear interpolation: 1 + (5-1)*0.5
        @test complex_pwl(2.0) == 5.0
        @test complex_pwl(2.5) ≈ 4.5  # linear interpolation: 5 + (4-5)*0.5
        @test complex_pwl(3.0) == 4.0
        @test complex_pwl(4.0) ≈ 6.0  # linear interpolation: 4 + (8-4)*0.5
        @test complex_pwl(5.0) == 8.0

        # Test single segment (2 points)
        single_seg =
            InfrastructureSystems.PiecewiseLinearData([(x=1.0, y=3.0), (x=4.0, y=9.0)])
        @test single_seg(1.0) == 3.0
        @test single_seg(2.5) ≈ 6.0  # 3 + (9-3)*(1.5/3)
        @test single_seg(4.0) == 9.0
    end
end

@testset "Value Curves" begin
    @testset "InputOutputCurve" begin
        # Test with LinearFunctionData
        linear_data = InfrastructureSystems.LinearFunctionData(2.0, 5.0)  # f(x) = 2x + 5
        io_linear = InfrastructureSystems.InputOutputCurve(linear_data)
        @test io_linear(0.0) == 5.0
        @test io_linear(3.0) == 11.0
        @test io_linear(10.0) == 25.0

        # Test with QuadraticFunctionData
        quad_data = InfrastructureSystems.QuadraticFunctionData(1.0, 2.0, 3.0)  # f(x) = x^2 + 2x + 3
        io_quad = InfrastructureSystems.InputOutputCurve(quad_data)
        @test io_quad(0.0) == 3.0
        @test io_quad(1.0) == 6.0
        @test io_quad(2.0) == 11.0
        @test io_quad(-1.0) == 2.0

        # Test with PiecewiseLinearData
        pwl_data = InfrastructureSystems.PiecewiseLinearData([
            (x=0.0, y=0.0),
            (x=2.0, y=4.0),
            (x=4.0, y=6.0),
        ])
        io_pwl = InfrastructureSystems.InputOutputCurve(pwl_data)
        @test io_pwl(0.0) == 0.0
        @test io_pwl(1.0) == 2.0  # interpolated
        @test io_pwl(2.0) == 4.0
        @test io_pwl(3.0) == 5.0  # interpolated
        @test io_pwl(4.0) == 6.0

        # Test with input_at_zero parameter
        io_with_zero = InfrastructureSystems.InputOutputCurve(linear_data, 10.0)
        @test InfrastructureSystems.get_input_at_zero(io_with_zero) == 10.0
        @test io_with_zero(5.0) == 15.0  # still evaluates function normally

        # Test zero curve
        zero_curve = zero(InfrastructureSystems.InputOutputCurve)
        @test zero_curve(0.0) == 0.0
        @test zero_curve(100.0) == 0.0
    end

    @testset "IncrementalCurve" begin
        # Test with LinearFunctionData (representing derivative)
        linear_data = InfrastructureSystems.LinearFunctionData(0.5, 2.0)  # f'(x) = 0.5x + 2
        inc_linear = InfrastructureSystems.IncrementalCurve(linear_data, 0.1)  # initial_input = 5.0
        @test inc_linear(1.0) == 2.5  # f'(1) = 0.5*1 + 2 = 2.5
        @test inc_linear(4.0) == 4.0  # f'(4) = 0.5*4 + 2 = 4.0

        # Test with PiecewiseStepData
        step_data = InfrastructureSystems.PiecewiseStepData([0.0, 2.0, 4.0], [1.0, 3.0])
        inc_step = InfrastructureSystems.IncrementalCurve(step_data, 0.1)
        @test inc_step(0.5) == 0.5  # first segment value
        @test inc_step(3.0) == 5.0  # second segment value

        # Test zero curve
        zero_inc = zero(InfrastructureSystems.IncrementalCurve)
        @test zero_inc(0.0) == 0.0
        @test zero_inc(10.0) == 0.0
    end

    @testset "AverageRateCurve" begin
        # Test with LinearFunctionData
        linear_data = InfrastructureSystems.LinearFunctionData(0.5, 3.0)  # average rate function
        avg_linear = InfrastructureSystems.AverageRateCurve(linear_data, 0.1)  # initial_input = 10.0
        @test avg_linear(2.0) == 8.0  # (0.5*2 + 3) * 2 = 4 * 2 = 8
        @test avg_linear(4.0) == 20.0  # (0.5*4 + 3) * 4 = 5 * 4 = 20

        # Test with PiecewiseStepData
        step_data = InfrastructureSystems.PiecewiseStepData([1.0, 3.0, 5.0], [2.0, 4.0])
        avg_step = InfrastructureSystems.AverageRateCurve(step_data, 1.0)

        # Test with input_at_zero parameter
        avg_with_zero = InfrastructureSystems.AverageRateCurve(linear_data, 0.1, 2.5)
        @test InfrastructureSystems.get_input_at_zero(avg_with_zero) == 2.5

        # Test zero curve
        zero_avg = zero(InfrastructureSystems.AverageRateCurve)
        @test zero_avg(1.0) == 0.0
        @test zero_avg(10.0) == 0.0
    end

    @testset "Curve Conversions" begin
        # Test InputOutputCurve to IncrementalCurve conversion (QuadraticFunctionData)
        quad_data = InfrastructureSystems.QuadraticFunctionData(2.0, 4.0, 1.0)  # f(x) = 2x^2 + 4x + 1
        io_quad = InfrastructureSystems.InputOutputCurve(quad_data)
        inc_from_io = InfrastructureSystems.IncrementalCurve(io_quad)
        # Derivative should be f'(x) = 4x + 4, with initial_input = 1.0
        @test inc_from_io(0.0) == 4.0  # f'(0) = 4
        @test inc_from_io(1.0) == 8.0  # f'(1) = 8

        # Test InputOutputCurve to AverageRateCurve conversion (QuadraticFunctionData)
        avg_from_io = InfrastructureSystems.AverageRateCurve(io_quad)
        # For f(x) = 2x^2 + 4x + 1, average rate function should be 2x + 4

        # Test IncrementalCurve to InputOutputCurve conversion
        linear_deriv = InfrastructureSystems.LinearFunctionData(2.0, 3.0)  # f'(x) = 2x + 3
        inc_curve = InfrastructureSystems.IncrementalCurve(linear_deriv, 5.0)  # initial_input = 5
        io_from_inc = InfrastructureSystems.InputOutputCurve(inc_curve)
        # Should give f(x) = x^2 + 3x + 5
        @test io_from_inc(0.0) == 5.0
        @test io_from_inc(1.0) == 9.0   # 1 + 3 + 5 = 9
        @test io_from_inc(2.0) == 15.0  # 4 + 6 + 5 = 15

        # Test error case for undefined initial_input
        inc_no_initial = InfrastructureSystems.IncrementalCurve(linear_deriv, nothing)
        @test_throws ArgumentError InfrastructureSystems.InputOutputCurve(inc_no_initial)

        # Test AverageRateCurve to InputOutputCurve conversion
        linear_avg = InfrastructureSystems.LinearFunctionData(1.0, 2.0)  # average rate function
        avg_curve = InfrastructureSystems.AverageRateCurve(linear_avg, 3.0)  # initial_input = 3
        io_from_avg = InfrastructureSystems.InputOutputCurve(avg_curve)
        # Should give f(x) = x^2 + 2x + 3
        @test io_from_avg(0.0) == 3.0
        @test io_from_avg(1.0) == 6.0   # 1 + 2 + 3 = 6
        @test io_from_avg(2.0) == 11.0  # 4 + 4 + 3 = 11

        # Test error case for undefined initial_input in AverageRateCurve
        avg_no_initial = InfrastructureSystems.AverageRateCurve(linear_avg, nothing)
        @test_throws ArgumentError InfrastructureSystems.InputOutputCurve(avg_no_initial)
    end
end
