import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer, ClockCycles

# Expected 7 segment outputs
segments = [ 63, 6, 91, 79, 102, 109, 124, 7, 127, 103 ]

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

    # Enable second counter
    dut.ui_in.value = 0x80

    # Wait one cycle for the registers to latch
    await ClockCycles(dut.clk, 1)

    dut._log.info("check all segments")
    for i in range(10):
        dut._log.info("check segment {}".format(i))
        assert int(dut.segments.value) == segments[i]

        # All bidirectionals are set to output
        assert dut.output_enable == 0xFF

        for j in range(0xFF):
            # Check bottom bits of counter
            assert dut.uio_out == j
            await ClockCycles(dut.clk, 1)

        # Wait for 1 second
        await ClockCycles(dut.clk, 1000 - 0xFF)

    dut._log.info("check factorize logic")
    dut.ui_in.value = 0x00
    await ClockCycles(dut.clk, 1)
    assert dut.uio_out == 0xFF
    dut.ui_in.value = 0x01
    await ClockCycles(dut.clk, 1)
    assert dut.uio_out == 0x00
    dut.ui_in.value = 0x0C
    await ClockCycles(dut.clk, 1)
    assert dut.uio_out == 0x17
