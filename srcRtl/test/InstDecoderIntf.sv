//-------------------------------------------------------------------------------
// Title      : InstDecoderIntf.sv
// Project    :
// -----------------------------------------------------------------------------
// File       : InstDecoderIntf.sv
// Author     : osmant -> otutaysalgir@gmail.com
// Company    :
// Created    : 26.04.2021
// Platform   :
//-----------------------------------------------------------------------------
// Description: decoder insterface code for testing purposes.
//-----------------------------------------------------------------------------
// Copyright (c) 2021
//-----------------------------------------------------------------------------
// Revisions  :
// Date        Version  Author  Description
// 26.04.2021  1.0      osmant  Created
//-----------------------------------------------------------------------------

import corePckg::*;
`include "InstRandomizer.sv"
class instDecoderIntf;

   logic [cXLEN-1:0] iInst;
   rand logic [cXLEN-1:0] iCurPc;
   logic	     iFlushPipe;

   rand InstRandomizer randInst = new();

   function directedInst(logic [6:0] opcode);
     iInst[6:0] = opcode;
      case (opcode)
	eOpLoad : // lbu
	  begin
	     iInst[11:7] = 5'b00001;
	     iInst[14:12] = 3'b100;
	     iInst[19:15] = 5'b00011;
	     iInst[31:20] = 12'hbab;
	  end
	eOpStore : // sw
	  begin
	     iInst[11:7] = 5'b11111;
	     iInst[14:12] = 3'b010;
	     iInst[19:15] = 5'b00111;
	     iInst[24:20] = 5'b01111;
	     iInst[31:25] = 12'hdec;
	  end
	eOpImmedi : // slli
	  begin
	     iInst[11:7] = 5'b11111;
	     iInst[14:12] = 3'b001;
	     iInst[19:15] = 5'b01111;
	     iInst[31:20] = 12'hbaf;
	  end
	eOpRtype : // sltu
	  begin
	     iInst[11:7] = 5'b00001;
	     iInst[14:12] = 3'b011;
	     iInst[19:15] = 5'b00001;
	     iInst[24:20] = 5'b00010;
	     iInst[31:25] = 7'b0000000;
	  end
	eOpJalr :
	  begin
	     iInst[11:7] = 5'b10001;
	     iInst[14:12] = 3'b000;
	     iInst[19:15] = 5'b01001;
	     iInst[31:20] = 12'hcaf;
	  end
	eOpJal:
	  begin
	     iInst[11:7] = 5'b11001;
	     iInst[14:12] = 3'b000;
	     iInst[19:15] = 5'b11101;
	     iInst[31:20] = 12'hfff;
	  end
	eOpLui:
	  begin
	     iInst[11:7] = 5'b11111;
	     iInst[31:12] = 20'hbeafc;
	  end
	eOpAuIpc:
	  begin
	     iInst[11:7] = 5'b11100;
	     iInst[31:12] = 20'habcde;
	  end
	eOpBranch : // BGE
	  begin
	     iInst[11:7] = 5'b11010;
	     iInst[14:12] = 3'b101;
	     iInst[19:15] = 5'b10001;
	     iInst[24:20] = 5'b10010;
	     iInst[31:25] = 7'b1010101;
	  end
      endcase

   endfunction

   function display();
      iInst = randInst.formInst();
      $display("randomized datas are iInst = %h, iCurPc = %h, iFlushPipe = %b, opcode = %s \n",iInst,iCurPc,iFlushPipe,tOpcodeEnum'(iInst[6:0]));

   endfunction // display


endclass
