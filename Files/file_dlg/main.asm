.686
.model flat, stdcall  
option casemap :none  

include		c:\masm32\include\windows.inc
include		c:\masm32\include\kernel32.inc
include		c:\masm32\include\user32.inc
include		c:\masm32\include\Comctl32.inc
include		c:\masm32\include\shell32.inc
include 		c:\masm32\include\winmm.inc
include		c:\masm32\include\masm32.inc
includelib	c:\masm32\lib\kernel32.lib
includelib	c:\masm32\lib\user32.lib
includelib	c:\masm32\lib\Comctl32.lib
includelib	c:\masm32\lib\shell32.lib
includelib 	c:\masm32\lib\winmm.lib
includelib	c:\masm32\lib\masm32.lib

DlgProc PROTO :HWND,:UINT,:WPARAM,:LPARAM
FillBuffer PROTO :DWORD, :DWORD, :DWORD
SaveToFile PROTO :DWORD, :DWORD, :DWORD

.const

IDD_MAIN	equ		101
SIZE_BUF	equ		88200

.data

MBCaption  db "Sound",0
MStart  db "Start",0
MFinish  db "Finish",0
MGo db "Go",0
MFail  db "Fail",0
buffer db SIZE_BUF dup (0)
fileName db 'c:\\1234.bin',0

.data?

hInstance	dd		?
hListBox	dd		?
hFile dd ?
SizeReadWrite dw ?

.code
start:
	invoke	GetModuleHandle,NULL
	mov	hInstance,eax
	invoke	InitCommonControls
	invoke	DialogBoxParam,hInstance,IDD_MAIN,NULL,addr DlgProc,NULL
	invoke	ExitProcess,0

DlgProc	proc hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM		
	mov	eax,uMsg
	.if	eax==WM_INITDIALOG		
		
	.elseif	eax==WM_COMMAND
		mov edx,wParam
		movzx eax,dx
		shr edx,16
		.if edx==BN_CLICKED
			.if eax==IDOK
				invoke FillBuffer, offset buffer, SIZE_BUF, 0ffh				
				invoke SaveToFile, offset fileName, offset buffer, SIZE_BUF
			.elseif eax==IDCANCEL
				invoke MessageBox, NULL, addr MFinish, addr MBCaption, MB_OK
			.endif
		.endif
	.elseif	eax==WM_CLOSE
		invoke	EndDialog,hWin,0
	.else
		mov	eax,FALSE
		ret
	.endif
	mov	eax,TRUE
	ret
DlgProc endp

FillBuffer proc pBuffer:DWORD, bufSize:DWORD, level:DWORD
	invoke  GetTickCount    
	invoke  nseed, eax
	mov ebx, pBuffer
	xor esi, esi
loop_rnd:	
	invoke  nrandom, level    ;0ffh	;mov eax, level	
	mov byte ptr [ebx+esi], al	
	inc esi
	cmp esi, bufSize
	jl loop_rnd
	ret
FillBuffer endp

MakeSound proc	   
    LOCAL whdr:WAVEHDR	
	LOCAL wfx: WAVEFORMATEX
	LOCAL hWO: DWORD 
		
	invoke RtlZeroMemory, addr whdr, sizeof WAVEHDR
	mov whdr.lpData, offset buffer
    mov whdr.dwBufferLength, SIZE_BUF
	    
	invoke RtlZeroMemory, addr wfx, sizeof WAVEFORMATEX
    mov wfx.wFormatTag, WAVE_FORMAT_PCM
    mov wfx.nChannels, 1
    mov wfx.nSamplesPerSec, 44100
    mov wfx.nAvgBytesPerSec, 4*44100
    mov wfx.nBlockAlign, 4
    mov wfx.wBitsPerSample, 16
    mov wfx.cbSize, sizeof WAVEFORMATEX
     
	invoke waveOutOpen, addr hWO, WAVE_MAPPER, addr wfx, 0, 0, CALLBACK_NULL
	.if eax == MMSYSERR_NOERROR	         
        invoke MessageBox, NULL, addr MGo, addr MBCaption, MB_OK				
    .else
        invoke MessageBox, NULL, addr MFail, addr MBCaption, MB_OK
	.endif 
    invoke waveOutPrepareHeader, hWO, addr whdr, sizeof WAVEHDR
    invoke waveOutWrite, hWO, addr whdr, sizeof WAVEHDR  
    invoke MessageBox, NULL, addr MGo, addr MBCaption, MB_OK 
    invoke waveOutUnprepareHeader, hWO, addr whdr, sizeof WAVEHDR
    invoke waveOutReset, hWO
    invoke waveOutClose, hWO
	ret
MakeSound endp

SaveToFile proc pFileName:DWORD, pBuffer:DWORD, szBuffer:DWORD
	LOCAL SZReadWrite: DWORD 
	LOCAL hF: DWORD
	invoke CreateFile, pFileName, \ 
				GENERIC_READ or GENERIC_WRITE, \ 
				FILE_SHARE_READ or FILE_SHARE_WRITE, NULL, \ 
				CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL
	mov hF, eax	
	invoke WriteFile, hF, pBuffer, szBuffer, addr SZReadWrite, NULL
	invoke CloseHandle,hF		
	ret
SaveToFile endp

end start
