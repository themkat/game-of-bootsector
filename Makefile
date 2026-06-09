gameoflife.img: gameoflife.S
	nasm -f bin gameoflife.S -o gameoflife.img

run: gameoflife.img
	qemu-system-i386 -fda gameoflife.img

clean:
	rm gameoflife.img
