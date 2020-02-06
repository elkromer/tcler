parray tcl_platform
set input [encoding convertto utf-8 "Æ"]
binary scan $input h* list
puts stdout $list