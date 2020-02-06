set foo filename
set object $foo.o
puts $object

set bar {yuk}
set x ${bar}y
puts $x

puts [if {[info exists x]} { set x } else { set y "test" }]
#puts [if {[info exists x]} { set x } else { set y "test" }]