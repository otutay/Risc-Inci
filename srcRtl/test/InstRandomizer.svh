//-------------------------------------------------------------------------------
// Title      : instruction randomizer
// Project    :
// -----------------------------------------------------------------------------
// File       : InstRandomizer.svh
// Author     : osmant -> otutaysalgir@gmail.com
// Company    :
// Created    : 05.04.2021
// Platform   :
//-----------------------------------------------------------------------------
// Description: instruction randomize for testing
//-----------------------------------------------------------------------------
// Copyright (c) 2021
//-----------------------------------------------------------------------------
// Revisions  :
// Date        Version  Author  Description
// 05.04.2021  1.0      osmant  Created
//-----------------------------------------------------------------------------
import corePckg::*;
class InstRandomizer;
   rand tOpcodeEnum opcode;
   rand logic [cRegSelBitW-1:0] src1Addr;
   rand logic [cRegSelBitW-1:0] src2Addr;
   rand logic [cRegSelBitW-1:0] destAddr;
   rand logic [2:0]		   funct3;
   rand logic [6:0]		   funct7;

   constraint src1Addr

endclass
