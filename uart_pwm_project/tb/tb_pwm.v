`timescale 1ns/1ps
//======================================================
// Testbench: tb_pwm
// Simple simulation of PWM module
//======================================================
module tb_pwm;

    reg clk;
    reg rst;
    reg [1:0] pow2_cfg;
    reg [1:0] pow5_cfg;
    reg [6:0] duty_cfg;
    reg cfg_valid;
    wire pwm_out;

    // DUT (Device Under Test)
    pwm_ctrl dut (
        .clk(clk),
        .rst(rst),
        .pow2_cfg(pow2_cfg),
        .pow5_cfg(pow5_cfg),
        .duty_cfg(duty_cfg),
        .cfg_valid(cfg_valid),
        .pwm_out(pwm_out)
    );

    // Clock generation: 50 MHz = 20 ns period
    initial begin
        clk = 0;
        forever #10 clk = ~clk; // 20 ns period
    end

    // Stimulus
    initial begin
        // Dump waveforms
        $dumpfile("wave_pwm.vcd");
        $dumpvars(0, tb_pwm);

        // Reset
        rst = 1;
        pow2_cfg = 0;
        pow5_cfg = 0;
        duty_cfg = 0;
        cfg_valid = 0;
        #100;
        rst = 0;

        // Apply duty cycle = 25% after reset
        #50;
        duty_cfg = 25;
        cfg_valid = 1;
        #20;
        cfg_valid = 0;

        // Change POW2 after some time
        #50000;
        pow2_cfg = 2;
        cfg_valid = 1;
        #20;
        cfg_valid = 0;

        // Run for some time
        #100000;
        $finish;
    end

endmodule
