TB_FILE := testbench/tb_cdc_4phase.sv
GTKWAVE_TCL_FILE := GTKWave/set_wave.tcl


TB_MODULE := $(basename $(notdir $(TB_FILE)))
VCD := $(TB_MODULE).vcd
VCD_PATH := build/$(VCD)


OUT := $(TB_MODULE).out
OUT_PATH := build/$(OUT)

# v_files := src/cdc_4phase.sv src/sync.sv 
sv_files := $(wildcard src/*.sv)
v_files := $(wildcard src/*.v)
all_files := $(sv_files) $(v_files)
$(info v_files=$(v_files))


all: $(TB_MODULE)
 
.PHONY: vvp waveform clean
 
$(TB_MODULE): $(TB_FILE) $(all_files)
	iverilog -g2012 -o $(OUT_PATH) $(TB_FILE) $(all_files)
 
$(VCD): $(TB_MODULE)
	cd build && vvp $(OUT)
	
 
vvp: $(VCD)
 
waveform: $(VCD)
	gtkwave $(VCD_PATH) -T $(GTKWAVE_TCL_FILE)
 
clean::
	cd build && del /Q $(OUT) $(VCD)