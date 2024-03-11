# -*- Makefile -*- for mimalloc

.SECONDEXPANSION:
.SUFFIXES:

ifneq ($(findstring $(MAKEFLAGS),s),s)
ifndef V
        QUIET          = @
        QUIET_CC       = @echo '   ' CC $<;
        QUIET_AR       = @echo '   ' AR $@;
        QUIET_RANLIB   = @echo '   ' RANLIB $@;
        QUIET_INSTALL  = @echo '   ' INSTALL $<;
        export V
endif
endif

LIB       = libmimalloc.a
AR       ?= ar
ARFLAGS  ?= rc
CC       ?= gcc
RANLIB   ?= ranlib
RM       ?= rm -f

BUILD_DIR := out
BUILD_ID  ?= default-build-id
OBJ_DIR   := $(BUILD_DIR)/$(BUILD_ID)

ifeq (,$(BUILD_ID))
$(error BUILD_ID cannot be an empty string)
endif

prefix ?= /usr/local
libdir := $(prefix)/lib
includedir := $(prefix)/include

HEADERS := $(wildcard include/*.h include/*/*.h)
SOURCES := \
	src/alloc.c \
	src/alloc-aligned.c \
	src/alloc-posix.c \
	src/arena.c \
	src/bitmap.c \
	src/heap.c \
	src/init.c \
	src/options.c \
	src/os.c \
	src/page.c \
	src/random.c \
	src/segment.c \
	src/segment-map.c \
	src/stats.c \
	src/prim/prim.c

HEADERS_INST := $(patsubst include/%,$(includedir)/%,$(HEADERS))
OBJECTS := $(patsubst %.c,$(OBJ_DIR)/%.o,$(SOURCES))

CFLAGS ?= -O2
CFLAGS += -std=c17 -Iinclude -Isrc -I$(includedir) -D_GNU_SOURCE

.PHONY: install

all: $(OBJ_DIR)/$(LIB)

$(includedir)/%.h: include/%.h | $$(@D)/.
	$(QUIET_INSTALL)cp $< $@
	@chmod 0644 $@

$(libdir)/%.a: $(OBJ_DIR)/%.a | $$(@D)/.
	$(QUIET_INSTALL)cp $< $@
	@chmod 0644 $@

install: $(HEADERS_INST) $(libdir)/$(LIB)

clean:
	$(RM) -r $(OBJ_DIR)

distclean: clean
	$(RM) -r $(BUILD_DIR)

$(OBJ_DIR)/$(LIB): $(OBJECTS) | $$(@D)/.
	$(QUIET_AR)$(AR) $(ARFLAGS) $@ $^
	$(QUIET_RANLIB)$(RANLIB) $@

$(OBJ_DIR)/%.o: %.c $(OBJ_DIR)/.cflags | $$(@D)/.
	$(QUIET_CC)$(CC) $(CFLAGS) -o $@ -c $<

.PRECIOUS: $(OBJ_DIR)/. $(OBJ_DIR)%/.

$(OBJ_DIR)/.:
	$(QUIET)mkdir -p $@

$(OBJ_DIR)%/.:
	$(QUIET)mkdir -p $@

$(libdir)/.:
	$(QUIET)mkdir -p $@

$(libdir)%/.:
	$(QUIET)mkdir -p $@

$(includedir)/.:
	$(QUIET)mkdir -p $@

$(includedir)%/.:
	$(QUIET)mkdir -p $@

TRACK_CFLAGS = $(subst ','\'',$(CC) $(CFLAGS))

$(OBJ_DIR)/.cflags: .force-cflags | $$(@D)/.
	@FLAGS='$(TRACK_CFLAGS)'; \
    if test x"$$FLAGS" != x"`cat $(OBJ_DIR)/.cflags 2>/dev/null`" ; then \
        echo "    * rebuilding mimalloc: new build flags or prefix"; \
        echo "$$FLAGS" > $(OBJ_DIR)/.cflags; \
    fi

.PHONY: .force-cflags
