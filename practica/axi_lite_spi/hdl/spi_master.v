`timescale 1ns/1ps


module spi_master #(
    parameter   SLAVES = 3,
    parameter   DWIDTH = 16,
    parameter   PRESCALER_WIDTH = 8
)
(
    input         CLK,
    input         RESETn,

    input [DWIDTH-1:0]       WDATA,
    output reg [DWIDTH-1:0]  RDATA,

    input                    WENA,
    input                    RENA,

    output reg                   BUSY,
    input [SLAVES-1:0]           SLAVE,
    input [$clog2(DWIDTH)-1:0]     LENGTH,
    input [PRESCALER_WIDTH-1:0]  PRESCALER,

    output reg              SPI_MOSI,
    input                   SPI_MISO,
    output reg              SPI_CLK,
    output reg [SLAVES-1:0] SPI_SS,
    output reg              INT
);
    
    localparam  IDLE = 0;
    localparam  FIRST_BIT  = 1;
    localparam  SENDING  = 2;
    localparam  LAST_BIT  = 3;
    localparam  WAIT = 4;
    
    reg [DWIDTH-1:0] wdata_r;
    reg [DWIDTH-1:0] rdata_r;
    reg [2:0] spi_state;
    reg [PRESCALER_WIDTH-1:0] cnt;
    reg [$clog2(DWIDTH)-1:0] nbit;
    reg [$clog2(DWIDTH)-1:0] length_r;
    reg spi_clk_parity;
    wire spi_clk_en;
    
    assign spi_clk_en = ( cnt[PRESCALER_WIDTH-2:0] == PRESCALER[PRESCALER_WIDTH-1:1] )? 1'b1 : 1'b0;
    
    always @(posedge(CLK)) begin
        if (spi_state != IDLE) begin
            cnt <= cnt + 'd1;
            if (cnt[PRESCALER_WIDTH-2:0] == PRESCALER[PRESCALER_WIDTH-1:1] ) begin
                cnt <= 'd1;
                spi_clk_parity <= ~spi_clk_parity;
            end
        end else begin
            cnt <= 'd1;
            spi_clk_parity <= 1'b0;
        end
    end
    
    always @(posedge(CLK)) begin
        if (RESETn == 1'b0) begin
            nbit <= 0;
            spi_state <= IDLE;
            rdata_r <= 'd0;
            RDATA <= 'd0;
            BUSY <= 1'b0;
            SPI_SS <= {SLAVES{1'b1}};
            SPI_CLK <= 1'b0;
            SPI_MOSI <= 1'b1;
            length_r <= 0;
            INT <= 1'b0;
        end else begin
            if (RENA) INT <= 1'b0;

            case (spi_state)
                IDLE: begin
                    SPI_SS <= {SLAVES{1'b1}} ;
                    if ( WENA == 1'b1) begin
                        SPI_SS <= ~SLAVE[SLAVES-1:0];
                        nbit <= 0;
                        wdata_r <= WDATA;
                        rdata_r <= 0;
                        spi_state <= FIRST_BIT;
                        BUSY <= 1'b1;
                        length_r <= LENGTH -1;
                    end
                end
                FIRST_BIT: begin
                    if (spi_clk_en) begin
                        spi_state <= SENDING;
                    end
                end
                SENDING: begin
                    SPI_CLK <= ~spi_clk_parity;
                    SPI_MOSI <= wdata_r[length_r];
                    if (spi_clk_en & ~spi_clk_parity) begin
                        wdata_r <= { wdata_r[DWIDTH-2:0],1'b0};
                        rdata_r <= { rdata_r[DWIDTH-2:0], SPI_MISO };
                        nbit <= nbit +1;
                        if (nbit == length_r ) begin
                            spi_state <= LAST_BIT;
                        end
                    end
                end
                LAST_BIT: begin
                    SPI_CLK <= 1'b0;
                    if (spi_clk_en & ~spi_clk_parity) begin
                        SPI_MOSI <= 1'b1;
                        SPI_SS <= {SLAVES{1'b1}} ;
                        spi_state <= WAIT;
                    end
                end
                WAIT: begin
                    if (spi_clk_en & spi_clk_parity) begin
                        spi_state <= IDLE;
                        BUSY <= 1'b0;
                        RDATA <= rdata_r;
                        INT <= 1'b1;
                    end
                end
            endcase
        end
    end
    
endmodule
