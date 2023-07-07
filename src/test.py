import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer, ClockCycles

# Expected 7 segment outputs
segments = [ 63, 6, 91, 79, 102, 109, 124, 7, 127, 103 ]

cycles_per_second = 1000

@cocotb.test()
async def test_7seg(dut):
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
    dut.ui_in.value = 0x80

    # Wait one cycle for the registers to latch
    await ClockCycles(dut.clk, 1)

    dut._log.info("check all segments")
    for i in range(10):
        dut._log.info("check segment {}".format(i))

        # All bidirectionals are set to output
        assert dut.output_enable == 0xFF

        for j in range(0xFF):
            # Check bottom bits of counter
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

    # Wait 1 second for 0 to disapear
    await ClockCycles(dut.clk, cycles_per_second)

    # Offset by 10 cycles to allow for register reads
    await ClockCycles(dut.clk, 10)

    dut._log.info("check factorize logic")
    # Run through all possible inputs
    for i in range(0x7F):
        expected_factors = 0x00
        # Calculate what the actual factors are
        for j in range(2,10):
            if (i % j) == 0:
                expected_factors |= 1 << (j-2)
        if (i % 16) == 0:
            dut._log.info("  now at input value 0x{:02X}".format(i))
        dut.ui_in.value = i

        # Wait for one second
        await ClockCycles(dut.clk, cycles_per_second)

        # Check expected factors
        assert dut.uio_out == expected_factors
