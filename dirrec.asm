.386
.model flat,stdcall
option casemap:none

include c:\masm32\include\windows.inc
include c:\masm32\include\gdi32.inc
include c:\masm32\include\gdiplus.inc
include c:\masm32\include\user32.inc
include c:\masm32\include\kernel32.inc
include c:\masm32\include\msvcrt.inc

includelib c:\masm32\lib\gdi32.lib
includelib c:\masm32\lib\kernel32.lib
includelib c:\masm32\lib\user32.lib
includelib c:\masm32\lib\msvcrt.lib

.DATA
; variables initialisees
strCommand 				db	"Pause",13,10,0
root 					db	"C:\Users\isador\Desktop\asm\projet\",0
endpath 				db 	"\*", 0
dirseparator 			db 	"\", 0
displayLine 			db	"%s%s %s",13,10,0
gte 					db	"PATH: %s",13,10,0
gte2 					db	"2: %d",13,10,0
dir 					db	"<DIR> ",0
file 					db	"<FILE> ",0
currentDir 				db	".",0
prevDir 				db	"..",0
step					dw	0

displayIndentation 		db "|", 0
TAB						db 9,0


.DATA?
; variables non-initialisees (bss)
fileData WIN32_FIND_DATA <> ; 318 bytes
pathcpy db ?


.CODE

displayFile PROC
	push ebp
	mov ebp, esp
	sub esp, 4
	
	mov eax, [ebp+8]
	mov [ebp-4], eax
	
	indentLoop:
	
	push offset TAB
	push offset displayIndentation
	call lstrcat ; concat TAB
	
	mov eax, [ebp-4]
	dec eax
	mov [ebp-4], eax
	cmp eax, 0h
	jne indentLoop
	
	
	push offset fileData.cFileName
	cmp fileData.dwFileAttributes, 10h ;check if file is a dir
	je isDir
		
	; if file is a file
	push offset file
	jmp endf
		
	isDir: ; if file is a dir
		push offset dir
	
	
	endf:
		push offset displayIndentation
		push offset displayLine
		call crt_printf
		mov esp, ebp
		pop ebp
		ret
displayFile ENDP


listDir PROC
	push ebp
	mov ebp, esp
	
	sub esp, 4
	
	start:
	
	
	push offset fileData
	push offset pathcpy
	call FindFirstFileA ;init for file search
	mov [ebp-4], eax
	
	
	mainLoop: ; main loop
		
		
		push offset fileData.cFileName
		push offset currentDir
		call crt_strcmp
		add esp, 8
		cmp eax, 0
		je next
		
		push offset fileData.cFileName
		push offset prevDir
		call crt_strcmp
		add esp, 8
		cmp eax, 0
		je next

		cmp fileData.dwFileAttributes, 10h
		jne next_file
		
		
		push offset pathcpy

		push offset pathcpy
		call lstrlen
		sub eax, 2
		mov edx, eax
		
		
		cmp step, 0
		jne subSubDir
		
		push offset root
		push offset pathcpy
		call lstrcpy ; copy root path
		
		push offset fileData.cFileName
		push offset pathcpy
		call lstrcat ; concat fileData.cFileName
		
		push offset endpath
		push offset pathcpy
		call lstrcat ; concat endpath '/*'
		
		jmp nextSubDir
		
		subSubDir:
			lea ecx, pathcpy
			mov bl, 0h
			mov [edx+ecx], bl
			push offset dirseparator
			push offset pathcpy
			call lstrcat ; concat dirseparator '/'
			
			push offset fileData.cFileName
			push offset pathcpy
			call lstrcat ; concat fileData.cFileName
			
			push offset endpath
			push offset pathcpy
			call lstrcat ; concat endpath '/*'
		
		nextSubDir:
		push offset pathcpy
		push offset gte
		call crt_printf
		
		push step
		push [ebp-4]
		push fileData
		inc step
		call listDir
		pop fileData
		pop [ebp-4]
		pop step

		add esp, 4
		pop eax
		mov dword ptr[pathcpy], eax
		
		
		next_file:
		push step
		call displayFile
		
		next: 
		push offset fileData
		push [ebp-4]
		call FindNextFile
		test eax, eax ; check if is last file
		jnz mainLoop
	
	
	
	endf:
		mov esp, ebp
		pop ebp
		ret
listDir ENDP

start:

		push offset root
		push offset pathcpy
		call lstrcpy ; copy root path
		
		push offset endpath
		push offset pathcpy
		call lstrcat ; concat endpath '/*'
		call listDir
		
		invoke crt_system, offset strCommand
		mov eax, 0
	    invoke	ExitProcess,eax

end start

