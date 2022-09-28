;-------------------------------------------------------------------------------------------------------------------
;// Mladen Stosic
;// Grupa 15
;// Projekat 13 - Simulacija stoperice i tajmera
;-------------------------------------------------------------------------------------------------------------------
;// Init block

include Irvine32.inc

.386
.model flat, stdcall
.stack 4096
ExitProcess proto,dwExitCode:dword

;-------------------------------------------------------------------------------------------------------------------
.const
;// ASCII characters of used keys
	R_KEY = 052h
	ESC_KEY	= 01Bh
	SPACE_KEY = 020h
	ENTER_KEY = 00Dh
;// Console window size bounds
	xmin = 0;
	xmax = 25;
	ymin = 0;
	ymax = 15;
;// Cursor positions for different screens
	x1 = 8;
	y1 = 6;
	x2 = 13;
	y2 = 5;
	x3 = 1;
	y3 = 10;

;-------------------------------------------------------------------------------------------------------------------
.data 
	;// Different screens
	T10 byte  "     _____________          ", 0dh, 0ah, 0
	T11 byte  "    /             \         ", 0dh, 0ah, 0
	T12 byte  "   /    Select     \        ", 0dh, 0ah, 0
	T13 byte  "  /      mode       \       ", 0dh, 0ah, 0
	T14 byte  " /                   \      ", 0dh, 0ah, 0
	T15 byte  " \    1: Stopwatch   /      ", 0dh, 0ah, 0
	T16 byte  "  \    2: Timer     /       ", 0dh, 0ah, 0
	T17 byte  "   \               /        ", 0dh, 0ah, 0
	T18 byte  "    \_____________/         ", 0dh, 0ah, 0

	T20 byte  "     _____________          ", 0dh, 0ah, 0
	T21 byte  "    /             \         ", 0dh, 0ah, 0
	T22 byte  "   /               \        ", 0dh, 0ah, 0
	T23 byte  "  /     SET TIME    \       ", 0dh, 0ah, 0
	T24 byte  " /  minutes seconds  \      ", 0dh, 0ah, 0
	T25 byte  " \                   /      ", 0dh, 0ah, 0
	T26 byte  "  \        :        /       ", 0dh, 0ah, 0
	T27 byte  "   \               /        ", 0dh, 0ah, 0
	T28 byte  "    \_____________/         ", 0dh, 0ah, 0
	
	T30 byte  "     _____________          ", 0dh, 0ah, 0
	T31 byte  "    /             \         ", 0dh, 0ah, 0
	T32 byte  "   /               \        ", 0dh, 0ah, 0
	T33 byte  "  / minutes seconds \       ", 0dh, 0ah, 0
	T34 byte  " /                   \      ", 0dh, 0ah, 0
	T35 byte  " \         :         /      ", 0dh, 0ah, 0
	T36 byte  "  \                 /       ", 0dh, 0ah, 0
	T37 byte  "   \               /        ", 0dh, 0ah, 0
	T38 byte  "    \_____________/         ", 0dh, 0ah, 0
	
	;// Empty string used for clearing console row
	emptyString byte "                          ", 0dh, 0ah, 0
	;// Pop-up message when timer runs out
	message byte " Timer ran out! ",0
	;// Press Enter message to start the timer/stopwatch
	pressEnterMSG byte " Press Enter to start ", 0
	;// Press space to pause message
	pressPauseMSG byte " Press Space to pause/unpause", 0
	;// Define cursors used to write minutes, seconds and messages at different screens
	cursorPos1 COORD <x1, y1>					
	cursorPos2 COORD <x2, y1>
	cursorPos3 COORD <x1, y2>
	cursorPos4 COORD <x2, y2>
	cursorPos5 COORD <x3, y3>
	winTitle byte "Stopwatch", 0					;// Specify console window title
	windowRect SMALL_RECT <xmin, ymin, xmax, ymax>	;// Specify console window size
	cursorInfo CONSOLE_CURSOR_INFO <>				;// Cursor info type
	
;-------------------------------------------------------------------------------------------------------------------

.data?
;// Input and output handles
	stdOutHandle	handle ?
	stdInHandle	handle ? 
;// Variables
	minutes	DWORD ?
	seconds	DWORD ?
	numRead	DWORD ?
	numInp	DWORD ?
	temp	BYTE 16 DUP(? )

;-------------------------------------------------------------------------------------------------------------------
;// MAIN
;-------------------------------------------------------------------------------------------------------------------

.code
main proc

	invoke GetStdHandle, STD_OUTPUT_HANDLE				;// Get output handle
	mov  stdOutHandle, eax						;// Set handle variable to equal outpt handle
	INVOKE GetStdHandle, STD_INPUT_HANDLE				;// Get input handle
	mov stdInHandle, eax						;// Set handle variable to equal input handle

	invoke GetConsoleCursorInfo, stdOutHandle, addr cursorInfo	;// Get current cursor info
	mov  cursorInfo.bVisible, 0					;// Configure cursor as invisible
	invoke SetConsoleCursorInfo, stdOutHandle, addr cursorInfo	;// Set new cursor info

	invoke SetConsoleTitle, addr winTitle					;// Set window title
	invoke SetConsoleWindowInfo, stdOutHandle, TRUE, addr windowRect	;// Set console size
	
start::
	call Clrscr		;// Clear scren
	call homeScreen	;// Draw stopwatch

startLoop:			;// Wait until one of the options is selected
	call ReadChar
	cmp	al, '1'		;// Enter stopwatch settings screen
	jne	check2
	call	stopwatchProc
check2:
	cmp	al, '2'		;// Enter timer settings screen
	jne startLoop		;// If nothing is selected, keep looping
	call	timerProc
	jmp start

main endp

;-------------------------------------------------------------------------------------------------------------------
;// PROCEDURES
;-------------------------------------------------------------------------------------------------------------------

homeScreen PROC
;// Draw homescreen
	mov edx, offset T10
	call WriteString
	mov edx, offset T11
	call WriteString
	mov edx, offset T12
	call WriteString
	mov edx, offset T13
	call WriteString
	mov edx, offset T14
	call WriteString
	mov edx, offset T15
	call WriteString
	mov edx, offset T16
	call WriteString
	mov edx, offset T17
	call WriteString
	mov edx, offset T18
	call WriteString

	RET
homeScreen ENDP

timerSettingsScreen PROC
;// Draw timer settings screen
	mov edx, offset T20
	call WriteString
	mov edx, offset T21
	call WriteString
	mov edx, offset T22
	call WriteString
	mov edx, offset T23
	call WriteString
	mov edx, offset T24
	call WriteString
	mov edx, offset T25
	call WriteString
	mov edx, offset T26
	call WriteString
	mov edx, offset T27
	call WriteString
	mov edx, offset T28
	call WriteString

	RET
timerSettingsScreen ENDP

timerScreen PROC	
;// Draw timer screen
	mov edx, offset T30
	call WriteString
	mov edx, offset T31
	call WriteString
	mov edx, offset T32
	call WriteString
	mov edx, offset T33
	call WriteString
	mov edx, offset T34
	call WriteString
	mov edx, offset T35
	call WriteString
	mov edx, offset T36
	call WriteString
	mov edx, offset T37
	call WriteString
	mov edx, offset T38
	call WriteString

	RET
timerScreen ENDP

clearField PROC
;// Clear 2 spaces from given cursor position
	mov al, ' '
	call WriteChar
	mov al, ' '
	call WriteChar

	RET
clearField ENDP


stopwatchProc PROC
;// Stopwatch procedure
	invoke GetConsoleCursorInfo, stdOutHandle, addr cursorInfo	;// Get current cursor info
	mov  cursorInfo.bVisible, 0							;// Configure cursor as invisible
	invoke SetConsoleCursorInfo, stdOutHandle, addr cursorInfo	;// Set new cursor info

;//-----------------------Draw initial screen---------------------------------------------------------------------------
	call Clrscr										;// Clear screen
	call timerScreen									;// Draw timer settings screen
reset:
	mov eax, 0
	mov minutes, eax									;// Set value of minutes to 0
	mov seconds, eax									;// Set value of seconds to 0
	invoke SetConsoleCursorPosition, stdOutHandle, cursorPos3	;// Position cursor beneath minutes label
	call clearField									;// Clear minutes field
	invoke SetConsoleCursorPosition, stdOutHandle, cursorPos3	;// Position cursor beneath minutes label
	mov eax, minutes									;// Write minutes value to the screen
	call WriteDec
	invoke SetConsoleCursorPosition, stdOutHandle, cursorPos4	;// Position cursor beneath seconds label
	call clearField									;// Clear seconds field
	invoke SetConsoleCursorPosition, stdOutHandle, cursorPos4	;// Position cursor beneath seconds label
	mov eax, seconds									;// Write seconds value to the screen
	call WriteDec
	call WaitForEnter									;// Wait for Enter key to be pressed to start counting
minutesLoop:
	invoke SetConsoleCursorPosition, stdOutHandle, cursorPos3	;// Position cursor beneath minutes label
	call clearField
	invoke SetConsoleCursorPosition, stdOutHandle, cursorPos3	;// Position cursor beneath minutes label
	mov eax, minutes
	call WriteDec										;// Write minutes value to the screen
	mov eax, 0
	mov seconds, eax									;// Set values of seconds to 0
secondsLoop:
	;// Check if any button was pressed
	invoke GetNumberOfConsoleInputEvents, stdInHandle, addr numInp
	mov eax, numInp
	cmp eax, 0										;// Check if input buffer is empty
	je cont
	invoke ReadConsoleInput, stdInHandle, addr temp, 1, addr numRead
	mov dx, word PTR temp								;// Check event type
	cmp dx, 1											;// if true keep going
	jne cont
	mov dl, byte PTR[temp + 4]							;// If only button release is detected
	cmp dl, 0											;// discard and continue
	je cont
	mov dl, byte PTR[temp + 10]							;// Check which button is pressed
	cmp dl, ESC_KEY									;// if ESC is pressed return to start screen
	je quit
	cmp dl, R_KEY										;// If R is pressed, reset stopwatch
	je reset
	cmp dl, SPACE_KEY									;// If SPACE key is pressed, pause the timer
	jne cont											;// until space is pressed again
hold:
	;// Check if any button is pressed
	invoke GetNumberOfConsoleInputEvents, stdInHandle, addr numInp
	mov eax, numInp
	cmp eax, 0										;// Check if input buffer is empty
	je hold
	invoke ReadConsoleInput, stdInHandle, addr temp, 1, addr numRead
	mov dx, word PTR temp								;// Check event type
	cmp dx, 1											;// if true keep looping
	jne hold
	mov dl, byte PTR[temp + 4]							;// If only button release is detected
	cmp dl, 0											;// discard and continue
	je hold
	mov dl, byte PTR[temp + 10]							;// Check which button is pressed
	cmp dl, ESC_KEY									;// if ESC is pressed return to start screen
	je quit
	cmp dl, R_KEY										;// If R is pressed, reset stopwatch
	je reset
	cmp dl, SPACE_KEY									;// if SPACE key is pressed, continue program
	jne hold											;// Else keep looping
cont:
	invoke SetConsoleCursorPosition, stdOutHandle, cursorPos4	;// Position cursor beneath seconds label
	call clearField									;// Clear seconds field
	invoke SetConsoleCursorPosition, stdOutHandle, cursorPos4	;// Position cursor beneath seconds label
	mov eax, seconds									;// Write seconds value to the screen
	call WriteDec										
	mov eax, seconds									;// Increment seconds variable
	inc eax									
	mov seconds, eax
	mov eax, 1000										;// Delay for 1s
	call Delay
	mov eax, seconds									;// Check if seconds variable is at or over 60
	cmp eax, 60										;// If it is increment minutes and reset seconds
	jne secondsLoop
	mov eax, minutes
	inc eax											
	mov minutes, eax
	jmp minutesLoop
quit:
	jmp start

	RET
stopwatchProc ENDP

timerProc PROC
;// Timer procedure
timer:	
	invoke GetConsoleCursorInfo, stdOutHandle, addr cursorInfo	;// Get current cursor info
	mov	cursorInfo.bVisible, 1							;// Configure cursor as visible
	invoke SetConsoleCursorInfo, stdOutHandle, addr cursorInfo	;// Set new cursor info
min:	call Clrscr										;// Clear screen
	call timerSettingsScreen								;// Draw timer settings screen
	invoke SetConsoleCursorPosition, stdOutHandle, cursorPos1	;// Position cursor beneath minutes label
	call ReadDec										;// Read minutes input
	mov ebx, 60
	cmp eax, ebx										;// Check if input is less than 60 minutes
	jns	min											;// If not, jump back to input
	mov minutes, eax									;// Store in minutes variable
sec:	invoke SetConsoleCursorPosition, stdOutHandle, cursorPos2	;// Position cursor beneath seconds label
	call clearField									;// Clear seconds field
	invoke SetConsoleCursorPosition, stdOutHandle, cursorPos2	;// Position cursor beneath seconds label
	call ReadDec										;// Read seconds input
	mov ebx, 60										;// Check if entered value is less than 60
	cmp eax, ebx
	jns min											;// If not repeat whole input proc
	mov seconds, eax									;// Store in seconds variable
	invoke GetConsoleCursorInfo, stdOutHandle, addr cursorInfo	;// Get current cursor info
	mov	cursorInfo.bVisible, 0							;// Configure cursor as invisible
	invoke SetConsoleCursorInfo, stdOutHandle, addr cursorInfo	;// Set new cursor info

;//----------------Draw timer-------------------------------------------------------------------------------
	call Clrscr										;// Clear screen
	call timerScreen									;// Draw timer graphic 
	invoke SetConsoleCursorPosition, stdOutHandle, cursorPos4	;// Position cursor beneath seconds label
	mov eax, seconds									;// Write seconds value to the screen
	call WriteDec
	invoke SetConsoleCursorPosition, stdOutHandle, cursorPos3	;// Position cursor beneath minutes label
	call	clearField									;// Clear minute field
	invoke SetConsoleCursorPosition, stdOutHandle, cursorPos3	;// Position cursor beneath minutes label
	mov	eax, minutes									;// Write minutes value to the screen
	call WriteDec
	call WaitForEnter									;// Wait for enter key to be pressed
minloop :
	invoke SetConsoleCursorPosition, stdOutHandle, cursorPos3	;// Position cursor beneath minutes label
	call	clearField									;// Clear minute field
	invoke SetConsoleCursorPosition, stdOutHandle, cursorPos3	;// Position cursor beneath minutes label
	mov	eax, minutes									;// Write minutes value to the screen
	call WriteDec
timerloop :
	mov ecx, seconds									;// Decrement seconds variable
	dec ecx
	mov seconds, ecx
	invoke SetConsoleCursorPosition, stdOutHandle, cursorPos4	;// Position cursor beneath seconds label
	call clearField									;// Clear seconds field
	invoke SetConsoleCursorPosition, stdOutHandle, cursorPos4	;// Position cursor beneath seconds label
	mov eax, seconds									;// Write seconds value to the screen
	call WriteDec
	mov eax, 1000										;// Delay 1s, not the best since all other operations 
	call Delay										;// also take some time but close enough 
	mov eax, seconds
	cmp eax, 0										;// If we haven't reached 0 seconds keep looping
	jne timerloop
	mov eax, minutes									;// Check if 0 minutes reached
	cmp eax, 0
	je exitlabel
	dec eax											;// If not 0 minutes, decrement minutes variable
	mov minutes, eax
	mov eax, 60										;// Update seconds variable to 60
	mov seconds, eax
	jmp minloop										;// Jump to write minutes value to the screen
exitlabel:
	;// Pop-up
	mov edx, offset message								;// Load message string into edx
	mov ebx, 0
	call MsgBox										;// Call msgbox procedure

	RET
timerProc ENDP

WaitForEnter PROC
	;// Write "Press enter to start" beneath the stopwatch/timer
	invoke SetConsoleCursorPosition, stdOutHandle, cursorPos5
	mov edx, offset pressEnterMSG
	call writeString
enter_loop:
	;// Check if any button is pressed
	invoke GetNumberOfConsoleInputEvents, stdInHandle, addr numInp
	mov eax, numInp
	cmp eax, 0										;// Check if input buffer is empty
	je enter_loop
	invoke ReadConsoleInput, stdInHandle, addr temp, 1, addr numRead
	mov dx, word PTR temp								;// Check event type
	cmp dx, 1											;// if true keep going
	jne enter_loop
	mov dl, byte PTR[temp + 4]							;// If only button release is detected
	cmp dl, 0											;// discard and continue looping
	je enter_loop
	mov dl, byte PTR[temp + 10]							;// Check which button is pressed
	cmp dl, ENTER_KEY									;// if ENTER break from the loop
	jne enter_loop

	;// Clear message beneath stopwatch/timer
	invoke SetConsoleCursorPosition, stdOutHandle, cursorPos5
	mov edx, offset emptyString
	call WriteString
	RET
WaitForEnter ENDP
end main