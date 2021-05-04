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

class smallDecoder;
   logic [6:0] opcode;
   logic [cRegSelBitW-1:0] src1;
   logic [cRegSelBitW-1:0] src2;
   logic [cRegSelBitW-1:0] dest;
   logic [2:0]		   f3;
   logic [6:0]		   f7;
   logic [cXLEN-1:0]	   imm;

   logic [5:0]		   typeOfInst;

   localparam logic [5:0]  Rtype = 6'b000001;
   localparam logic [5:0]  Itype = 6'b000010;
   localparam logic [5:0]  Stype = 6'b000100;
   localparam logic [5:0]  Btype = 6'b001000;
   localparam logic [5:0]  Utype = 6'b010000;
   localparam logic [5:0]  Jtype = 6'b100000;
   //  6'b000001 -> R
   /// 6'b000010 -> I
   /// 6'b000100 -> S
   /// 6'b001000 -> B
   /// 6'b010000 -> U
   /// 6'b100000 -> j

   function new (args);

   endfunction

   function logic [5:0] decodeInst(logic [31:0] inst);
      opcode = inst[6:0];

      case (opcode)
	eOpLoad | eOpImmedi | eOpJalr :
	  begin
	     typeOfInst = Itype;
	     dest = inst[11:7];
	     f3 = inst[14:12];
	     src1 = inst[19:15];
	     imm = {{20{inst[31]}},inst[31:20]};
	  end
	eOpStore:
	  begin
	     typeOfInst = Stype;
	     f3 = inst[14:12];
	     src1 = inst[19:15];
	     src2 = inst[24:20];
	     imm = {{20{inst[31]}},inst[31:25],inst[11:7]};
	  end
	eOpRtype :
	  begin
	     typeOfInst = Rtype;
	     dest = inst[11:7];
	     f3 = inst[14:12];
	     src1 = inst[19:15];
	     src2 = inst[24:20];
	     f7 = inst[31:25];
	  end
	eOpLui | eOpAuIpc :
	  begin
	     typeOfInst = Utype;
	     dest = inst[11:7];
	     imm[31:12] = inst[31:12];
	     imm[11:0] = {12{1'b0}};
	  end
	eOpJal:
	  begin
	     typeOfInst = Jtype;
	     dest = inst[11:7];
	     imm = {{12{inst[31]}},inst[31], inst[19:12], inst[20], inst[30:21],1'b0 };
	  end
	eOpBranch  :
	  begin
	     typeOfInst = Btype;
	     f3 = inst[14:12];
	     src1 = inst[19:12];
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

   endfunction
endclass