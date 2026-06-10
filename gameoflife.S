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

    ;; Screen memory. Set up segments for adressing 
    mov ax,0xb800
    mov ds,ax

    mov bx,0x6
update_editor_pos:
    push bx 
    mov bx,[editor_pos]
    mov [bx+1],0x00
    pop bx
    mov [bx+1],0x20 
    mov [editor_pos],bx
main_loop:
    call editor_handle_input
    cmp bx,[editor_pos]
    jne update_editor_pos
exit:
    jmp main_loop

    ;;  subroutine to place tiles
    ;;  Input: ah = ascii character
    ;;         al = colors (high + low)
    ;;         bx = position (0-fff)
    ;; TODO: keep? or delete?
place_tile:
    push ax
    push ds
        
    mov [bx],ah
    mov [bx+1],al
    pop ds
    pop ax
    ret
    
    ;; Editor subroutine
    ;; Returns possible new position in bx
editor_handle_input:
    mov ah,0x00
    int 0x16

    mov bx,[editor_pos]
    cmp ah,0x50
    je editor_down
    cmp ah,0x48
    je editor_up
    cmp ah,0x4d
    je editor_right
    cmp ah,0x4b
    jne editor_end
editor_left:
    sub bx,0x2
    jmp editor_end
editor_down:
    add bx,0xa0
    jmp editor_end
editor_up:
    sub bx,0xa0
    jmp editor_end
editor_right:
    add bx,0x2
editor_end:
    ret
    
    ;; variables and data storage
editor_pos:   equ 0x0faa
    ;; TODO: screen position variable for readability. in editor.
    
    ;; Put BIOS signature at end after filling with 0s
    times 510-($-$$) db 0
    db 0x55,0xaa
