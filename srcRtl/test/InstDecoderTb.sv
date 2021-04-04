//                              -*- Mode: Verilog -*-
// Filename        : InstDecoderTb.sv
// Description     : instruction decoder test bench
// Author          : osmant
// Created On      : Sun Apr  4 23:18:52 2021
// Last Modified By: osmant
// Last Modified On: Sun Apr  4 23:18:52 2021
// Update Count    : 0
// Status          : Unknown, Use with caution!

`include "InstDecoderIntf.sv"

module InstDecoderTb();

  instDecoderIntf intf;


   initial begin
      intf = new();
      assert(intf.randomize());
      intf.display();
   end


endmodule : InstDecoderTb
