OBJECTS = main.o csr.o adj.o 
FLAGS = -lrt -openmp -DUSE_OMP 
debug=1
CC=icc
EXE=pagerank.out

ifeq (${debug}, 1)
  FLAGS += -g -O3 -DUSE_DEBUG
else
  FLAGS += -O3 
endif

ifeq (${omp}, 1)
  FLAGS += -DUSE_OMP
endif

INC = #-I/opt/intel/vtune_amplifier_xe_2013/include/
LIB = 
$(EXE): $(OBJECTS)
	$(CC) $(FLAGS) $(LIB) $(INC) -o $(EXE) $(OBJECTS) #/opt/intel/vtune_amplifier_xe_2013/lib64/libittnotify.a

main.o : main.c graph.h
	$(CC) $(FLAGS) $(LIB) $(INC) -c main.c
csr.o : csr.c graph.h
	$(CC) $(FLAGS) $(LIB) $(INC) -c csr.c
adj.o : adj.c graph.h
	$(CC) $(FLAGS) $(LIB) $(INC) -c adj.c

clean :
	rm -f $(OBJECTS) $(EXE)
