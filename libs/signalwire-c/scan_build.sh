#!/bin/bash
cd /__w/signalwire-c/signalwire-c
sed -i '/cotire/d' ./CMakeLists.txt
sed -i '/cotire/d' ./swclt_test/CMakeLists.txt
mkdir -p scan-build
scan-build-7 -o ./scan-build/ cmake .
scan-build-7 -o ./scan-build/ make -j`nproc --all` |& tee ./scan-build-result.txt
exitstatus=${PIPESTATUS[0]}
echo "*** Exit status is $exitstatus";
export SubString="scan-build: No bugs found";
export COMPILATION_FAILED=false;
export BUGS_FOUND=false;
if [ "0" -ne $exitstatus ] ; then
  export COMPILATION_FAILED=true;
  echo MESSAGE="compilation failed" >> $GITHUB_OUTPUT;
fi
export RESULTFILE="/__w/signalwire-c/signalwire-c/scan-build-result.txt";
cat $RESULTFILE;
if ! grep -sq "$SubString" $RESULTFILE; then
  export BUGS_FOUND=true;
  echo MESSAGE="found bugs" >> $GITHUB_OUTPUT;
fi
echo "COMPILATION_FAILED=$COMPILATION_FAILED" >> $GITHUB_OUTPUT;
echo "BUGS_FOUND=$BUGS_FOUND" >> $GITHUB_OUTPUT;
if [ "0" -ne $exitstatus ] || ! grep -sq "$SubString" $RESULTFILE; then
  exit 1;
fi
exit 0;