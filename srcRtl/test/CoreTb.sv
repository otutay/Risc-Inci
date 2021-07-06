//-------------------------------------------------------------------------------
// Title      : coreTb
// Project    :
// -----------------------------------------------------------------------------
// File       : CoreTb.sv
// Author     : osmant -> otutaysalgir@gmail.com
// Company    :
// Created    : 06.07.2021
// Platform   :
//-----------------------------------------------------------------------------
// Description: test bench for our core
//-----------------------------------------------------------------------------
// Copyright (c) 2021
//-----------------------------------------------------------------------------
// Revisions  :
// Date        Version  Author  Description
// 06.07.2021  1.0      osmant  Created
//-----------------------------------------------------------------------------
`timescale 1ns/1ns
`include "InstRandomizer.sv";
`include "testVector.sv"
`include "logData.sv"
`include "smallDecoder.sv"
`include "decoderComparator.sv"

module CoreTb();
   // parameters for tb
   localparam realtime cClkPeriod = 10ns;
   localparam realtime cResetTime = 1000ns;
   localparam integer  cRandomSize = 2000;
   localparam integer  cRandomize = 1;
   localparam integer  cDispOnTerm = 1;

   // clk and rst gen
   logic	       clk;
   logic	       rst = 1;

   always #(cClkPeriod/2) clk =~clk;

   initial begin
      rst = 1'b1;
      #(cResetTime)
      rst = 1'b0;
   end
   // random inst created and written 2 a file
   testVector testVectorObj;
   InstRandomizer randInstObj;
   initial
     begin
	if(cRandomize == 1)
	  begin
	     display("---------- Randomization ----------------------");
	     testVectorObj = new("/home/otutay/Desktop/tWork/rtl/Risc-Inci/srcRtl/test/testVec.txt",cDispOnTerm);
	     randInstObj = new();
	     for (int i = 0; i < cRandomSize; i++) begin
		assert(randInstObj.randomize());
		testVectorObj.setData(randInstObj.formInst());
	     end
	     testVectorObj.closeFile();
	     display("---------- Done ----------------------");
	  end
     end


   // instruction read from file

   initial
     begin
	testVectorObj  = new("/home/otutay/Desktop/tWork/rtl/Risc-Inci/srcRtl/test/testVec.txt",cDispOnTerm);
     end

   logic instWen;
   logic [cXLEN-1:0] inst2Write;
   logic [cXLEN-1:0] inst2Writei1;
   logic	     readDone;

   always_ff @(posedge clk) begin
      if(rst == 1'b1)
	begin
	   inst2Write <= 32'h00000000;
	end
      else
	begin
	   inst2Write <= testVectorObj.getData();
	end
   end

   always_ff @(posedge clk) begin
      inst2Writei1 <= inst2Write;
      if(rst == 1'b1)
	begin
	   inst2Wen <= 1'b0;
	end
      else if (inst2Write != 'hdeabbeaf)
	begin
	   inst2Wen <= 1'b1;
	end
      else
	begin
	   inst2Wen <= 1'b0;
	end
   end


endmodule : CoreTb;
