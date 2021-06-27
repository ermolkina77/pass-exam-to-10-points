
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
  jmp     dword ptr CS:[old_1Ch]  ; в обработчик прерываний без вовзрата
  
  iret
new_1Ch     endp
;===========================================================================

;============================================================================
new_09h proc far
pushf
  ; Получение нажатой клавиши 
  in al, 60H   
  cmp al, 77   
  jnz keytest1    
  ; Вправо   
  inc bx   
  inc bx    
keytest1:   
  ; влево   
  ja keytest2   
  dec bx   
  dec bx   
keytest2:     
  
  popf
  jmp     dword ptr CS:[old_09h]  ; в обработчик прерываний без вовзрата
  
  iret
new_09h     endp
;===========================================================================
int_2Fh proc far
    cmp     AH,0C7h         ; Наш номер?
    jne     Pass_2Fh        ; Нет, на выход
    cmp     AL,00h          ; Подфункция проверки на повторную установку?
    je      inst            ; Программа уже установлена
    cmp     AL,01h          ; Подфункция выгрузки?
    je      unins           ; Да, на выгрузку
    jmp     short Pass_2Fh  ; Неизвестная подфункция - на выход
inst:
    mov     AL,0FFh         ; Сообщим о невозможности повторной установки
    iret
Pass_2Fh:
    jmp dword PTR CS:[old_2Fh]
;
; -------------- Проверка - возможна ли выгрузка программы из памяти 09h ? ------
unins:
    push    BX
    push    CX
    push    DX
    push    ES
;
    mov     CX,CS   ; Пригодится для сравнения, т.к. с CS сравнивать нельзя
    mov     AX,3509h    ; Проверить вектор 09h
    int     21h ; Функция 35h в AL - номер прерывания. Возврат-вектор в ES:BX
;
    mov     DX,ES
    cmp     CX,DX
    jne     Not_remove
;
    cmp     BX, offset CS:new_09h
    jne     Not_remove
;
    mov     AX,352Fh    ; Проверить вектор 2Fh
    int     21h ; Функция 35h в AL - номер прерывания. Возврат-вектор в ES:BX
;
    mov     DX,ES
    cmp     CX,DX
    jne     Not_remove
;
    cmp     BX, offset CS:int_2Fh
    jne     Not_remove
; ---------------------- Выгрузка программы из памяти 09h ---------------------
;
    push    DS
;
    lds     DX, CS:old_09h   ; Эта команда эквивалентна следующим двум
;    mov     DX, word ptr old_09h
;    mov     DS, word ptr old_09h+2
    mov     AX,2509h        ; Заполнение вектора старым содержимым
    int     21h
;
    lds     DX, CS:old_2Fh   ; Эта команда эквивалентна следующим двум
;    mov     DX, word ptr old_2Fh
;    mov     DS, word ptr old_2Fh+2
    mov     AX,252Fh
    int     21h
;
    pop     DS
;
    mov     ES,CS:2Ch       ; ES -> окружение
    mov     AH, 49h         ; Функция освобождения блока памяти
    int     21h
;
    mov     AX, CS
    mov     ES, AX          ; ES -> PSP выгрузим саму программу
    mov     AH, 49h         ; Функция освобождения блока памяти
    int     21h
;
    mov     AL,0Fh          ; Признак успешной выгрузки
    jmp     short pop_ret
Not_remove:
    mov     AL,0F0h          ; Признак - выгружать нельзя
pop_ret:
    pop     ES
    pop     DX
    pop     CX
    pop     BX
;
	
	; -------------- Проверка - возможна ли выгрузка программы из памяти 1Ch? ------
unins2:
    push    BX
    push    CX
    push    DX
    push    ES
;
    mov     CX,CS   ; Пригодится для сравнения, т.к. с CS сравнивать нельзя
    mov     AX,351Ch    ; Проверить вектор 1Ch
    int     21h ; Функция 35h в AL - номер прерывания. Возврат-вектор в ES:BX
;
    mov     DX,ES
    cmp     CX,DX
    jne     Not_remove2
;
    cmp     BX, offset CS:new_1Ch
    jne     Not_remove2
;
    mov     AX,352Fh    ; Проверить вектор 2Fh
    int     21h ; Функция 35h в AL - номер прерывания. Возврат-вектор в ES:BX
;
    mov     DX,ES
    cmp     CX,DX
    jne     Not_remove2
;
    cmp     BX, offset CS:int_2Fh
    jne     Not_remove2
; ---------------------- Выгрузка программы из памяти 1Ch---------------------
;
    push    DS
;
    lds     DX, CS:old_1Ch   ; Эта команда эквивалентна следующим двум
;    mov     DX, word ptr old_1Ch
;    mov     DS, word ptr old_1Ch+2
    mov     AX,251Ch        ; Заполнение вектора старым содержимым
    int     21h
;
    lds     DX, CS:old_2Fh   ; Эта команда эквивалентна следующим двум
;    mov     DX, word ptr old_2Fh
;    mov     DS, word ptr old_2Fh+2
    mov     AX,252Fh
    int     21h
;
    pop     DS
;
    mov     ES,CS:2Ch       ; ES -> окружение
    mov     AH, 49h         ; Функция освобождения блока памяти
    int     21h
;
    mov     AX, CS
    mov     ES, AX          ; ES -> PSP выгрузим саму программу
    mov     AH, 49h         ; Функция освобождения блока памяти
    int     21h
;
    mov     AL,0Fh          ; Признак успешной выгрузки
    jmp     short pop_ret
Not_remove2:
    mov     AL,0F0h          ; Признак - выгружать нельзя
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

; Проверим, не установлена ли уже эта программа
check_install:
        mov AX,0C700h   ; AH=0C7h номер процесса C7h
                        ; AL=00h -дать статус установки процесса
        int 2Fh         ; мультиплексное прерывание
        cmp AL,0FFh
        je  already_ins ; возвращает AL=0FFh если установлена
;----------------------------------------------------------------------------
    cmp flag_off,1
    je  next
;----------------------------------------------------------------------------
    mov AX,352Fh                      ;   получить
                                      ;   вектор
    int 21h                           ;   прерывания  2Fh
    mov word ptr old_2Fh,BX    ;   ES:BX - вектор
    mov word ptr old_2Fh+2,ES  ;
;
    mov DX,offset int_2Fh           ;   получить смещение точки входа в новый
                                    ;   обработчик на DX
    mov AX,252Fh                    ;   функция установки прерывания
                                    ;   изменить вектор 2Fh
    int 21h  ; AL - номер прерыв. DS:DX - указатель программы обработки прер.
;----------------------------------------------------------------------------

    mov AX,3509h                        ;   получить
                                        ;   вектор
    int 21h                             ;   прерывания  09h
    mov word ptr old_09h,BX    ;   ES:BX - вектор
    mov word ptr old_09h+2,ES  ;
    mov DX,offset new_09h           ;   получить смещение точки входа в новый
;                                   ;   обработчик на DX
    mov AX,2509h                        ;   функция установки прерывания
                                        ;   изменить вектор 09h
    int 21h ;   AL - номер прерыв. DS:DX - указатель программы обработки прер.
;


mov AX,351Ch                        ;   получить
                                        ;   вектор
    int 21h                             ;   прерывания  09h
    mov word ptr old_1Ch,BX    ;   ES:BX - вектор
    mov word ptr old_1Ch+2,ES  ;
    mov DX,offset new_1Ch           ;   получить смещение точки входа в новый
;                                   ;   обработчик на DX
    mov AX,251Ch                        ;   функция установки прерывания
                                        ;   изменить вектор 09h
    int 21h ;   AL - номер прерыв. DS:DX - указатель программы обработки прер.
;


next:
pop DX
pop CX
pop BX
pop AX
  ; ds указывает на видеопам€ть  
  push 0b800H  
  pop ds  
  ; установить графический режим 40?25  
  int 10H  
  ; bx = 700H - смещение, по которому находитьс€ грузовик  
  mov bh, 7H
  
   
main_loop:   
  ; Задержка и вывод грузовика на экран   
  xchg cx, ax  ; mov ah, 0   
  int 1AH   
  mov [bx], dl   
  int 1Ch
    
  ; si - смещение следующего препятствия   
  xchg ax, si   
  add al, dl   
  xchg ax, si   
     
  xchg ax, cx   ; mov cx, 0   
    
  ;очистка буфера клавиатуры  
  mov ah, 0CH   
  int 21H
  ; скролл экрана на 1 строчку   
  mov ax, 0701H   
  mov dx, 1827H   
  int 10H   
     
  ; вывод препятствия   
  mov [si], ax   
  ; вывод травы и разделительной полосы   
  mov [di+79], dx   
  ; проверка что перед грузовиком нет препятствий   
  cmp [bx], dh   
  ja main_loop 
  jna to_end
  
  already_ins:
        cmp flag_off,1      ; Запрос на выгрузку установлен?
        je  uninstall       ; Да, на выгрузку
		jmp next
; ------------------ Выгрузка -----------------------------------------------
 uninstall:
        mov AX,0C701h  ; AH=0C7h номер процесса C7h, подфункция 01h-выгрузка
        int 2Fh             ; мультиплексное прерывание
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

