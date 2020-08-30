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
		opLoad   = 7'h03,
		opFence  = 7'h0f,
		opImmedi = 7'h13,
		opAuIpc  = 7'h17,
		opStore  = 7'h23,
		opRtype  = 7'h33,
		opLui 	 = 7'h37,
		opBranch = 7'h63,
		opJalr   = 7'h67,
		opJal 	 = 7'h6f,
		opCntrlSt= 7'h73
	}tOpcodeEnum;
		
	typedef struct packed{
		logic [2:0] size;
		logic [cRegSelBitW-1:0] destAddr;
		logic [cRegSelBitW-1:0] srcAddr;
		logic [11:0] imm;
		logic dv;
	} tOpLoad;

endpackage


