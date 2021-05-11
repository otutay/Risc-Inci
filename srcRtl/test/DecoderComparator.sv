//-------------------------------------------------------------------------------
// Title      : decoderComparator
// Project    : RiscInci
// -----------------------------------------------------------------------------
// File       : DecoderComparator.sv
// Author     : osmant -> otutaysalgir@gmail.com
// Company    :
// Created    : 12.05.2021
// Platform   :
//-----------------------------------------------------------------------------
// Description: output of decoder and smallDecoder
//-----------------------------------------------------------------------------
// Copyright (c) 2021
//-----------------------------------------------------------------------------
// Revisions  :
// Date        Version  Author  Description
// 12.05.2021  1.0      osmant  Created
//-----------------------------------------------------------------------------
import corePckg::*;

class decoderComparator;

   function logic [6:0] compareInst(tDecodedInst controlInst, tDecodedInst dutInst, logic [5:0] typeOfInst);
      logic [6:0] compare = 7'b000000;
      if(controlInst.rs1.addr == dutInst.rs1.addr)
	compare[0] = 1'b1;

      if(controlInst.rs2.addr == dutInst.rs2.addr)
	compare[1] = 1'b1;

      if(controlInst.rdAddr == dutInst.rdAddr)
	compare[2] = 1'b1;

      if(controlInst.funct3 == dutInst.funct3)
	compare[3] = 1'b1;

      if(controlInst.funct7 == dutInst.funct7)
	compare[4] = 1'b1;

      if(controlInst.opcode == dutInst.opcode)
	compare[5] = 1'b1;

      if(controlInst.imm == dutInst.imm)
	compare[6] = 1'b1;

      return compare;
   endfunction // compareInst

   function logic [6:0] compareReg(tDecodedReg controlReg, tDecodedReg dutReg);
      logic [6:0] compare = 7'b0000000;

      if (controlReg.arithType == dutReg.arithType)
	compare[0] = 1'b1;

      if (controlReg.opRs1 == dutReg.opRs1)
	compare[1] = 1'b1;

      if (controlReg.opRs2 == dutReg.opRs2)
	compare[2] = 1'b1;

      if (controlReg.opImm == dutReg.opImm)
	compare[3] = 1'b1;

      if (controlReg.opPc == dutReg.opPc)
	compare[4] = 1'b1;

      if (controlReg.opConst == dutReg.opConst)
	compare[5] = 1'b1;

      if (controlReg.dv == dutReg.dv)
	compare[6] = 1'b1;

      return compare;

   endfunction // compareReg

   function logic [1:0] compareBranch(tDecodedBranch controlBr, tDecodedBranch dutBr);
      logic [1:0] compare = 2'b00;
      if(controlBr.op = dutBr.op)
	compare[0] = 1'b1;

      if(controlBr.dv = dutBr.dv)
	compare[1] = 1'b0;

      return compare;
   endfunction // compareBranch

   function logic[2:0] compareMem(tDecodedMem controlMem, tDecodedMem dutMem);
      logic [2:0] compare = 3'b000;
      if(controlMem.load = dutMem.load)
	compare[0] = 1'b1;

      if(controlMem.store = dutMem.store)
	compare[1] = 1'b1;

      if(controlMem.dv = dutMem.dv)
	compare[2] = 1'b1;


      return compare;
   endfunction // compareMem

   function compareOutputs(logic [5:0] typeOfInst,
			   tDecodedInst controlInst, tDecodedInst dutInst,
			   tDecodedReg controlReg, tDecodedReg dutReg,
			   tDecodedMem controlMem, tDecodedMem dutMem,
			   tDecodedBranch controlBr, tDecodedBranch dutBr);
      logic [6:0] resultInst =  compareInst(controlInst,dutInst);
      logic [6:0] resultReg =  compareReg(controlReg, dutReg);
      logic [2:0] resultMem = compareMem(controlMem, dutMem);
      logic [1:0] resultBr  = compareMem(controlBr, dutBr);

      case (typeOfInst)
	6'b000001: begin

	end
	6'b000010: begin

	end
	6'b000100: begin

	end
	6'b001000: begin

	end
	6'b010000: begin

	end
	6'b100000: begin

	end
	default: begin

	end
      endcase // case (instTypei2)

   endfunction // compareOutputs


endclass
