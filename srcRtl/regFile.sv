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
		input tRegControl  rs1Cntrl,
		input tRegControl  rs2Cntrl,
		input tRegControl  rdCntrl,
		output logic[cXLEN-1:0] rs1Data,
		output logic[cXLEN-1:0] rs2Data,
		input  logic[cXLEN-1:0] rdData
		);

	logic [cRegNum-1:0][cXLEN-1:0] rf;
	
	always_ff @(posedge iClk)
	begin
		if (rdCntrl.en) 
		begin
			if(rdCntrl.addr == {cRegSelBitW{ 1'b0}})
				begin
					rf[rdCntrl.addr] <= '0;
				end
			else
				begin
					rf[rdCntrl.addr] <= rdData;
				end
			
		end
	end

	always_comb 
	begin
		if (rs1Cntrl.en) 
		begin
			rs1Data = rf[rs1Cntrl.addr];
		end
		else
		begin
			rs1Data = '0; 
		end
	
	end
	
	always_comb 
	begin
		if (rs2Cntrl.en) 
		begin
			rs2Data = rf[rs2Cntrl.addr];
		end
		else
		begin
			rs2Data = '0; 
		end
	
	end
	
	
endmodule : regFile




