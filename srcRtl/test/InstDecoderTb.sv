//                              -*- Mode: Verilog -*-
// Filename        : InstDecoderTb.sv
// Description     : instruction decoder test bench
// Author          : osmant
// Created On      : Sun Apr  4 23:18:52 2021
// Last Modified By: osmant
// Last Modified On: Sun Apr  4 23:18:52 2021
// Update Count    : 0
// Status          : Unknown, Use with caution!

`include "InstDecoderIntf.svh"

module InstDecoderTb();

   instDecoderIntf intf;


   always
     begin
	intf = new();
	assert(intf.randomize());
	intf.display();

     end




endmodule : InstDecoderTb
