//=============================================================================
// Module Name:						AXI_Lite_FIFO
// Function Description:			
// Department:						Qualcomm (Shanghai) Co., Ltd.
// Author:							Verdvana
// Email:							verdvana@outlook.com
//-----------------------------------------------------------------------------
// Version 	Design		Coding		Simulata	  Review		Rel data
// V1.0		
//-----------------------------------------------------------------------------
// Version	Modified History
// V1.0		
//=============================================================================



//The time unit and precision of the external declaration
timeunit        1ns;
timeprecision   1ps;

// Define
//`define			FPGA_EMU

//Module
module  AXI_Lite_FIFO#(
	parameter		DEVICE_ADDR	= 64'h0000_0000_0000_00aa,
					DATA_WIDTH	= 8,						//Data width
					FIFO_DEPTH	= 16,						//FIFO depth
					ALMOST_WR	= 2,						//Almost full asserted advance value
					ALMOST_RD	= 2							//Almost empty asserted advance value
)(
	// Clock and reset
	input	wire							clk,			//Write clock
	input	wire							rst_n,

	AXI_Lite_Intf.Slave						axi_lite_s,

	// Write interface
	input									wr_en,			//Write enable
	input		 [DATA_WIDTH-1:0]			din,	    	//Write data
	// Read interface
	input									rd_en,			//Read enable
	output logic [DATA_WIDTH-1:0]			dout,	    	//Read data
	// Status	
	output logic							full,			//Full flag
	output logic							empty, 			//Empty flag
	output logic							almost_full,	//Almost full flag
	output logic							almost_empty, 	//Almost empty flag
	output logic							wr_ack,			//Write acknowledge
	output logic							valid,			//Valid flag
	output logic [clogb2(FIFO_DEPTH-1):0]	wr_count,     	//Write count
	output logic [clogb2(FIFO_DEPTH-1):0]	rd_count     	//Read count
);

	//=========================================================
	// Bit width calculation function
	function integer clogb2 (input integer depth);
	begin
		for (clogb2=0; depth>0; clogb2=clogb2+1) 
			depth = depth >>1;                          
	end
	endfunction


	//=========================================================
	// Parameter
	localparam		TCO			= 1.6,
					ADDR_WIDTH	= clogb2(FIFO_DEPTH-1);

	//=========================================================
	//Signal
	logic							addr_match_wr,addr_match_rd;

	logic							full_wf,full_rf;
	logic							empty_wf,empty_rf;
	logic							almost_full_wf,almost_full_rf;
	logic							almost_empty_wf,almost_empty_rf;
	logic							wr_ack_wf,wr_ack_rf;
	logic							valid_wf,valid_rf;
	logic [clogb2(FIFO_DEPTH-1):0]	wr_count_wf,wr_count_rf;
	logic [clogb2(FIFO_DEPTH-1):0]	rd_count_wf,rd_count_rf;     

	//=========================================================
	// match
	assign	addr_match_wr = (axi_lite_s.AWADDR == DEVICE_ADDR) ? 1'b1 : 1'b0;
	assign	addr_match_rd = (axi_lite_s.ARADDR == DEVICE_ADDR) ? 1'b1 : 1'b0;

	//=========================================================
	// AXI-Lite Write Side
	always_ff@(posedge axi_lite_s.ACLK, negedge axi_lite_s.ARESETN)begin
		if(!axi_lite_s.ARESETN)begin
			axi_lite_s.AWREADY	<= #TCO '0;
			axi_lite_s.WREADY	<= #TCO '0;
		end
		else if(axi_lite_s.AWVALID && axi_lite_s.WVALID && !axi_lite_s.AWREADY && !axi_lite_s.WREADY && !almost_full_wf)begin
			axi_lite_s.AWREADY	<= #TCO '1;
			axi_lite_s.WREADY	<= #TCO '1;
		end
		else begin
			axi_lite_s.AWREADY	<= #TCO '0;
			axi_lite_s.WREADY	<= #TCO '1;
		end
	end

	always_ff@(posedge axi_lite_s.ACLK, negedge axi_lite_s.ARESETN)begin
		if(!axi_lite_s.ARESETN)begin
			axi_lite_s.BVALID	<= #TCO '0;
		end
		else if(axi_lite_s.AWREADY && axi_lite_s.WREADY && addr_match_wr && !axi_lite_s.BREADY)begin
			axi_lite_s.BVALID	<= #TCO '1;
		end
		else begin
			axi_lite_s.BVALID	<= #TCO '0;
		end
	end

	//=========================================================
	// AXI-Lite Read Side
	always_ff@(posedge axi_lite_s.ACLK, negedge axi_lite_s.ARESETN)begin
		if(!axi_lite_s.ARESETN)begin
			axi_lite_s.ARREADY	<= #TCO '0;
		end
		else if(axi_lite_s.ARVALID && !axi_lite_s.ARREADY && !almost_empty_rf)begin
			axi_lite_s.ARREADY	<= #TCO '1;
		end
		else begin
			axi_lite_s.ARREADY	<= #TCO '0;
		end
	end

	always_ff@(posedge axi_lite_s.ACLK, negedge axi_lite_s.ARESETN)begin
		if(!axi_lite_s.ARESETN)begin
			axi_lite_s.RVALID	<= #TCO '0;
		end
		else if(axi_lite_s.ARREADY && addr_match_rd && !axi_lite_s.RREADY)begin
			axi_lite_s.RVALID	<= #TCO '1;
		end
		else begin
			axi_lite_s.RVALID	<= #TCO '0;
		end
	end


	//=========================================================
	// Status

	//=========================================================
	// Instantiate
	Async_FIFO #(
		.DATA_WIDTH		(DATA_WIDTH),						//Data width
		.FIFO_DEPTH		(FIFO_DEPTH),						//FIFO depth
		.ALMOST_WR		(ALMOST_WR),						//Almost full asserted advance value
		.ALMOST_RD		(ALMOST_RD)						//Almost empty asserted advance value
	)u_Write_FIFO(
		// Clock and reset
		.wr_clk			(axi_lite_s.ACLK),			//Write clock
		.rd_clk			(clk),			//Read clock
		.rst_n			(axi_lite_s.ARESETN),			//Async reset
		// Write interface
		.wr_en			(axi_lite_s.BVALID && !axi_lite_s.BREADY),			//Write enable
		.din			(axi_lite_s.WDATA[7:0]),	    	//Write data
		// Read interface
		.rd_en			(rd_en),			//Read enable
		.dout			(dout),	    	//Read data
		// Status	
		.full			(full_wf),			//Full flag
		.empty			(empty_wf), 			//Empty flag
		.almost_full	(almost_full_wf),	//Almost full flag
		.almost_empty	(almost_empty_wf), 	//Almost empty flag
		.wr_ack			(wr_ack_wf),			//Write acknowledge
		.valid			(valid_wf),			//Valid flag
		.wr_count		(wr_count_wf),     	//Write count
		.rd_count		(rd_count_wf)     	//Read count
	);

	Async_FIFO #(
		.DATA_WIDTH		(DATA_WIDTH),						//Data width
		.FIFO_DEPTH		(FIFO_DEPTH),						//FIFO depth
		.ALMOST_WR		(ALMOST_WR),						//Almost full asserted advance value
		.ALMOST_RD		(ALMOST_RD)							//Almost empty asserted advance value
	)u_Read_FIFO(
		// Clock and reset
		.wr_clk			(clk),			//Write clock
		.rd_clk			(axi_lite_s.ACLK),			//Read clock
		.rst_n			(rst_n),			//Async reset
		// Write interface
		.wr_en			(wr_en),			//Write enable
		.din			(din),	    	//Write data
		// Read interface
		.rd_en			(axi_lite_s.RVALID && !axi_lite_s.RREADY),			//Read enable
		.dout			(axi_lite_s.RDATA[7:0]),	    	//Read data
		// Status	
		.full			(full_rf),			//Full flag
		.empty			(empty_rf), 			//Empty flag
		.almost_full	(almost_full_rf),	//Almost full flag
		.almost_empty	(almost_empty_rf), 	//Almost empty flag
		.wr_ack			(wr_ack_rf),			//Write acknowledge
		.valid			(valid_rf),			//Valid flag
		.wr_count		(wr_count_rf),     	//Write count
		.rd_count		(rd_count_rf)     	//Read count
	);

	assign full		= full;
endmodule