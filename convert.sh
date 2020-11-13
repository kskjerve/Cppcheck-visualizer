#!/bin/sh
/cppcheck/cppcheck --dump --suppress=uninitvar --suppress=uninitStructMember --std=c89 $1
xslt -xsl:/viz/dump2dot.xsl -s:$1.dump -o:$1.dot
dot -T svg $1.dot > $1.svg
echo Wrote $1.svg