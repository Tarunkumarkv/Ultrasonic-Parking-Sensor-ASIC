# ==============================================================================
# Makefile — Ultrasonic Parking Sensor ASIC (Verilog-2001 Verification Suite)
# ==============================================================================
IVERILOG ?= iverilog
VVP      ?= vvp

RTL_ALL  = rtl/parking_sensor_full.v \
           rtl/trigger_generator.v \
           rtl/echo_counter.v \
           rtl/distance_comparator.v \
           rtl/fsm_controller.v

.PHONY: all sim unit top clean

all: sim

sim: unit top

unit:
	$(IVERILOG) -o sim_trig rtl/trigger_generator.v dv/tb_trigger_generator.v && $(VVP) sim_trig
	$(IVERILOG) -o sim_echo rtl/echo_counter.v dv/tb_echo_counter.v && $(VVP) sim_echo
	$(IVERILOG) -o sim_comp rtl/distance_comparator.v dv/tb_distance_comparator.v && $(VVP) sim_comp
	$(IVERILOG) -o sim_fsm  rtl/fsm_controller.v dv/tb_fsm_controller.v && $(VVP) sim_fsm

top:
	$(IVERILOG) -o sim_top $(RTL_ALL) dv/tb_parking_system.v && $(VVP) sim_top

clean:
	rm -f sim_trig sim_echo sim_comp sim_fsm sim_top *.vcd *.vvp
