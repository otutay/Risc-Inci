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
`timescale 1ns/1ns
`include "InstDecoderIntf.sv";
`include "testVector.sv"
`include "logData.sv"
module InstDecoderTb();

   instDecoderIntf intf;
   logic clk;
   logic rst;
   logic [cXLEN-1:0] inst;
   logic [cXLEN-1:0] curPC = 0;
   logic	     flushPipe = 0;

   logic [8:0]	     shftReg = 9'b0000001;
   testVector data;
   logData logObj;

   initial
     begin
	intf = new();
	clk <= 0;
	rst <= 1;
	#1000 rst <=0;
	data = new("/home/otutay/Desktop/tWork/rtl/Risc-Inci/srcRtl/test/testVec.txt");
	logObj  = new("/home/otutay/Desktop/tWork/rtl/Risc-Inci/srcRtl/test/log.txt");

     end

   always #5 clk =~clk;


   always_ff @(posedge clk) begin
      if (rst == 1'b0)
	begin
	   shftReg <= {shftReg[$size(shftReg)-2:0],shftReg[$size(shftReg)-1]};
	end
   end


   always_ff @(posedge clk) begin
      if(rst)
	begin
	   inst <= 0;
	end
      else
	begin
	   inst = data.getData();
	   $display("data %h",inst);
	   $display("--------------------------\n");
	   inst = data.getData();
	   $display("data %h",inst);
	   $display("--------------------------\n");
	   inst = data.getData();
	   $display("data %h",inst);
	   $display("--------------------------\n");
	end
      /* -----\/----- EXCLUDED -----\/-----
       begin
       intf.directedInst(shftReg);
       inst <= intf.iInst;
	end
       assert(intf.randomize());
       -----/\----- EXCLUDED -----/\----- */
      //intf.display();

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
