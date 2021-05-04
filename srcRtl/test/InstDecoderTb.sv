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
`include "InstRandomizer.sv";
//`include "InstDecoderIntf.sv";
`include "testVector.sv"
`include "logData.sv"

 `define randomizer 1

module InstDecoderTb();

   /* -----\/----- EXCLUDED -----\/-----
    instDecoderIntf intf;
    -----/\----- EXCLUDED -----/\----- */
   localparam integer cRandomSize = 10;


   logic clk;
   logic rst;
   logic [cXLEN-1:0] inst;
   logic [cXLEN-1:0] curPC = 0;
   logic	     flushPipe = 0;

   logic [8:0]	     shftReg = 9'b0000001;
   testVector dataObj;
   logData logObj;
   InstRandomizer randInstObj;


   initial
     begin

`ifdef randomizer

	dataObj = new("/home/otutay/Desktop/tWork/rtl/Risc-Inci/srcRtl/test/testVec.txt");
	randInstObj = new();
	for (int i = 0; i < cRandomSize; i++) begin
	   assert(randInstObj.randomize());
	   dataObj.setData(randInstObj.formInst());

	end
	dataObj.closeFile();

`endif //  `ifdef randomizer
	clk <= 0;
	rst <= 1;
	logObj  = new("/home/otutay/Desktop/tWork/rtl/Risc-Inci/srcRtl/test/log.txt");
	dataObj = new("/home/otutay/Desktop/tWork/rtl/Risc-Inci/srcRtl/test/testVec.txt");
	#1000 rst <=0;

     end // initial begin


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
	   inst = dataObj.getData();
	   logObj.addLog("NormalOp", inst);
	end
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
