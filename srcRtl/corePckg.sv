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
	parameter int unsigned cDataWidth = 32;
	parameter int unsigned cRegNum = 2**cRegSelBitW;
	
	
	//	parameter logic [6:0] cRtype =  7'b0110011;
	typedef enum logic [6:0]{
		eOpLoad   = 7'h03,
		eOpFence  = 7'h0f,
		eOpImmedi = 7'h13,
		eOpAuIpc  = 7'h17,
		eOpStore  = 7'h23,
		eOpRtype  = 7'h33,
		eOpLui 	 = 7'h37,
		eOpBranch = 7'h63,
		eOpJalr   = 7'h67,
		eOpJal 	 = 7'h6f,
		eOpCntrlSt= 7'h73
	}tOpcodeEnum;

	typedef struct packed{
		logic [cRegSelBitW-1:0] addr;
		logic en;
	}tRegControl;
	
	typedef struct packed {
		logic[31:0] data;
		logic dv;
	}tRegister;
//	
	
	typedef struct packed {
		logic[2:0] value;
		logic dv;
	}tFunct3;
	
	typedef struct packed {
		logic[6:0] value;
		logic dv;
	}tFunct7;
	
	typedef struct packed {
		logic[31:0] value;
		logic dv;
	}tImmedi;
	
	typedef struct packed {
		tRegControl rs1;
		tRegControl rs2;
		tRegControl rd;
		tFunct3 funct3;
		tFunct7 funct7;
		tImmedi imm;
		tOpcodeEnum opcode;
	}tDecodedInst;
	
	typedef struct packed {
		tRegister rs1;
		tRegister rs2;
		tRegControl rd;
		tFunct3 funct3;
		tFunct7 funct7;
		tImmedi imm;
		tOpcodeEnum opcode;
	}tDecoded;


	typedef struct packed {
		logic [31:0] addr;
		logic memOp;
		tRegControl destReg;
		
	}tAluOut;

endpackage


