//======================================================
// Testbench: tb_pwm_ctrl
//======================================================
`timescale 1ns/1ps

module tb_pwm_ctrl;

    reg clk;
    reg rst;
    reg [1:0] pow2_cfg;
    reg [1:0] pow5_cfg;
    reg [6:0] duty_cfg;
    reg cfg_valid;
    wire pwm_out;

    // DUT
    pwm_ctrl dut (
        .clk(clk),
        .rst(rst),
        .pow2_cfg(pow2_cfg),
        .pow5_cfg(pow5_cfg),
        .duty_cfg(duty_cfg),
        .cfg_valid(cfg_valid),
        .pwm_out(pwm_out)
    );

    // Reloj 100 MHz
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Estímulos
    initial begin
        $dumpfile("wave_pwm_ctrl.vcd");
        $dumpvars(0, tb_pwm_ctrl);

        // Reset
        rst = 1;
        pow2_cfg = 0;
        pow5_cfg = 0;
        duty_cfg = 0;
        cfg_valid = 0;
        #50;
        rst = 0;

        // Configuración 1: duty = 25%
        duty_cfg = 25;
        cfg_valid = 1; #10; cfg_valid = 0;
        #2000;

        // Configuración 2: duty = 50%
        duty_cfg = 50;
        cfg_valid = 1; #10; cfg_valid = 0;
        #2000;

        // Configuración 3: duty = 75%
        duty_cfg = 75;
        cfg_valid = 1; #10; cfg_valid = 0;
        #2000;

        // Cambiamos frecuencia con pow2_cfg y pow5_cfg
        pow2_cfg = 2; // divide entre 4
        pow5_cfg = 1; // divide entre 5
        duty_cfg = 10;
        cfg_valid = 1; #10; cfg_valid = 0;
        #4000;

        // Caso borde: duty = 0%
        duty_cfg = 0;
        cfg_valid = 1; #10; cfg_valid = 0;
        #1000;

        // Caso borde: duty = 99% (máximo permitido)
        duty_cfg = 99;
        cfg_valid = 1; #10; cfg_valid = 0;
        #1000;

        $finish;
    end

endmodule
