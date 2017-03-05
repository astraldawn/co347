
# distributed algorithms, n.dulay, 4 jan 17
# simple build and run makefile, v1

.SUFFIXES: .erl .beam

MODULES  = client server database system replica acceptor scout leader commander
HOSTS    = 3
HOSTSm1  = 2

# BUILD =======================================================

ERLC	= erlc -o ebin

ebin/%.beam: %.erl
	$(ERLC) $<

all:	ebin ${MODULES:%=ebin/%.beam} 

ebin:	
	mkdir ebin

debug:
	erl -s crashdump_viewer start 

.PHONY: clean
clean:
	rm -f ebin/* erl_crash.dump

# LOCAL RUN ===================================================

SYSTEM    = system

L_HOST    = localhost.localdomain
L_ERL     = erl -smp enable -noshell -pa ebin -setcookie pass
L_ERL_SINGLE = erl -smp disable -noshell -pa ebin -setcookie pass
L_ERLNODE = node

run:	all
	$(L_ERL) -s $(SYSTEM) start

run-single: all
	$(L_ERL_SINGLE) -s $(SYSTEM) start
