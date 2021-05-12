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
import packageTb::*;

class decoderComparator;

   function void compareInst(tDecodedInst controlInst, tDecodedInst dutInst, logic [5:0] typeOfInst);
      $display("time ------------------->%0t, %b \n",$time, typeOfInst);

      case (typeOfInst)
	Itype, Stype, Rtype, Btype:
	  begin
	     if(controlInst.rs1.addr != dutInst.rs1.addr)
	       $display("TIME -> %0t, ERROR ->DecodedInst rs1Addr is wrong !!!!!!!!! \n", $time);
	  end
      endcase


      case (typeOfInst)
	Stype, Rtype, Btype:
	  begin
	     if(controlInst.rs2.addr != dutInst.rs2.addr)
	       $display("TIME -> %0t, ERROR ->DecodedInst rs2Addr is wrong !!!!!!!!! \n", $time);
	  end
      endcase

      case (typeOfInst)
	Itype, Rtype, Utype, Jtype: begin
	   if(controlInst.rdAddr != dutInst.rdAddr)
	     $display("TIME -> %0t, ERROR ->DecodedInst rdAddr is wrong !!!!!!!!! \n", $time);
	end
      endcase

      case (typeOfInst)
	Itype, Stype, Rtype, Btype: begin
	   if(controlInst.funct3 != dutInst.funct3)
	     $display("TIME -> %0t, ERROR ->DecodedInst F3 is wrong !!!!!!!!! \n", $time);
	end
      endcase

      case (typeOfInst)
	Rtype: begin
	   if(controlInst.funct7 != dutInst.funct7)
	     $display("TIME -> %0t, ERROR ->DecodedInst F7 is wrong !!!!!!!!! \n", $time);
	end
      endcase // case (expression)

      if(controlInst.opcode != dutInst.opcode)
	$display("TIME -> %0t, ERROR ->DecodedInst opcode %s,%s is wrong !!!!!!!!! \n", $time,tOpcodeEnum'(controlInst.opcode),tOpcodeEnum'(dutInst.opcode));


      case (typeOfInst)
	Itype, Stype, Utype, Stype, Btype: begin
	   if(controlInst.imm != dutInst.imm)
	     $display("TIME -> %0t, ERROR ->DecodedInst imm is wrong !!!!!!!!! \n", $time);
	end
      endcase // case (typeOfInst)

   endfunction // compareInst


   /* -----\/----- EXCLUDED -----\/-----
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
    -----/\----- EXCLUDED -----/\----- */





   /* -----\/----- EXCLUDED -----\/-----
    function compareOutputs(logic [5:0] typeOfInst,
    tDecodedInst controlInst, tDecodedInst dutInst,
    tDecodedReg controlReg, tDecodedReg dutReg,
    tDecodedMem controlMem, tDecodedMem dutMem,
    tDecodedBranch controlBr, tDecodedBranch dutBr);
    logic [6:0] resultInst =  compareInst(controlInst,dutInst);
    logic [6:0] resultReg =  compareReg(controlReg, dutReg);
    logic [2:0] resultMem = compareMem(controlMem, dutMem);
    logic [1:0] resultBr  = compareMem(controlBr, dutBr);




   endfunction // compareOutputs
    -----/\----- EXCLUDED -----/\----- */

endclass
