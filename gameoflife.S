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
    mov bx,0x3
update_editor_pos:
    call editor_clear_cursor
    mov [editor_pos],bx
    shl bx,0x1
    mov ah,[bx+1]
    and ah,0x0f
    or ah,0x20
    mov [bx+1],ah
editor_loop:
    call editor_handle_input
    ;; exit editor condition
    cmp bx,0xbeef
    je prepare_main
    cmp bx,[editor_pos]
    jne update_editor_pos
    jmp editor_loop

prepare_main:
    call editor_clear_cursor
    
    ;; Main rendering and simulation loop
main_loop:
    ;; Update prev_board
    push ds
    mov cx,0x7d0
    mov ax,current_board
    mov ds,ax
    mov ax,prev_board
    mov es,ax
    cld
    rep movsb
    pop ds
        
    mov cx,0x7d0
render_loop:
    mov bx,cx
    call count_neighbors

    ;; TODO: can probably rewrite to avoid a few jumps
    cmp al,0x3
    je render_alive
    cmp ah,0x1
    jne render_dead
    cmp al, 0x2
    je render_alive
render_dead:
    call kill_tile
    jmp render_end
render_alive:
    call place_tile
render_end:
    dec cx
    cmp cx,0x0
    jge render_loop
    
prepare_next_frame:
    ;; TODO: tune this. Maybe it can be a paramater if I can fit the extra bytes
    mov cx,0x02
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

    ;; Subroutine to count neighbors
    ;; Expected state: bx contains coordinate of current cell
    ;; Output: al contains number of neighbors, ah contains if self is alive
count_neighbors:
    push ds
    mov ax,prev_board
    mov ds,ax
    xor al,al
    add al,[bx-81]
    add al,[bx-80]
    add al,[bx-79]
    add al,[bx-1]
    add al,[bx+1]
    add al,[bx+79]
    add al,[bx+80]
    add al,[bx+81]

    mov ah,[bx]
    
    pop ds
    ret
    
    ;;  subroutine to place game of life tiles
    ;;  Input: bx = position (0-800)
place_tile:
    ;; place tile, but preserve editor selection if present
    push bx

    ;; Put into internal rep
    push ds
    mov ax,current_board
    mov ds,ax
    mov [bx],0x01
    pop ds
    
    shl bx,0x1
    mov ax,[bx]
    mov [bx],0x2a
    mov ah,[bx+1]
    and ah,0xf0
    or ah,0x05
    mov [bx+1],ah
    pop bx
    ret

    ;; Equivalent of the above, but remove a tile.
    ;; TODO: can we unify the two current_board marking logic pieces?
kill_tile:  
    push bx

    ;; Put into internal rep
    push ds
    mov ax,current_board
    mov ds,ax
    mov [bx],0x0
    pop ds
    
    shl bx,0x1
    mov word [bx],0x0
    pop bx
    ret
    
    ;; Subroutine for clearing cursor. Either when moving around, or when entering the main loop.
editor_clear_cursor:
    push bx
    mov bx,[editor_pos]
    shl bx,0x1
    mov ah,[bx+1]
    and ah,0x0f
    mov [bx+1],ah
    pop bx
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
    dec bx
    jmp editor_end
editor_down:
    add bx,0x50
    jmp editor_end
editor_up:
    sub bx,0x50
    jmp editor_end
editor_right:
    inc bx
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
    ;; Boards with on/off switches for each cell
    ;; Extremely wasteful memory-wise, but makes for easy short code. That is after all the most important thing here
    ;; (just a random place in memory. With some space between to avoid adding extra boundary checks)
current_board:  equ 0x2000
prev_board:     equ 0x3000
    
    ;; Put BIOS signature at end after filling with 0s
    times 510-($-$$) db 0
    db 0x55,0xaa
