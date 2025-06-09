.data
input:  .asciz "(a+b)c-d/e(f^g)"   # Modified example with brackets
output: .zero 100              # Buffer for postfix output
stack:  .zero 100              # Stack for operators
stack_top: .word -1            # Stack pointer initialized to -1

.text
.global _start

_start:
    la x3, input                # Input pointer
    la x4, output               # Output pointer
    la x5, stack                # Stack pointer
    li x6, -1                   # Stack pointer initialized to -1

process_input:
    lb x7, 0(x3)                # Load next character from input
    beq x7, x0, process_stack   # If null terminator, process remaining stack

    # Check if character is operand (a-z)
    li x28, 97                  # ASCII 'a'
    li x29, 122                 # ASCII 'z'
    blt x7, x28, check_brackets
    bgt x7, x29, check_brackets
    sb x7, 0(x4)                # Store operand in output
    addi x4, x4, 1              # Increment output pointer
    j next_character

check_brackets:
    # Check for opening bracket
    li x28, 40                  # AS
    beq x7, x28, push_open_bracket
    # Check for closing bracket
    li x28, 41                  # 
    beq x7, x28, handle_close_bracket
    j check_operator

push_open_bracket:
    addi x6, x6, 1              # Increment stack pointer
    sb x7, 0(x5)                # stack
    addi x5, x5, 1              # Move stack pointer
    j next_character

handle_close_bracket:
    li x10, -1                  # Check if stack is empty
    ble x6, x10, next_character # Skip if stack empty (error case)
    
    pop_until_open:
        lb x14, -1(x5)          # Look at top of stack
        li x28, 40              # ASCI
        beq x14, x28, pop_open  # If opening bracket found, pop it
        
        # Pop operator to output
        sb x14, 0(x4)           # Store operator in output
        addi x4, x4, 1          # Increment output pointer
        addi x6, x6, -1         # Decrement stack pointer
        addi x5, x5, -1         # Move stack pointer
        
        li x10, -1              # Check if stack is empty
        ble x6, x10, next_character # Error: no match
        j pop_until_open
        
    pop_open:
        addi x6, x6, -1         # Decrement stack pointer
        addi x5, x5, -1         # Move stack pointer
        j next_character

check_operator:
    # Handle operators
    li x28, 43                  # ASCII '+'
    beq x7, x28, handle_operator
    li x28, 45                  # ASCII '-'
    beq x7, x28, handle_operator
    li x28, 42                  # ASCII '*'
    beq x7, x28, handle_operator
    li x28, 47                  # ASCII '/'
    beq x7, x28, handle_operator
    li x28, 94                  # ASCII '^'
    beq x7, x28, handle_operator
    j next_character

handle_operator:
    # Set precedence for the operator
    li x8, 0                    # Default precedence
    li x28, 42                  # ASCII '*'
    beq x7, x28, set_mul_div
    li x28, 47                  # ASCII '/'
    beq x7, x28, set_mul_div
    li x28, 43                  # ASCII '+'
    beq x7, x28, set_add_sub
    li x28, 45                  # ASCII '-'
    beq x7, x28, set_add_sub
    li x28, 94                  # ASCII '^'
    beq x7, x28, set_exp
    j compare_stack

set_mul_div:
    li x8, 1                    # Precedence for '*' and '/'
    j compare_stack

set_add_sub:
    li x8, 0                    # Precedence for '+' and '-'
    j compare_stack

set_exp:
    li x8, 2                    # Precedence for '^'
    j compare_stack

compare_stack:
    li x10, -1                  # Check if stack is empty
    ble x6, x10, push_operator

    lb x11, -1(x5)              # Load top of stack
    
    # If top of stack i push operator
    li x28, 40                  # AS
    beq x11, x28, push_operator
    
    li x12, 0                   # Top precedence

    li x28, 42                  # ASCII '*'
    beq x11, x28, set_top_mul_div
    li x28, 47                  # ASCII '/'
    beq x11, x28, set_top_mul_div
    li x28, 43                  # ASCII '+'
    beq x11, x28, set_top_add_sub
    li x28, 45                  # ASCII '-'
    beq x11, x28, set_top_add_sub
    li x28, 94                  # ASCII '^'
    beq x11, x28, set_top_exp
    j check_precedence

set_top_mul_div:
    li x12, 1                   # Precedence for '*' and '/'
    j check_precedence

set_top_add_sub:
    li x12, 0                   # Precedence for '+' and '-'
    j check_precedence

set_top_exp:
    li x12, 2                   # Precedence for '^'
    j check_precedence

check_precedence:
    blt x12, x8, push_operator  # Push if current operator has higher precedence
    bne x12, x8, pop_higher_or_equal
    li x13, 2                   # Exponentiation is right-associative
    bne x8, x13, pop_higher_or_equal
    j push_operator

pop_higher_or_equal:
    lb x14, -1(x5)              # Pop top of stack
    sb x14, 0(x4)               # Store operator in output
    addi x4, x4, 1              # Increment output pointer
    addi x6, x6, -1             # Decrement stack pointer
    addi x5, x5, -1             # Move stack pointer
    j compare_stack

push_operator:
    addi x6, x6, 1              # Increment stack pointer
    sb x7, 0(x5)                # Push operator to stack
    addi x5, x5, 1              # Move stack pointer
    j next_character

next_character:
    addi x3, x3, 1              # Move to next character
    j process_input

process_stack:
    li x10, -1                  # Check if stack is empty
    ble x6, x10, finish
    lb x14, -1(x5)              # Pop top of stack
    
    # Don't output parentheses
    li x28, 40                  # AS
    beq x14, x28, skip_output
    li x28, 41                  # ASCII
    beq x14, x28, skip_output
    
    sb x14, 0(x4)               # Store operator in output
    addi x4, x4, 1              # Increment output pointer

skip_output:
    addi x6, x6, -1             # Decrement stack pointer
    addi x5, x5, -1             # Move stack pointer
    j process_stack

finish:
    sb x0, 0(x4)                # Null-terminate output

print_output:
    la x4, output               # Reload output address
print_loop:
    lb x7, 0(x4)                # Load character from output
    beq x7, x0, exit            # If null terminator, exit
    li a7, 11                   # Syscall to print character
    mv a0, x7                   # Move character to a0
    ecall
    addi x4, x4, 1              # Move to next character
    j print_loop

exit:
    li a7, 10                   # Syscall to exit
    ecall
