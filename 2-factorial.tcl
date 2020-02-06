proc Factorial {x} {
    set i 1; set product 1;
    while {$i <= $x} {
        set product [expr {$product * $i}]
        incr i
    }
    return $product
}

proc rFactorial {x} {
    if {$x <= 1} {
        return 1
    } else {
        return [expr {$x * [rFactorial [expr {$x - 1}]]}]
    }
}

puts [Factorial 10]
puts [rFactorial 10]