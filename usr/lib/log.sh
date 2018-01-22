info()    { echo -e "\e[32m[INFO]\e[0m    $*" >&2 ; }
warning() { echo -e "\e[33m[WARNING]\e[0m $*" >&2 ; }
error()   { echo -e "\e[31m[ERROR]\e[0m   $*" >&2 ; }
fatal()   { echo -e "\e[35m[FATAL]\e[0m   $*" >&2 ; exit 1 ; }
