    ;; Game of Life boot sector edition
    org 0x7c00
    
    ;; TODO: Basic on screen "editor" to place initial state. Use space or something to place "blocks". To get familiar with graphics and keyboard handling on bare metal 386
init:
    ;; just text 80x25 mode.
    mov ax,0x0002
    int 10h
    mov ax,0xb800
    mov es,ax
    mov ds,ax
    
main_loop:  
    mov ah,0x00
    int 0x16
    cmp ah,0x48
    jne main_loop
    ;; simple drawing to test it out
    mov [0x0], 0x20
    mov [0x1], 0x50
    
exit:
    jmp $

    ;; Board:
    ;; Can we have a single big board where we use a fancy instruction to shift each entry? each entry having curr+prev bit? or is it easier to have two boards?
board:   equ 0x8000
editor_x:   db 40
editor_y:   db 20
    ;; TODO: screen position variable for readability. in editor.
    
    ;; Put BIOS signature at end after filling with 0s
    times 510-($-$$) db 0
    db 0x55,0xaa
