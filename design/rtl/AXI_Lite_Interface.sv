//=============================================================================
//
//Module Name:					AXI_Lite_Interface
//Department:					Xidian University
//Function Description:	        AXI Lite接口
//
//------------------------------------------------------------------------------
//
//Version 	Design		Coding		Simulata	  Review		Rel data
//V1.0		Verdvana	Verdvana	Verdvana		  			2021-10-03
//
//------------------------------------------------------------------------------
//
//Version	Modified History
//V1.0		AXI4 Lite Interface
//
//=============================================================================

import AXI_Lite_Package::*;

interface AXI_Lite_Intf;

	//全局信号
	wire			ACLK;
	wire			ARESETN;

	//写地址通道
	addr_t			AWADDR;
	cach_t			AWCACHE;
	prot_t			AWPROT;
	logic	 		AWVALID;
	logic	 		AWREADY;
	
	//写数据通道	
	data_t			WDATA;
	strb_t			WSTRB;
	logic	  		WVALID;
	logic	  		WREADY;
	
	//写响应通道	
	resp_t			BRESP;
	logic	  		BVALID;
	logic	  		BREADY;
	
	//读地址地址	
	addr_t			ARADDR;
	cach_t			ARCACHE;
	prot_t			ARPROT;
	logic	  		ARVALID;
	logic	  		ARREADY;
	
	//读数据通道	
	data_t			RDATA;
	resp_t			RRESP;
	logic	 		RVALID;
	logic	 		RREADY;


	modport Master(
		input			ACLK,
		input			ARESETN,
		//写地址通道
		output	  		AWADDR,
		output	  		AWCACHE,
		output	  		AWPROT,
		output	 		AWVALID,
		input	 		AWREADY,
		//写数据通道
		output			WDATA,
		output			WSTRB,
		output	  		WVALID,
		input	  		WREADY,
		//写响应通道
		input			BRESP,
		input	  		BVALID,
		output	  		BREADY,
		//读地址地址
		output	  		ARADDR,
		output	  		ARCACHE,
		output	  		ARPROT,
		output	  		ARVALID,
		input	  		ARREADY,
		//读数据通道
		input	  		RDATA,
		input	  		RRESP,
		input	 		RVALID,
		output	 		RREADY
	);



	modport Slave(
		input			ACLK,
		input			ARESETN,
		//写地址通道
		input	  		AWADDR,
		input	  		AWCACHE,
		input	  		AWPROT,
		input	 		AWVALID,
		output	 		AWREADY,
		//写数据通道
		input			WDATA,
		input			WSTRB,
		input	  		WVALID,
		output	  		WREADY,
		//写响应通道
		output			BRESP,
		output	  		BVALID,
		input	  		BREADY,
		//读地址地址
		input	  		ARADDR,
		input	  		ARCACHE,
		input	  		ARPROT,
		input	  		ARVALID,
		output	  		ARREADY,
		//读数据通道
		output	  		RDATA,
		output	  		RRESP,
		output	 		RVALID,
		input	 		RREADY
	);

endinterface