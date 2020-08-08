// ****************************************************************************
// * regFileRandomize.svh
// * osmant 
// * 
// ****************************************************************************/

/**
 * Class: regFileRandomize
 * 
 * TODO: Add class documentation
 * 
 */
import corePckg::*;
class regFileRandomize;
	
	rand tRegControl  rs1Cntrl;
	rand tRegControl  rs2Cntrl;
	rand tRegControl  rdCntrl;
	rand logic[cDataWidth-1:0] rdData;
	
	function display ();
		$display("Datas are rs1 = %p \t , rs2 = %p \t, rd = %p \t, rdData = %h ", rs1Cntrl,rs2Cntrl,rdCntrl, rdData);
	endfunction
//	function new();
//
//	endfunction


endclass


