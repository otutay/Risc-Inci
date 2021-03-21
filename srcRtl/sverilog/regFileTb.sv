// ****************************************************************************
// * regFileTb.sv
// * osmant 
// * 
// ****************************************************************************/

/**
 * Module: regFileTb
 * 
 * TODO: Add module documentation
 */
`include "regFileRandomize.svh"

module regFileTb();
	
	logic clk,rst;
	logic [31:0] counter = '0;
	tRegControl rs1Ctrl;
	tRegControl rs2Ctrl;
	tRegControl rdCtrl;
	logic[cDataWidth-1:0] rs1Data;
	logic[cDataWidth-1:0] rs2Data;
	logic[cDataWidth-1:0] rdData;
	
	
	regFileRandomize random;
	
	
	initial begin
		random = new();
		clk <= 0;
	end
	
	always #5 clk = ~clk; 
	
	always_ff @(posedge clk)
	begin
		if(counter < 32)
		begin
			assert(random.randomize());
			random.display();
			rdCtrl.en <= 1'b1;
			rdCtrl.addr <= counter;
			rdData <= random.rdData;
		end
	end
	
	always_ff @(posedge clk)
	begin
		counter <= counter +1;
	end
	
	
	
		regFile DUT(
				.iClk(clk),
				.iRst(rst),
				.rs1Cntrl(rs1Ctrl),
				.rs2Cntrl(rs2Ctrl),
				.rdCntrl(rdCtrl),
				.oRs1Data(rs1Data),
				.oRs2Data(rs2Data),
				.rdData(rdData)
				);

endmodule


