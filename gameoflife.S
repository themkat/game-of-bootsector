    ;; Game of Life boot sector edition
    org 0x7c00
    
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

    ;; The basic on screen editor for creating initial state
editor:
    mov bx,0x6
update_editor_pos:
    push bx
    mov bx,[editor_pos]
    mov ah,[bx+1]
    and ah,0x0f
    mov [bx+1],ah
    pop bx
    mov ah,[bx+1]
    and ah,0x0f
    or ah,0x20
    mov [bx+1],ah
    mov [editor_pos],bx
editor_loop:
    call editor_handle_input
    ;; exit editor condition
    cmp bx,0xbeef
    je main_loop
    cmp bx,[editor_pos]
    jne update_editor_pos
    jmp editor_loop

    ;; Main rendering and simulation loop
main_loop:
    ;; TODO: count neighbors
    ;; TODO: update map based upon game of life rules
    jmp $

    
prepare_next_frame:
    ;; TODO: tune this. Maybe it can be a paramater if I can fit the extra bytes
    mov cx,0x0002
frame_sync:
    call wait_for_clock_tick
    loop frame_sync
    
    jmp main_loop

    ;; Subroutine to wait a tick
    ;; TODO: look into how many registers I actually need to preserve
wait_for_clock_tick:
    push ax
    push bx
    push cx
    push dx
    
    mov ah,0x0
    int 0x1a
    mov bx,dx
clock_sync:
    mov ah,0x0
    int 0x1a
    cmp bx,dx
    je clock_sync

    pop dx
    pop cx
    pop bx
    pop ax
    ret
    
    ;;  subroutine to place game of life tiles
    ;;  Input: bx = position (0-800)
place_tile:
    ;; place tile, but preserve editor selection if present
    mov [bx],0x2a
    mov ah,[bx+1]
    and ah,0xf0
    or ah,0x05
    mov [bx+1],ah
    ret
    
    ;; Editor subroutine
    ;; Returns possible new position in bx.
    ;; Special return: bx=0xbeef means marked for exit.
editor_handle_input:
    mov ah,0x00
    int 0x16

    mov bx,[editor_pos]
    cmp ah,0x1
    je editor_esc
    cmp ah,0x39
    je editor_space
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
    jmp editor_end
editor_space:
    call place_tile
    jmp editor_end
editor_esc:
    mov bx,0xbeef
editor_end:
    ret
    
    ;; variables and data storage
editor_pos:   equ 0x0faa
    ;; Neighbors lookup. Outside the graphics segment for simplicity
neighbors_table: equ 0x8000
    
    ;; Put BIOS signature at end after filling with 0s
    times 510-($-$$) db 0
    db 0x55,0xaa
