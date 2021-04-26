//-------------------------------------------------------------------------------
// Title      : insDecoderTb
// Project    :
// -----------------------------------------------------------------------------
// File       : InstDecoderTb.sv
// Author     : osmant -> otutaysalgir@gmail.com
// Company    :
// Created    : 26.04.2021
// Platform   :
//-----------------------------------------------------------------------------
// Description: decoder testBench
//-----------------------------------------------------------------------------
// Copyright (c) 2021
//-----------------------------------------------------------------------------
// Revisions  :
// Date        Version  Author  Description
// 26.04.2021  1.0      osmant  Created
//-----------------------------------------------------------------------------



`include "InstDecoderIntf.sv";

module InstDecoderTb();

   instDecoderIntf intf;
   logic clk;
   logic rst;
   logic [6:0] opcode;
   logic [cXLEN-1:0] inst;
   logic [cXLEN-1:0] curPC;
   logic	     flushPipe;

   logic [7:0] shftReg = 7'b0000001;


   initial
     begin
	intf = new();
	clk <= 0;
	rst <= 1;
	#1000 rst <=0;
     end

   always #5 clk =~clk;


   always_ff @(clk) begin
      shftReg <= {shftReg[$size(shftReg)-2:0],shftReg[$size(shftReg)-1]};
   end


   always_ff @(clk) begin
      case (shftReg)
	7'b0000001:
	  begin
	     opcode <= eOpLoad;
	     intf.directedInst(opcode);
	     inst <= intf.iInst;

	  end
/* -----\/----- EXCLUDED -----\/-----
	7'b0000010:
	  begin

	  end
 -----/\----- EXCLUDED -----/\----- */

	default: begin
	   opcode <= eNOOP;
	   inst <= cXLEN'(0);

	end
      endcase
      /* -----\/----- EXCLUDED -----\/-----
       assert(intf.randomize());
       -----/\----- EXCLUDED -----/\----- */
      intf.display();

   end





   instDecoder #(.cycleNum(2))
   DUT(
       .iClk(clk),
       .iRst(rst),
       .iInst(inst),
       .iCurPC(curPC),
       .iFlushPipe(flushPipe),
       .oDecoded(),
       .oMemOp(),
       .oRegOp(),
       .oBranchOp()
       );



endmodule : InstDecoderTb
