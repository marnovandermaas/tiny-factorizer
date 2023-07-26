import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer, ClockCycles

# Expected 7 segment outputs
segments = [ 63, 6, 91, 79, 102, 109, 125, 7, 127, 103 , 119, 124, 57, 94, 121, 113 ]

cycles_per_second = 1000

base_of_factors = 16

@cocotb.test()
async def test_segment_values(dut):
    # Check that all values in the segments list are unique
    assert len(segments) == len(set(segments))

@cocotb.test()
async def test_7seg_cycling(dut):
    # Start the clock
    dut._log.info("start")
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    # Reset the design
    dut._log.info("reset")
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    # Set output as second counter
    dut.ui_in.value = 0x00

    # Wait one cycle for registers to latch after reset
    await ClockCycles(dut.clk, 1)

    # Check that display is reset to zero
    dut._log.info("check segment 0x0")
    assert int(dut.segments.value) == segments[0]

    # Wait for zero to turn into one
    await ClockCycles(dut.clk, cycles_per_second)

    for k in range(3):
        dut._log.info("check all segments for {}th time".format(k))
        for i in range(1, base_of_factors):
            dut._log.info("  check segment 0x{:X}".format(i))

            # All bidirectionals are set to output
            assert dut.output_enable == 0xFF

            for j in range(0xFF):
                # Check bottom bits of counter
                if (dut.uio_out != j):
                    dut._log.info("  assertion about to fail for bottom bits of counter output 0x{:X} vs expected 0x{:X}".format(int(dut.uio_out), j))
                assert dut.uio_out == j
                await ClockCycles(dut.clk, 1)

            assert int(dut.segments.value) == segments[i]

            # Wait for 1 second
            await ClockCycles(dut.clk, cycles_per_second - 0xFF)

@cocotb.test()
async def test_factor(dut):
    # Start the clock
    dut._log.info("start")
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    # Reset the design
    dut._log.info("reset")
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    # Wait for zero to turn into one
    await ClockCycles(dut.clk, cycles_per_second)

    list_of_primes = [2, 3, 5, 7, 11, 13, 17, 19]

    max_input_value = 0xFF
    dut._log.info("check factorize logic")
    # Run through all possible inputs
    for i in range(1, max_input_value):
        expected_factors = 0x00
        # Calculate what the actual factors are
        for idx, j in enumerate(list_of_primes):
            if (i % j) == 0:
                expected_factors |= 1 << (idx)
        if (i % 16) == 15:
            dut._log.info("  {:d} percent done".format(int(i*100/max_input_value)))
        dut.ui_in.value = i

        # Wait for some cycles to propagate the input
        await ClockCycles(dut.clk, 10)

        # Check expected factors
        assert dut.uio_out == expected_factors

        # Wait for one second minus the previous offset
        await ClockCycles(dut.clk, cycles_per_second - 10)

        # All values are divisible by 1
        assert int(dut.segments.value) == segments[1]

        for j in range(2, base_of_factors):
            if (i % j) == 0:
                # Wait for one second
                await ClockCycles(dut.clk, cycles_per_second)
                if (int(dut.segments.value) != segments[j]):
                    dut._log.info("  assertion about to fail for segment values 0x{:X} vs expected 0x{:X}".format(int(dut.segments.value), segments[j]))
                assert int(dut.segments.value) == segments[j]
