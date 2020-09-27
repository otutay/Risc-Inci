// ****************************************************************************
// * corePckg.sv
// * osmant 
// * 
// ****************************************************************************/

/**
 * Package: corePckg
 * 
 * TODO: Add package documentation
 */
package corePckg;

	parameter int unsigned cRegSelBitW = 5;
	//	parameter int unsigned cDataWidth = 32;
	//	parameter int unsigned cPCBitW = 32;
	//	parameter int unsigned cImmBitW = 32;
	parameter int unsigned cXLEN = 32;
	parameter int unsigned cRegNum = 2**cRegSelBitW;


	//	parameter logic [6:0] cRtype =  7'b0110011;


	//	typedef struct packed{
	//		logic [cRegSelBitW-1:0] addr;
	//		logic en;
	//	}tRegControl;
	//
	//	typedef struct packed {
	//		logic[31:0] data;
	//		logic dv;
	//	}tRegister;
	//	//	
	//
	//	typedef struct packed {
	//		logic[2:0] value;
	//		logic dv;
	//	}tFunct3;
	//
	//	typedef struct packed {
	//		logic[6:0] value;
	//		logic dv;
	//	}tFunct7;
	//
	//	typedef struct packed {
	//		logic[31:0] value;
	//		logic dv;
	//	}tImmedi;
	typedef enum logic [6:0]{
		eOpLoad   = 7'h03, // done;
		eOpFence  = 7'h0f,
		eOpImmedi = 7'h13, // done
		eOpAuIpc  = 7'h17,
		eOpStore  = 7'h23, // done;
		eOpRtype  = 7'h33, // done
		eOpLui 	  = 7'h37,
		eOpBranch = 7'h63, // done
		eOpJalr   = 7'h67, // done
		eOpJal 	  = 7'h6f, // done
		eOpCntrlSt = 7'h73
	}tOpcodeEnum;


	typedef struct packed {
		logic [cRegSelBitW-1:0] rs1Addr;
		logic [cRegSelBitW-1:0] rs2Addr;
		logic [cRegSelBitW-1:0] rdAddr;
		logic [2:0] funct3;
		logic [6:0] funct7;
		logic[cXLEN-1:0] imm;
		tOpcodeEnum opcode;
		logic [cXLEN-1:0] curPc;
	}tDecodedInst;

	typedef struct packed {
		logic [cXLEN-1:0] rs1Data;
		logic [cXLEN-1:0] rs2Data;
		logic [cRegSelBitW-1:0] rdAddr;
		logic [2:0] funct3;
		logic [6:0] funct7;
		logic[cXLEN-1:0] imm;
		tOpcodeEnum opcode;
		logic [cXLEN-1:0] curPc;
	}tDecoded;


	typedef struct packed {
		logic read;
		logic write;
		logic [cXLEN-1:0] addr;
		logic [cXLEN-1:0] data;
		logic [2:0] opType;
		logic [cRegSelBitW-1:0] rdAddr;
	}tMemOp;

	typedef struct packed {
		logic dv;
		logic [cRegSelBitW-1:0] addr;
		logic [cXLEN-1:0] data;
	}tRegOp;

	typedef struct packed {
		logic branchTaken;
		logic flushPipe;
		logic newPC;
	}tBranchOp;

	typedef struct packed {
		tMemOp memOp;
		tRegOp regOp;
		tBranchOp brchOp;
	}tAluOut;





endpackage


