    ;; Game of Life boot sector edition
    org 0x7c00
    
    ;; TODO: Basic on screen "editor" to place initial state. Use space or something to place "blocks". To get familiar with graphics and keyboard handling on bare metal 386
init:
    ;; text 80x25 mode.
    mov ax,0x0002
    int 0x10

    ;; Hide blinking cursor
    mov ah,0x01
    mov cx,0x2607
    int 0x10
    
main_loop:
    ;; TODO: maybe make the input handling here a subroutine? then I avoid the issue with the segments being reset in the middle.
    mov ah,0x00
    int 0x16
    cmp ah,0x48
    jne main_loop
    ;; simple drawing to test it out
    mov ah, 0x2a
    mov al, 0x05
    mov bx,0xfe
    call place_tile
    
exit:
    jmp $


    ;;  subroutine to place tiles
    ;;  Input: ah = ascii character
    ;;         al = colors (high + low)
    ;;         bx = position (0-fff)
place_tile:
    push ax
    push ds
    
    ;; Screen memory. Set up segments for adressing 
    push ax
    mov ax,0xb800
    mov ds,ax
    pop ax
    
    mov [bx],ah
    mov [bx+1],al
    pop ds
    pop ax
    ret
    
    ;; Board:
    ;; Can we have a single big board where we use a fancy instruction to shift each entry? each entry having curr+prev bit? or is it easier to have two boards?
board:   equ 0x8000
editor_x:   db 40
editor_y:   db 20
    ;; TODO: screen position variable for readability. in editor.
    
    ;; Put BIOS signature at end after filling with 0s
    times 510-($-$$) db 0
    db 0x55,0xaa
