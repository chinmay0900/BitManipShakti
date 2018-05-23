### Makefile for the srio

TOP_MODULE:=mklzcounter
TOP_FILE:=lzcounter.bsv
TOP_DIR:= ./src
BSVBUILDDIR:=./build/
FILES:= ./src/:./testbench/
BSVINCDIR:= .:%/Prelude:%/Libraries:%/Libraries/BlueNoC:$(FILES)
default: full_clean compile link
.PHONY: compile
compile:
	@echo Compiling $(TOP_MODULE)....
	@mkdir -p $(BSVBUILDDIR)
	@bsc -u -sim -simdir $(BSVBUILDDIR) -bdir $(BSVBUILDDIR) -info-dir $(BSVBUILDDIR) -keep-fires -p $(BSVINCDIR) -g $(TOP_MODULE)  $(TOP_DIR)/$(TOP_FILE)
	@echo Compilation finished

.PHONY: link
link:
	@echo Linking $(TOP_MODULE)...
	@mkdir -p bin
	@bsc -e $(TOP_MODULE) -sim -o ./bin/out -simdir $(BSVBUILDDIR) -p .:%/Prelude:%/Libraries:%/Libraries/BlueNoC\
  -bdir $(BSVBUILDDIR) -keep-fires 
	@echo Linking finished

.PHONY: simulate
simulate:
	@echo Simulation...
	./out 
	@echo Simulation finished. 

.PHONY: clean
clean:
	@rm -rf build bin

.PHONY: full_clean
full_clean:
