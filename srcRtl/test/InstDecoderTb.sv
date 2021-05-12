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
   localparam integer cRandomSize = 100;
   localparam integer randomizer = 1;


   logic	      clk;
   logic	      rst = 1;
   logic	      rsti1=1;
   logic	      rsti2=1;
   logic	      rsti3=1;
   logic [cXLEN-1:0]  inst;
   logic [cXLEN-1:0]  insti1;
   logic [cXLEN-1:0]  curPC = 0;
   logic	      flushPipe = 0;
   logic [5:0]	      instType;
   logic [5:0]	      instTypei1;
   logic [5:0]	      instTypei2;
   logic [5:0]	      instTypei3;

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


   logic [8:0]	      shftReg = 9'b0000001;

   // test classes
   testVector dataObj;
   logData logObj;
   InstRandomizer randInstObj;
   smallDecoder decoderObj;
   decoderComparator comparatorObj;


   initial
     begin

	clk = 0;
	rst = 1;

	if(randomizer == 1)
	  begin
	     dataObj = new("/home/otutay/Desktop/tWork/rtl/Risc-Inci/srcRtl/test/testVec.txt");
	     randInstObj = new();
	     for (int i = 0; i < cRandomSize; i++) begin
		assert(randInstObj.randomize());
		dataObj.setData(randInstObj.formInst());

	     end
	     dataObj.closeFile();

	  end

	logObj  = new("/home/otutay/Desktop/tWork/rtl/Risc-Inci/srcRtl/test/log.txt");
	dataObj = new("/home/otutay/Desktop/tWork/rtl/Risc-Inci/srcRtl/test/testVec.txt");
	decoderObj = new();
	comparatorObj = new();
	#1000 rst =0;

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
	inst <= 0;
      else
	inst <= dataObj.getData();
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
	   instType = decoderObj.decodeInst(inst);
	   logObj.addInstLog("NormalOp", inst);
	   case (instType)
	     6'b000001:
	       begin
		  logObj.addRtypeLog(decoderObj.opcode, decoderObj.src1,decoderObj.src2,decoderObj.dest,
				     decoderObj.f3,decoderObj.f7);
	       end
	     6'b000010:
	       begin
		  logObj.addItypeLog(decoderObj.opcode,decoderObj.src1,decoderObj.dest, decoderObj.f3,
				     decoderObj.imm);
	       end
	     6'b000100 , 6'b001000:
	       begin
		  logObj.addSBtypeLog(decoderObj.opcode, decoderObj.src1,decoderObj.src2, decoderObj.f3,
				      decoderObj.imm);
	       end
	     6'b010000 , 6'b100000:
	       begin
		  logObj.addUJtypeLog(decoderObj.opcode, decoderObj.dest, decoderObj.imm);
	       end
	     default: begin
		logObj.addTypeError(decoderObj.opcode);

	     end
	   endcase // case (instType)
	   decodedInst = decoderObj.collectInst();
	   regOp = decoderObj.decodeReg(inst);
	   branchOp = decoderObj.decodedBranch();
	   memOp = decoderObj.decodedMem();


	end
   end



   always_ff @(posedge clk) begin
      rsti1 <= rst;
      rsti2 <= rsti1;
      rsti3 <= rsti2;
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



       if(!rsti3)
	comparatorObj.compareInst(decodedInsti2,dutInst, instTypei2);
   end

/* -----\/----- EXCLUDED -----\/-----
   always_comb begin
      if(!rsti3)
	comparatorObj.compareInst(decodedInsti2,dutInst, instTypei2);
   end
 -----/\----- EXCLUDED -----/\----- */

   instDecoder #(.cycleNum(2))
   DUT(
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
       /* -----\/----- EXCLUDED -----\/-----
	.oDecoded(),
	.oMemOp(dutMemOp),
	.oRegOp(dutRegOp),
	.oBranchOp(dutBranchOp)
	-----/\----- EXCLUDED -----/\----- */
       );



endmodule : InstDecoderTb
