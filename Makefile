.PHONY: all test clean

all:
	alr -n build

test: all
	tests/run.sh

clean:
	alr -n clean
	rm -rf tests/output
