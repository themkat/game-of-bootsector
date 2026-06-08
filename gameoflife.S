    ;; Game of Life boot sector edition
    org 0x7c00

    ;; TODO: Basic on screen "editor" to place initial state. Use space or something to place "blocks". To get familiar with graphics and keyboard handling on bare metal 386
init:
    jmp $
    
    ;; Put BIOS signature at end after filling with 0s
    times 510-($-$$) db 0
    db 0x55,0xaa
