TARGET_EXEC:=zelda3de.html
ROM:=tables/zelda3.sfc
SRCS:=$(wildcard src/*.c snes/*.c) third_party/gl_core/gl_core_3_1.c third_party/opus-1.3.1-stripped/opus_decoder_amalgam.c
OBJS:=$(SRCS:%.c=%.o)
PYTHON:=/usr/bin/env python3
CFLAGS:=$(if $(CFLAGS),$(CFLAGS),-O3 -Werror) -I .
CFLAGS:=${CFLAGS} -DSYSTEM_VOLUME_MIXER_AVAILABLE=0

CFLAGS += -flto -fno-rtti -fno-exceptions
CFLAGS += -sUSE_SDL=2
CFLAGS += -sUSE_SDL_IMAGE=2
CFLAGS += -sUSE_SDL_MIXER=2
CFLAGS += -sSDL2_IMAGE_FORMATS='["png"]'
CFLAGS += -sSDL2_MIXER_FORMATS='["opus"]'

LDFLAGS += $(CFLAGS)
#LDFLAGS += -flto -fno-rtti -fno-exceptions
LDFLAGS += -sASYNCIFY -sASYNCIFY_ONLY=["main","SdlRenderer_EndDraw","SDL_Delay","SDL_GL_SwapWindow","GLES2_RenderPresent","Emscripten_GLES_SwapWindow","dynCall_v"] -sASYNCIFY_IGNORE_INDIRECT
LDFLAGS += -sENVIRONMENT=web
LDFLAGS += --preload-file zelda3_assets.dat --preload-file zelda3.ini
LDFLAGS += --closure 1

ifeq (${OS},Windows_NT)
    WINDRES:=windres
    RES:=zelda3.res
    SDLFLAGS:=-Wl,-Bstatic $(shell sdl2-config --static-libs)
else
    #SDLFLAGS:=$(shell sdl2-config --libs) -lm
endif

.PHONY: all clean clean_obj clean_gen

all: $(TARGET_EXEC) zelda3_assets.dat
$(TARGET_EXEC): $(OBJS) $(RES)
	$(CC) $^ -o $@ $(LDFLAGS) $(SDLFLAGS)
%.o : %.c
	$(CC) -c $(CFLAGS) $< -o $@

$(RES): src/platform/win32/zelda3.rc
	@echo "Generating Windows resources"
	@$(WINDRES) $< -O coff -o $@

zelda3_assets.dat:
	@echo "Extracting game resources"
	$(PYTHON) assets/restool.py --extract-from-rom

clean: clean_obj clean_gen
clean_obj:
	@$(RM) $(OBJS) $(TARGET_EXEC)
clean_gen:
	@$(RM) $(RES) zelda3_assets.dat tables/zelda3_assets.dat tables/*.txt tables/*.png tables/sprites/*.png tables/*.yaml
	@rm -rf tables/__pycache__ tables/dungeon tables/img tables/overworld tables/sound
