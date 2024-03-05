#---------------------------------------------------------------------------------------------------
# System Programming                         I/O Lab                                    Spring 2024
#
# script to generate directory tree for testing
#
# Author: Bernhard Egger <bernhard@csap.snu.ac.kr>
#

INPUT=${0%/*}/test1.tree
MKSOCK=

if [[ -n "$1" ]]; then
  INPUT=$1
fi

if [[ ! -r $INPUT ]]; then
  echo "Cannot read from input file '$INPUT'."
  exit 1
fi

LINEC=0
FILES=0
LINKS=0
PIPES=0
SOCKS=0

echo "Generating tree from '$INPUT'..."
while read line; do
  # ignore comments
  [[ $line =~ ^#.* ]] && continue

  # split and ignore blank lines
  read -a split <<< "$line"
  [[ ${#split[*]} == 0 ]] && continue

  tokens=${#split[*]}

  let LINEC=$LINEC+1

  case ${split[0],,} in
    f) # regular file
      # [[ ${#split[*]} != 4 ]] && echo "  Ingoring invalid file spec '$line'." && continue
      [[ ${tokens} < 4 || ${tokens} > 5 ]] && echo "  Ingoring invalid file spec '$line'." && continue
      MOD=${split[4]}
      [[ ${tokens} == 4 ]] && MOD=664

      file=${split[1]}
      size=${split[2]}
      skip=${split[3]}

      mkdir -p ${file%/*} && dd if=/dev/zero of=$file bs=1 count=$size seek=$skip 2>/dev/null
      if [[ $? == 0 ]]; then
        let FILES=$FILES+1
      else
        echo "  Failed to create file '$file'."
      fi

      chmod $MOD $file

      ;;

    l) # symbolic link
      [[ ${#split[*]} != 3 ]] && echo "  Ingoring invalid link spec '$line'." && continue

      from=${split[1]}
      to=${split[2]}

      mkdir -p ${from%/*} && ln -srf $to $from
      if [[ $? == 0 ]]; then
        let LINKS=$LINKS+1
      else
        echo "  Failed to create link '$from'."
      fi

      ;;

    p) # named pipe
      [[ ${#split[*]} != 2 ]] && echo "  Ingoring invalid fifo spec '$line'." && continue

      fifo=${split[1]}

      mkdir -p ${fifo%/*} && mkfifo $fifo 2>/dev/null
      if [[ $? == 0 ]]; then
        let PIPES=$PIPES+1
      else
        echo "  Failed to create named pipe '$fifo'."
      fi

      ;;

    s) # unix socket
      [[ ${#split[*]} != 2 ]] && echo "  Ingoring invalid socket spec '$line'." && continue

      if [[ -z "$MKSOCK" ]]; then
        MKSOCK=`PATH=${0%/*}:$PATH which mksock 2>/dev/null`
        [[ ! -x "$MKSOCK" ]] && echo "  Can't find 'mksock', ignoring socket." && continue
      fi

      socket=${split[1]}

      mkdir -p ${socket%/*} && $MKSOCK $socket 2>/dev/null
      if [[ $? == 0 ]]; then
        let SOCKS=$SOCKS+1
      else
        echo "  Failed to create unix socket '$socket'."
      fi

      ;;

    *) # unknown
      echo "  Ingoring invalid line: '$line'."
      ;;
  esac

done < <(cat $INPUT)

let ERRORS=$LINEC-$FILES-$LINKS-$PIPES-$SOCKS
echo "Done. Generated $FILES files, $LINKS links, $PIPES fifos, and $SOCKS sockets. $ERRORS errors reported."

exit 0


