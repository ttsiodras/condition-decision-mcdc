all:
	gcc -g -O0 -fprofile-arcs -ftest-coverage coverage_demo.c

report:
	gcov -pcb coverage_demo.c
	cat coverage_demo.c.gcov

clean:
	rm -f coverage_demo.c.gcov coverage_demo.gcda coverage_demo.gcno a.out
