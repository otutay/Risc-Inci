//-------------------------------------------------------------------------------
// Title      : decoderTest
// Project    :
// -----------------------------------------------------------------------------
// File       : decoderTest.sv
// Author     : osmant -> otutaysalgir@gmail.com
// Company    :
// Created    : 21.07.2021
// Platform   :
//-----------------------------------------------------------------------------
// Description: decoder test top module
//-----------------------------------------------------------------------------
// Copyright (c) 2021
//-----------------------------------------------------------------------------
// Revisions  :
// Date        Version  Author  Description
// 21.07.2021  1.0      osmant  Created
//-----------------------------------------------------------------------------
import corePckg::*;
`include "decoderLog.sv"
`include "smallDecoder.sv"
`include "decoderComparator.sv"

module decoderTest
  (
   input logic		   clk,
   input logic		   rst,
   input logic [cXLEN-1:0] instr,
   input logic [cXLEN-1:0] curPc,
   input		   tDecodedInst dutInst,
   input		   tDecodedReg dutReg,
   input		   tDecodedMem dutMemOp,
   input		   tDecodedBranch dutBranchOp

   );
   localparam integer	   cDispOnTerm = 1;


   // here comes the automatic control codes.
   decoderLog decoderLogObj;
   initial
     begin : testLogObjInit
	decoderLogObj  = new("/home/otutay/Desktop/tWork/rtl/Risc-Inci/srcRtl/test/DecoderLog.txt",cDispOnTerm);

     end //testLogObjInit


   smallDecoder decoderObj;
   initial
     begin: decoderInit
	decoderObj = new();

     end // decoderInit

   decoderComparator comparatorObj;
   initial
     begin: comparatorInit
	comparatorObj = new();
     end //comparatorInit






   logic [5:0]	       instType;
   tDecodedInst decodedInst = cDecodedInst;
   tDecodedReg regOp = cDecodedReg;
   tDecodedMem memOp  = cDecodedMem;
   tDecodedBranch branchOp = cDecodedBranch;
   always_comb
     begin : decoderLogPro
	if(rst)
	  begin
	     instType = {6{1'b0}};
	     decodedInst = cDecodedInst;
	     regOp = cDecodedReg;
	     memOp = cDecodedMem;
	     branchOp = cDecodedBranch;
	  end
	else
	  begin
	     instType = decoderObj.decodeInstType(instr);
	     decoderLogObj.addInstLog("NormalOp", instr);
	     case (instType)
	       6'b000001:
		 begin
		    decoderLogObj.addDecodeRtypeLog(decoderObj.opcode, decoderObj.src1,decoderObj.src2,decoderObj.dest,
						    decoderObj.f3,decoderObj.f7);
		 end
	       6'b000010:
		 begin
		    decoderLogObj.addDecodeItypeLog(decoderObj.opcode,decoderObj.src1,decoderObj.dest, decoderObj.f3,
						    decoderObj.imm);
		 end
	       6'b000100 , 6'b001000:
		 begin
		    decoderLogObj.addDecodeSBtypeLog(decoderObj.opcode, decoderObj.src1,decoderObj.src2, decoderObj.f3,
						     decoderObj.imm);
		 end
	       6'b010000 , 6'b100000:
		 begin
		    decoderLogObj.addDecodeUJtypeLog(decoderObj.opcode, decoderObj.dest, decoderObj.imm);
		 end
	       default:
		 begin
		    decoderLogObj.addDecodeTypeError(decoderObj.opcode);
		 end
	     endcase // case (instType)

	     decodedInst = decoderObj.decodeInst();
	     regOp = decoderObj.decodeReg(instr);
	     branchOp = decoderObj.decodedBranch();
	     memOp = decoderObj.decodedMem();


	  end

     end // block: decoderLogPro

endmodule : decoderTest
