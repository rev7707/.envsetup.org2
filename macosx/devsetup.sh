#!/bin/bash

PS1="\[\e[0;34m\]\u@\h\[\e[m\] \[\e[1;34m\]\w\[\e[m\] \`ruby -e \"print (%x{git branch 2> /dev/null}.split(%r{\n}).grep(/^\*/).first || '').gsub(/^\* (.+)$/, '(\1) ')\"\`\[\e[0;34m\]\$ \[\e[m\]\[\e[0;34m\]"

alias make.ctags='ctags -B -F -R --languages=C,C++,Sh,Make --exclude="^out"'
alias make.cscope='$envsetup/makecscope.sh'
alias make.filelist='rm filelist'
alias make.allDBs='make.ctags; make.cscope; make.filelist'

function alias.function() {
  local T=~/.envsetup
  local A=""
  for i in `cat $T/macosx/devsetup.sh | sed -n "/^function /s/function \([a-z_.]*\).*/\1/p" | sort`; do
    A="$A $i"
  done
  echo "all function : $A"
}

function DEBUG_echo()
{
  #echo $@
  echo $@ 1>/dev/null
}

function ls.component.needs()
{
  local Target=`echo $@ | sed -e "s/^.*\///"`
  local T=$OUT/symbols/system
  local FullPath=`find $T -name $Target`
  DEBUG_echo "FullPath: $FullPath"
  for i in `find $T -name $Target`; do
  DEBUG_echo "i: $i"
    $ANDROID_TOOLCHAIN/arm-linux-androideabi-readelf -Wa $i 2>/dev/null | grep NEEDED | sed -e "s/^.*library: / /" | sort
  done
}

function ls.component.owners()
{
  local Target=`echo $@ | sed -e "s/^.*\///"`
  local T=$OUT/symbols/system
  local Tbin=$T/bin
  local Tlib=$T/lib
  local AllBinaries=`find $Tbin -type f`
  local AllLibraries=`find $Tlib -name "*.so"`
  DEBUG_echo "check AllBinaries"
  for i in $AllBinaries; do
    DEBUG_echo "i: $i"
    result=`ls.component.needs $i | grep "\<$Target\>"`
    if [ $? == 0 ]; then
      echo $i | sed -e "s/^.*system/ system/"
    fi
  done
  DEBUG_echo "check AllLibraries"
  for i in $AllLibraries; do
    DEBUG_echo "i: $i"
    result=`ls.component.needs $i | grep "\<$Target\>"`
    if [ $? == 0 ]; then
      DEBUG_echo $i
      echo $i | sed -e "s/^.*\/system/ system/"
    fi
  done
}

function ls.component.relation()
{
  if [ $# = 1 ]; then
    echo ""
    echo "*** Owners of the component $@"
    ls.component.owners $@
    echo ""
    echo "*** Component $@ needs shared libraries below..."
    ls.component.needs $@
    echo ""
  else
    echo "function ls.component.relation"
    echo "Usage: ls.component.relation shared_library (or executable)"
    echo "    example) ls.component.relation mediaserver"
    echo "    example) ls.component.relation libaudioflinger.so"
  fi
}

echo ~/.envsetup/$os/devsetup.sh sourced!!!
