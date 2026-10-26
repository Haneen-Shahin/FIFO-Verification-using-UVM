vlib work
vlog -f src_files.list
vlog -f src_dut.list +cover=bcesft +define+SIM
vsim -voptargs=+acc -cover +define+SIM work.FIFO_top -classdebug -uvmcontrol=all -assertdebug
add wave -divider FIFO_IF
add wave /FIFO_top/f_if/*
run 0
add wave -position insertpoint sim:/uvm_root/uvm_test_top/env/sb/seq_item_sb
coverage save FIFO_top.ucdb -onexit
run -all

##vcover report FIFO_top.ucdb -details -annotate -all -output coverage.txt