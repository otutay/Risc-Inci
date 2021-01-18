// ****************************************************************************
// * regFile.sv
// * osmant 
// * 
// ****************************************************************************/

/**
 * Module: regFile
 * 
 * TODO: Add module documentation
 */

import corePckg::*;

module regFile 
		(
		input logic iClk,
		input logic iRst,
		input tRegOp rs1,
		input tRegOp rs2,
		input tRegOp rd,
		input  logic[cXLEN-1:0] rdData,
		output logic[cXLEN-1:0] rs1Data,
		output logic[cXLEN-1:0] rs2Data
//		input logic [cRegSelBitW-1:0] rs1Addr,
//		input logic [cRegSelBitW-1:0] rs2Addr,
//		input logic [cRegSelBitW-1:0] rdAddr,
//		input tRegControl  rs1Cntrl,
//		input tRegControl  rs2Cntrl,
//		input tRegControl  rdCntrl,
		);

	logic [cRegNum-1:0][cXLEN-1:0] rf;
	
	always_ff @(posedge iClk)
	begin
		if (rd.dv) 
		begin
			if(rd.addr == {cRegSelBitW{ 1'b0}})
				begin
					rf[0] <= '0;
				end
			else
				begin
					rf[rd.addr] <= rdData;
				end
			
		end
	end

	always_comb 
	begin
	    rs1Data <= rs1.dv ? rf[rs1.addr] : cXLEN'(0);   
	    rs2Data <= rs2.dv ? rf[rs2.addr] : cXLEN'(0);   
    end
	
	
endmodule : regFile




