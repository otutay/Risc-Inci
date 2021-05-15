//-------------------------------------------------------------------------------
// Title      : smallDecoderClass
// Project    :
// -----------------------------------------------------------------------------
// File       : smallDecoder.sv
// Author     : osmant -> otutaysalgir@gmail.com
// Company    :
// Created    : 03.05.2021
// Platform   :
//-----------------------------------------------------------------------------
// Description: small Decoder for logging
//-----------------------------------------------------------------------------
// Copyright (c) 2021
//-----------------------------------------------------------------------------
// Revisions  :
// Date        Version  Author  Description
// 03.05.2021  1.0      osmant  Created
//-----------------------------------------------------------------------------
import corePckg::*;
import packageTb::*;

class smallDecoder;
   logic [6:0] opcode;
   logic [cRegSelBitW-1:0] src1;
   logic [cRegSelBitW-1:0] src2;
   logic [cRegSelBitW-1:0] dest;
   logic [2:0]		   f3;
   logic [6:0]		   f7;
   logic [cXLEN-1:0]	   imm;


   //logic [5:0]		   typeOfInst;

/* -----\/----- EXCLUDED -----\/-----
   localparam logic [5:0]  Rtype = 6'b000001;
   localparam logic [5:0]  Itype = 6'b000010;
   localparam logic [5:0]  Stype = 6'b000100;
   localparam logic [5:0]  Btype = 6'b001000;
   localparam logic [5:0]  Utype = 6'b010000;
   localparam logic [5:0]  Jtype = 6'b100000;
 -----/\----- EXCLUDED -----/\----- */


   function logic [5:0] decodeInstType(logic [cXLEN-1:0] inst);
      logic [5:0]	   typeOfInst =  {6{1'b0}};
      opcode = inst[6:0];

      src1 = 0;
      src2 = 0;
      dest = 0;
      f3 = 0;
      f7 = 0;
      imm = 0;

      case (opcode)
	cOpLoad , cOpImmedi , cOpJalr :
	  begin
	     typeOfInst = Itype;
	     dest = inst[11:7];
	     f3 = inst[14:12];
	     src1 = inst[19:15];
	     imm = {{20{inst[31]}},inst[31:20]};
	  end
	cOpStore:
	  begin
	     typeOfInst = Stype;
	     f3 = inst[14:12];
	     src1 = inst[19:15];
	     src2 = inst[24:20];
	     imm = {{20{inst[31]}},inst[31:25],inst[11:7]};
	  end
	cOpRtype :
	  begin
	     typeOfInst = Rtype;
	     dest = inst[11:7];
	     f3 = inst[14:12];
	     src1 = inst[19:15];
	     src2 = inst[24:20];
	     f7 = inst[31:25];
	  end
	cOpLui , cOpAuIpc :
	  begin
	     typeOfInst = Utype;
	     dest = inst[11:7];
	     imm[31:12] = inst[31:12];
	     imm[11:0] = {12{1'b0}};
	  end
	cOpJal:
	  begin
	     typeOfInst = Jtype;
	     dest = inst[11:7];
	     imm = {{12{inst[31]}},inst[31], inst[19:12], inst[20], inst[30:21],1'b0 };
	  end
	cOpBranch  :
	  begin
	     typeOfInst = Btype;
	     f3 = inst[14:12];
	     src1 = inst[19:15];
	     src2 = inst[24:20];
	     imm = {{19{inst[31]}},inst[31],inst[7],inst[30:25],inst[11:8],1'b0};
	  end

	default: begin
	   typeOfInst = {6{1'b0}};
	   f3 = 0;
	   f7 = 0;
	   src1 = 0;
	   src2 = 0;
	   dest = 0;
	   imm = 0;
	end
      endcase // case (opcode)

      return typeOfInst;
   endfunction // decodeInst


   function tDecodedInst decodeInst();
      tDecodedInst decodedInst = cDecodedInst;
      decodedInst.rs1.addr = this.src1;
      decodedInst.rs2.addr = this.src2;
      decodedInst.rdAddr  = this.dest;
      decodedInst.funct3 = this.f3;
      decodedInst.funct7 = this.f7;
      decodedInst.imm = this.imm;
      decodedInst.opcode = this.opcode;

      return decodedInst;
   endfunction // collectInst


   function tDecodedReg decodeReg(logic [cXLEN-1:0] inst);
      tDecodedReg regOp;
      regOp = cDecodedReg;
      case (opcode)
	cOpRtype:
	  begin
	     regOp.arithType = tArithEnum'({inst[30], f3});
	     regOp.opRs1 = 1'b1;
	     regOp.opRs2 = 1'b1;
	     regOp.dv = 1'b1;
	  end
	cOpImmedi:
	  begin
	     regOp.arithType =tArithEnum'({inst[30], f3});
	     regOp.opRs1 = 1'b1;
	     regOp.opImm = 1'b1;
	     regOp.dv = 1'b1;
	  end
	cOpJal:
	  begin
	     regOp.arithType = tArithEnum'("0000");
	     regOp.opPc = 1'b1;
	     regOp.opConst = 1'b1;
	     regOp.dv = 1'b1;
	  end
	cOpJalr:
	  begin
	     regOp.arithType = tArithEnum'("0000");
	     regOp.opPc = 1'b1;
	     regOp.opConst = 1'b1;
	     regOp.dv = 1'b1;
	  end
	cOpLui:
	  begin
	     regOp.arithType = tArithEnum'("1111");
	     regOp.opImm = 1'b1;
	     regOp.dv = 1'b1;
	  end
	cOpAuIpc:
	  begin
	     regOp.arithType = tArithEnum'("0000");
	     regOp.opImm = 1'b1;
	     regOp.opPc = 1'b1;
	     regOp.dv = 1'b1;
	  end
	default: begin
	   regOp = cDecodedReg;
	end
      endcase // case (opcode)
      return regOp;
   endfunction // decodeReg


   function tDecodedBranch decodedBranch();
      tDecodedBranch branchOp = cDecodedBranch;

      case (opcode)
	cOpJal :
	  begin
	     branchOp.op = eJal;
	     branchOp.dv = 1'b1;
	  end
	cOpJalr:
	  begin
	     branchOp.op = eJalr;
	     branchOp.dv = 1'b1;
	  end
	cOpBranch:
	  begin
	     branchOp.op = tBranchEnum'(f3);
	     branchOp.dv = 1'b1;
	  end
	default: begin
	   branchOp = cDecodedBranch;
	end
      endcase // case (opcode)
      return branchOp;
   endfunction // decodedBranch

   function tDecodedMem decodedMem();
      tDecodedMem memOp = cDecodedMem;
      case (opcode)
	cOpLoad:
	  begin
	     memOp.load = 1'b1;
	     memOp.dv = 1'b1;

	  end
	cOpStore:
	  begin
	     memOp.store = 1'b1;
	     memOp.dv = 1'b1;
	  end
	default: begin
	   memOp = cDecodedMem;
	end
      endcase // case (opcode)
      return memOp;
   endfunction // decodedMem

endclass
