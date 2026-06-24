`timescale 1ns / 1ps

module top(
    input        clk,
    input  [3:0] sw,
    input        btnL,
    input        btnR,
    input        btnC,

    output [2:0] led,
    output [6:0] seg,
    output [3:0] an,
    output       dp
);

    // PicoRV32 memory interface
    wire        mem_valid;
    wire        mem_instr;
    wire        mem_ready;
    wire [31:0] mem_addr;
    wire [31:0] mem_wdata;
    wire [3:0]  mem_wstrb;
    wire [31:0] mem_rdata;

    // Program memory interface
    wire        ram_ready;
    wire [31:0] ram_rdata;

    // Memory-mapped I/O interface
    wire        io_ready;
    wire [31:0] io_rdata;
    wire [2:0]  cpu_led;
    wire        io_select;
    wire        resetn;

    // Hold the CPU in reset briefly after FPGA configuration.
    reg [5:0] reset_count;

    initial begin
        reset_count = 6'd0;
    end

    always @(posedge clk) begin
        if (!reset_count[5])
            reset_count <= reset_count + 1'b1;
    end

    assign resetn = reset_count[5];

    // 0x0300_xxxx is reserved for memory-mapped I/O.
    assign io_select = (mem_addr[31:16] == 16'h0300);
    assign mem_ready = io_select ? io_ready : ram_ready;
    assign mem_rdata = io_select ? io_rdata : ram_rdata;

    // Open-source PicoRV32 CPU core.
    picorv32 cpu (
        .clk         (clk),
        .resetn      (resetn),

        .mem_valid   (mem_valid),
        .mem_instr   (mem_instr),
        .mem_ready   (mem_ready),
        .mem_addr    (mem_addr),
        .mem_wdata   (mem_wdata),
        .mem_wstrb   (mem_wstrb),
        .mem_rdata   (mem_rdata),

        .irq         (32'b0),
        .eoi         (),
        .trace_valid (),
        .trace_data  (),
        .trap        ()
    );

    // RISC-V program ROM.
    simple_ram ram (
        .clk         (clk),
        .mem_valid   (mem_valid),
        .mem_addr    (mem_addr),
        .mem_ready   (ram_ready),
        .mem_rdata   (ram_rdata)
    );

    // Switch, button, LED, and pseudo-random target registers.
    io myio (
        .clk         (clk),
        .resetn      (resetn),

        .mem_valid   (mem_valid),
        .mem_addr    (mem_addr),
        .mem_wdata   (mem_wdata),
        .mem_wstrb   (mem_wstrb),
        .mem_ready   (io_ready),
        .mem_rdata   (io_rdata),

        .sw          (sw),
        .btnL        (btnL),
        .btnR        (btnR),
        .btnC        (btnC),
        .led         (cpu_led)
    );

    assign led = cpu_led;

    // Display the current switch value on the rightmost digit.
    seven_seg display0 (
        .value       (sw),
        .seg         (seg),
        .an          (an),
        .dp          (dp)
    );

endmodule
