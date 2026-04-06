ASM      = nasm
LD       = ld
ASMFLAGS = -f elf64 -g

SRC      = main.asm
OBJ      = main.o
BIN      = main

.PHONY: build run check clean

build: $(BIN)

$(BIN): $(OBJ)
	$(LD) -o $@ $^

$(OBJ): $(SRC)
	$(ASM) $(ASMFLAGS) -o $@ $<

run: build
	./$(BIN)

check: build
	./$(BIN) > actual.txt
	diff -u expected_output actual.txt && echo "PASS" || (echo "FAIL"; rm -f actual.txt; exit 1)
	@rm -f actual.txt

clean:
	rm -f $(OBJ) $(BIN) actual.txt
