### HELPER FUNCTIONS ###

proc testfunction {input} { 
    ### Conversions into a binary string ###

    set bin              [binary format b5b* 10100 111000011010]
    # to a binary string <-  From binary ^

    set chr                  [binary format a7a*a alpha bravo charlie]
    # to a binary string     <-  From string
    
    set 8bit                 [binary format c3cc* {3 -3 128 1} 257 {2 5}]
    # to a binary string     <-  From integers

    set test [binary format b* 01110100 01100101 01110011 01110100 01110100 01100101 01110011 01110100 01110100 01100101 01110011 01110100 01110100 01100101 01110011 01110100 01110100 01100101 01110011 01110100 01110100 01100101 01110011 01110100 01110100 01100101 01110011 01110100 01110100 01100101 01110011 01110100]

    puts $test
    puts "len:[string length $test]"

    ### Conversions from a binary string into Tcl variables ###
    set value1 {}
    set value2 {}

    binary scan $bin b5b* value1 value2
    #                     ^ 11100    ^ 111000011010   (in tcl variables)

    binary scan $chr a* mystring
    #                    ^ alpha  bravoc

    binary scan $8bit h* myhex
    #                    ^ 30df08102050

    #binary scan $8bit c3cc* value1 value2 
    puts "value1:$value1"
    puts "value2:$value2"
    puts "mystring:$mystring"
    puts "myhex:$myhex"
    puts "bin:$bin"
    puts "chr:$chr"
}

proc score textdata {
    # takes in ascii text and scores it based on readability
    set numchars [string length $textdata]
    set textscore 0
    set i 0
    while {$i < $numchars} {
        scan [string index $textdata $i] %c asciivalue
        if {$asciivalue >= 97 && $asciivalue <= 122} {
            incr textscore 5
        } elseif {$asciivalue > 122} {
            incr textscore -2
        } elseif {
            $asciivalue == 20 ||
            $asciivalue == 33 ||
            $asciivalue == 34 ||
            $asciivalue == 39 ||
            $asciivalue == 44 ||
            $asciivalue == 46 } {
            incr textscore 2
        } elseif {
            $asciivalue == 36 ||
            $asciivalue == 37 ||
            $asciivalue == 60 ||
            $asciivalue == 62 ||
            $asciivalue == 92 ||
            $asciivalue == 93 ||
            $asciivalue == 94 ||
            $asciivalue == 95 } {
            incr textscore -2
        } elseif {
            $asciivalue == 96 } {
            incr textscore -5
        }
        incr i
    }
    format "%03d" $textscore
}

proc readfile {filename} {
    set f [open $filename r]
    return [read $f]
}

proc testb64 {} {
    set inputdata [readfile tests/b64testinput.txt]
    set assertdata [readfile tests/b64testoutput.txt]
    set myrawdata [base64 $inputdata]
    set mydata [regsub -all {\n} $myrawdata ""] ;# remove newlines from the raw output
    if {$mydata eq $assertdata} {
        puts "MATCH"
    } else {
        puts stderr {Output does not match expected.}
    }
}

### STRING OPERATIONS ###

proc base64 {inputstring {maxlen 60}} {
    # `binary` performs conversions on the bytes in a string, rather than the characters
    binary encode base64 -maxlen $maxlen $inputstring
}

proc dbase64 inputb64 {
    # decodes the string data to a string of bytes
    binary decode base64 $inputb64
}

### BINARY/HEX CONVERSIONS ###

# bin2hex
# takes a whole binary string of arbiturary length and 
# converts it to hex octets by the nibble
proc bin2hex binary {
    set binarylen [string length $binary]
    set j 1
    set hex {}
    while {$j <= $binarylen} {
        append currentnibble [string index $binary [expr $j-1]] 
        if {$j % 4 == 0} {
            append hex [nib2hex $currentnibble]
            set currentnibble {}
        } 
        incr j
    }
    set hex
}

# nib2hex
# one nibble to one hex digit
proc nib2hex nibble {
    string map {
        0000 0
        0001 1
        0010 2
        0011 3
        0100 4
        0101 5
        0110 6
        0111 7
        1000 8
        1001 9
        1010 A
        1011 B
        1100 C
        1101 D
        1110 E
        1111 F
    } $nibble
}

# hex2bin
# takes a whole string of hex of arbiturary length
# and converts it to binary by the nibble
proc hex2bin hex {

    set numchars [string length $hex]
    set i 1
    set binary {}
    while {$i <= $numchars} {
        set currenth [string index $hex [expr $i-1]] 
        append binary [hex2nib $currenth]
        set currenth {}
        incr i
    }
    set binary
}

# hex2nib
# one hex digit to one nibble
proc hex2nib hex {
    set hexdigit [string toupper $hex]
    string map {
        0 0000
        1 0001
        2 0010
        3 0011
        4 0100
        5 0101
        6 0110
        7 0111
        8 1000
        9 1001
        A 1010
        B 1011
        C 1100
        D 1101
        E 1110
        F 1111
    } $hexdigit
}

### ASCII/HEX CONVERSIONS ###

proc ascii2hex inputascii {
    binary encode hex $inputascii
}

proc hex2ascii inputhex {
    binary decode hex $inputhex
}

### BITWISE OPERATIONS ###

proc binaryxor {firstinput secondinput} {
    set numchars [string length $firstinput]
    if {$numchars != [string length $secondinput]} { 
        # Inputs must be the same length
        puts stderr {inputs are of different length}  
    }

    if {$numchars == 1} { return [expr $firstinput ^ $secondinput] }
    set i 0
    set xorbinary {}
    while {$i < $numchars} {
        set binbit [string index $firstinput $i]
        set keybit [string index $secondinput $i]
        append xorbinary [expr $binbit ^ $keybit] 
        incr i
    }
    set xorbinary
}

### CHALLENGES ###

# Challenge 1: hex to b64. beware chars > 255
proc hextobase64 inputhex {
    base64 [hex2ascii $inputhex]
}

proc base64tohex inputbase64 {
    ascii2hex [dbase64 $inputbase64]
}

puts [hextobase64 49276d206b696c6c696e6720796f757220627261696e206c696b65206120706f69736f6e6f7573206d757368726f6f6d]

# Challenge 2: Fixed XOR. takes in two equal-length buffers and produces their XOR
proc fixedxor {hexdata keydata} {
    # Break down the input hex to binary
    set hexbinary [hex2bin $hexdata]
    set keybinary [hex2bin $keydata]

    # Check inputs are the same length
    set numchars [string length $hexbinary]
    if {$numchars != [string length $keybinary]} { 
        puts stderr {inputs are of different length}  
    }

    # XOR two binary values. 1 XOR 1 = 0. 0 XOR 0 = 0, all else are 1s
    set xorbinary [binaryxor $hexbinary $keybinary]

    # convert binary to hex one nibble at a time
    return [bin2hex $xorbinary]

}

puts [fixedxor 1c0111001f010100061a024b53535009181c 686974207468652062756c6c277320657965]

# Challenge 3: Single-byte XOR cipher. In this challenge, we know that the stream of data was XOR'ed against a single
# ascii character. The goal is to find the key and decrypt the message
#   1) Convert the stream into binary
#   2) Create a key the same length as the input based off a single ascii character
#   3) Convert the key into binary
#   4) XOR the input again. If the correct key was chosen, then after translating to ascii you will get the original plaintext
#   5) Create keys in a loop to test many key possibilities
# Note: This isn't decrypting the stream, rather reading the stream in as a block and decrypting it.
# TODO: Create stream-based solution.
proc brute {targetstream {limit 3} {mode default}} {
    set keys {}
    set plaintexts {}
    set scores {}
    set numchars [string length $targetstream]
    if {$mode == "debug"} {puts "targetstream: $targetstream len: [string length $targetstream]"}
    
    # expand the stream into binary
    set binaryexpansion [hex2bin $targetstream]
    if {$mode == "debug"} {puts "targetbinary: $binaryexpansion len: [string length $binaryexpansion]"}

    # for each printable ascii character, try creating a binary key the same length as targetstream.
    # Then, xor it with the binary targetstream    
    set i 0
    while {$i < 255} {
        set testchardecimal $i
        set testchar [format %c $testchardecimal]
        if {$mode == "debug"} {puts "Testing character $i: $testchar"}

        # get the key and expands it to be the same length as the target stream
        # the while loop is based off the length of targetstream/2. WARNING: ASCII ONLY
        set keyhex {}
        set j 0
        while {$j < [expr $numchars/2]} {
            append keyhex [ascii2hex $testchar]
            incr j
        }        
        if {$mode == "debug"} {puts "key hex: $keyhex len:[string length $keyhex]"}

        # expand the key into binary
        set keybinary [hex2bin $keyhex]
        if {$mode == "debug"} {puts "key binary: $keybinary len:[string length $keybinary]"}
        if {$mode == "debug"} {puts "targbinary: $binaryexpansion len:[string length $keybinary]" }

        # xor the binary of the key with the binary of the stream
        # i.e. check and see if this is the key that was used
        set xorbinary [fixedxor $binaryexpansion $keybinary]
        set xorbinarylen [string length $xorbinary]
        if {$mode == "debug"} {puts "xorbinary : $xorbinary len:[string length $xorbinary]"}

        # convert binary to hex one nibble at a time
        set xorhex [bin2hex $xorbinary]
        if {$mode == "debug"} {puts "xorhex: $xorhex"}
        
        # now the problem is, how can you tell programmatically if the output was desirable?
        # score the plaintext based on occurence of readable characters
        set currentplaintext [hex2ascii $xorhex]
        set currenttextscore [score $currentplaintext]
        lappend plaintexts "$currentplaintext"
        lappend keys "$keyhex"
        lappend scores "$currenttextscore $i"
        incr i
    }

    set sortedscores [lsort -decreasing $scores]
    # at this point, we have a list of scored plaintexts and ours is close to the top!

    if {$mode == "debug"} {
        puts "\nscores: $scores"
        puts "\nlsort: $sortedscores"

        foreach entry $sortedscores {
            puts "{$entry} -> [lindex $plaintexts [lindex $entry 1]]"
        }
    }

    # this is just indexing into the list of plaintexts using the second value in the top sorted scores
    # because the scores and indexes are stored like this { score, idx into plaintexts arr }
    set k 1
    set guess {}
    set key {}
    while {$k <= $limit} {
        set guess [lindex $plaintexts [lindex [lindex $sortedscores [expr $k-1]] 1]]
        set key [lindex $keys [lindex [lindex $sortedscores [expr $k-1]] 1]]
        if {$mode == "debug"} { puts "brute ($k):  $guess (key: $key)" }
        incr k
    }
    return $key ;# fix: returns last key only
}

# brute 1b37373331363f78151b7f2b783431333d78397828372d363c78373e783a393b3736

# Challenge 4: Find the XOR'ed character string. "Now that the party is jumping" 
proc findxorstring {filename} {
    set filedata [readfile $filename]
    foreach line $filedata {
        puts "============================================"
        puts "Line(): $line"
        brute $line
    }
}

# findxorstring challenge-4.txt

# Challenge 5: Repeating-key XOR Encrypt
proc repeatingkeyxor {keyword inputstring} {
    set iterationsize [string length $keyword]
    # input hex and binary
    set inputlen [string length $inputstring]
    set inputhex [ascii2hex $inputstring]
    set inputbinary [hex2bin $inputhex] 
    set inputbinarylen [string length $inputbinary]
    # repeatkey
    # revisit: how to create the perfect repeatkey length on the first try?
    set repeatkey [string repeat $keyword $inputlen]
    set repeatkeyhex [ascii2hex $repeatkey]
    set repeatkeybin [hex2bin $repeatkeyhex]
    set xor {}
    set i 0
    
    while {$i < $inputbinarylen} {
        append xor [binaryxor [string index $inputbinary $i] [string index $repeatkeybin $i]]
        incr i
    }

    # return the hex of the binary xor
    return [bin2hex $xor]
}

puts [repeatingkeyxor {ICE} {Burning 'em, if you ain't quick and nimble
I go crazy when I hear a cymbal}]


proc hamming {first second {mode ascii}} {
    # bit-level hamming distance calculator
    switch -exact -- $mode {
       ascii { 
        set firsthex [ascii2hex $first]
        set firstbin [hex2bin $firsthex]

        set secondhex [ascii2hex $second]
        set secondbin [hex2bin $secondhex]

        set firstbinlen [string length $firstbin]
        set secondbinlen [string length $secondbin]
        set maxbinlen [expr $firstbinlen > $secondbinlen ? $firstbinlen : $secondbinlen]
        
        # a program shouldn't be allowed to read past the space its allocated for a string. 
        # assume that if the index $i exceeds the size of one of the below strings, the
        # bit that doesn't exist shall be treated as a 0.
        set differing 0
        set i 0
        while {$i < $maxbinlen} {  
            set b1 [string index $firstbin $i]
            set b2 [string index $secondbin $i]
            if {$b1 == ""} { set $b1 "0" } 
            if {$b2 == ""} { set $b1 "0" }
            if {$b1 != $b2} {
                incr differing
            } 
            incr i
        }
        set differing
       }
       binary { 
        set firstbin $first
        set secondbin $second
        
        set firstbinlen [string length $firstbin]
        set secondbinlen [string length $secondbin]
        set maxbinlen [expr $firstbinlen > $secondbinlen ? $firstbinlen : $secondbinlen]

        set differing 0
        set i 0
        while {$i < $maxbinlen} {  
            set b1 [string index $firstbin $i]
            set b2 [string index $secondbin $i]
            if {$b1 == ""} { set $b1 "0" } 
            if {$b2 == ""} { set $b1 "0" }
            if {$b1 != $b2} {
                incr differing
            } 
            incr i
        }
        set differing
       } 
       test {
        set firstbinstring $first
        set secondbinstring $second

        set firstbinstringlen [string length $firstbinstring]
        set secondbinstringlen [string length $secondbinstring]
    
        set firstbin [binary format b$firstbinstringlen $firstbinstring]
        set secondbin [binary format b$secondbinstringlen $secondbinstring]
        puts "firstbin:$firstbin"
        puts "firstbin:$firstbin"
        puts "xor:[expr $firstbin ^ $secondbin]"


       }
       default { 
           puts stderr {mode not implemented}
        }
    }
}

proc stringsplit {string index} {
    # splits a string up into parts by an index
    # e.g. "abcdefg" 3 -> "abc def g"
    set i 0
    set stringlen [string length $string]
    while {$i < $stringlen} {
        lappend splititems [string range $string $i [expr $i+$index-1]]
        incr i $index
    }
    set splititems
}

# Challenge 6: Break repeating-key XOR. Filename should point to a line-oriented list of encrypted-then-base64 encoded values.
proc xorpwned {filename} {
    set filedata [readfile $filename]
    set filelen [string length $filedata]
    set filestring [dbase64 $filedata]
    set keysize 2
    # if {$filelen % 8 != 0} {puts stderr {not an order of 8}}

    set normalizeddistances {}
    while {$keysize <= 40} {
        # compute the edit distance/Hamming distance (number of differing bits)
        # go one by one, check if the bits are differing, if so, count it

        #puts "ham1: [string range $filestring 0 [expr $keysize-1]] ham2: [string range $filestring $keysize [expr {$keysize*2-1}]]"
        set hamdist [hamming \
                    [string range $filestring 0 [expr $keysize-1]] \
                    [string range $filestring $keysize [expr $keysize*2-1]]]
        
        lappend normalizeddistances "[expr {$hamdist / $keysize}] $keysize"
        incr keysize 2
    }
    
    # the most likely key sizes, in order
    set keysizes [lsort $normalizeddistances]
    puts $keysizes 

    # break the ciphertext into blocks of keysize length
    foreach hamkeypair $keysizes {
        puts "current hamkeypair: $hamkeypair"
        set normalizedvalue [lindex $hamkeypair 0]
        set size [lindex $hamkeypair 1] ;# size of the key
        puts "keysize: $size"
        if {$size eq 18 || $size eq 2} {continue }
        if {$normalizedvalue < 3} { ;# if the key looks good
            puts "looks good! "
            set fileblocks [stringsplit $filestring $size]    
                ;# [ a number at a particular index in $fileblocks]
                ;# [ signifies the how many back to back pieces of ]
                ;# [ plaintext there are. Smaller key = more pieces ]

            set fileblockscount [llength $fileblocks] ;# 160
            puts "fileblockscount: $fileblockscount"
                ;# make a block that is the first byte of every block and
                ;# a block that is the second byte of every block and so on.
                ;# Take advantage of knowledge that the key repeats itself.

            set transposedblocks {}
            set transpose {}
            set i 0
            set j 0
            while {$j < $size} {
                ;# iterate through this keysize
                while {$i < $fileblockscount} {
                    ;# in each block take out the jth byte
                    set block [lindex $fileblocks $i]
                    append transpose [ascii2hex [string index $block $j]]
                    #append transpose 1
                    #puts "transpose ($i): $transpose"
                    incr i
                }
                lappend transposedblocks "$transpose"
                puts "transpose: $transpose"
                puts "transpose size: [string length $transpose]"
                puts "transposedblocks size: [llength $transposedblocks]"
                set transpose {}
                set i 0
                incr j
            }
            
            ;# go down one-by-one in the transposed blocks and figure out the corresponding keybyte
            ;# format the final key and apply it to the original plaintext 
            set transposedblockscount [llength $transposedblocks]
            set keybyte {}
            set i 0
            while {$i < $transposedblockscount} {
                ;# each time this finishes, the most likely key for the block is returned
                puts "========== Round $i ============"
                set keyblock [brute [lindex $transposedblocks $i] 1]
                append keybyte [string range $keyblock 0 1]
                incr i
            }
            puts  $keybyte
            
        }
    }  
    


    # solve each block as if it was single-character XOR
}


#puts [hamming {this is a test} {wokka wokka!!!} ]
#puts [hamming {karolin} {kerstin} ]
#puts [hamming {11011001} {10011101} test]
#puts [hamming {BDBF} {PHU5} base64]
#puts [hex2ascii 6f6c6e696f636f6969636f6f6e6f656f7478]
#puts [hex2ascii 3232]
#xorpwned challenge-6.txt


#testb64
testfunction 01001001