# AARCH64 Basics

`aarch64` is not a complicated instruction set but is slightly unconventional
if you are only used to x86, that's because `aarch64` is a load and store ISA
which means that data processing instructions always operate on registers.
So values will always be moved from and into the stack between operations
unlike x86 where you can operate on memory addresses directly.

It is highly recommended to read the ARM docs Learn the Architecture section
[ARM64 - Learn The Architecture Guide](https://developer.arm.com/documentation/102374/0101).

### The Stack

The stack is a region of virtual memory that is used to for local and intra
procedure function calls. The stack is the second scratch space after registers
used by the CPU for storing data.

The stack is an abstract over virtual memory, meaning that when you push or pop
from the stack you are actually writing and reading from memory.

The stack pointer `sp` is a register that holds the memory address of the top
of the stack. For example `sp` can hold 0x1000 which means that when a push
will store a value at the address starting at 0x1000 to 0x1004 (if we are storing)
an `int` for example.

The stack isn't subject to gravity so when you try to visualize it you should
imagine it upside down where the top of the stack is at a low memory address
and the bottom of the stack is at a high memory address, when you push items
to a stack, you substract from `sp` the size of the item you push.

The stack alignment (16 bytes in aarch64) is the smallest value you can add
or substract from the stack. For example if you need 7 bytes of space you will
need to substract 16 (allocate space for 16 bytes).

### Registers

On ARM64 registers are X0~X31 and are 64-bit wide with their 32-bit
sub quantities addresses using W0~W31, ARM64 is exclusively little
endian so when we say something like `w4[0..8] = 0xA8` imagine something
like this (assume the remaining bit fields are populated by 0's or 1's):

| | | | | | | | | | | | | | | | | | | | | | | |1|0|1|0|1|0|0|0|

### Moves

The `mov` instruction writes an immediate value to a register, it comes in
different flavors :
- (bitmask immediate): `mov <Xd|SP>, #<imm>`

- (inverted wide immediate): `mov <Xd>, #imm[16], LSL#<shift>`
where shift = {0,16,32,48} is the amount of the left shift

- (register copy): `mov <Xd>, <Xm>` (copy Xm into Xd)

- (stack pointer copy): `mov <Xd|SP>, <Xn|SP>`

- (wide immediate): `mov <Xd>, #imm`

- (move with keep): `movk <Xd>, #imm{,LSL #<shift>}`

The above are useful for moving immediates into registers.

### Loads and Stores

ARM is a load and store oriented architecture with no direct memory access
like in x86. There are two main load and store operations :

- `LDR <Dst>, [<address>]` : Load from value @ `<address>` to `<Dst>`
- `STR <Src>, [<address>]` : Store value @ `<address>` from `<Src>`

The size of the load and store is determined from the register
for example Xd registers are 64-bit wide, but we can still use Wd
as a short hand to only populate the low 32 bits e.g

`ldr w0, [sp, #16]` : Load 32 bit value from SP + 16 into w0
`ldr x0, [sp, #16]` : Load 64 bit value from SP + 16 into x0

There are variants to LDR/STR that are suffixed by a <size> quantity
- `strb w0, [sp, #16]` : Load bottom byte of w0 to [address] (u8/char)
- `strh w0, [sp, #16]` : Load bottom 2 bytes of w0 to [address] (u16,short)
- `strw w0, [sp, #16]` : Load bottom 4 bytes of w0 to [address] (u32, int)

The above instructions respect zero and sign extension for example in case

`ldr w0, [sp, #16]` the top 32 bits of x0 are zeroed by default.
`ldrb w4, <addr>` Will read one byte from <addr> e.g 0x8A into w4[0..8]
the remaining bits w[8..31] will be zero extended.

The second variants to LDR/STR are suffixed by `S` to mean sign extension
the range of sign extension will depend on the target register.

`ldrsb w4, <addr>` will load 0xA8 from <addr> into w4[0..8] and w4[8..31] = 0xff

`ldrsb x4, <addr>` will load 0xA8 from <addr> into x4[0..8] and x4[8..63] = 0xff

Another example :

`ldrsb x4, [0x8000]` assume [0x8000] = 0x1F then x4[0..8] = 0x1F and x[8..63] = 0x00.

The reason is that 0x1F in binary is '0b00011111' where the MSB is 0 therefore sign
extension will fill the rest of the registers by 0x00 = 0b00000000

On the other hand 0xA8 in binary is '0b10101000' where the MSB is 1 therefore sign
extension will fill the rest of the registers by 0xFF = 0b11111111

### Addressing modes in Loads and Stores

Generally all assembly for loads and store will look something like this :

`ldr W0, [X]` where `X` is the address within bracket, now how the address
is accessed is what we call addressing modes.

- Base Register Mode: `X` is a register that contains the virtual address to access.

- Offset mode: uses a combination of a base address and an offset such `X = [X1, #12]`
which says to access virtual address that's stored in `X1 + 12` this mode always
assume the offset is a byte offset, the offset itself can also be a register e.g `X1 + X0`.

- Pre-index mode: Pre-indexing is shown with `!` example `ldr W0, [X1, #12]!` this is
similar to the offset mode except that we update `X1` to store `X1 + 12`.

- Post-index mode: Post indexing looks like this `ldr W0, [X1], #12` and it stays to acess
the virtual address @ X1 *AND AFTER* update `X1` to `X1 + 12`.

Post indexing mode is weird but useful for popping off the stack since it basically moves a
value pointed at by the stack pointer and the updates the stack pointer to point to the next
value.

### Branching and Control Flow

There are two unconditional branch instructions `B` for PC-relative branches and `BR` for
register indirect branches.

- `B <label>` : Branches to label, the offset from PC to `label` is encoded in the instruction
as an immediate and can be in the range +/-128MB, to see this consider that instructions in ARM
are 32-bit wide (fixed) the branch instruction is encoded as [0,0,0,1,0,1,IMM[26..0]] where we
use 26-bits to encode an immediate, to get the offset multiply the immediate by 4.

So 2^26 * 4 is 256MB since relative addressing can be in both directions that's +/-128MB

- `BR <Xd>` : Branch indirectly to memory address stored @ `<Xd>`

There is a conditional variant of the branch instruction `B.<cond> <label>` which jumps
to `<label>` if `<cond>` is true. The `<cond>` is set in the ALU flags in the Program State
also called `PSTATE`.

## Snippets

For a better experience use the following snippets in Godbolt

```c

1: int memchr(char* s, int len, char b) {
2:     for (int i = 0;i < len;i++) {
3:         if (s[i] == b) {
4:             return i;
5:         }
6:     }
7:     return -1;
8: }

```

The snippet equivalent in assembly with annotations can be seen below.

```asm

memchr(char*, int, char):
        // Stack alignment is 16 bytes on AARCH64 meaning the stack pointer can
        // only be changed in multiples of 16. To guesstimate how much `sp` is
        // changed we can use the following :
        // sizeof(char*) + sizeof(int) + sizeof(char) + sizeof(int)
        // 8 bytes + 4 bytes + 1 bytes + 4 bytes = 17 bytes, nearest multiple
        // is 32 so we leave space for 32
        sub     sp, sp, #32
        // The calling conventions of aarch64 is that the first 7 arguments
        // that are primitive values or pointer go in register x0..x7.
        // The memory address at [sp + 8] stores the pointer to `s`.
        // So the memory range [sp+8..sp+16] contains the address of `s`.
        str     x0, [sp, 8]
        // The memory range [sp+4..sp+8] contains `len`
        str     w1, [sp, 4]
        // The memory range [sp+3..sp+4] contains `b` (single byte)
        strb    w2, [sp, 3]
        // [sp + 28] contains the first local variable `i` we store 0 there
        // by reading the contents of `wzr` which is the zero register.
        // The zero register always contains 0.
        str     wzr, [sp, 28]
        // Branch is equivalent to unconditional jump, here we jump execution
        // to .L6.
        b       .L6
.L9:
        // Load the contents of [sp, 28] which is the `i` loop counter, sign
        // extend it and store it in x0.
        ldrsw   x0, [sp, 28]
        // Load the contents of [sp,8] which is the memory address of the string
        // `s` into x1.
        ldr     x1, [sp, 8]
        // Increment the memory address in x1 by the contents of x0 (`i`).
        add     x0, x1, x0
        // Load a single byte from the memory address in x0 which has been incremented.
        // This is equivalent to *(s + i) in C.
        ldrb    w0, [x0]
        // Load a single byte from [sp, 3] which is the character `b` we're
        // looking for into x1.
        ldrb    w1, [sp, 3]
        // Compare *s( + i) with b
        cmp     w1, w0
        // Branch to .L7 if w1 is not equal to w0
        bne     .L7
        // Load i back into w0
        ldr     w0, [sp, 28]
        // Jump to .L8
        b       .L8
.L7:
        // Load `i` into w0.
        ldr     w0, [sp, 28]
        // Incrment `i` by 1
        add     w0, w0, 1
        // Store `i` back into [sp, 28]
        str     w0, [sp, 28]
.L6:
        // L6 contains the loop statement
        // Load [sp, 28] which is `i` into w1
        ldr     w1, [sp, 28]
        // Load [sp, 4] which is `len` into w0
        ldr     w0, [sp, 4]
        // Compare w1 and w0 and set the status flag
        cmp     w1, w0
        // Break if w1 is less than or equal w0.
        blt     .L9
        // This is the loop exit and stores -1 in w0 which contains the return
        // value of the function (by convention).
        mov     w0, -1
.L8:
        // Restore the stack pointer.
        add     sp, sp, 32
        // Return to the address from which we were called usually stored
        // in the link register.
        ret

```

One thing that we can remark is that the contents of the stack are mutated
for example `[sp, 28]` always contains the variable `i` each time we increment
`i` in the loop we read it into a register, increment the register and then
store it back.

Another example this time we check if two vectors are equal.

```c

int compare(int x, int y) {
    if (x == y) {
        return 0;
    } else if (x > y) {
        return 1;
    }
    return -1;
}

int equal(Vec3* x, Vec3* y) {
    if (compare(x->x,y->x) == 0 &&
        compare(x->y,y->y) == 0  && compare(x->z,y->z) == 0) {
        return 0;
    }
    return -1;
}


```

```asm

compare(int, int):
        // We only need space for two variables so allocate 16 bytes
        // in the stack.
        sub     sp, sp, #16
        // Store x at [sp, 12]
        str     w0, [sp, 12]
        // Store y at [sp, 8]
        str     w1, [sp, 8]
        // Load back x from [sp, 12]
        ldr     w1, [sp, 12]
        // Load back y from [sp, 8]
        ldr     w0, [sp, 8]
        // Compare x and y
        cmp     w1, w0
        // If the are not equal jump to .L6
        bne     .L6
        // If they are equal store 0 into w0
        mov     w0, 0
        // Then jump to .L7
        b       .L7
.L6:
        // Load x into w1
        ldr     w1, [sp, 12]
        // Load y into w0
        ldr     w0, [sp, 8]
        // Compare x and y
        cmp     w1, w0
        // Branch to .L8 if w1 is less than or equal w0
        ble     .L8
        // Otherwise store 1 into w0
        mov     w0, 1
        // Then jump to .L7
        b       .L7
.L8:
        // Store -1 into w0.
        mov     w0, -1
.L7:
        // When we arrive here the return value (either 0 or 1 or -1)
        // is stored in w0, so restore the stack pointer and go back.
        add     sp, sp, 16
        ret
equal(Vec3*, Vec3*):
        // The `equal` function makes a function call so the contents
        // x29 and x30 will be clobbered when we call `compare` down
        // the line, to preserve them we store them in the stack at
        // [sp - 32] then set `sp = sp -32` which is equivalent to
        // sub sp, sp, #32.
        // Originally x29 and x30 contain the addresses of whichever
        // function calls `equal`.
        stp     x29, x30, [sp, -32]!
        // Preserve the stack pointer in x29.
        mov     x29, sp
        // Store pointer to `Vec3 x` at [sp, 24]
        str     x0, [sp, 24]
        // Store pointer to `Vec3 y` at [sp, 16]
        str     x1, [sp, 16]
        // Load pointer to x in x0
        ldr     x0, [sp, 24]
        // Load contents of the pointer at x0 which would be the `x->x` field
        // into w2.
        ldr     w2, [x0]
        // Load the pointer to `Vec3 y` in x0
        ldr     x0, [sp, 16]
        // Load the `y->x` field into w0.
        ldr     w0, [x0]
        // Move w0 into w1
        mov     w1, w0
        // Move w2 into w0
        mov     w0, w2
        // Now w0 = x->x and w1 = y->x
        // Call compare.
        bl      compare(int, int)
        // Compare the return value to 0
        cmp     w0, 0
        // If not equal jump to .L10
        bne     .L10
        // Load pointer to `Vec3 x` into x0
        ldr     x0, [sp, 24]
        // Load `x->y` into w2 (this increments the address of x by 4)
        ldr     w2, [x0, 4]
        // Load pointer to `Vec3 y` into x0
        ldr     x0, [sp, 16]
        // Load `y->y` into w0.
        ldr     w0, [x0, 4]
        // Move w0 into w1
        mov     w1, w0
        // Move w2 into w0
        mov     w0, w2
        // w0 contains x->y and w1 contains y->y
        // call compare.
        bl      compare(int, int)
        // Compare the return value to 0
        cmp     w0, 0
        // If not equal go .L10
        bne     .L10
        // Again load the pointer to `Vec3 x` into x0
        ldr     x0, [sp, 24]
        // Load `x->z` the third field in the struct into w2
        ldr     w2, [x0, 8]
        // Again load the pointer to `Vec3 y` into x0
        ldr     x0, [sp, 16]
        // Load `y->z` the third field in the struct into w0
        ldr     w0, [x0, 8]
        // Move w0 to w1
        mov     w1, w0
        // Move w2 to w0
        mov     w0, w2
        // Call compare
        bl      compare(int, int)
        // Compare the return value to 0
        cmp     w0, 0
        // Branch to .L10 if not equal
        bne     .L10
        // If we didn't branch then move 1 to w0 this will be used
        // to signal that the equality failed.
        mov     w0, 1
        // Branch unconditionally to .L11
        b       .L11
.L10:
        // Store 0 into w0
        mov     w0, 0
.L11:
        // Unconditional branch, compares w0 to w0
        cmp     w0, 0
        // If equal then branch to .L12
        beq     .L12
        // If the inequality failed we would have branched to .L12
        // which means at this point equality succeeds so we store
        // 0 into w0 and branch to .L13.
        mov     w0, 0
        b       .L13
.L12:
        // Store return value -1 into w0
        mov     w0, -1
.L13:
        // Load original frame pointer and and link register
        // into x29 and x30.then increment `sp` by 32.
        ldp     x29, x30, [sp], 32
        ret

```
