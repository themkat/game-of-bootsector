EXTRA_FLAGS :=

ifdef DEBUG
	EXTRA_FLAGS += -l machine_code_listing.lst
endif

gameoflife.img: gameoflife.S
	nasm -f bin gameoflife.S ${EXTRA_FLAGS} -o gameoflife.img

run: gameoflife.img
	qemu-system-i386 -fda gameoflife.img

clean:
	rm -f gameoflife.img machine_code_listing.lst
