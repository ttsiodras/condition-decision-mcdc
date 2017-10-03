coverage_demo:
	gcc -g -O0 -fprofile-arcs -ftest-coverage -o $@ coverage_demo.c

report:	coverage_demo
	$(MAKE)
	gcov -pcb coverage_demo.c
	cat coverage_demo.c.gcov

decision: coverage_demo
	$(MAKE) clean
	$(MAKE)
	./coverage_demo 3 0 2
	./coverage_demo 1 0 1
	$(MAKE) report

condition: coverage_demo
	$(MAKE) clean
	$(MAKE)
	./coverage_demo 1 0 2
	./coverage_demo 2 1 1
	$(MAKE) report

conditiondecision: coverage_demo
	$(MAKE) clean
	$(MAKE)
	./coverage_demo 1 1 1
	./coverage_demo 2 0 2
	$(MAKE) report
		
mcdc:	coverage_demo
	$(MAKE) clean
	$(MAKE)
	./coverage_demo 2 0 1
	./coverage_demo 3 1 2
	./coverage_demo 1 0 1
	$(MAKE) report

clean:
	rm -f coverage_demo.c.gcov coverage_demo.gcda coverage_demo.gcno coverage_demo
