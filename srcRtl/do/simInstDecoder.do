quit -sim
vlog -work work -vopt -sv -stats=none /home/otutay/Desktop/tWork/rtl/Risc-Inci/srcRtl/sverilog/corePckg.sv
vlog -work work -vopt -sv -stats=none /home/otutay/Desktop/tWork/rtl/Risc-Inci/srcRtl/test/packageTb.sv
vlog -work work -vopt -sv -stats=none /home/otutay/Desktop/tWork/rtl/Risc-Inci/srcRtl/test/testVector.sv
vlog -work work -vopt -sv -stats=none /home/otutay/Desktop/tWork/rtl/Risc-Inci/srcRtl/test/decoderComparator.sv
vlog -work work -vopt -sv -stats=none /home/otutay/Desktop/tWork/rtl/Risc-Inci/srcRtl/test/smallDecoder.sv
vlog -work work -vopt -sv -stats=none /home/otutay/Desktop/tWork/rtl/Risc-Inci/srcRtl/test/InstRandomizer.sv
vlog -work work -vopt -sv -stats=none /home/otutay/Desktop/tWork/rtl/Risc-Inci/srcRtl/test/InstDecoderIntf.sv
vlog -work work -vopt -sv -stats=none /home/otutay/Desktop/tWork/rtl/Risc-Inci/srcRtl/test/InstDecoderTb.sv
vcom -work work -vopt -stats=none /home/otutay/Desktop/tWork/rtl/Risc-Inci/srcRtl/vhdl/corePackage.vhd
vcom -work work -vopt -stats=none /home/otutay/Desktop/tWork/rtl/Risc-Inci/srcRtl/vhdl/instDecoder.vhd

vsim -voptargs=+acc work.InstDecoderTb
add wave -position insertpoint sim:/InstDecoderTb/*
add wave -divider dutInstDecoder
add wave -position insertpoint sim:/InstDecoderTb/DUTDecoder/*

#add wave -r /*
run 2500 ns
