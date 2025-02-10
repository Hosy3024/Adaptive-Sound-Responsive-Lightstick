org   0000h
      jmp   Start
      ORG 000BH
      LJMP Interrupt0
      
Interrupt0:
   CPL P2.7
   RETI

      org   0100h
Start:
      MOV TMOD, #012H
      MOV TL0, #00H
      MOV TH0, #00H
      SETB TR0
      SETB ET0
      SETB EA
      MOV P0, #00000001B
      MOV P1, #00H
      MOV R6, #00H
      MOV R1, #0
      MOV R0, #0FFH
      MOV R3, #0
      Loop:
	 ACALL ADC0808_Read
	 JMP ModeCheck
	 
Delay_10ms:
   MOV TH1, #HIGH(-10000)
   MOV TL1, #LOW(-10000)
   SETB TR1
   JNB TF1, $
   CLR TR1
   CLR TF1
   RET
   
Delay_25ms:
   MOV TH1, #HIGH(-25000)
   MOV TL1, #LOW(-25000)
   SETB TR1
   JNB TF1, $
   CLR TR1
   CLR TF1
   RET
      
ADC0808_Read:
   CLR P2.0
   CLR P2.1
   CLR P2.2
   
   SETB P2.3
   SETB P2.4
   CLR P2.3
   CLR P2.4
Wait_EOC0: 
   JNB P2.5,  Wait_EOC1
   jmp Wait_EOC0
Wait_EOC1: 
   JB P2.5, Go_on
   jmp Wait_EOC1
Go_on:
   SETB P2.6
   MOV R2, P3
   CLR P2.6
   RET

ModeCheck:
   DEC R0
   CJNE R0, #0, Mode_1
   INC R3
   CJNE R3, #2, Mode_1
   MOV R0, #0FFH
   MOV R3, #0
   JMP ChangeMode
   Mode_1:
      CJNE R1, #0, Mode_2
      JMP Mode1
   Mode_2:
      CJNE R1, #1, Mode_3
      JMP Mode2
   Mode_3:
      CJNE R1, #2, resetmode
      JMP Mode3
   resetmode:
      MOV R1, #0
      JMP Mode_1
   ChangeMode:
      MOV A, R1
      ADD A, #1
      MOV R1, A
      CLR A
      JMP Mode_1
      
Mode1:
   INC R2 
Continue:
Row8:
   CJNE R2, #255, Row7
   CJNE R6, #11111111B, Compare
   JMP Loop
Row7:
   CJNE R2, #145, Row6
   CJNE R6, #01111111B, Compare
   JMP Loop
Row6:
   CJNE R2, #140, Row5
   CJNE R6, #00111111B, Compare
   JMP Loop
Row5:
   CJNE R2, #135, Row4
   CJNE R6, #00011111B, Compare
   JMP Loop
Row4:
   CJNE R2, #130, Row3
   CJNE R6, #00001111B, Compare
   JMP Loop
Row3:
   CJNE R2, #120, Row2
   CJNE R6, #00000111B, Compare
   JMP Loop
Row2:
   CJNE R2, #110, Row1
   CJNE R6, #00000011B, Compare
   JMP Loop
Row1:
   CJNE R2, #95, Row0
   CJNE R6, #00000001B, Compare
   JMP Loop
Row0:
   CJNE R2, #80, Row1
   CJNE R6, #00000000B, Compare
   JMP Loop

   
Compare:
	MOV A, #0
	RLC A
	CJNE A, #00000001B, ShiftRight
	CJNE A, #00000000B, ShiftLeft
	
ShiftRight:
	CLR C
	MOV A, R6
	RRC A
	MOV R6, A
	ACALL Delay_10ms
	CLR C
	MOV P1, R6
	JMP Continue
	
ShiftLeft:
	SETB C
	MOV A, R6
	RLC A
	MOV R6, A
	ACALL Delay_10ms
	CLR C
	MOV P1, R6
	JMP Continue

Mode2:
	 MOV A, R2
	 SUBB A, #97
	 MOV A, #0
	 RLC A
	 CJNE A, #00000001B, ShiftLeftC
	 CJNE A, #00000000B, ShiftLeftnoneC
	 ShiftLeftC:
		  SETB C
		  MOV A, R6
		  RRC A
		  MOV R6, A
		  ACALL Delay_10ms
		  CLR C
		  MOV P1, R6
		  JMP Loop
	 ShiftLeftnoneC:
		  CLR C
		  MOV A, R6
		  RRC A
		  MOV R6, A
		  ACALL Delay_10ms
		  CLR C
		  MOV P1, R6
		  JMP Loop
		  
Mode3:
	 MOV P1, R2
	 ACALL Delay_25ms
	 JMP Loop

	
;====================================================================

      END