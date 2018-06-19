
Read the following, keeping these in mind:

- Statement is a complete line of code
- Conditions and decisions: inside...

```c
    if (a > 1 && b == 0) { 
```

...the `a > 1` part is a condition - i.e. a part of a decision 
(which in this case is comprised of two conditions).

- Branch (at least in terms of the discussion that follows - i.e. in terms
  of what GCOV describes as a branch) is a condition being checked at object
  code level. A branch therefore exists at any instruction like `ble` (branch
  if less or equal, etc)

Given the context above...

To get 100% decision coverage every decision in the program must take all
possible outcomes at least once. Given that in the code we have two decisions...

```c
    if (a > 1 && b == 0) { 
        puts("Decision 1 was true");
    } else {
        puts("Decision 1 was false");
    } 

    if (a == 2 || x > 1) { 
        puts("Decision 2 was true");
    } else {
        puts("Decision 2 was false");
    } 
```

...we need test cases that make those decisions true and false.  For example, we
could have the following test cases:

    a=3, b=0, x=2 → a > 1 && b == 0 (T), a == 2 || x > 1 (T)
    a=1, b=0, x=1 → a > 1 && b == 0 (F), a == 2 || x > 1 (F)

    $ make decision
    ...
    ./coverage_demo 3 0 2
    Decision 1 was true
    Decision 2 was true

    ./coverage_demo 1 0 1
    Decision 1 was false
    Decision 2 was false
    ...
    
Both decisions are exercised to be both true and false.

But notice in the gcov annotated output that all stmts are executed (there are
no `####` reported in any source line in the gcov output, we have 100%
statement coverage).  But there ARE branches (i.e. object-code-level
conditions) that were never executed (because these conditions were never
exercised - e.g. `b` was always 0! Look at the last branch counter, i.e. branch
3 of line 10:

```c
        2:   10:    if (a > 1 && b == 0) {
    branch  0 taken 1 (fallthrough)
    branch  1 taken 1
    branch  2 taken 1 (fallthrough)
    branch  3 taken 0
        1:   11:        puts("Decision 1 was true");
```

That is, the object code generated to represent the checking of condition `b==0`
NEVER evaluated the condition as false. This means we don't have 100% condition
coverage.

Now, if we want to get 100% condition coverage, every condition in a decision
in the program must take all possible outcomes at least once. In the code we
have 4 conditions `a > 1`, `b == 0`, `a == 2`, `x > 1`. We need test cases that make
all 4 of the conditions true and false. The previous test cases don’t suffice
because e.g. the condition `b == 0` is never evaluated to false. That could mean
an untested critical scenario that could have a bug. 

To achieve 100% condition coverage we could have the following test cases:

    a = 1, b = 0, x = 2 → a > 1(F), b == 0(T), a == 2(F), x > 1(T)
    a = 2, b = 1, x = 1 → a > 1(T), b == 0(F), a == 2(T), x > 1(F)

    $ make condition
    ...
    ./coverage_demo 1 0 2
    Decision 1 was false
    Decision 2 was true
    ./coverage_demo 2 1 1
    Decision 1 was false
    Decision 2 was true

Now each condition has been both true and false, but overall, decision 1
was NEVER true - because its two conditions were once FT, and once TF.
Since the decision is formed from a logical AND (`&&`) of the two conditions,
it was never evaluated as true.

The gcov output indicates this, in that...

(a) the stmt coverage is not 100% - notice the `#####`:

```c
        2:   10:    if (a > 1 && b == 0) {
    branch  0 taken 1 (fallthrough)
    branch  1 taken 1
    branch  2 taken 0 (fallthrough)
    branch  3 taken 1
        #####:   11:        puts("Decision 1 was true");
    call    0 never executed
        -:   12:    } else {
        2:   13:        puts("Decision 1 was false");
```

(b) ...and the branch coverage is also not 100%, since the FINAL branch
in the object code (the one that says *"we've evaluated to true,
let's execute the `then` action of the `if`"*) is also not executed
(see above, branch 2 is taken 0 times).

Since both types of coverage are important and one does not guarantee
satisfying the other, in practice they are typically combined, and that is
called condition decision coverage. For this level of coverage we could have
the following test cases:

    a = 1, b = 1, x = 1 → a > 1(F), b == 0(F), a == 2(F), x > 1(F)
    a = 2, b = 0, x = 2 → a > 1(T), b == 0(T), a == 2(T), x > 1(T)

    $ make conditiondecision
    ...
    ./coverage_demo 1 1 1
    Decision 1 was false
    Decision 2 was false
    ./coverage_demo 2 0 2
    Decision 1 was true
    Decision 2 was true

Now, notice that although these cases would provide both levels of coverage
some conditions are being masked and therefore never evaluated.

```c
        2:   10:    if (a > 1 && b == 0) { 
branch  0 taken 1 (fallthrough)
branch  1 taken 1
branch  2 taken 1 (fallthrough)
branch  3 taken 0
        1:   11:        puts("Decision 1 was true");
```

gcov indicates this, since there are branches that are still, never executed.

For example, `a = 1` masks the condition `b == 0` in the decision `(a > 1 && b == 0)`
because it makes the condition `a > 1` false and therefore the executable
doesn't need to evaluate the other condition to determine the outcome of the
AND expression. These are the 'short-circuit' semantics of the C language.

Hence, we need to modify the test cases to ensure the coverage of masking
conditions, and that's called modified condition decision coverage (MCDC):
every condition in a decision has been shown to independently affect that
decision’s outcome. The test cases below satisfy MCDC coverage and therefore
also satisfy decision coverage and condition coverage:

    a = 2, b = 0, x = 1 → a > 1 && b == 0 (T), a == 2 || x > 1 (T)
    a = 3, b = 1, x = 2 → a > 1 && b == 0 (F), a == 2 || x > 1 (T)
    a = 1, b = 0, x = 1 → a > 1 && b == 0 (F), a == 2 || x > 1 (F)

    $ make mcdc

At which point, all statements are executed, and all branches are reported
as executed by gcov:

    $ make mcdc  | grep branch
    branch  0 taken 2 (fallthrough)
    branch  1 taken 1
    branch  2 taken 1 (fallthrough)
    branch  3 taken 1
    branch  0 taken 2 (fallthrough)
    branch  1 taken 1
    branch  2 taken 1 (fallthrough)
    branch  3 taken 1

*The content above is based on [a nice (but slightly buggy) Quora article](https://www.quora.com/What-is-the-difference-between-decision-coverage-and-condition-coverage-when-it-comes-to-code-coverage).*
