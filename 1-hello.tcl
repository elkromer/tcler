puts "argv0: $argv0 argc: $argc argv: $argv"

proc getName {} {
    return "puts"
}

puts {Hello TCL!}

set fname {Reese }
set sname {Krome}
puts $fname$sname

# compute proc name
[getName] {Is this even coding?}

