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
class instDecoderIntf;

   rand logic [cXLen-1:0] iInst;
   rand logic [cXLen-1:0] iCurPc;
   rand logic iFlushPipe;

   function display ();
      $display("randomized datas are iInst = %h, iCurPc = %h, iFlushPipe = %b \n",iInst,iCurPc,iFlushPipe);
   endfunction // display


endclass
