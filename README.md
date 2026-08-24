# x86_32

## From Zero to Memory Manager: The Assembly Gauntlet

> prepare yourself for a AI slop (DeepSeek) description because I am too lazy to write it myself. Just once, come on, I promise he's not a larper, itwould be a good reminder for yourself 😉

You've built web apps. You've used React, Vue, and probably a dozen frameworks that will be obsolete in two years. You've never once wondered what actually happens when your JavaScript calls `fetch()` or when Python's garbage collector decides to free memory.

This is your wake-up call.

`x86_32` is a complete, brutal, and transformative journey through the foundation of computer science. It's based on *Programming from the Ground Up* — not a textbook, but a rite of passage. By the end, you won't just understand how a computer works. You'll have written a memory allocator from scratch. You'll have debugged stack frames with GDB. You'll have linked your own shared libraries.

And then, CS:APP will look easy.

> oh, really, this book really changes the way you look at computer. As DeepSeek told you, it will demistify everything... You can even imagine visually on what's going on when you run your code, from your finger down to transistors ;)

---

## What This Repo Is

This is not a "tutorial" with pretty screenshots. This is a checklist — a gauntlet of 23 projects that take you from "I can write `movl` to a register" to "I implemented a heap allocator with splitting."

Every project here builds on the last. Skip one, and the next one will break you. That's the point.

### The Phases

| Phase | What You'll Master | Why It Matters |
|-------|-------------------|----------------|
| 0 | Environment setup, `as`, `ld`, `gdb` | The tools of the trade |
| 1 | Basic instructions, addressing modes | How data actually moves |
| 2 | Functions, stack frames, recursion | How C actually works under the hood |
| 3 | System calls, file I/O, `.bss` | What happens when you `open()` a file |
| 4 | Records, structs, linked lists | How data structures are truly laid out |
| 5 | Shared libraries, linking against libc | The bridge to high-level code |
| 6 | **A memory allocator with splitting** | The boss level. CS:APP's Malloc Lab, but first |
| 7 | Number-to-string conversion, bitwise flags | How computers think in binary |
| 8 | Performance comparison, optimization | Why assembly still matters in 2026 |

---

## Why This Will Change You

You've probably heard "learn the fundamentals" a thousand times. Let me make it concrete.

When you finish Project 18, you will have written a memory allocator that splits free blocks. That's not a toy exercise — that's what `malloc()` actually does. Every single time your Python script creates a list, it's calling something like what you wrote.

When you finish Project 13, you'll know exactly why that segfault happened. Because you'll have written the error handling that catches it.

When you finish Project 23, you'll understand why that `xorl %eax, %eax` is faster than `movl $0, %eax`. Because you'll have measured it.

This repo isn't about getting a badge on GitHub. It's about understanding the machine you use every single day.

> And.... here's the important thing... This could be YOUR NEXT milestone to learn Rust, that damn languge that people repeatedly told you that it's the future of programming language! 

---

## Getting Started

### Prerequisites

- Linux (any distro works)
- GNU Assembler (`as`)
- GNU Linker (`ld`)
- GDB (`gdb`)
- A terminal. No IDE. You need to suffer a little. It builds character.

### Clone and Begin

```bash
git clone https://github.com/yourusername/x86_32.git
cd x86_32
```

### Phase 0: Verify Your Environment

Before you touch any project, run this:

```bash
as --version
ld --version
gdb --version
```

Then write your first program:

```asm
# exit.s
.section .data
.section .text
.globl _start
_start:
    movl $1, %eax    # system call 1 = exit
    movl $42, %ebx   # exit status 42
    int $0x80        # interrupt
```

Assemble, link, and run:

```bash
as exit.s -o exit.o
ld exit.o -o exit
./exit
echo $?
```

You should see `42`. If you don't, stop. Fix it. This is your foundation.

---

## The Gauntlet (or Spoiler)
Grab the book ASAP! Here's the spoiler on what will you do:

### The First 3 Projects (Get Hooked)

1. **Exit with code 42** — Learn `movl` and `int $0x80`. Simple. But it's your first program.

2. **Find the max in a list** — Indexed addressing mode. This is where you realize that `arr[i]` in C is really just `data_items(, %edi, 4)`.

3. **Three addressing modes, one value** — Direct, Base Pointer, Indirect. Write it three ways. Then you'll understand *why* the compiler does what it does.

### Project 5: The Deep Dive

This one will break you. Factorial recursion, with a hand-drawn stack frame.

Before you run `factorial(3)`, draw the stack. Predict where `%ebp` points. Then run GDB:

```bash
gdb ./factorial
break factorial
run
info registers
x/10x $esp
```

Verify your drawing was correct. If it wasn't, you learned more than any tutorial could teach you.

### Project 17: The Malloc Bridge

This is the moment it all clicks. You'll modify `read-records.s` to use your own memory allocator instead of `.bss`. You'll call `allocate_init`, then `allocate` for 324 bytes, then `deallocate` before exiting.

You wrote `malloc()`. That's not a metaphor. That's exactly what you did.

### Project 18: The Boss Level

Splitting. If you find a 100-byte free block but only need 10, split it. This is the exact same problem CS:APP's Malloc Lab throws at you. And you'll have already solved it.

---

## What You'll Be Able to Do When You're Done

- Read assembly code and know exactly what's happening at every instruction
- Debug stack overflows, buffer overflows, and segmentation faults without Stack Overflow (the website)
- Write your own memory allocator
- Link against libc and call `printf` from assembly
- Explain why `xorl %eax, %eax` is faster than `movl $0, %eax`
- Look at a C function and trace it down to the stack frame operations
- Continue to CS:APP and feel like a prodigy

> source: trust me bro

---

## Contribute

This gauntlet is meant to be brutal. If you find a project too vague, too hard, or too easy — open an issue. If you have a better challenge, submit a PR.

But don't water it down. The suffering is the point.

> nah it aint that hard bro, especially if you are comfortable with LeetCode (or maybe even Codeforces). This repo is basically a warm up.

---

## License

MIT. Do whatever you want. Just don't pretend you understood assembly if you didn't do the projects.

---

## The Challenge

You can keep building that portfolio with three React apps that all look the same.

Or you can clone this repo and learn what a computer actually does.

Your choice.

> As a human, I want to add something: THIS MENTAL MODEL WILL LAST FOR DECADES
>
> "A lot of programmers these days will end up learning a higher level language — such as Python, Ruby, or Java — and then not even really have a good grasp on anything that is causing that code in the language to execute and therefore not appreciating why things are slow or weird." - Joel Spolsky (Co-Founder, Stack Overflow)