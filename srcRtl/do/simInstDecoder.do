quit -sim
vlog -work work -vopt -sv -stats=none /home/otutay/Desktop/tWork/rtl/Risc-Inci/srcRtl/sverilog/corePckg.sv
vlog -work work -vopt -sv -stats=none /home/otutay/Desktop/tWork/rtl/Risc-Inci/srcRtl/test/InstRandomizer.sv
vlog -work work -vopt -sv -stats=none /home/otutay/Desktop/tWork/rtl/Risc-Inci/srcRtl/test/InstDecoderIntf.sv
vlog -work work -vopt -sv -stats=none /home/otutay/Desktop/tWork/rtl/Risc-Inci/srcRtl/test/InstDecoderTb.sv

vsim -voptargs=+acc work.InstDecoderTb
#add wave -position insertpoint sim:/InstDecoderTb/*
#add wave -r /*
run 20000 ns
