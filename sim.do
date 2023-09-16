if {[file isdirectory work]} { vdel -all -lib work }

vlib work
vmap work work

vcom -work work cade-eu.vhd
vcom -work work cade-eu-tb.vhd

vsim -gui work.tb_ondeestou -t ns
do wave.do

run 20000ns cade-eu-tb.vhd