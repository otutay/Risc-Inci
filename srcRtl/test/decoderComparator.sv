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

   function void compareInst(tDecodedInst controlInst, tDecodedInst dutInst, logic [5:0] typeOfInst, logic [cXLEN-1:0] inst);

      $display("TIME -> %0t, Inst ->  %h will be tested \n",$time, inst);

      case (typeOfInst) // rs1 addr compare
	Itype, Stype, Rtype, Btype:
	  begin
	     if(controlInst.rs1.addr != dutInst.rs1.addr)
	       $display("\t\t TIME -> %0t, ERROR ->DecodedInst rs1Addr is wrong !!!!!!!!! \n", $time);
	  end
      endcase


      case (typeOfInst)  // rs2 addr compare
	Stype, Rtype, Btype:
	  begin
	     if(controlInst.rs2.addr != dutInst.rs2.addr)
	       $display("\t\t TIME -> %0t, ERROR ->DecodedInst rs2Addr is wrong !!!!!!!!! \n", $time);
	  end
      endcase

      case (typeOfInst)  // rd addr compare
	Itype, Rtype, Utype, Jtype: begin
	   if(controlInst.rdAddr != dutInst.rdAddr)
	     $display("\t\t TIME -> %0t, ERROR ->DecodedInst rdAddr is wrong !!!!!!!!! \n", $time);
	end
      endcase

      case (typeOfInst)  // funct3  compare
	Itype, Stype, Rtype, Btype: begin
	   if(controlInst.funct3 != dutInst.funct3)
	     $display("\t\t TIME -> %0t, ERROR ->DecodedInst F3 is wrong !!!!!!!!! \n", $time);
	end
      endcase

      case (typeOfInst)  // f7 compare
	Rtype: begin
	   if(controlInst.funct7 != dutInst.funct7)
	     $display("\t\t TIME -> %0t, ERROR ->DecodedInst F7 is wrong !!!!!!!!! \n", $time);
	end
      endcase // case (expression)

      if(controlInst.opcode != dutInst.opcode)  // opcode compare
	$display("\t\t TIME -> %0t, ERROR ->DecodedInst opcode %s,%s is wrong !!!!!!!!! \n", $time,tOpcodeEnum'(controlInst.opcode),tOpcodeEnum'(dutInst.opcode));


      case (typeOfInst)  // imm compare
	Itype, Stype, Utype, Stype, Btype: begin
	   if(controlInst.imm != dutInst.imm)
	     $display("\t\t TIME -> %0t, ERROR ->DecodedInst imm is wrong !!!!!!!!! \n", $time);
	end
      endcase // case (typeOfInst)

   endfunction // compareInst



   function void compareReg(tDecodedReg controlReg, tDecodedReg dutReg);
      if (controlReg.arithType != dutReg.arithType)
	begin
	   $display("\t\t TIME -> %0t, ERROR ->RegOp arithType is wrong !!!!!!!!! \n", $time);
	   $display("\t\t TIME -> %0t, control %h dut %h \n", $time, controlReg.arithType,dutReg.arithType);
	end

      if(controlReg.opRs1 != dutReg.opRs1)
	begin
	   $display("\t\t TIME -> %0t, ERROR ->RegOp opRs1 is wrong !!!!!!!!! \n", $time);
	end

      if(controlReg.opRs2 != dutReg.opRs2)
	begin
	   $display("\t\t TIME -> %0t, ERROR ->RegOp opRs2 is wrong !!!!!!!!! \n", $time);
	end

      if(controlReg.opImm != dutReg.opImm)
	begin
	   $display("\t\t TIME -> %0t, ERROR ->RegOp opImm is wrong !!!!!!!!! \n", $time);
	end

      if(controlReg.opPc != dutReg.opPc)
	begin
	   $display("\t\t TIME -> %0t, ERROR ->RegOp opPc is wrong !!!!!!!!! \n", $time);
	end

      if(controlReg.opConst != dutReg.opConst)
	begin
	   $display("\t\t TIME -> %0t, ERROR ->RegOp opPc is wrong !!!!!!!!! \n", $time);
	end

   endfunction // compareReg

   function void compareBranch(tDecodedBranch controlBr, tDecodedBranch dutBr);
      if(controlBr.op != dutBr.op)
	begin
	   $display("\t\t TIME -> %0t, ERROR ->BranchOp is wrong !!!!!!!!! \n", $time);
	end
   endfunction // compareBranch


   function void compareMem(tDecodedMem controlMem, tDecodedMem dutMem);
      if(controlMem.load != dutMem.load)
	begin
	   $display("\t\t TIME -> %0t, ERROR ->MemOp load is wrong !!!!!!!!! \n", $time);
	end

      if(controlMem.store != dutMem.store)
	begin
	   $display("\t\t TIME -> %0t, ERROR ->MemOp store is wrong !!!!!!!!! \n", $time);
	end

   endfunction // compareMEm



endclass
