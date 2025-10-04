# =========================================================
# Makefile para simular módulos del proyecto UART + PWM
# Uso:
#   make sim SIM=tb_uart_rx
#   make sim SIM=tb_uart_tx
#   make sim SIM=tb_cmd_parser
#   make sim SIM=tb_pwm
#   make sim SIM=tb_top
# =========================================================

# Herramientas
IVERILOG = iverilog
VVP      = vvp

# Carpetas
RTL_DIR  = ../rtl
TB_DIR   = ../tb
BUILD_DIR = build

# Archivos fuente RTL
RTL_SRCS = $(RTL_DIR)/cmd_parser.v \
           $(RTL_DIR)/freq_scale.v \
           $(RTL_DIR)/pwm_ctrl.v \
           $(RTL_DIR)/pwm.v \
           $(RTL_DIR)/rx_buffer.v \
           $(RTL_DIR)/uart_rx.v \
           $(RTL_DIR)/uart_tx.v \
           $(RTL_DIR)/top.v

# Target por defecto
all:
	@echo "Usa: make sim SIM=tb_<nombre>"

# Simulación
sim: $(BUILD_DIR)/sim.out
	@echo ">> Ejecutando simulación: $(SIM)"
	$(VVP) $(BUILD_DIR)/sim.out

# Compilación
$(BUILD_DIR)/sim.out: $(RTL_SRCS) $(TB_DIR)/$(SIM).v | $(BUILD_DIR)
	@echo ">> Compilando $(SIM)..."
	$(IVERILOG) -g2012 -o $@ $(RTL_SRCS) $(TB_DIR)/$(SIM).v
	@echo ">> Compilación finalizada."

# Crear directorio de build si no existe
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Limpiar compilados
clean:
	rm -rf $(BUILD_DIR) *.vcd
	@echo ">> Limpieza completada."
