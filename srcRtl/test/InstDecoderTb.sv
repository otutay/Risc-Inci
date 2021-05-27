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
`include "testVector.sv"
`include "logData.sv"
`include "smallDecoder.sv"
`include "decoderComparator.sv"

module InstDecoderTb();
   localparam realtime cClkPeriod = 10ns;
   localparam realtime cResetTime = 1000ns;
   localparam integer  cRandomSize = 2000;
   localparam integer  cRandomizer = 1;
   localparam integer  cDispOnTerm = 0;


   logic	       clk;
   logic	       rst = 1;
   logic	       rsti1=1;
   logic	       rsti2=1;
   logic	       rsti3=1;
   logic [cXLEN-1:0]   inst;
   logic [cXLEN-1:0]   insti1;
   logic [cXLEN-1:0]   insti2;
   logic [cXLEN-1:0]   curPC = 0;
   logic	       flushPipe = 0;
   logic [5:0]	       instType;
   logic [5:0]	       instTypei1;
   logic [5:0]	       instTypei2;
   logic [5:0]	       instTypei3;

   tDecodedInst dutInst = cDecodedInst;
   tDecodedInst dutInsti1 = cDecodedInst;
   tDecodedReg dutRegOp = cDecodedReg;
   tDecodedMem dutMemOp = cDecodedMem;
   tDecodedBranch dutBranchOp = cDecodedBranch;

   tDecodedInst decodedInst = cDecodedInst;
   tDecodedInst decodedInsti1 = cDecodedInst;
   tDecodedInst decodedInsti2 = cDecodedInst;
   tDecodedInst decodedInsti3 = cDecodedInst;


   tDecodedReg regOp = cDecodedReg;
   tDecodedReg regOpi1 = cDecodedReg;
   tDecodedReg regOpi2 = cDecodedReg;


   tDecodedMem memOp  = cDecodedMem;
   tDecodedMem memOpi1 = cDecodedMem;
   tDecodedMem memOpi2 = cDecodedMem;

   tDecodedBranch branchOp = cDecodedBranch;
   tDecodedBranch branchOpi1 = cDecodedBranch;
   tDecodedBranch branchOpi2 = cDecodedBranch;

   // test classes
   testVector testVectorObj;
   InstRandomizer randInstObj;
   logData testLogObj;
   smallDecoder decoderObj;
   decoderComparator comparatorObj;


   initial
     begin

	clk = 0;
	rst = 1;

	if(cRandomizer == 1)
	  begin
	     $display("-----------------------------------");

	     testVectorObj = new("/home/otutay/Desktop/tWork/rtl/Risc-Inci/srcRtl/test/testVec.txt",cDispOnTerm);
	     randInstObj = new();
	     for (int i = 0; i < cRandomSize; i++) begin
		assert(randInstObj.randomize());
		testVectorObj.setData(randInstObj.formInst());

	     end
	     testVectorObj.closeFile();

	  end

	testLogObj  = new("/home/otutay/Desktop/tWork/rtl/Risc-Inci/srcRtl/test/testLog.txt",cDispOnTerm);
	testVectorObj  = new("/home/otutay/Desktop/tWork/rtl/Risc-Inci/srcRtl/test/testVec.txt",cDispOnTerm);
	decoderObj = new();
	comparatorObj = new();


	#cResetTime rst =0;

     end // initial begin


   always #(cClkPeriod/2) clk =~clk;

   always_ff @(posedge clk) begin
      if(rst)
	inst <= 0;
      else
	inst <= testVectorObj.getData();
   end


   always_comb begin
      if(rsti1)
	begin
	   instType = 0;
	   decodedInst = cDecodedInst;
	   regOp = cDecodedReg;
	   memOp = cDecodedMem;
	   branchOp = cDecodedBranch;
	end
      else
	begin
	   instType = decoderObj.decodeInstType(inst);
	   testLogObj.addInstLog("NormalOp", inst);
	   case (instType)
	     6'b000001:
	       begin
		  testLogObj.addDecodeRtypeLog(decoderObj.opcode, decoderObj.src1,decoderObj.src2,decoderObj.dest,
						 decoderObj.f3,decoderObj.f7);
	       end
	     6'b000010:
	       begin
		  testLogObj.addDecodeItypeLog(decoderObj.opcode,decoderObj.src1,decoderObj.dest, decoderObj.f3,
						 decoderObj.imm);
	       end
	     6'b000100 , 6'b001000:
	       begin
		  testLogObj.addDecodeSBtypeLog(decoderObj.opcode, decoderObj.src1,decoderObj.src2, decoderObj.f3,
						  decoderObj.imm);
	       end
	     6'b010000 , 6'b100000:
	       begin
		  testLogObj.addDecodeUJtypeLog(decoderObj.opcode, decoderObj.dest, decoderObj.imm);
	       end
	     default:
	       begin
		  testLogObj.addDecodeTypeError(decoderObj.opcode);
	       end
	   endcase // case (instType)

	   decodedInst = decoderObj.decodeInst();
	   regOp = decoderObj.decodeReg(inst);
	   branchOp = decoderObj.decodedBranch();
	   memOp = decoderObj.decodedMem();


	end
   end



   always_ff @(posedge clk) begin
      rsti1 <= rst;
      rsti2 <= rsti1;
      rsti3 <= rsti2;

      insti1 <= inst;
      insti2 <= insti1;

      // small Decoder registers
      instTypei1 <= instType;
      instTypei2 <= instTypei1;
      // instTypei3 <= instTypei2;


      decodedInsti1 <= decodedInst;
      decodedInsti2 <= decodedInsti1;
      //	    decodedInsti3 <= decodedInsti2;

      memOpi1 <= memOp;
      memOpi2 <= memOpi1;


      regOpi1 <= regOp;
      regOpi2 <= regOpi1;

      branchOpi1<= branchOp;
      branchOpi2<= branchOpi1;


      dutInsti1 <= dutInst;

   end

   always_ff @(posedge clk) begin
      if(!rsti3)
	begin
	   comparatorObj.compareInst(decodedInsti2 , dutInst, instTypei2, insti2);
	   comparatorObj.compareReg(regOpi2,dutRegOp);
	   comparatorObj.compareBranch(branchOpi2,dutBranchOp);
	   comparatorObj.compareMem(memOpi2,dutMemOp);

	end
   end




   instDecoder #(.cycleNum(2))
   DUTDecoder(
       .iClk(clk),
       .iRst(rst),
       .iInst(inst),
       .iCurPC(curPC),
       .iFlushPipe(flushPipe),
       // decodedInst
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
       );



endmodule : InstDecoderTb
