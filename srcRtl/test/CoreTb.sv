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
   localparam integer  cRandomSize = 10;
   localparam integer  cRandomize = 1;
   localparam integer  cDispOnTerm = 1;

   // clk and rst gen
   logic	       clk = 0;
   logic	       rst = 1;
   logic	       rsti1 =1;
   always #(cClkPeriod/2) clk =~clk;

   initial begin
      rst = 1'b1;
      #(cResetTime)
      rst = 1'b0;
   end

   always_ff @(posedge clk) begin
      rsti1 <= rst;
   end

   // random inst created and written 2 a file
   testVector testVectorObj;
   InstRandomizer randInstObj;
   initial
     begin
	testVectorObj = new("/home/otutay/Desktop/tWork/rtl/Risc-Inci/srcRtl/test/testVec.txt",cDispOnTerm);
	if(cRandomize == 1)
	  begin
	     $display("---------- Randomization ----------------------");
	     randInstObj = new();
	     for (int i = 0; i < cRandomSize; i++) begin
		assert(randInstObj.randomize());
		testVectorObj.setData(randInstObj.formInst());
	     end
	     testVectorObj.closeFile();
	     $display("---------- Done ----------------------");
	     testVectorObj = new("/home/otutay/Desktop/tWork/rtl/Risc-Inci/srcRtl/test/testVec.txt",cDispOnTerm);
	  end
     end

   // instruction read from file
   logic instWen;
   logic [cXLEN-1:0] inst2Write;
   logic [cXLEN-1:0] inst2Writei1;
   logic	     readDone;
   logic	     startExecution;

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
      if(rsti1 == 1'b1)
	begin
	   instWen <= 1'b0;
	   startExecution <= 1'b0;
	end
      else if (inst2Write != 'hdeadbeaf)
	begin
	   instWen <= 1'b1;
	   startExecution <= 1'b0;
	end
      else
	begin
	   instWen <= 1'b0;
	   startExecution <= 1'b1;
	end
   end

   tDecodedInst dutInst;
   tDecodedReg dutRegOp;
   tDecodedMem dutMemOp;
   tDecodedBranch dutBranchOp;


   Top DUTCore(
	       .iClk(clk),
	       .iRst(rst),
	       .iStart(startExecution),
	       // inst load interface
	       .iInst2Write(inst2Writei1),
	       .iInstWen(instWen),
	       // data load interface
	       .iData2Write(),
	       .iDataWen(),
	       // instDecode signals for tb
	       .oRs1Addr(dutInst.rs1.addr),
	       .oRs2Addr(dutInst.rs2.addr),
	       .oRdAddr(dutInst.rdAddr),
	       .oF3(dutInst.funct3),
	       .oF7(dutInst.funct7),
	       .oImm(dutInst.imm),
	       .oOpcode(dutInst.opcode),
	       .oCurPc(dutInst.curPc),
	       //oDecodedMem
	       .oLoad(dutMemOp.load),
	       .oStore(dutMemOp.store),
	       .oMemDv(dutMemOp.dv),
	       //oDecodedReg
	       .oAritType(dutRegOp.arithType),
	       .oOpRs1(dutRegOp.opRs1),
	       .oOpRs2(dutRegOp.opRs2),
	       .oOpImm(dutRegOp.opImm),
	       .oOpPc(dutRegOp.opPc),
	       .oOpConst(dutRegOp.opConst),
	       .oOpDv(dutRegOp.dv),
	       //oDecodedBranch
	       .oBrOp(dutBranchOp.op),
	       .oBrDv(dutBranchOp.dv)

	       // alu signals for tb

	       );

endmodule : CoreTb;
