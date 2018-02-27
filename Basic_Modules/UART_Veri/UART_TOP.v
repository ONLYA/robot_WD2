module serialGPIO(
    input clk,
    input RxD,
    output TxD,

    output reg [7:0] GPout,  // general purpose outputs
    input [7:0] GPin  // general purpose inputs
);

wire RxD_data_ready;
wire [7:0] RxD_data;
async_receiver RX(.clk(clk), .RxD(RxD), .RxD_data_ready(RxD_data_ready), .RxD_data(RxD_data));
always @(posedge clk) if(RxD_data_ready) GPout <= RxD_data;

async_transmitter TX(.clk(clk), .TxD(TxD), .TxD_start(RxD_data_ready), .TxD_data(GPin));
endmodule
