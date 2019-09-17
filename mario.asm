%include "asm_io.inc"
%include "io.inc"
; initialized data is put in the .data segment
segment .data
clear db 27,"[2J",27,"[1;1H",0
cc db 27,"c",0
scanFormat db "%c",0
file db "input.txt",0
file1 db "input2.txt",0
mode db "r",0
formatA db "%c",0
x dd 3
y dd 3
prevX dd 0
prevY dd 0
saveprevX dd 0
saveprevY dd 0
scoreScreen db "Score: ", 0
finalString db "Your final score is: ",0
congrats db "Congratuations. You got the best solution.", 0
message db "Gameover, but you can find a better solution.", 0
message1 db "I am sorry, you failed.", 0
prompt db "Do you want to play one more game? y/n: ", 0
prompt1 db "Do you want to play again? y/n: ", 0
level1 db "Level one", 0
level2 db "Level two", 0
score dd 20
rows dd 8
cols dd 27
; uninitialized data is put in the .bss segment
segment .bss
text resb 2000
input resd 1
input1 resd 1
; code is put in the .text segment
segment .text
    global  asm_main
	extern fscanf
	extern fopen
	extern fclose
	extern scanf
	extern getchar
	extern putchar
asm_main:
    enter   0,0               ; setup routine
    pusha
	;***************CODE STARTS HERE*******
	
	start:	mov eax, 3
                mov [x],eax
                mov [y],eax
                mov eax,0
                mov [prevX],eax
                mov [prevY],eax
                mov [saveprevX],eax
                mov [saveprevY],eax
		mov eax, 20
		mov [score], eax
		mov eax, clear    ;two lines to clear
		call print_string ;clear the screen
		mov eax, cc
		mov eax, level1
		call print_string
		call print_nl
		call load	;load the file into text
		call update ;update the file with the location 
		
		mov eax, text
		call print_string
		call print_nl
		mov eax, scoreScreen
		call print_string
		mov eax, [score]
		call print_int
		mov ecx, 500
	  top:
		mov eax, 1
		sub [score], eax
		call movement
		call update
		mov eax, clear    ;two lines to clear
		call print_string ;clear the screen
                mov eax, level1
                call print_string
                call print_nl                
		mov eax, text
		call print_string
		mov eax, scoreScreen
                call print_string
                mov eax, [score]
                call print_int
		mov ebx, [x]
		mov ecx, [y]
		inc ecx
		imul ecx, [cols]
		add ecx, ebx
		mov eax, [text+ecx]
		cmp al, 'E'
		jz gameover
		mov eax, 0
		cmp [score], eax
		jz sorry
		loop top
	gameover:
		mov eax, clear    ;two lines to clear
                call print_string ;clear the screen
		mov eax, finalString
		call print_string
		mov eax, [score]
		call print_int
		call print_nl
		mov eax, [score]
		cmp eax, 490
		jz cong
		mov eax, message
		call print_string
		mov eax, prompt1
		call print_string
		call read_char
		mov [input1], eax
		call getchar
		mov eax, 'y'
		cmp [input1], eax
	 	jz start
		
		jmp donedone
        cong:
		mov eax,congrats
		call print_string
		mov eax, prompt
		call print_string
		call read_char
     		mov [input], eax
		call getchar
		mov eax, 'y'
		cmp [input], eax
		jz secondround		
		jmp donedone

	sorry:
		call print_nl
	        mov eax, message1
		call print_string
		jmp donedone
	secondround:
		mov eax, 3
                mov [x],eax
                mov [y],eax
                mov eax,0
                mov [prevX],eax
                mov [prevY],eax
                mov [saveprevX],eax
                mov [saveprevY],eax
	        mov eax, clear    ;two lines to clear
                call print_string ;clear the screen
                mov eax, cc
		mov eax, level2
		call print_string
		call print_nl
                call load2       ;load the file into text
                call update ;update the file with the location 

                mov eax, text
                call print_string
                call print_nl
	
                mov eax, 20
		mov [score], eax
                mov eax, scoreScreen
                call print_string
                mov eax, [score]
                call print_int
		
                mov ecx, 500
		
	top2:   mov eax, 1
                sub [score], eax
	
                call movement
                call update
                mov eax, clear    ;two lines to clear
                call print_string ;clear the screen
		mov eax, level2
                call print_string
                call print_nl
                mov eax, text
                call print_string
                call print_nl
                mov eax, scoreScreen
                call print_string
                mov eax, [score]
                call print_int
                mov ebx, [x]
                mov ecx, [y]
                inc ecx
                imul ecx, [cols]
                add ecx, ebx
                mov eax, [text+ecx]
                cmp al, 'E'
                jz donedone
                mov eax, 0
                cmp [score], eax
                jz sorry2
                loop top2
	sorry2: call print_nl
                mov eax, message1
                call print_string
		
	donedone:
		call print_nl
		
		
		

	;***************CODE ENDS HERE*********
    popa
    mov     eax, 0            ; return back to C
    leave                     
    ret
;*********************************
;* Function to load var text with*
;* input from input.txt          * 
;*********************************
load:
	push eax
	push esi
	mov esi, 0

	sub esp, 20h
	;get the file pointer
	mov dword [esp+4], mode; the mode for the file which is "r"	
	mov dword [esp], file; the name of the file.  Hard coded here (input.txt)
	call fopen ; call fopen to open the file

	;read stuff
	mov [esp], eax; mov the file pointer to param 1
	mov eax, esp  ;use stack to store a pointer where char goes
	add eax, 1Ch  ;address is 1C up from the bottom of the stack
	mov [esp+8], eax;pointer is param 3
	mov dword [esp+4], scanFormat; fromat is param 2

	mov edx, 0
	mov [prevX], edx
  	mov [prevY], edx

  scan:	call fscanf; call scanf 
	cmp eax, 0 ; eax will be less than 1 when EOF
	jl done; eof means quit
	mov eax, [esp+1Ch]; mov the result (on the stack) to eax
	
	cmp al, 'M'
	jz Mario
	
	mov edx, [prevX]; increment prevX
	inc edx
	mov [prevX], edx

	cmp al, 10
	jz NewLine
	
	jmp save
NewLine:

	mov dword [prevX], 0
	mov edx, [prevY]
	inc edx
	mov [prevY], edx
	jmp save
	
Mario:
	mov edx, [prevX]
	mov [x], edx
	mov edx, [prevY]
	mov [y], edx
	jmp save
	
save:
	
	mov [text + esi], al; store in the array
	inc esi; add one to esi (index in the array)
	cmp esi, 2000; dont go tooo far into the array
	jz done; quit if went too far
	jmp scan ;loop back
done:
	call fclose; close the file pointer
	mov byte [text+esi],0 ;set the last char to null
	add esp, 20h; unallocate stack space
	
	pop esi	;restore registers
	pop eax
	ret
load2:
        push eax
        push esi
        mov esi, 0

        sub esp, 20h
        ;get the file pointer
        mov dword [esp+4], mode; the mode for the file which is "r"     
        mov dword [esp], file1; the name of the file.  Hard coded here (input.txt)
        call fopen ; call fopen to open the file

        ;read stuff
        mov [esp], eax; mov the file pointer to param 1
        mov eax, esp  ;use stack to store a pointer where char goes
        add eax, 1Ch  ;address is 1C up from the bottom of the stack
        mov [esp+8], eax;pointer is param 3
        mov dword [esp+4], scanFormat; fromat is param 2

        mov edx, 0
        mov [prevX], edx
        mov [prevY], edx

  scan2: call fscanf; call scanf 
        cmp eax, 0 ; eax will be less than 1 when EOF
        jl done2; eof means quit
        mov eax, [esp+1Ch]; mov the result (on the stack) to eax

        cmp al, 'M'
        jz Mario2

        mov edx, [prevX]; increment prevX
        inc edx
        mov [prevX], edx

        cmp al, 10
        jz NewLine2

        jmp save2
NewLine2:

        mov dword [prevX], 0
        mov edx, [prevY]
        inc edx
        mov [prevY], edx
        jmp save2

Mario2:
        mov edx, [prevX]
        mov [x], edx
        mov edx, [prevY]
        mov [y], edx
        jmp save2
save2:

        mov [text + esi], al; store in the array
        inc esi; add one to esi (index in the array)
        cmp esi, 2000; dont go tooo far into the array
        jz done2; quit if went too far
        jmp scan2 ;loop back
done2:
        call fclose; close the file pointer
        mov byte [text+esi],0 ;set the last char to null
        add esp, 20h; unallocate stack space

        pop esi ;restore registers
        pop eax
        ret
	;*********************************
	;* Function to update the screen *
	;*                               * 
	;*********************************

update:
	push eax
	push ebx 
	;update the new loc
	mov eax, [x]
	mov ebx, [y]
	mov edx, 0
	imul ebx, [cols]

	add eax, ebx
	mov byte [text + eax], 'M'
	;update the old loc
	mov eax, [prevX]
	mov ebx, [prevY]
	mov edx, 0
	imul ebx, [cols]

	add eax, ebx
	mov byte [text + eax], ' '
	
	pop ebx
	pop eax
	
ret


;*********************************
;* Function to get mouse movement*
;*                               * 
;*********************************
movement:	
	pushad
	mov ebx, [prevX]
	mov [saveprevX], ebx
	mov ebx, [prevY]
	mov [saveprevY],ebx
        mov ebx, [x]
	mov [prevX], ebx;save old value of x in prevX
        mov ebx, [y]
	mov [prevY], ebx; save old value of y in prevY
	call canonical_off
	call echo_off
	mov eax, formatA
	push eax
	;http://stackoverflow.com/questions/15306463/getchar-returns-the-same-value-27-for-up-and-down-arrow-keys
	call getchar
	call getchar
	call getchar
	call canonical_on
	call echo_on
	push eax
	cmp eax, 43h; right
	jz right
	cmp eax, 44h; left
	jz left
	cmp eax, 41h; up
	jz up
	cmp eax, 42h; down
	jz down
	
  right:
	call checkAround
	cmp esi,0
	jz saving
	call fall
	mov eax,[x]
	inc eax
	mov [x], eax        
	jmp mDone
  left:
	call checkAround
	cmp esi, 0
	jz saving
	call fall
   	mov eax, [x]
	dec eax
	mov [x], eax
        jmp mDone
  up:
	mov ebx, [x]
	mov ecx, [y]
	inc ecx
	imul ecx, [cols]
	add ebx, ecx
	mov ebx, [text+ebx]
	cmp bl, ' '
	jz saving
	call checkAround
  	cmp esi, 0
	jz saving
	jmp mDone
  down:
	call checkAround
	cmp esi, 0
	jz saving
	call fall
	jmp mDone
  saving:
	mov eax, [saveprevX]
	mov [prevX],eax
	mov eax, [saveprevY]
	mov [prevY], eax


  mDone:
	add esp,4
	pop eax
	popad
	ret
    ;*********************************
    ;* function to check around the mario *
    ;* up down left right to see if it is *
    ;* movable towards the direction *
    ;*********************************
checkAround: 
	push ebp
	mov ebp, esp
	mov ebx, [x]
	mov ecx, [y]

    mov eax, [ebp+8] ;parameter of arrow key
    cmp eax, 43h; right
    jz checkright
    cmp eax, 44h; left
    jz checkleft
    cmp eax, 42h; down
    jz checkdown
    cmp eax, 41h; up
    jz checkup
    
  checkright:
    imul ecx, [cols]
    add ebx, ecx
    add ebx, 1
    mov eax, [text+ebx];right one
    call goldChecker
    cmp al, 'B'
    jz cantright
    cmp al, '*'
    jz cantright
    cmp al, 'E'
    jz cantright
    jmp canright
    cantright:
    mov esi, 0
    jmp checkdone
    canright:
    mov esi, 1
    jmp checkdone
  checkleft:
    imul ecx, [cols]
    add ebx, ecx
    sub ebx, 1
    mov eax, [text+ebx]
    push ebx
    push eax
    call goldChecker
    cmp al, 'B'
    jz cantleft
    cmp al, '*'
    jz cantleft
    cmp al, 'E'
    jz cantleft
    jmp canleft
    cantleft:
    mov esi, 0
    jmp checkdone
    canleft:
        mov esi, 1
    jmp checkdone
  checkdown:
    inc ecx
    imul ecx, [cols]
    add ebx, ecx
    mov eax, [text+ebx]
    cmp al, 'B'
    jz cantdown
    cmp al, '*'
    jz cantdown
    jmp candown
    cantdown:
    mov esi, 0
    jmp checkdone
    candown:
        mov esi, 1
    jmp checkdone
  checkup:
    mov edx, [y]
    dec edx      
    dec ecx
    imul ecx, [cols] 
    add ebx, ecx
    mov eax, [text+ebx]
    push ebx
    push eax
    call goldChecker
    cmp al, 'B'
    jz stopone
    cmp al, '*'
    jz stopone
    mov ecx, [y]
    mov edx, [y]
    mov ebx, [x]
    sub ecx, 2
    sub edx, 2
    imul ecx, [cols]
    add ebx, ecx
    mov eax, [text+ebx]
    push ebx
    push eax
    call goldChecker
    cmp al, 'B'
    jz stop
    cmp al, '*'
    jz stop
    mov ecx, [y]
    mov edx, [y]
    mov ebx, [x]
    sub ecx, 3
    sub edx, 3
    imul ecx, [cols]
    add ebx, ecx
    mov eax, [text+ebx]
    push ebx
    push eax
    call goldChecker
    cmp al, 'B'
    jz stop
    cmp al, '*'
    jz stop
    jmp nonstop
    stopone:
    inc edx
    mov [y], edx
    mov esi, 0
    jmp checkdone
    stop:
    inc edx
    mov [y], edx
    mov esi, 1
    jmp checkdone
    nonstop:
    mov [y], edx
    mov esi, 1
    jmp checkdone
    
    checkdone:
   
    mov esp, ebp
    pop ebp
    ret
    ;*********************************
    ;* function to calculate where *
    ;* you will fall to *
    ;*********************************
    fall:
    push ebp
    mov ebp, esp
    mov ebx, [ebp+8];arrow key
    mov eax, [x]
    cmp ebx, 44h; left
    jz fallleft
    cmp ebx, 43h; right
    jz fallright
    cmp ebx, 42h; down
    jz falldone
    fallright:
    inc eax
    jmp falldone
    fallleft:
    dec eax
    falldone:
    mov ebx, [y]
    imul ebx, [cols]
    add ebx, eax
    mov ecx, [y]
    godown:
    cmp bl, '*'
    jz end
    cmp bl, 'B'
    jz end
    cmp bl, 'E'
    jz end
    inc ecx
    mov ebx, ecx
    imul ebx, [cols]
    add ebx, eax
    push ebx
    mov ebx, [text+ebx]
    push ebx
    call goldChecker
    jmp godown
    end:
    dec ecx
    mov [y], ecx
   
    mov esp, ebp
    pop ebp
    ret
    ;*********************************
    ;* function to add 100 points *
    ;* when you hit a G. * 
    ;*********************************
    goldChecker:
    push ebp
    mov ebp, esp
    push eax
    push ebx
    mov eax, [ebp+8]; checkGold
    mov ebx, [ebp+12]; location
    cmp al, 'G'
    jz yesgold
    jmp nogold
    yesgold:
    mov eax, 100
    add [score], eax
    mov byte [text+ebx], ' '
    nogold:
    pop ebx
    pop eax
    mov esp, ebp
    pop ebp
    ret
   
