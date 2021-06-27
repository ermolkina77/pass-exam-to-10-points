
code_seg segment
        ASSUME  CS:CODE_SEG,DS:code_seg,ES:code_seg
org 100h
start:
    jmp begin
;----------------------------------------------------------------------------
int_2Fh_vector  DD  ?
old_09h         DD  ?
pos				DW	?
old_2Fh  		DD  ?
old_1Ch			DD	?
;----------------------------------------------------------------------------
new_1Ch proc far
pushf
  delay:   
  int 1AH   
  cmp [bx], dl   
  je delay         
  popf
  jmp     dword ptr CS:[old_1Ch]  ; � ���������� ���������� ��� ��������
  
  iret
new_1Ch     endp
;===========================================================================

;============================================================================
new_09h proc far
pushf
  ; ��������� ������� ������� 
  in al, 60H   
  cmp al, 77   
  jnz keytest1    
  ; ������   
  inc bx   
  inc bx    
keytest1:   
  ; �����   
  ja keytest2   
  dec bx   
  dec bx   
keytest2:     
  
  popf
  jmp     dword ptr CS:[old_09h]  ; � ���������� ���������� ��� ��������
  
  iret
new_09h     endp
;===========================================================================
int_2Fh proc far
    cmp     AH,0C7h         ; ��� �����?
    jne     Pass_2Fh        ; ���, �� �����
    cmp     AL,00h          ; ���������� �������� �� ��������� ���������?
    je      inst            ; ��������� ��� �����������
    cmp     AL,01h          ; ���������� ��������?
    je      unins           ; ��, �� ��������
    jmp     short Pass_2Fh  ; ����������� ���������� - �� �����
inst:
    mov     AL,0FFh         ; ������� � ������������� ��������� ���������
    iret
Pass_2Fh:
    jmp dword PTR CS:[old_2Fh]
;
; -------------- �������� - �������� �� �������� ��������� �� ������ 09h ? ------
unins:
    push    BX
    push    CX
    push    DX
    push    ES
;
    mov     CX,CS   ; ���������� ��� ���������, �.�. � CS ���������� ������
    mov     AX,3509h    ; ��������� ������ 09h
    int     21h ; ������� 35h � AL - ����� ����������. �������-������ � ES:BX
;
    mov     DX,ES
    cmp     CX,DX
    jne     Not_remove
;
    cmp     BX, offset CS:new_09h
    jne     Not_remove
;
    mov     AX,352Fh    ; ��������� ������ 2Fh
    int     21h ; ������� 35h � AL - ����� ����������. �������-������ � ES:BX
;
    mov     DX,ES
    cmp     CX,DX
    jne     Not_remove
;
    cmp     BX, offset CS:int_2Fh
    jne     Not_remove
; ---------------------- �������� ��������� �� ������ 09h ---------------------
;
    push    DS
;
    lds     DX, CS:old_09h   ; ��� ������� ������������ ��������� ����
;    mov     DX, word ptr old_09h
;    mov     DS, word ptr old_09h+2
    mov     AX,2509h        ; ���������� ������� ������ ����������
    int     21h
;
    lds     DX, CS:old_2Fh   ; ��� ������� ������������ ��������� ����
;    mov     DX, word ptr old_2Fh
;    mov     DS, word ptr old_2Fh+2
    mov     AX,252Fh
    int     21h
;
    pop     DS
;
    mov     ES,CS:2Ch       ; ES -> ���������
    mov     AH, 49h         ; ������� ������������ ����� ������
    int     21h
;
    mov     AX, CS
    mov     ES, AX          ; ES -> PSP �������� ���� ���������
    mov     AH, 49h         ; ������� ������������ ����� ������
    int     21h
;
    mov     AL,0Fh          ; ������� �������� ��������
    jmp     short pop_ret
Not_remove:
    mov     AL,0F0h          ; ������� - ��������� ������
pop_ret:
    pop     ES
    pop     DX
    pop     CX
    pop     BX
;
	
	; -------------- �������� - �������� �� �������� ��������� �� ������ 1Ch? ------
unins2:
    push    BX
    push    CX
    push    DX
    push    ES
;
    mov     CX,CS   ; ���������� ��� ���������, �.�. � CS ���������� ������
    mov     AX,351Ch    ; ��������� ������ 1Ch
    int     21h ; ������� 35h � AL - ����� ����������. �������-������ � ES:BX
;
    mov     DX,ES
    cmp     CX,DX
    jne     Not_remove2
;
    cmp     BX, offset CS:new_1Ch
    jne     Not_remove2
;
    mov     AX,352Fh    ; ��������� ������ 2Fh
    int     21h ; ������� 35h � AL - ����� ����������. �������-������ � ES:BX
;
    mov     DX,ES
    cmp     CX,DX
    jne     Not_remove2
;
    cmp     BX, offset CS:int_2Fh
    jne     Not_remove2
; ---------------------- �������� ��������� �� ������ 1Ch---------------------
;
    push    DS
;
    lds     DX, CS:old_1Ch   ; ��� ������� ������������ ��������� ����
;    mov     DX, word ptr old_1Ch
;    mov     DS, word ptr old_1Ch+2
    mov     AX,251Ch        ; ���������� ������� ������ ����������
    int     21h
;
    lds     DX, CS:old_2Fh   ; ��� ������� ������������ ��������� ����
;    mov     DX, word ptr old_2Fh
;    mov     DS, word ptr old_2Fh+2
    mov     AX,252Fh
    int     21h
;
    pop     DS
;
    mov     ES,CS:2Ch       ; ES -> ���������
    mov     AH, 49h         ; ������� ������������ ����� ������
    int     21h
;
    mov     AX, CS
    mov     ES, AX          ; ES -> PSP �������� ���� ���������
    mov     AH, 49h         ; ������� ������������ ����� ������
    int     21h
;
    mov     AL,0Fh          ; ������� �������� ��������
    jmp     short pop_ret
Not_remove2:
    mov     AL,0F0h          ; ������� - ��������� ������
pop_ret2:
    pop     ES
    pop     DX
    pop     CX
    pop     BX
;
    iret

int_2Fh endp
;============================================================================
begin:
push AX
push BX
push CX
push DX

; ��������, �� ����������� �� ��� ��� ���������
check_install:
        mov AX,0C700h   ; AH=0C7h ����� �������� C7h
                        ; AL=00h -���� ������ ��������� ��������
        int 2Fh         ; �������������� ����������
        cmp AL,0FFh
        je  already_ins ; ���������� AL=0FFh ���� �����������
;----------------------------------------------------------------------------
    cmp flag_off,1
    je  next
;----------------------------------------------------------------------------
    mov AX,352Fh                      ;   ��������
                                      ;   ������
    int 21h                           ;   ����������  2Fh
    mov word ptr old_2Fh,BX    ;   ES:BX - ������
    mov word ptr old_2Fh+2,ES  ;
;
    mov DX,offset int_2Fh           ;   �������� �������� ����� ����� � �����
                                    ;   ���������� �� DX
    mov AX,252Fh                    ;   ������� ��������� ����������
                                    ;   �������� ������ 2Fh
    int 21h  ; AL - ����� ������. DS:DX - ��������� ��������� ��������� ����.
;----------------------------------------------------------------------------

    mov AX,3509h                        ;   ��������
                                        ;   ������
    int 21h                             ;   ����������  09h
    mov word ptr old_09h,BX    ;   ES:BX - ������
    mov word ptr old_09h+2,ES  ;
    mov DX,offset new_09h           ;   �������� �������� ����� ����� � �����
;                                   ;   ���������� �� DX
    mov AX,2509h                        ;   ������� ��������� ����������
                                        ;   �������� ������ 09h
    int 21h ;   AL - ����� ������. DS:DX - ��������� ��������� ��������� ����.
;


mov AX,351Ch                        ;   ��������
                                        ;   ������
    int 21h                             ;   ����������  09h
    mov word ptr old_1Ch,BX    ;   ES:BX - ������
    mov word ptr old_1Ch+2,ES  ;
    mov DX,offset new_1Ch           ;   �������� �������� ����� ����� � �����
;                                   ;   ���������� �� DX
    mov AX,251Ch                        ;   ������� ��������� ����������
                                        ;   �������� ������ 09h
    int 21h ;   AL - ����� ������. DS:DX - ��������� ��������� ��������� ����.
;


next:
pop DX
pop CX
pop BX
pop AX
  ; ds ��������� �� �����������  
  push 0b800H  
  pop ds  
  ; ���������� ����������� ����� 40?25  
  int 10H  
  ; bx = 700H - ��������, �� �������� ���������� ��������  
  mov bh, 7H
  
   
main_loop:   
  ; �������� � ����� ��������� �� �����   
  xchg cx, ax  ; mov ah, 0   
  int 1AH   
  mov [bx], dl   
  int 1Ch
    
  ; si - �������� ���������� �����������   
  xchg ax, si   
  add al, dl   
  xchg ax, si   
     
  xchg ax, cx   ; mov cx, 0   
    
  ;������� ������ ����������  
  mov ah, 0CH   
  int 21H
  ; ������ ������ �� 1 �������   
  mov ax, 0701H   
  mov dx, 1827H   
  int 10H   
     
  ; ����� �����������   
  mov [si], ax   
  ; ����� ����� � �������������� ������   
  mov [di+79], dx   
  ; �������� ��� ����� ���������� ��� �����������   
  cmp [bx], dh   
  ja main_loop 
  jna to_end
  
  already_ins:
        cmp flag_off,1      ; ������ �� �������� ����������?
        je  uninstall       ; ��, �� ��������
		jmp next
; ------------------ �������� -----------------------------------------------
 uninstall:
        mov AX,0C701h  ; AH=0C7h ����� �������� C7h, ���������� 01h-��������
        int 2Fh             ; �������������� ����������
        cmp AL,0F0h
        je  not_sucsess
        cmp AL,0Fh
        jne not_sucsess
		jmp next
not_sucsess:
		jmp next
xm_stranno:
		jmp next
;----------------------------------------------------------------------------
key         DB  '/off'
flag_off    DB  0
;============================================================================
PRINT       PROC NEAR
    MOV AH,09H
    INT 21H
    RET
PRINT       ENDP
;;============================================================================

to_end:
  mov DX,offset begin
  int 27h
code_seg ends
end start 

