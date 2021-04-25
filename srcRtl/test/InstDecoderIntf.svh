//                              -*- Mode: Verilog -*-
// Filename        : InstDecoderIntf.sv
// Description     : instDecoderInterface
// Author          : osmant
// Created On      : Sun Apr  4 23:08:25 2021
// Last Modified By: osmant
// Last Modified On: Sun Apr  4 23:08:25 2021
// Update Count    : 0
// Status          : Unknown, Use with caution!
import corePckg::*;
`include "InstRandomizer.svh"
class instDecoderIntf;

   logic [cXLEN-1:0] iInst;
   rand logic [cXLEN-1:0] iCurPc;
   logic	     iFlushPipe;

   rand InstRandomizer randInst = new();

   function directedInst(logic [6:0] opcode)
     case opcode
       eOpLoad :
	 begin
	    iInst[6:0] = opcode;
	    iInst[11:7] = 5'b00001;
	    iInst[14:12] = 3'b100;
	    iInst[19:15] = 5'b00011;
	    iInst[31:20] = 12'hbab;
	 end
       eOpStore :
	 begin
	    iInst[6:0] = opcode;
	    iInst[11:7] = 5'b11111;
	    iInst[14:12] = 3'b010;
	    iInst[19:15] = 5'b00111;
	    iInst[19:15] = 5'b01111;
	    iInst[31:20] = 12'hdec;
	 end
       eOpImmedi :



     endcase

   endfunction

   function display();
      iInst = randInst.formInst();
      $display("randomized datas are iInst = %h, iCurPc = %h, iFlushPipe = %b, opcode = %s \n",iInst,iCurPc,iFlushPipe,tOpcodeEnum'(iInst[6:0]));

   endfunction // display


endclass
