GHDL  = ghdl
FLAGS = --std=08 --workdir=build

# Analysis order matters, every unit must come after the units it uses
RTL = rtl/ls247.vhd rtl/display4.vhd course/mux_4x1.vhd
TB  = tb/seg_pkg.vhd tb/tb_ls247.vhd tb/tb_display4.vhd course/tb_mux_4x1.vhd

TESTBENCHES = tb_ls247 tb_display4 tb_mux_4x1
WAVE ?= tb_display4

all: test

build:
	mkdir -p build

# Analyze, elaborate and run every testbench, and save the waveforms for GTKWave
test: | build
	$(GHDL) -a $(FLAGS) $(RTL) $(TB)
	for t in $(TESTBENCHES); do \
		$(GHDL) -e $(FLAGS) -o build/$$t $$t && ./build/$$t --wave=build/$$t.ghw || exit 1; \
	done

# make wave opens tb_display4, make wave WAVE=tb_ls247 opens the other one
wave: test
	gtkwave build/$(WAVE).ghw

clean:
	rm -rf build *.o e~*.o

.PHONY: all test wave clean
