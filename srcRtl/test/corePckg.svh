//-------------------------------------------------------------------------------
// Title      : corePckg for tests
// Project    :
// -----------------------------------------------------------------------------
// File       : corePckg.sv
// Author     : osmant -> otutaysalgir@gmail.com
// Company    :
// Created    : 05.04.2021
// Platform   :
//-----------------------------------------------------------------------------
// Description:
//-----------------------------------------------------------------------------
// Copyright (c) 2021
//-----------------------------------------------------------------------------
// Revisions  :
// Date        Version  Author  Description
// 05.04.2021  1.0      osmant  Created
//-----------------------------------------------------------------------------
package corePckg;
   parameter int cXLen = 32;
   parameter int cRegSelBitW = 5;

   typedef enum  logic [6:0]
		 {
		  eOpLoad   = 7'h03, // done;
		  eOpStore  = 7'h23, // done;
		  eOpRtype  = 7'h33, // done
		  eOpImmedi = 7'h13, // done
		  eOpJalr   = 7'h67, // done
		  eOpJal	  = 7'h6f, // done
		  eOpLui	  = 7'h37, // done
		  eOpAuIpc  = 7'h17, // done
		  eOpBranch = 7'h63, // done
		  eOpFence  = 7'h0f,
		  eOpCntrlSt = 7'h73,
		  eNOOP = 7'hff
		  }tOpcodeEnum;


endpackage : corePckg
