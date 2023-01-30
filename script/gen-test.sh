# args: -I examples examples/file.proto
# set -ex
DEST_DIR=gen

# iterate args, skipping '-I examples'
state="start"
inc=""

for arg in $@; do
  if [[ $arg == "-I" ]]; then
    state="-I"
  elif [[ $state == "-I" ]]; then
    state=""
    inc=$arg
  else
    arg=${arg#$inc/} # remove $inc/ prefix
    FILE="$DEST_DIR/${arg%.*}.pb.zig" # replace the extension, add $DEST_DIR prefix
    CMD="zig test -lc -I$DEST_DIR $FILE --pkg-begin protobuf src/lib.zig --pkg-begin protobuf src/lib.zig --pkg-end -freference-trace=20"
    echo $CMD
    $($CMD)
    FILE="$DEST_DIR/${arg%.*}.pb.c" # replace the extension, add $DEST_DIR prefix
    CMD="zig build-lib -lc -I$DEST_DIR $FILE -femit-bin=/tmp/tmp.a"
    echo $CMD
    $($CMD)
  fi
done
