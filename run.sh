#!/bin/sh

if [ $1 == "build" ]; then
	make clean; make
	hadoop-moonshot jar dist/WordCount.jar WordCount input out
elif [ $1 == "clean" ]; then
	rm -rf out/
fi
