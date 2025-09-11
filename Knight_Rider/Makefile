# Compilador Verilog
IVERILOG = iverilog
VVP = vvp

# Carpetas
SRC = src
TB = tb
WAVES = waves

# Opciones
FLAGS = -Wall

# Reglas
all: decoder3to8 counter4 fsm2 knight_rider

decoder3to8:
	$(IVERILOG) $(FLAGS) -o tb_decoder3to8.out $(SRC)/decoder3to8.v $(TB)/tb_decoder3to8.v
	$(VVP) tb_decoder3to8.out
	mv *.vcd $(WAVES)/

counter4:
	$(IVERILOG) $(FLAGS) -o tb_counter4.out $(SRC)/counter4.v $(TB)/tb_counter4.v
	$(VVP) tb_counter4.out
	mv *.vcd $(WAVES)/

fsm2:
	$(IVERILOG) $(FLAGS) -o tb_fsm2.out $(SRC)/fsm2.v $(TB)/tb_fsm2.v
	$(VVP) tb_fsm2.out
	mv *.vcd $(WAVES)/

knight_rider:
    $(IVERILOG) $(FLAGS) -o tb_knight_rider.out $(SRC)/knight_rider.v $(SRC)/counter4.v $(SRC)/fsm2.v $(SRC)/decoder3to8.v $(TB)/tb_knight_rider.v
    $(VVP) tb_knight_rider.out
    mv *.vcd $(WAVES)/

# Limpieza de compilados
clean:
	rm -f *.out $(WAVES)/*.vcd
