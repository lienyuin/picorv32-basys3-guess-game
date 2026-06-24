`timescale 1ns / 1ps

module io(
    input         clk,
    input         resetn,

    input         mem_valid,
    input  [31:0] mem_addr,
    input  [31:0] mem_wdata,
    input  [3:0]  mem_wstrb,
    output        mem_ready,
    output reg [31:0] mem_rdata,

    input  [3:0]  sw,
    input         btnL,
    input         btnR,
    input         btnC,

    output reg [2:0] led
);

    // 按鈕同步暫存器
    reg btnL_meta;
    reg btnL_sync;

    reg btnR_meta;
    reg btnR_sync;

    reg btnC_meta;
    reg btnC_sync;
    reg btnC_prev;

    // 高速自由運行計數器
    reg [31:0] random_counter;

    // 目前的隨機答案，範圍 0～15
    reg [3:0] target;

    // 混合計數器中的不同位元，產生 4-bit 數值
    wire [3:0] random_value;

    assign random_value =
        random_counter[3:0]   ^
        random_counter[11:8]  ^
        random_counter[19:16] ^
        random_counter[27:24];

    // 偵測 BTN_CENTER 從 0 變成 1
    wire btnC_rise;

    assign btnC_rise = btnC_sync && !btnC_prev;

    // 同步三個按鈕
    always @(posedge clk) begin
        if (!resetn) begin
            btnL_meta <= 1'b0;
            btnL_sync <= 1'b0;

            btnR_meta <= 1'b0;
            btnR_sync <= 1'b0;

            btnC_meta <= 1'b0;
            btnC_sync <= 1'b0;
            btnC_prev <= 1'b0;
        end
        else begin
            btnL_meta <= btnL;
            btnL_sync <= btnL_meta;

            btnR_meta <= btnR;
            btnR_sync <= btnR_meta;

            btnC_meta <= btnC;
            btnC_sync <= btnC_meta;
            btnC_prev <= btnC_sync;
        end
    end

    // 計數器持續運行
    always @(posedge clk) begin
        if (!resetn)
            random_counter <= 32'd0;
        else
            random_counter <= random_counter + 1'b1;
    end

    // 中間按鈕產生新答案
    always @(posedge clk) begin
        if (!resetn) begin
            target <= 4'd7;
        end
        else if (btnC_rise) begin

            // 避免新答案剛好和舊答案相同
            if (random_value == target)
                target <= target + 4'd1;
            else
                target <= random_value;

        end
    end

    // I/O 存取立即完成
    assign mem_ready = mem_valid;

    // CPU 讀取 Memory-Mapped I/O
    always @(*) begin
        case (mem_addr)

            // Switch
            32'h0300_0004:
                mem_rdata = {28'b0, sw};

            // BTN_LEFT
            32'h0300_0008:
                mem_rdata = {31'b0, btnL_sync};

            // BTN_RIGHT
            32'h0300_000C:
                mem_rdata = {31'b0, btnR_sync};

            // 隨機答案
            32'h0300_0010:
                mem_rdata = {28'b0, target};

            default:
                mem_rdata = 32'b0;

        endcase
    end

    // CPU 寫入 LED
    always @(posedge clk) begin
        if (!resetn) begin
            led <= 3'b000;
        end

        // 產生新答案時清除上一次結果
        else if (btnC_rise) begin
            led <= 3'b000;
        end

        else if (mem_valid && (|mem_wstrb)) begin
            if (mem_addr == 32'h0300_0000)
                led <= mem_wdata[2:0];
        end
    end

endmodule