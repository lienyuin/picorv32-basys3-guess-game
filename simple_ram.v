`timescale 1ns / 1ps

module simple_ram (
    input         clk,
    input         mem_valid,
    input  [31:0] mem_addr,
    output        mem_ready,
    output reg [31:0] mem_rdata
);

    assign mem_ready = mem_valid;

    always @(*) begin
        case (mem_addr)

            // x1 = 0x03000000
            32'h0000_0000:
                mem_rdata = 32'h030000B7;

            // main：讀 BTN_RIGHT
            32'h0000_0004:
                mem_rdata = 32'h00C0A303;

            // 只保留 bit 0
            32'h0000_0008:
                mem_rdata = 32'h00137313;

            // BTN_RIGHT 按下時跳到 reset
            32'h0000_000C:
                mem_rdata = 32'h04031A63;

            // 讀 BTN_LEFT
            32'h0000_0010:
                mem_rdata = 32'h0080A283;

            // 只保留 bit 0
            32'h0000_0014:
                mem_rdata = 32'h0012F293;

            // BTN_LEFT 沒按，回 main
            32'h0000_0018:
                mem_rdata = 32'hFE0286E3;

            // 讀 Switch
            32'h0000_001C:
                mem_rdata = 32'h0040A103;

            // 只保留低 4 bit
            32'h0000_0020:
                mem_rdata = 32'h00F17113;

            // x3 = 隨機答案
            // 從 0x03000010 讀取 target
            32'h0000_0024:
                mem_rdata = 32'h0100A183;

            // guess < target：跳太小
            32'h0000_0028:
                mem_rdata = 32'h02314063;

            // target < guess：跳太大
            32'h0000_002C:
                mem_rdata = 32'h0221C463;

            // 猜中：LED = 001
            32'h0000_0030:
                mem_rdata = 32'h00100213;

            // 寫 LED
            32'h0000_0034:
                mem_rdata = 32'h0040A023;

            // 等待 BTN_LEFT 放開
            32'h0000_0038:
                mem_rdata = 32'h0080A283;

            32'h0000_003C:
                mem_rdata = 32'h0012F293;

            // 還按著就繼續等待
            32'h0000_0040:
                mem_rdata = 32'hFE029CE3;

            // 回 main
            32'h0000_0044:
                mem_rdata = 32'hFC1FF06F;

            // 太小：LED = 010
            32'h0000_0048:
                mem_rdata = 32'h00200213;

            32'h0000_004C:
                mem_rdata = 32'h0040A023;

            // 回等待 BTN_LEFT 放開
            32'h0000_0050:
                mem_rdata = 32'hFE9FF06F;

            // 太大：LED = 100
            32'h0000_0054:
                mem_rdata = 32'h00400213;

            32'h0000_0058:
                mem_rdata = 32'h0040A023;

            // 回等待 BTN_LEFT 放開
            32'h0000_005C:
                mem_rdata = 32'hFDDFF06F;

            // reset：LED 全部熄滅
            32'h0000_0060:
                mem_rdata = 32'h0000A023;

            // 等待 BTN_RIGHT 放開
            32'h0000_0064:
                mem_rdata = 32'h00C0A303;

            32'h0000_0068:
                mem_rdata = 32'h00137313;

            // 還按著就繼續等待
            32'h0000_006C:
                mem_rdata = 32'hFE031CE3;

            // 回 main
            32'h0000_0070:
                mem_rdata = 32'hF95FF06F;

            default:
                mem_rdata = 32'h00000013;

        endcase
    end

endmodule