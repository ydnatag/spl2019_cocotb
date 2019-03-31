//------------------------------------------------------------------------------
// Company: Satellogic S.A
//
// File: axi_spi.v
// Description: 
//
// Author: Andres Demski
//
//------------------------------------------------------------------------------

`timescale 1ns/1ps

module axi_spi  #(
    parameter                               C_AXI_DATA_WIDTH = 32,
    parameter                               C_AXI_ADDR_WIDTH = 5,
    parameter                               SLAVES = 3,
    parameter                               PRESCALER_WIDTH = 8
)(
    // AXI4-Lite Slave Port
    input                                   AXI_ACLK,
    input                                   AXI_ARESETN,
    input    [C_AXI_ADDR_WIDTH-1:0]         AXI_AWADDR,
    input                                   AXI_AWVALID,
    output                                  AXI_AWREADY,
    input    [C_AXI_DATA_WIDTH-1:0]         AXI_WDATA,
    input    [(C_AXI_DATA_WIDTH/8)-1:0]     AXI_WSTRB,
    input                                   AXI_WVALID,
    output                                  AXI_WREADY,
    output  [1:0]                           AXI_BRESP,
    output                                  AXI_BVALID,
    input                                   AXI_BREADY,
    input   [C_AXI_ADDR_WIDTH-1:0]          AXI_ARADDR,
    input                                   AXI_ARVALID,
    output                                  AXI_ARREADY,
    output  [C_AXI_DATA_WIDTH-1:0]          AXI_RDATA,
    output  [1:0]                           AXI_RRESP,
    output                                  AXI_RVALID,
    input                                   AXI_RREADY,

    output                                  MOSI,
    input                                   MISO,
    output                                  SCLK,
    output  [SLAVES-1:0]                    SS,

    output                                  INT
);

    wire     [C_AXI_DATA_WIDTH-1:0]       wdata;
    reg      [C_AXI_DATA_WIDTH-1:0]       rdata;
    wire     [C_AXI_ADDR_WIDTH-1:0]      raddr;
    wire     [C_AXI_ADDR_WIDTH-1:0]      waddr;
    wire                                  wena;
    wire                                  rena;
    wire     [PRESCALER_WIDTH-1:0]        prescaler;
    wire     [$clog2(C_AXI_DATA_WIDTH)-1:0] length;
    wire     [SLAVES-1:0]                 slave;

    localparam IDX_ID = 0;
    localparam IDX_STATUS = 1;
    localparam IDX_SLAVE = 2;
    localparam IDX_LENGTH = 3;
    localparam IDX_PRESCALER = 4;
    localparam IDX_WRITE = 5;
    localparam IDX_READ = 6;

    reg [C_AXI_DATA_WIDTH-1:0] registers [5:0];

    wire busy;
    wire [C_AXI_DATA_WIDTH-1:0] spi_rdata;
    reg  [C_AXI_DATA_WIDTH-1:0] spi_wdata;
    reg spi_rena;
    reg spi_wena;


    axi_lite_slave_int #(
        .C_S_AXI_ADDR_WIDTH             (C_AXI_ADDR_WIDTH),
        .C_S_AXI_DATA_WIDTH             (C_AXI_DATA_WIDTH)
    ) axi_registers (
        .WDATA_O                        (wdata),
        .RDATA_I                        (rdata),
        .WENA_O                         (wena),
        .RENA_O                         (rena),
        .RADDR_O                        (raddr),
        .WADDR_O                        (waddr),
        .S_AXI_ACLK                     (AXI_ACLK),
        .S_AXI_ARESETN                  (AXI_ARESETN),
        .S_AXI_AWADDR                   (AXI_AWADDR),
        .S_AXI_AWVALID                  (AXI_AWVALID),
        .S_AXI_AWREADY                  (AXI_AWREADY),
        .S_AXI_WDATA                    (AXI_WDATA),
        .S_AXI_WSTRB                    (AXI_WSTRB),
        .S_AXI_WVALID                   (AXI_WVALID),
        .S_AXI_WREADY                   (AXI_WREADY),
        .S_AXI_BRESP                    (AXI_BRESP),
        .S_AXI_BVALID                   (AXI_BVALID),
        .S_AXI_BREADY                   (AXI_BREADY),
        .S_AXI_ARADDR                   (AXI_ARADDR),
        .S_AXI_ARVALID                  (AXI_ARVALID),
        .S_AXI_ARREADY                  (AXI_ARREADY),
        .S_AXI_RDATA                    (AXI_RDATA),
        .S_AXI_RRESP                    (AXI_RRESP),
        .S_AXI_RVALID                   (AXI_RVALID),
        .S_AXI_RREADY                   (AXI_RREADY)
    );

    always @(posedge(AXI_ACLK)) begin
        if (AXI_ARESETN == 1'b0) begin
            spi_rena <= 1'b0;
            spi_wena <= 1'b0;
        end else begin
            spi_rena <= 1'b0;
            spi_wena <= 1'b0;

            if (wena == 1'b1) begin 
                case (waddr[C_AXI_ADDR_WIDTH-1:2])
                    IDX_WRITE: begin
                        spi_wdata <= wdata;
                        spi_wena <= 1'b1;
                    end
                    default: begin
                        registers[waddr[C_AXI_ADDR_WIDTH-1:2]] <= wdata;
                    end
                endcase
            end

            if (rena == 1'b1) begin
                case (raddr[C_AXI_ADDR_WIDTH-1:2])
                    IDX_ID: begin
                        rdata <= 32'hFAFAFAFA;
                    end
                    IDX_STATUS: begin
                        rdata <= {{C_AXI_DATA_WIDTH-1{1'b0}}, busy};
                    end
                    IDX_READ: begin
                        rdata <= spi_rdata;
                        spi_rena <= 1'b1;
                    end
                    default: begin
                        rdata <= registers[raddr[C_AXI_ADDR_WIDTH-1:2]];
                    end
                endcase
            end
        end
    end

    assign prescaler = registers[IDX_PRESCALER][PRESCALER_WIDTH-1:0];
    assign length = registers[IDX_LENGTH][$clog2(C_AXI_DATA_WIDTH)-1:0];
    assign slave = registers[IDX_SLAVE][SLAVES-1:0];


    spi_master #(
        .DWIDTH                         (C_AXI_DATA_WIDTH),
        .SLAVES                         (SLAVES),
        .PRESCALER_WIDTH                (PRESCALER_WIDTH)
    ) spi_core (
        .WDATA                          (spi_wdata),
        .RDATA                          (spi_rdata),
        .WENA                           (spi_wena),
        .RENA                           (spi_rena),
        .SPI_MOSI                       (MOSI),
        .SPI_MISO                       (MISO),
        .SPI_CLK                        (SCLK),
        .SPI_SS                         (SS),
        .BUSY                           (busy),
        .SLAVE                          (slave),
        .LENGTH                         (length),
        .PRESCALER                      (prescaler),
        .INT                            (INT),
        .RESETn                         (AXI_ARESETN),
        .CLK                            (AXI_ACLK)
    );
    //-------------------------------------------------------

`ifdef COCOTB_SIM
    initial begin
        $dumpfile("sim_build/waveform.vcd");
        $dumpvars (0,axi_spi);
    end
`endif


endmodule
