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

    # Wait one cycle for the registers to latch
    await ClockCycles(dut.clk, 1)

    # Enable second counter
    dut.ui_in.value = 0x80

    dut._log.info("check all segments")
    for i in range(10):
        dut._log.info("check segment {}".format(i))
        assert int(dut.segments.value) == segments[i]

        # Wait for 1 second
        await ClockCycles(dut.clk, 1000)

        # All bidirectionals are set to output
        assert dut.output_enable == 0xFF

        # Bottom bits of counter are zero
        assert dut.lsb_counter == 0x00


    dut.ui_in.value = 0x00
    await ClockCycles(dut.clk, 1)
    assert dut.lsb_counter == 0x00
    await ClockCycles(dut.clk, 1)
    assert dut.lsb_counter == 0x00
