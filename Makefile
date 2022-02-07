ifeq ($(OS), centos)
	CC = g++-4.9
	FLAGS = -std=c++11 -g -DOS_CENTOS

	ROSE_PATH = ${CURDIR}/tools/rose_build
	FLAGS += -DROSE_PATH=$(ROSE_PATH)
	BOOST_PATH = ${CURDIR}/tools/boost_build
	ROSE_INCLUDE = -I${ROSE_PATH}/include/ -I${BOOST_PATH}/include/
	ROSE_LIB = -lROSE_DLL
else
	CC = g++
	FLAGS = -std=c++11 -g

	ROSE_PATH = /usr/rose
	#BOOST_PATH = ${CURDIR}/tools/boost_build
	ROSE_INCLUDE = -I${ROSE_PATH}/include/rose #-I${BOOST_PATH}/include/
	ROSE_LIB = -lrose
endif

OBJS = obj
BIN  = bin

EXTRACTOR_PATH    = src/extractor
DRIVER_PATH       = src/driver

LE_DATA_FOLDER    = /tmp/LoopExtractor_data

DIRS := $(shell mkdir -p ${CURDIR}/$(OBJS) &&  mkdir -p ${CURDIR}/$(BIN))
  
all: extractor driver

##### EXTRACTOR #####
EXTRACTOR_COMPILE_FLAGS = -I${CURDIR}/src $(ROSE_INCLUDE)
EXTRACTOR_LD_FLAGS = -L${ROSE_PATH}/lib \
                     $(ROSE_LIB) \
                     -lboost_system  -lboost_chrono -lquadmath
                     #-L${BOOST_PATH}/lib \
                     #-lboost_iostreams -lboost_system

OBJ_EXTRACTOR = $(OBJS)/extractor.o
SRC_EXTRACTOR  = $(EXTRACTOR_PATH)/extractor.cpp 
OBJ_COMMON = $(OBJS)/common.o

extractor: $(OBJ_EXTRACTOR) $(OBJ_COMMON)

$(OBJ_EXTRACTOR): $(SRC_EXTRACTOR)
	$(CC) $(FLAGS) $(EXTRACTOR_COMPILE_FLAGS) $(SRC_EXTRACTOR) -c -o $@

$(OBJ_COMMON): src/driver/common.cpp
	$(CC) $(FLAGS) src/driver/common.cpp $(ROSE_INCLUDE) -c -o $@

##### DRIVER #####

DRIVER_COMPILE_FLAGS = $(EXTRACTOR_COMPILE_FLAGS) $(OPENCV_INCLUDE)
DRIVER_LD_FLAGS      = $(EXTRACTOR_LD_FLAGS) -pthread $(PREDICTOR_LD_FLAGS)

OBJ_DRIVER = $(OBJS)/driver.o
SRC_DRIVER = $(DRIVER_PATH)/driver.cpp 

driver: $(OBJ_DRIVER) $(OBJ_EXTRACTOR) $(OBJ_COMMON) 
	$(CC) $^ $(DRIVER_LD_FLAGS) -o $(BIN)/LoopExtractor
$(OBJ_DRIVER): $(SRC_DRIVER)
	$(CC) $(FLAGS) $(DRIVER_COMPILE_FLAGS) $(SRC_DRIVER) -c -o $@

##### CLEAN #####
clean:
	rm -f $(OBJS)/* $(BIN)/*
clean_data_folder:
	rm -rf $(LE_DATA_FOLDER)
  
.PHONY: all dirs extractor driver clean
