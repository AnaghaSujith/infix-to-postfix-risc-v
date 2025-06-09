# Infix to Postfix Converter in RISC-V Assembly (Ripes)

This project implements an **infix to postfix expression converter** using **RISC-V Assembly**. The program is tested and simulated in **Ripes**, a graphical RISC-V pipeline simulator.

---

## Features

- Converts infix expressions (with brackets and operators) to postfix (Reverse Polish Notation)
- Handles operators: `+`, `-`, `*`, `/`, `^`
- Handles right-associative exponentiation and parentheses
- Uses `.data` segment for input, output buffer, and stack
- Prints the postfix result using `syscall 11` (print character)

---

##  Tested On
- **Ripes** Simulator 
- RISC-V RV32I architecture
- No memory-mapped I/O or external devices needed

---

## Files

| File | Description |
|------|-------------|
| `infix_to_postfix.S` | RISC-V assembly code for the conversion logic |
| `example_output.txt` | Output postfix expression for `(a+b)c-d/e(f^g)` |
| `assets` | Screenshot from Ripes memory/register view |


---

## How to Run (in Ripes)

1. Open **Ripes**
2. File → Load Assembly → Select `infix_to_postfix.S`
3. Run → Reset & Assemble
4. Open **Console** (bottom right)
5. Run the program — postfix expression will be printed

### Sample Output:
ab+cdefg^/-
Program exited with code: 0

---

## Expression Example Used

```assembly
.data
input:  .asciz "(a+b)c-d/e(f^g)"
