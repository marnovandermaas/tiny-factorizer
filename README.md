![](../../workflows/gds/badge.svg) ![](../../workflows/docs/badge.svg) ![](../../workflows/test/badge.svg)

# Tiny Factorizer

This project takes an input number and calculates its factors.
It does this in hardware and is part of the [TinyTapeout project](https://tinytapeout.com).

Please have a look at the [documentation](https://github.com/marnovandermaas/tiny-factorizer/actions/workflows/docs.yaml) to see the details of what the design does.

## Testing this design
To run the tests please run the following commands:
```
make -C src
```

If you want to see the waveform from your simulation:
```
gtkwave src/tb.gtkw
```

## Generating the GDS

When you edit the info.yaml to choose a different ID, the [GitHub Action](.github/workflows/gds.yaml) will fetch the digital netlist of your design from Wokwi.

After that, the action uses the open source ASIC tool called [OpenLane](https://www.zerotoasiccourse.com/terminology/openlane/) to build the files needed to fabricate an ASIC.

You can see the result of the GDS action [here](https://marnovandermaas.github.io/tiny-factorizer/).

## Building documentation locally

To build the documentaiton locally you need to clone the [TinyTapeout support tools](https://github.com/TinyTapeout/tt-support-tools).
Then run the following commands:
```
pip3 install -r tt-support-tools/requirements.txt
tt-support-tools/tt_tool.py --create-pdf
```
