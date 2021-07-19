quit -sim
delete wave *
## test files
vlog -work work -novopt -sv -stats=none /home/otutay/Desktop/tWork/rtl/Risc-Inci/srcRtl/sverilog/corePckg.sv
vlog -work work -novopt -sv -stats=none /home/otutay/Desktop/tWork/rtl/Risc-Inci/srcRtl/test/packageTb.sv
vlog -work work -novopt -sv -stats=none /home/otutay/Desktop/tWork/rtl/Risc-Inci/srcRtl/test/testVector.sv
vlog -work work -novopt -sv -stats=none /home/otutay/Desktop/tWork/rtl/Risc-Inci/srcRtl/test/decoderComparator.sv
vlog -work work -novopt -sv -stats=none /home/otutay/Desktop/tWork/rtl/Risc-Inci/srcRtl/test/smallDecoder.sv
vlog -work work -novopt -sv -stats=none /home/otutay/Desktop/tWork/rtl/Risc-Inci/srcRtl/test/InstRandomizer.sv
vlog -work work -novopt -sv -stats=none /home/otutay/Desktop/tWork/rtl/Risc-Inci/srcRtl/test/InstDecoderIntf.sv


## core files
vcom -work work -2008 -novopt -stats=none /home/otutay/Desktop/tWork/rtl/Risc-Inci/srcRtl/vhdl/corePackage.vhd
vcom -work work -2008 -novopt -stats=none /home/otutay/Desktop/tWork/rtl/Risc-Inci/srcRtl/vhdl/ram.vhd
vcom -work work -2008 -novopt -stats=none /home/otutay/Desktop/tWork/rtl/Risc-Inci/srcRtl/vhdl/fetch.vhd
vcom -work work -2008 -novopt -stats=none /home/otutay/Desktop/tWork/rtl/Risc-Inci/srcRtl/vhdl/dataRam.vhd
vcom -work work -2008 -novopt -stats=none /home/otutay/Desktop/tWork/rtl/Risc-Inci/srcRtl/vhdl/regFile.vhd
vcom -work work -2008 -novopt -stats=none /home/otutay/Desktop/tWork/rtl/Risc-Inci/srcRtl/vhdl/instDecoder.vhd
vcom -work work -2008 -novopt -stats=none /home/otutay/Desktop/tWork/rtl/Risc-Inci/srcRtl/vhdl/alu.vhd
vcom -work work -2008 -novopt -stats=none /home/otutay/Desktop/tWork/rtl/Risc-Inci/srcRtl/vhdl/Top.vhd

# tb top
vlog -work work -vopt -sv -stats=none /home/otutay/Desktop/tWork/rtl/Risc-Inci/srcRtl/test/CoreTb.sv

vsim -voptargs=+acc work.CoreTb
add wave -position insertpoint -radix unsigned sim:/CoreTb/*
add wave -divider FetchComp
add wave -position insertpoint -radix unsigned sim:/CoreTb/DUTCore/fetchComp/*
add wave -divider InstRam
add wave -position insertpoint -radix unsigned sim:/CoreTb/DUTCore/fetchComp/InstRam/*
add wave -divider instDecoderComp
add wave -position insertpoint -radix unsigned sim:/CoreTb/DUTCore/instDecoderComp/*
add wave -divider regFileComp
add wave -position insertpoint -radix unsigned sim:/CoreTb/DUTCore/regFileComp/*
add wave -divider aluComp
add wave -position insertpoint -radix unsigned sim:/CoreTb/DUTCore/aluComp/*
add wave -divider dataRamComp
add wave -position insertpoint -radix unsigned sim:/CoreTb/DUTCore/dataRamComp/*

run 2 us
