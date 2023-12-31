import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer, ClockCycles

import os

# Expected 7 segment outputs
segments = [ 63, 6, 91, 79, 102, 109, 125, 7, 127, 103 , 119, 124, 57, 94, 121, 113 ]

gate_level_sim = False
if 'GATES' in os.environ.keys():
    if os.environ['GATES'] == 'yes':
        gate_level_sim = True
cycles_per_second = 1000
if gate_level_sim:
    cycles_per_second = 10000000

base_of_factors = 16

@cocotb.test()
async def test_segment_values(dut):
    # Check that all values in the segments list are unique
    assert len(segments) == len(set(segments))
    dut._log.info("Line segment values are unique")
    dut._log.info("GATES is equal to {}".format(gate_level_sim))

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

    for j in range(0xFF):
        # Check bottom bits of counter
        if (dut.uio_out != j):
            dut._log.info("  assertion about to fail for bottom bits of counter output 0x{:X} vs expected 0x{:X}".format(int(dut.uio_out), j))
        assert dut.uio_out == j
        await ClockCycles(dut.clk, 1)

    # Check that display is reset to zero
    dut._log.info("check segment 0x0")
    assert int(dut.segments.value) == segments[0]

    # Check that input is zero
    assert dut.is_prime == 0

    # If in gate level simulator do not wait for one second, this will take a long time
    if gate_level_sim:
        return

    # Wait for zero to turn into one
    await ClockCycles(dut.clk, cycles_per_second - 0xFF)

    number_of_cycles = 3

    for k in range(number_of_cycles):
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
            assert dut.is_prime == 0

            # Wait for 1 second
            await ClockCycles(dut.clk, cycles_per_second - 0xFF)

@cocotb.test()
async def test_factor(dut):
    # Skip this test in the gate level simulator
    if gate_level_sim:
        return

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
    list_of_all_primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97, 101, 103, 107, 109, 113, 127, 131, 137, 139, 149, 151, 157, 163, 167, 173, 179, 181, 191, 193, 197, 199, 211, 223, 227, 229, 233, 239, 241, 251]

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

        # Check that input is correctly identified as prime
        assert dut.is_prime == (1 if i in list_of_all_primes else 0)

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
