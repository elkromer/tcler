# string map crypto
set plaintext {1400 hours Port Laguna pier 11A. Bring no one.}

# encryption key
set keymap {
    14 3ȗfc 
    00 a 
    our z&* 
    s 765x0p:--12335
    o c
    Br 1
    ng 3aǾa
    . u
    La **Ƹûǆ
    pie cru$t
}

# encryption
set ciphertext [string map $keymap $plaintext]

puts stdout $ciphertext

# really only one-way is easy at first glance

set ladyanna "a young women of noble birth"
puts [append ladyanna "... a tragedy"]