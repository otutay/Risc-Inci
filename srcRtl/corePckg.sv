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
	
	typedef struct packed{
		logic en;
		logic [cRegSelBitW-1:0] addr;
	}tRegControl;
	
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

	typedef struct packed {
		logic[cRegSelBitW-1:0] addr;
		logic dv;
	}tRegister;
	
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
		tRegister rs1;
		tRegister rs2;
		tRegister rd;
		tFunct3 funct3;
		tFunct7 funct7;
		tImmedi imm;
		tOpcodeEnum opcode;
	}tDecodedInst;
	
	//	typedef struct packed{// includes 5 operation
	//		logic [2:0] loadType;
	//		logic [cRegSelBitW-1:0] destAddr;
	//		logic [cRegSelBitW-1:0] srcAddr;
	//		logic [11:0] imm;
	//		logic dv;
	//	} tOpLoad;
	//	
	//	typedef struct packed{ // includes 9 operation
	//		logic [2:0] imType;
	//		logic [cRegSelBitW-1:0] destAddr;
	//		logic [cRegSelBitW-1:0] srcAddr;
	//		logic [11:0] imm;// can be all immediates or shamt+ selection
	//		logic dv;
	//	} tOpImmediate;
	//	
	//	typedef struct packed{
	//		logic [19:0] imm;
	//		logic [cRegSelBitW-1:0] destAddr;
	//		logic dv;
	//	}tOpAuIPC;
	//	
	//	typedef struct packed{
	//		logic [2:0] storeType;
	//		logic [cRegSelBitW-1:0] src1Addr;
	//		logic [cRegSelBitW-1:0] src2Addr;
	//		logic [11:0] imm;
	//		logic dv;
	//	}tOpStore;

endpackage


