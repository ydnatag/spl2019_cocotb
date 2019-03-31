//------------------------------------------------------------------------------
// Company: Satellogic S.A
//
// File: axi_lite_slave_int.vhdl
// Description: 
//
// AXI Lite Slave Interface for any ip core. Based in Xilinx automagic core.
//
// Author: Xilinx, David Caruso
//
//------------------------------------------------------------------------------
`timescale 1ns/1ps

module axi_lite_slave_int #(
    parameter C_S_AXI_DATA_WIDTH=32,
    parameter C_S_AXI_ADDR_WIDTH=4
)
(
    // Users to add parameters here
    output     [C_S_AXI_DATA_WIDTH-1:0]     WDATA_O,
    input      [C_S_AXI_DATA_WIDTH-1:0]     RDATA_I,
    output                                  WENA_O,
    output                                  RENA_O,
    output     [C_S_AXI_ADDR_WIDTH -1:0]    RADDR_O,
    output     [C_S_AXI_ADDR_WIDTH -1:0]    WADDR_O,
    // AXI4-Lite Slave Port
    input                                   S_AXI_ACLK,
    input                                   S_AXI_ARESETN,
    input      [C_S_AXI_ADDR_WIDTH-1:0]     S_AXI_AWADDR,
    input                                   S_AXI_AWVALID,
    output reg                              S_AXI_AWREADY,
    input      [C_S_AXI_DATA_WIDTH-1:0]     S_AXI_WDATA,
    input      [(C_S_AXI_DATA_WIDTH/8)-1:0] S_AXI_WSTRB,
    input                                   S_AXI_WVALID,
    output reg                              S_AXI_WREADY,
    output     [1:0]                        S_AXI_BRESP,
    output reg                              S_AXI_BVALID,
    input                                   S_AXI_BREADY,
    input      [C_S_AXI_ADDR_WIDTH-1:0]     S_AXI_ARADDR,
    input                                   S_AXI_ARVALID,
    output reg                              S_AXI_ARREADY,
    output     [C_S_AXI_DATA_WIDTH-1:0]     S_AXI_RDATA,
    output     [1:0]                        S_AXI_RRESP,
    output reg                              S_AXI_RVALID,
    input                                   S_AXI_RREADY
);

localparam ADDR_LSB = (C_S_AXI_DATA_WIDTH / 32) + 1;
localparam EXTRA_ZEROS        = {ADDR_LSB{1'b0}};

wire                          slv_reg_rden;
wire                          slv_reg_wren;
reg [C_S_AXI_DATA_WIDTH-1:0]  wdata_r;
integer                       byte_index;

assign S_AXI_BRESP = 2'b00;
assign S_AXI_RRESP = 2'b00;

always @(posedge S_AXI_ACLK) begin
    if(S_AXI_ARESETN == 1'b0) begin
        S_AXI_AWREADY <= 1'b0;
    end
    else begin
        if((S_AXI_AWREADY == 1'b0 && S_AXI_AWVALID == 1'b1))
            S_AXI_AWREADY <= 1'b1;
        else
            S_AXI_AWREADY <= 1'b0;
    end
end

always @(posedge S_AXI_ACLK) begin
    if(S_AXI_ARESETN == 1'b0) begin
        S_AXI_WREADY <= 1'b0;
    end
    else begin
        if((S_AXI_WREADY == 1'b0 && S_AXI_WVALID == 1'b1))
            S_AXI_WREADY <= 1'b1;
        else
            S_AXI_WREADY <= 1'b0;
    end
end

assign slv_reg_wren = S_AXI_WREADY & S_AXI_WVALID;

always @(posedge S_AXI_ACLK) begin
    if(S_AXI_ARESETN == 1'b0) begin
        S_AXI_BVALID <= 1'b0;
    end
    else begin
        if((S_AXI_WREADY == 1'b1 && S_AXI_WVALID == 1'b1 && S_AXI_BVALID == 1'b0))
            S_AXI_BVALID <= 1'b1;
        else if((S_AXI_BREADY == 1'b1 && S_AXI_BVALID == 1'b1))
            S_AXI_BVALID <= 1'b0;
    end
end

always @(posedge S_AXI_ACLK) begin
    if(S_AXI_ARESETN == 1'b0) begin
        S_AXI_ARREADY <= 1'b0;
    end
    else begin
        if((S_AXI_ARREADY == 1'b0 && S_AXI_ARVALID == 1'b1))
            S_AXI_ARREADY <= 1'b1;
        else
            S_AXI_ARREADY <= 1'b0;
    end
end

assign slv_reg_rden = S_AXI_ARREADY & S_AXI_ARVALID;

always @(posedge S_AXI_ACLK) begin
    if(S_AXI_ARESETN == 1'b0) begin
        S_AXI_RVALID <= 1'b0;
    end
    else begin
        if((S_AXI_ARREADY == 1'b1 && S_AXI_ARVALID == 1'b1 && S_AXI_RVALID == 1'b0))
            S_AXI_RVALID <= 1'b1;
        else if((S_AXI_RVALID == 1'b1 && S_AXI_RREADY == 1'b1))
            S_AXI_RVALID <= 1'b0;
    end
end

assign S_AXI_RDATA = RDATA_I;
assign RADDR_O = {S_AXI_ARADDR[C_S_AXI_ADDR_WIDTH-1 : ADDR_LSB],EXTRA_ZEROS};
assign WADDR_O = {S_AXI_AWADDR[C_S_AXI_ADDR_WIDTH-1 : ADDR_LSB],EXTRA_ZEROS};

assign WDATA_O = S_AXI_WDATA;
assign RENA_O = slv_reg_rden;
assign WENA_O = slv_reg_wren;

endmodule
