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
	

endpackage


