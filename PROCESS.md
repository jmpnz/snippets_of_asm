# Notes on process addresses and entry point

I've long tried to find out what was special about 0x8000000 without
much success. Until I read Eli Bendersky's "How debuggers work series"
this section is copied from his blog post which you can find at the
following link [here](https://eli.thegreenplace.net/2011/01/27/how-debuggers-work-part-2-breakpoints/)

```

Digression - process addresses and entry point

Frankly, 0x8048096 itself doesn't mean much, it's just a few bytes away from the beginning
of the text section of the executable. If you look carefully at the dump listing above,
you'll see that the text section starts at 0x08048080. This tells the OS to map the text
section starting at this address in the virtual address space given to the process.

On Linux these addresses can be absolute i.e. the executable isn't being relocated when
it's loaded into memory, because with the virtual memory system each process gets its own
chunk of memory and sees the whole 32-bit address space as its own (called "linear" address).

If we examine the ELF header with readelf, we get:

$ readelf -h traced_printer2
ELF Header:
  Magic:   7f 45 4c 46 01 01 01 00 00 00 00 00 00 00 00 00
  Class:                             ELF32
  Data:                              2's complement, little endian
  Version:                           1 (current)
  OS/ABI:                            UNIX - System V
  ABI Version:                       0
  Type:                              EXEC (Executable file)
  Machine:                           Intel 80386
  Version:                           0x1
  Entry point address:               0x8048080
  Start of program headers:          52 (bytes into file)
  Start of section headers:          220 (bytes into file)
  Flags:                             0x0
  Size of this header:               52 (bytes)
  Size of program headers:           32 (bytes)
  Number of program headers:         2
  Size of section headers:           40 (bytes)
  Number of section headers:         4
  Section header string table index: 3

Note the "entry point address" section of the header, which also points to 0x8048080.
So if we interpret the directions encoded in the ELF file for the OS, it says:

    Map the text section (with given contents) to address 0x8048080
    Start executing at the entry point - address 0x8048080

But still, why 0x8048080? For historic reasons, it turns out. Some googling led me to a few
sources that claim that the first 128MB of each process's address space were reserved for the stack.
128MB happens to be 0x8000000, which is where other sections of the executable may start.
0x8048080, in particular, is the default entry point used by the Linux ld linker.

This entry point can be modified by passing the -Ttext argument to ld.

To conclude, there's nothing really special in this address and we can freely change it.
As long as the ELF executable is properly structured and the entry point address in the header matches
the real beginning of the program's code (text section), we're OK.

```

To change the text section you can either pass `-Ttext=0xDEADBEEF` to `ld` or use a linker
script like below :

```ld

SECTIONS {
    . = 0x40000;
    .text : {
        *(.text)
    }
}

```
