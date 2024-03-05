#---------------------------------------------------------------------------------------------------
# System Programming                         I/O Lab                                    Spring 2024
#
# Makefile
#
# GNU make documentation: https://www.gnu.org/software/make/manual/make.html
#
# You shouldn't have to modify anything in this Makefile unless you add new source files.
#

#--- variable declarations

# directories
SRC_DIR=src
OBJ_DIR=obj
DEP_DIR=.deps

# C compiler and compilation flags
CC=gcc
CFLAGS=-Wall -Wno-stringop-truncation -O2 -g
CFLAGS_HDT=-Wall -Wno-stringop-truncation -O2
DEPFLAGS=-MMD -MP -MT $@ -MF $(DEP_DIR)/$*.d

# make sure SOURCES includes ALL source files required to compile the project
SOURCES=dirtree.c
TARGET=dirtree

# derived variables
OBJECTS=$(SOURCES:%.c=$(OBJ_DIR)/%.o)
DEPS=$(SOURCES:%.c=$(DEP_DIR)/%.d)


#--- rules
.PHONY: doc

all: $(TARGET)

$(TARGET): $(OBJECTS)
	$(CC) $(CFLAGS) -o $@ $^

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c | $(DEP_DIR) $(OBJ_DIR)
	$(CC) $(CFLAGS) $(DEPFLAGS) -o $@ -c $<

$(DEP_DIR):
	@mkdir -p $(DEP_DIR)

$(OBJ_DIR):
	@mkdir -p $(OBJ_DIR)

-include $(DEPS)

doc: $(SOURES:%.c=$(SRC_DIR)/%.c) $(wildcard $(SOURCES:%.c=$(SRC_DIR)/%.h))
	doxygen doc/Doxyfile

clean:
	rm -rf $(OBJ_DIR) $(DEP_DIR)

mrproper: clean
	rm -rf $(TARGET) doc/html
