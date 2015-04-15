DIR_SRC = ../../../Source/FFGLPlugins
DIR_COMMON = ../../../Source/Common

DEBUG = 0

FFGLBARSHIFT_SRCS = $(DIR_SRC)/FFGLBarshift/FFGLBarshift.cpp
FFGLCHROMAKEY_SRCS = $(DIR_SRC)/FFGLChromaKey/FFGLChromaKey.cpp
FFGLEDGEDETECTION_SRCS = $(DIR_SRC)/FFGLEdgeDetection/FFGLEdgeDetection.cpp
FFGLPOLARCOORDINATES_SRCS = $(DIR_SRC)/FFGLPolarCoordinates/FFGLPolarCoordinates.cpp
FFGLSTATIC_SRCS = $(DIR_SRC)/FFGLStatic/FFGLStatic.cpp
FFGLSTATICSOURCE_SRCS = $(DIR_SRC)/FFGLStatic-source/FFGLStaticSource.cpp
FFGLSTOPMOTION_SRCS = $(DIR_SRC)/FFGLStopMotion/FFGLStopMotion.cpp
FFGLSTROBOSCOPE_SRCS = $(DIR_SRC)/FFGLStroboscope/FFGLStroboscope.cpp
FFGLSTROBOSCOPEFX_SRCS = $(DIR_SRC)/FFGLStroboscope-effect/FFGLStroboscopeEffect.cpp
FFGLWAVEWARP_SRCS = $(DIR_SRC)/FFGLWaveWarp/FFGLWaveWarp.cpp

FFGLBARSHIFT_OBJS = $(notdir $(FFGLBARSHIFT_SRCS:%cpp=%o))
FFGLCHROMAKEY_OBJS = $(notdir $(FFGLCHROMAKEY_SRCS:%cpp=%o))
FFGLEDGEDETECTION_OBJS = $(notdir $(FFGLEDGEDETECTION_SRCS:%cpp=%o))
FFGLPOLARCOORDINATES_OBJS = $(notdir $(FFGLPOLARCOORDINATES_SRCS:%cpp=%o))
FFGLSTATIC_OBJS = $(notdir $(FFGLSTATIC_SRCS:%cpp=%o))
FFGLSTATICSOURCE_OBJS = $(notdir $(FFGLSTATICSOURCE_SRCS:%cpp=%o))
FFGLSTOPMOTION_OBJS = $(notdir $(FFGLSTOPMOTION_SRCS:%cpp=%o))
FFGLSTROBOSCOPE_OBJS = $(notdir $(FFGLSTROBOSCOPE_SRCS:%cpp=%o))
FGLSTROBOSCOPEFX_OBJS = $(notdir $(FFGLSTROBOSCOPEFX_SRCS:%cpp=%o))
FFFGLWAVEWARP_OBJS = $(notdir $(FFGLWAVEWARP_SRCS:%cpp=%o))

COMMON_SRCS = $(DIR_SRC)/FFGLPluginInfo.cpp $(DIR_SRC)/FFGLPluginInfoData.cpp \
	$(DIR_SRC)/FFGL.cpp $(DIR_COMMON)/FFGLShader.cpp \
	$(DIR_COMMON)/FFGLExtensions.cpp \
	$(DIR_SRC)/FFGLPluginManager.cpp $(DIR_SRC)/FFGLPluginSDK.cpp \
	$(DIR_SRC)/../Common/utilities.cpp

COMMON_OBJS = $(notdir $(COMMON_SRCS:%cpp=%o))

OBJS = $(COMMON_OBJS) \
	$(FFGLBARSHIFT_OBJS) $(FFGLCHROMAKEY_OBJS) $(FFGLEDGEDETECTION_OBJS) \
	$(FFGLPOLARCOORDINATES_OBJS) $(FFGLSTATIC_OBJS) \
	$(FFGLSTATICSOURCE_OBJS) $(FFGLSTOPMOTION_OBJS) \
	$(FFGLSTROBOSCOPE_OBJS) $(FFGLSTROBOSCOPEFX_OBJS) $(FFGLWAVEWARP_OBJS)

vpath %.cpp $(DIR_SRC)/FFGLBarshift:$(DIR_SRC)/FFGLChromaKey:\
	$(DIR_SRC)/FFGLEdgeDetection:\
	$(DIR_SRC)/FFGLPolarCoordinates:\
	$(DIR_SRC)/FFGLStatic:\
	$(DIR_SRC)/FFGLStatic-source:\
	$(DIR_SRC)/FFGLStopMotion:\
	$(DIR_SRC)/FFGLStroboscope:\
	$(DIR_SRC)/FFGLStroboscope-effect:\
	$(DIR_SRC)/FFGLWaveWarp:\
	$(DIR_SRC):$(DIR_COMMON)

CCPP = @g++
CPPFLAGS = -Wall -Wno-unknown-pragmas -pedantic -fPIC \
	-I../../../Include -I../../../Source/Common

CSHLIB = $(CCPP) $(CPPFLAGS) -shared -Wl,-soname,$@ -o $@ $^ \
	-lc -lX11 -lGL -lglut

ifeq ($(DEBUG), 1)
	CPPFLAGS += -ggdb2 -O0 -D_DEBUG=1
else
	CPPFLAGS += -g0 -O3
endif

all: FFGLBarshift.so FFGLChromaKey.so FFGLEdgeDetection.so FFGLPolarCoordinates.so FFGLStatic.so FFGLStaticSource.so FFGLStopMotion.so FFGLStroboscope.so FFGLStroboscopeEffect.so FFGLWaveWarp.so

%.o: %.cpp
	$(CCPP) -c $(CPPFLAGS) -o $@ $<

FFGLBarshift.so: $(FFGLBARSHIFT_OBJS) $(COMMON_OBJS)
	$(CSHLIB)

FFGLChromaKey.so: $(FFGLCHROMAKEY_OBJS) $(COMMON_OBJS)
	$(CSHLIB)

FFGLEdgeDetection.so: $(FFGLEDGEDETECTION_OBJS) $(COMMON_OBJS)
	$(CSHLIB)

FFGLPolarCoordinates.so: $(FFGLPOLARCOORDINATES_OBJS) $(COMMON_OBJS)
	$(CSHLIB)

FFGLStatic.so: $(FFGLSTATIC_OBJS) $(COMMON_OBJS)
	$(CSHLIB)

FFGLStaticSource.so: $(FFGLSTATICSOURCE_OBJS) $(COMMON_OBJS)
	$(CSHLIB)

FFGLStopMotion.so: $(FFGLSTOPMOTION_OBJS) $(COMMON_OBJS)
	$(CSHLIB)

FFGLStroboscope.so: $(FFGLSTROBOSCOPE_OBJS) $(COMMON_OBJS)
	$(CSHLIB)

FFGLStroboscopeEffect.so: $(FFGLSTROBOSCOPEFX_OBJS) $(COMMON_OBJS)
	$(CSHLIB)

FFGLWaveWarp.so: $(FFGLWAVEWARP_OBJS) $(COMMON_OBJS)
	$(CSHLIB)

.PHONY: clean

clean:
	-rm -rf $(OBJS) *.so
