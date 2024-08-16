// gcc -m32 -nostdlib -static -Wl,-Ttext,0 -Wl,--build-id=none -o forth forth.S

	.set MY_VERSION,47

	.macro NEXT
		movl (%esi), %eax
		addl $4, %esi
		jmp *(%eax)
	.endm

	.macro PUSHRSP reg
		lea -4(%ebp),%ebp
		movl \reg,(%ebp)
	.endm

	.macro POPRSP reg
		mov (%ebp),\reg
		lea 4(%ebp),%ebp
	.endm

	.text
	.align 4
DOCOL:
	PUSHRSP %esi
	addl $4,%eax
	movl %eax,%esi
	NEXT

	.text
	.globl _start
_start:
	cld
	mov %esp,var_S0
	mov $return_stack_top,%ebp
	call set_up_data_segment

	mov $cold_start,%esi
	NEXT

	.section .rodata
cold_start:
	.int QUIT

	.set F_IMMED,0x80
	.set F_HIDDEN,0x20
	.set F_LENMASK,0x1f

	.set link,0

	.macro defword name, namelen, flags=0, label
	.section .rodata
	.align 4
	.globl name_\label
name_\label :
	.int link
	.set link, name_\label
	.byte \flags+\namelen
	.ascii "\name"
	.align 4
	.globl \label
\label :
	.int DOCOL
	.endm

	.macro defcode name, namelen, flags=0, label
	.section .rodata
	.align 4
	.globl name_\label
name_\label :
	.int link
	.int link,name_\label
	.byte \flags+\namelen
	.ascii "\name"
	.align 4
	.globl \label
\label :
	.int code_\label
	.text
	.globl code_\label
code_\label :
	.endm

	defcode "DROP",4,,DROP
	pop %eax
	NEXT

	defcode "SWAP",4,,SWAP
	pop %eax
	pop %eax
	push %eax
	push %eax
	NEXT

	defcode "DUP",3,,DUP
	mov (%esp),%eax
	push %eax
	NEXT

	defcode "OVER",4,,OVER
	mov 4(%esp),%eax
	push %eax
	NEXT

	defcode "ROT",3,,ROT
	pop %eax
	pop %ebx
	pop %ecx
	push %ebx
	push %eax
	push %ecx
	NEXT

	defcode "-ROT",4,,NROT
	pop %eax
	pop %ebx
	pop %ecx
	push %eax
	push %ecx
	push %ebx

	defcode "2DROP",5,,TWODROP
	pop %eax
	pop %eax
	NEXT

	defcode "2DUP",4,,TWODUP
	pop %eax
	pop %eax
	NEXT

	defcode "2SWAP",5,,TWOSWAP
	pop %eax
	pop %ebx
	pop %ecx
	pop %edx
	push %ebx
	push %eax
	push %edx
	push %ecx
	NEXT

	defcode "?DUP",4,,QDUP
	movl (%esp),%eax
	test %eax,%eax
	jz 1f
	push %eax
1:	NEXT

	defcode "1+",2,,INCR
	incl (%esp)
	NEXT

	defcode "1-",2,,DECR
	decl (%esp)
	NEXT

	defcode "4+",2,,INCR4
	addl $4,(%esp)
	NEXT

	defcode "4-",2,,DECR4
	subl $4,(%esp)
	NEXT

	defcode "+",1,,ADD
	pop %eax
	addl %eax,(%esp)
	NEXT

	defcode "-",1,,SUB
	pop %eax
	subl %eax,(%esp)
	NEXT

	defcode "*",1,,MUL
	pop %eax
	pop %ebx
	imull %ebx,%eax
	push %eax
	NEXT

	defcode "/MOD",4,,DIVMOD
	xor %edx,%edx
	pop %ebx
	pop %eax
	idivl %ebx
	push %edx
	push %eax
	NEXT

	defcode "=",1,,EQU
	pop %eax
	pop %ebx
	cmp %ebx,%eax
	sete %al
	movzbl %al, %eax
	pushl %eax
	NEXT

	defcode "<>",2,,NEQU
	pop %eax
	pop %ebx
	cmp %ebx,%eax
	setne %al
	movzbl %al,%eax
	pushl %eax
	NEXT

	defcode "<",1,,LT
	pop %eax
	pop %ebx
	cmp %eax,%ebx
	setl %al
	movzbl %al,%eax
	pushl %eax
	NEXT

	defcode ">",1,,GT
	pop %eax
	pop %ebx
	cmp %eax,%ebx
	setg %al
	movzbl %al,%eax
	pushl %eax
	NEXT

	defcode "<=",1,,LE
	pop %eax
	pop %ebx
	cmp %eax,%ebx
	setle %al
	movzbl %al,%eax
	pushl %eax
	NEXT

	defcode ">",1,,GE
	pop %eax
	pop %ebx
	cmp %eax,%ebx
	setge %al
	movzbl %al,%eax
	pushl %eax
	NEXT

	defcode "0=",2,,ZEQU
	pop %eax
	test %eax,%eax
	setz %al
	movzbl %al,%eax
	pushl %eax
	NEXT

	defcode "0<>",3,,ZNEQU
	pop %eax
	test %eax,%eax
	setnz %al
	movzbl %al,%eax
	pushl %eax
	NEXT

	defcode "0<",2,,ZLT
	pop %eax
	test %eax,%eax
	setl %al
	movzbl %al,%eax
	pushl %eax
	NEXT

	defcode "0>",2,,ZGT
	pop %eax
	test %eax,%eax
	setg %al
	movzbl %al,%eax
	pushl %eax
	NEXT

	defcode "0<=",3,,ZLE
	pop %eax
	test %eax,%eax
	setle %al
	movzbl %al,%eax
	pushl %eax
	NEXT

	defcode "0>=",3,,ZGE
	pop %eax
	test %eax,%eax
	setge %al
	movzbl %al,%eax
	pushl %eax
	NEXT

	defcode "AND",3,,AND
	pop %eax
	andl %eax,(%esp)
	NEXT

	defcode "OR",2,,OR
	pop %eax
	orl %eax,(%esp)
	NEXT

	defcode "XOR",3,,XOR
	pop %eax
	xorl %eax,(%esp)
	NEXT

	defcode "INVERT",6,,INVERT
	notl (%esp)
	NEXT

	defcode "EXIT",4,,EXIT
	POPRSP %esi
	NEXT

	defcode "LIT",3,,LIT
	movl (%esi), %eax
	addl $4, %esi
	push %eax
	NEXT

	defcode "!",1,,STORE
	pop %ebx
	pop %eax
	mov %eax,(%ebx)
	NEXT

	defcode "@",1,,FETCH
	pop %ebx
	mov (%ebx),%eax
	push %eax
	NEXT

	defcode "+!",2,,ADDSTORE
	pop %ebx
	pop %eax
	addl %eax,(%ebx)
	NEXT

	defcode "-!",2,,SUBSTORE
	pop %ebx
	pop %eax
	subl %eax,(%ebx)
	NEXT

	defcode "C!",2,,STOREBYTE
	pop %ebx
	pop %eax
	movb %al,(%ebx)
	NEXT

	defcode "C@",2,,FETCHBYTE
	pop %ebx
	xor %eax,%eax
	movb (%ebx),%al
	push %eax
	NEXT

	defcode "C@C!",4,,CCOPY
	movl 4(%esp),%ebx
	movb (%ebx),%al
	pop %edi
	stosb
	push %edi
	incl 4(%esp)
	NEXT

	defcode "CMOVE",5,,CMOVE
	mov %esi,%edx
	pop %ecx
	pop %edi
	pop %esi
	rep movsb
	mov %edx,%esi
	NEXT

	.macro defvar name, namelen, flags=0, label, initial=0
	defcode \name,\namelen,\flags,\label
	push $var_\name
	NEXT
	.data
	.align 4
var_\name :
	.int \initial
	.endm

	defvar "STATE",5,,STATE
	defvar "HERE",4,,HERE
	defvar "LATEST",6,,LATEST,name_SYSCALL0
	defvar "S0",2,,SZ
	defvar "BASE",4,,BASE,10

//#include <asm-i386/unistd.h>
#include <asm/unistd.h>

	.macro defconst name, namelen, flags=0, label, value
	defcode \name,\namelen,\flags,\label
	push $\value
	NEXT
	.endm

	defconst "VERSION",7,,VERSION,MY_VERSION
	defconst "R0",2,,RZ,return_stack_top
	defconst "DOCOL",5,,__DOCOL,DOCOL
	defconst "F_IMMED",7,,__F_IMMED,F_IMMED
	defconst "F_HIDDEN",8,,__F_HIDDEN,F_HIDDEN
	defconst "F_LENMASK",9,,__F_LENMASK,F_LENMASK

	defconst "SYS_EXIT",8,,SYS_EXIT,__NR_exit
	defconst "SYS_OPEN",8,,SYS_OPEN,__NR_open
	defconst "SYS_CLOSE",9,,SYS_CLOSE,__NR_close
	defconst "SYS_READ",8,,SYS_READ,__NR_read
	defconst "SYS_WRITE",9,,SYS_WRITE,__NR_write
	defconst "SYS_CREAT",9,,SYS_CREAT,__NR_creat
	defconst "SYS_BRK",7,,SYS_BRK,__NR_brk

	defconst "O_RDONLY",8,,__O_RDONLY,0
	defconst "O_WRONLY",8,,__O_WRONLY,1
	defconst "O_RDWR",6,,__O_RDWR,2
	defconst "O_CREAT",7,,__O_CREAT,0100
	defconst "O_EXCL",6,,__O_EXCL,0200
	defconst "O_TRUNC",7,,__O_TRUNC,01000
	defconst "O_APPEND",8,,__O_APPEND,02000
	defconst "O_NONBLOCK",10,,__O_NONBLOCK,04000

	defcode ">R",2,,TOR
	pop %eax
	PUSHRSP %eax
	NEXT

	defcode "R>",2,,FROMR
	POPRSP %eax
	push %eax
	NEXT

	defcode "RSP@",4,,RSPFETCH
	push %ebp
	NEXT

	defcode "RSP!",4,,RSPSTORE
	pop %ebp
	NEXT

	defcode "RDROP",5,,RDROP
	addl $4,%ebp
	NEXT

	defcode "DSP@",4,,DSPFETCH
	mov %esp,%eax
	push %eax
	NEXT

	defcode "DSP!",4,,DSPSTORE
	pop %esp
	NEXT

	defcode "KEY",3,,KEY
	call _KEY
	push %eax
	NEXT
_KEY:
	mov (currkey),%ebx
	cmp (bufftop),%ebx
	jge 1f
	xor %eax,%eax
	mov (%ebx),%al
	inc %ebx
	mov %ebx,(currkey)
	ret
1:	xor %ebx,%ebx
	mov $buffer,%ecx
	mov %ecx,currkey
	mov $BUFFER_SIZE,%edx
	mov $__NR_read,%eax
	int $0x80
	test %eax,%eax
	jbe 2f
	addl %eax,%ecx
	mov %ecx,bufftop
	jmp _KEY
2:	xor %ebx,%ebx
	mov $__NR_exit,%eax
	int $0x80

	.data
	.align 4
currkey:
	.int buffer
bufftop:
	.int buffer

	defcode "EMIT",4,,EMIT
	pop %eax
	call _EMIT
	NEXT
_EMIT:
	mov $1,%ebx
	mov %al,emit_scratch
	mov $emit_scratch,%ecx
	mov $1,%edx
	mov $__NR_write,%eax
	int $0x80
	ret

	.data
emit_scratch:
	.space 1

	defcode "WORD",4,,WORD
	call _WORD
	push %edi
	push %ecx
	NEXT
_WORD:
1:	call _KEY
	cmpb $'\\',%al
	je 3f
	cmpb $' ',%al
	jbe 1b
	mov $word_buffer,%edi
2:	stosb
	call _KEY
	cmpb $' ',%al
	ja 2b
	sub $word_buffer,%edi
	mov %edi,%ecx
	mov $word_buffer,%edi
	ret
3:	call _KEY
	cmpb $'\n',%al
	jne 3b
	jmp 1b

	.data
word_buffer:
	.space 32

	defcode "NUMBER",6,,NUMBER
	pop %ecx
	pop %edi
	call _NUMBER
	push %eax
	push %ecx
	NEXT
_NUMBER:
	xor %eax,%eax
	xor %ebx,%ebx
	test %ecx,%ecx
	jz 5f

	movl var_BASE,%edx
	movb (%edi),%bl
	inc %edi
	push %eax
	cmpb $'-',%bl
	jnz 2f
	pop %eax
	push %ebx
	dec %ecx
	jnz 1f
	pop %ebx
	movl $1,%ecx
	ret
1:	imull %edx,%eax
	movb (%edi),%bl
	inc %edi
2:	subb $'0',%bl
	jb 4f
	cmp $10,%bl
	jb 3f
	subb $17,%bl
	jb 4f
	addb $10,%bl
3:	cmp %dl,%bl
	jge 4f
	add %ebx,%eax
	dec %ecx
	jnz 1b
4:	pop %ebx
	test %ebx,%ebx
	jz 5f
	neg %eax
5:	ret

	defcode "FIND",4,,FIND
	pop %ecx
	pop %edi
	call _FIND
	push %eax
	NEXT
_FIND:
	push %esi
	mov var_LATEST,%edx
1:	test %edx,%edx
	je 4f
	xor %eax,%eax
	movb 4(%edx),%al
	andb $(F_HIDDEN|F_LENMASK),%al
	cmpb %cl,%al
	jne 2f
	push %ecx
	push %edi
	lea 5(%edx),%esi
	repe cmpsb
	pop %edi
	pop %ecx
	jne 2f
	pop %esi
	mov %edx,%eax
	ret
2:	mov (%edx),%edx
	jmp 1b
4:	pop %esi
	xor %eax,%eax
	ret

	defcode ">CFA",4,,TCFA
	pop %edi
	call _TCFA
	push %edi
	NEXT
_TCFA:
	xor %eax,%eax
	add $4,%edi
	movb (%edi),%al
	inc %edi
	andb $F_LENMASK,%al
	add %eax,%edi
	addl $3,%edi
	andl $~3,%edi
	ret

	defword ">DFA",4,,TDFA
	.int TCFA
	.int INCR4
	.int EXIT

	defcode "CREATE",6,,CREATE
	pop %ecx
	pop %ebx
	movl var_HERE,%edi
	movl var_LATEST,%eax
	stosl
	mov %cl,%al
	stosb
	push %esi
	mov %ebx,%esi
	rep movsb
	pop %esi
	addl $3,%edi
	andl $~3,%edi
	movl var_HERE,%eax
	movl %eax,var_LATEST
	movl %edi,var_HERE
	NEXT

	defcode ",",1,,COMMA
	pop %eax
	call _COMMA
	NEXT
_COMMA:
	movl var_HERE,%edi
	stosl
	movl %edi,var_HERE
	ret

	defcode "[",1,F_IMMED,LBRAC
	xor %eax,%eax
	movl %eax,var_STATE
	NEXT

	defcode "]",1,,RBRAC
	movl $1,var_STATE
	NEXT

	defword ":",1,,COLON
	.int WORD
	.int CREATE
	.int LIT, DOCOL, COMMA
	.int LATEST, FETCH, HIDDEN
	.int RBRAC
	.int EXIT

	defword ";",1,F_IMMED,SEMICOLON
	.int LIT, EXIT, COMMA
	.int LATEST, FETCH, HIDDEN
	.int LBRAC
	.int EXIT

	defcode "IMMEDIATE",9,F_IMMED,IMMEDIATE
	movl var_LATEST,%edi
	addl $4,%edi
	xorb $F_IMMED,(%edi)
	NEXT

	defcode "HIDDEN",6,,HIDDEN
	pop %edi
	addl $4,%edi
	xorb $F_HIDDEN,(%edi)
	NEXT

	defword "HIDE",4,,HIDE
	.int WORD
	.int FIND
	.int HIDDEN
	.int EXIT

	defcode "'",1,,TICK
	movl (%esi), %eax
	addl $4, %esi
	pushl %eax
	NEXT

	defcode "BRANCH",6,,BRANCH
	add (%esi),%esi
	NEXT

	defcode "0BRANCH",7,,ZBRANCH
	pop %eax
	test %eax,%eax
	jz code_BRANCH
	lodsl
	NEXT

	defcode "LITSTRING",9,,LITSTRING
	movl (%esi), %eax
	addl $4, %esi
	push %esi
	push %eax
	addl %eax,%esi
	addl $3,%esi
	andl $~3,%esi
	NEXT

	defcode "TELL",4,,TELL
	mov $1,%ebx
	pop %edx
	pop %ecx
	mov $__NR_write,%eax
	int $0x80
	NEXT

	defword "QUIT",4,,QUIT
	.int RZ,RSPSTORE
	.int INTERPRET
	.int BRANCH,-8

	defcode "INTERPRET",9,,INTERPRET
	call _WORD
	xor %eax,%eax
	movl %eax,interpret_is_lit
	call _FIND
	test %eax,%eax
	jz 1f
	mov %eax,%edi
	movb 4(%edi),%al
	push %ax
	call _TCFA
	pop %ax
	andb $F_IMMED,%al
	mov %edi,%eax
	jnz 4f
	jmp 2f
1:	incl interpret_is_lit
	call _NUMBER
	test %ecx,%ecx
	jnz 6f
	mov %eax,%ebx
	mov $LIT,%eax
2:	movl var_STATE,%edx
	test %edx,%edx
	jz 4f
	call _COMMA
	mov interpret_is_lit,%ecx
	test %ecx,%ecx
	jz 3f
	mov %ebx, %eax
	call _COMMA
3:	NEXT
4:	mov interpret_is_lit,%ecx
	test %ecx,%ecx
	jnz 5f
	jmp *(%eax)
5:	push %ebx
	NEXT
6:	mov $2,%ebx
	mov $errmsg,%ecx
	mov $errmsgend-errmsg, %edx
	mov $__NR_write,%eax
	int $0x80
	mov (currkey),%ecx
	mov %ecx,%edx
	sub $buffer,%edx
	cmp $40,%edx
	jle 7f
	mov $40,%edx
7:	sub %edx,%ecx
	mov $__NR_write,%eax
	int $0x80
	mov $errmsgnl,%ecx
	mov $1,%edx
	mov $__NR_write,%eax
	int $0x80
	NEXT

	.section .rodata
errmsg: .ascii "PARSE ERROR: "
errmsgend:
errmsgnl: .ascii "\n"
	.data
	.align 4
interpret_is_lit:
	.int 0

	defcode "CHAR",4,,CHAR
	call _WORD
	xor %eax,%eax
	movb (%edi),%al
	push %eax
	NEXT

	defcode "EXECUTE",7,,EXECUTE
	pop %eax
	jmp *(%eax)

	defcode "SYSCALL3",8,,SYSCALL3
	pop %eax
	pop %ebx
	pop %ecx
	pop %edx
	int $0x80
	push %eax
	NEXT

	defcode "SYSCALL2",8,,SYSCALL2
	pop %eax
	pop %ebx
	pop %ecx
	int $0x80
	push %eax
	NEXT

	defcode "SYSCALL1",8,,SYSCALL1
	pop %eax
	pop %ebx
	int $0x80
	push %eax
	NEXT

	defcode "SYSCALL0",8,,SYSCALL0
	pop %eax
	int $0x80
	push %eax
	NEXT

	.text
	.set INITIAL_DATA_SEGMENT_SIZE,65536
set_up_data_segment:
	xor %ebx,%ebx
	movl $__NR_brk,%eax
	int $0x80
	movl %eax,var_HERE
	addl $INITIAL_DATA_SEGMENT_SIZE,%eax
	movl %eax,%ebx
	movl $__NR_brk,%eax
	int $0x80
	ret

	.set RETURN_STACK_SIZE,8192
	.set BUFFER_SIZE,4096

	.bss
	.align 4096
return_stack:
	.space RETURN_STACK_SIZE
return_stack_top:
	.align 4096
buffer:
	.space BUFFER_SIZE
