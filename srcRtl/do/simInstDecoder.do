quit -sim
## test files
vlog -work work -vopt -sv -stats=none /home/otutay/Desktop/tWork/rtl/Risc-Inci/srcRtl/sverilog/corePckg.sv
vlog -work work -vopt -sv -stats=none /home/otutay/Desktop/tWork/rtl/Risc-Inci/srcRtl/test/packageTb.sv
vlog -work work -vopt -sv -stats=none /home/otutay/Desktop/tWork/rtl/Risc-Inci/srcRtl/test/testVector.sv
vlog -work work -vopt -sv -stats=none /home/otutay/Desktop/tWork/rtl/Risc-Inci/srcRtl/test/decoderComparator.sv
vlog -work work -vopt -sv -stats=none /home/otutay/Desktop/tWork/rtl/Risc-Inci/srcRtl/test/smallDecoder.sv
vlog -work work -vopt -sv -stats=none /home/otutay/Desktop/tWork/rtl/Risc-Inci/srcRtl/test/InstRandomizer.sv
vlog -work work -vopt -sv -stats=none /home/otutay/Desktop/tWork/rtl/Risc-Inci/srcRtl/test/InstDecoderIntf.sv


## core files
vcom -work work -2008 -vopt -stats=none /home/otutay/Desktop/tWork/rtl/Risc-Inci/srcRtl/vhdl/corePackage.vhd
vcom -work work -2008 -vopt -stats=none /home/otutay/Desktop/tWork/rtl/Risc-Inci/srcRtl/vhdl/ram.vhd
vcom -work work -2008 -vopt -stats=none /home/otutay/Desktop/tWork/rtl/Risc-Inci/srcRtl/vhdl/fetch.vhd
vcom -work work -2008 -vopt -stats=none /home/otutay/Desktop/tWork/rtl/Risc-Inci/srcRtl/vhdl/dataRam.vhd
vcom -work work -2008 -vopt -stats=none /home/otutay/Desktop/tWork/rtl/Risc-Inci/srcRtl/vhdl/regFile.vhd
vcom -work work -2008 -vopt -stats=none /home/otutay/Desktop/tWork/rtl/Risc-Inci/srcRtl/vhdl/instDecoder.vhd
vcom -work work -2008 -vopt -stats=none /home/otutay/Desktop/tWork/rtl/Risc-Inci/srcRtl/vhdl/alu.vhd
vcom -work work -2008 -vopt -stats=none /home/otutay/Desktop/tWork/rtl/Risc-Inci/srcRtl/vhdl/Top.vhd

# tb top
vlog -work work -vopt -sv -stats=none /home/otutay/Desktop/tWork/rtl/Risc-Inci/srcRtl/test/CoreTb.sv

vsim -voptargs=+acc work.CoreTb
add wave -position insertpoint sim:/CoreTb/*
add wave -divider FetchComp
add wave -position insertpoint sim:/CoreTb/fetchComp/*
add wave -divider instDecoderComp
add wave -position insertpoint sim:/InstDecoderTb/instDecoderComp/*
add wave -divider regFileComp
add wave -position insertpoint sim:/InstDecoderTb/regFileComp/*
add wave -divider aluComp
add wave -position insertpoint sim:/InstDecoderTb/aluComp/*
add wave -divider dataRamComp
add wave -position insertpoint sim:/InstDecoderTb/dataRamComp/*



#add wave -r /*
run 11 us
