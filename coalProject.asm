Include Irvine32.inc

.data
; System Messages
M_BORDER BYTE "************************************", 0
M_WELCOME_TEXT BYTE "*        WELCOME TO XYZ BANK       *", 0
M_ROLE_PROMPT BYTE "PLS CHOOSE YOUR ROLE:", 0
M_ROLE_USER BYTE "1. USER", 0
M_ROLE_EMP BYTE "2. BANK EMPLOYEE", 0
M_ROLE_EXIT BYTE "3. EXIT", 0        ; Added Exit Option
M_USER_TITLE BYTE "*** CUSTOMER SERVICES ***", 0
M_EMP_TITLE BYTE "*** EMPLOYEE SERVICES ***", 0
M_ENTER_ID BYTE "PLEASE ENTER YOUR ID: ", 0
M_ENTER_PASS BYTE "PLEASE ENTER YOUR PASSWORD: ", 0
M_LOGIN_SUCCESS BYTE "LOGIN SUCCESSFUL", 0
M_LOGIN_FAIL BYTE "INCORRECT INFORMATION. Try again.", 0
M_CUST_MENU BYTE "1. WITHDRAW  2. DEPOSIT  3. CHECK BALANCE  4. LOGOUT", 0 ; Changed EXIT to LOGOUT
M_WITHDRAW_AMT BYTE "ENTER AMOUNT TO WITHDRAW: ", 0
M_DEPOSIT_AMT BYTE "ENTER AMOUNT TO DEPOSIT: ", 0
M_INSUFFICIENT BYTE "INSUFFICIENT FUNDS.", 0
M_CURRENT_BAL BYTE "CURRENT BALANCE IS: ", 0
M_EMP_CHECK_ID BYTE "ENTER USER ID TO CHECK THEIR BALANCE: ", 0
M_CONTINUE BYTE "PERFORM ANOTHER TRANSACTION? 1. YES  2. LOGOUT: ", 0 ; More user friendly
M_CHECK_ANOTHER  BYTE "CHECK ANOTHER ACCOUNT? 1. YES  2. LOGOUT: ", 0
M_GOODBYE BYTE "Thank you for using XYZ Bank.", 0

; Data Storage (DWORD for 32-bit integers)
UserCount EQU 5
UID DWORD 1001, 1002, 1003, 1004, 1005
UPASS DWORD 1111, 2222, 3333, 4444, 5555
BALANCE DWORD 2000, 4000, 6000, 8000, 10000 
EID DWORD 9001, 9002, 9003, 9004, 9005
EPASS DWORD 9991, 9992, 9993, 9994, 9995

InputID DWORD ?
InputPass DWORD ?
UserIndex DWORD ? 
Amount DWORD ?

.code

main PROC
    call CrLf
    mov eax,gray + (black * 16)
    call SetTextColor

    mov EDX, OFFSET M_BORDER
    call WriteString
    call CrLf 
    mov EDX, OFFSET M_WELCOME_TEXT
    call WriteString
    call CrLf
    
    mov EDX, OFFSET M_BORDER
    call WriteString
    call CrLf

MainMenu:
    call Crlf
    mov eax, cyan  + (black * 16)
    call SetTextColor

    call CrLf
    mov  EDX, OFFSET M_ROLE_PROMPT
    call WriteString
    call CrLf
    mov EDX, OFFSET M_ROLE_USER
    call WriteString
    call CrLf
    mov EDX, OFFSET M_ROLE_EMP
    call WriteString
    call CrLf
    mov EDX, OFFSET M_ROLE_EXIT  ; Display Exit Option
    call WriteString
    call CrLf
    mov eax,white + (black * 16)
    call SetTextColor
    
    call ReadInt 
    cmp EAX, 1
    je UserLogin
    cmp EAX, 2
    je EmpLogin
    cmp EAX, 3      ; Check for Exit
    je ExitProgram
    jmp MainMenu

; -----------------------------------------------------------------
; Customer Login
; -----------------------------------------------------------------
UserLogin:
    call  CrLf
    mov  EDX, OFFSET M_USER_TITLE
    call  WriteString
    call CrLf
    
    mov EDX, OFFSET M_ENTER_ID
    call WriteString
    call ReadInt 
    mov InputID, EAX
    
    mov EDX, OFFSET M_ENTER_PASS
    call WriteString
    call ReadInt 
    mov InputPass, EAX
    
    mov ECX, UserCount
    mov ESI, 0 
CheckUserID:
    mov EAX, InputID
    cmp EAX, UID[ESI * 4] 
    jne NextUser
    
    mov EAX, InputPass
    cmp EAX, UPASS[ESI * 4] 
    jne NextUser
    
    mov UserIndex, ESI 
    jmp LoginSuccess
    
NextUser:
    inc   ESI
    loop  CheckUserID
    
    jmp   LoginFailure

LoginSuccess:
    mov   eax, lightGreen + (black * 16)
    call  SetTextColor
    call  CrLf
    mov   EDX, OFFSET M_LOGIN_SUCCESS
    call  WriteString
    mov eax,white + (black * 16)
    call SetTextColor
    jmp   UserMenu
    
LoginFailure:
    call  CrLf
    mov   eax, lightRed + (black * 16)
    call  SetTextColor
    mov   EDX, OFFSET M_LOGIN_FAIL
    call  WriteString
    mov eax,white + (black * 16)
    call SetTextColor
    jmp   UserLogoutChoice ; Ask if they want to try again or leave

; -----------------------------------------------------------------
; Customer Menu & Functions
; -----------------------------------------------------------------
UserMenu:
    call  CrLf
    mov   EDX, OFFSET M_CUST_MENU
    call  WriteString
    call  CrLf
    
    call ReadInt
    cmp EAX, 1
    je Withdraw
    cmp EAX, 2
    je Deposit
    cmp EAX, 3
    je CheckBalance
    cmp EAX, 4
    je MainMenu     ; Logout returns to Main Menu
    jmp UserMenu 

Withdraw:
    mov EDX, OFFSET M_WITHDRAW_AMT
    call WriteString
    call  ReadInt 
    mov Amount, EAX
    
    mov ESI, UserIndex
    mov EBX, BALANCE[ESI * 4]
    cmp EAX, EBX
    jg InsuffFunds 
    
    sub EBX, EAX 
    mov BALANCE[ESI * 4], EBX 
    jmp DisplayBalance

Deposit:
    mov EDX, OFFSET M_DEPOSIT_AMT
    call WriteString
    call ReadInt 
    mov Amount, EAX
    
    mov ESI, UserIndex
    mov EBX, BALANCE[ESI * 4]
    add EBX, EAX 
    mov BALANCE[ESI * 4], EBX 
    jmp DisplayBalance

CheckBalance:
    call CrLf
    DisplayBalance:
    mov EDX, OFFSET M_CURRENT_BAL
    call WriteString
    mov ESI, UserIndex
    mov EAX, BALANCE[ESI * 4]
    call WriteInt 
    jmp ContinuePrompt

InsuffFunds:
    call CrLf
    mov EDX, OFFSET M_INSUFFICIENT
    call WriteString
    jmp ContinuePrompt

; -----------------------------------------------------------------
; Employee Login
; -----------------------------------------------------------------
EmpLogin:
    call CrLf
    mov EDX, OFFSET M_EMP_TITLE
    call WriteString
    call CrLf
    
    mov EDX, OFFSET M_ENTER_ID
    call WriteString
    call ReadInt 
    mov InputID, EAX
    
    mov  EDX, OFFSET M_ENTER_PASS
    call WriteString
    call ReadInt 
    mov InputPass, EAX
    
    mov ECX, UserCount
    mov ESI, 0
CheckEmpID:
    mov EAX, InputID
    cmp EAX, EID[ESI * 4]
    jne NextEmp
    
    mov EAX, InputPass
    cmp EAX, EPASS[ESI * 4]
    jne NextEmp
    
    jmp EmpMenuLoop 
    
NextEmp:
    inc ESI
    loop CheckEmpID
    
    jmp LoginFailure_Emp

LoginFailure_Emp:
    call CrLf
    mov EDX, OFFSET M_LOGIN_FAIL
    call WriteString
    jmp MainMenu ; Go back to main menu on failure

; -----------------------------------------------------------------
; Employee Menu & Function
; -----------------------------------------------------------------
EmpMenuLoop: 
    call CrLf
    mov EDX, OFFSET M_EMP_CHECK_ID
    call WriteString
    call ReadInt 
    mov InputID, EAX
    
    mov ECX, UserCount
    mov ESI, 0
FindCustID:
    mov EAX, InputID
    cmp EAX, UID[ESI * 4] 
    je EmpFoundCustomer
    inc ESI
    loop FindCustID
    
    call CrLf
    mov EDX, OFFSET M_LOGIN_FAIL ; "Incorrect Info"
    call WriteString
    jmp EmpAfterAction 

EmpFoundCustomer:
    call  CrLf
    mov EDX, OFFSET M_CURRENT_BAL
    call WriteString
    mov EAX, BALANCE[ESI * 4]
    call WriteInt 
    ; Fall through

EmpAfterAction:
    call CrLf
    call CrLf
    mov EDX, OFFSET M_CHECK_ANOTHER 
    call WriteString
    
    call ReadInt
    cmp EAX, 1
    je EmpMenuLoop 
    cmp EAX, 2
    je MainMenu    ; Logout to Main Menu
    jmp EmpAfterAction 

; -----------------------------------------------------------------
; Continue/Exit Prompts (User Only)
; -----------------------------------------------------------------
ContinuePrompt:
    call CrLf
    mov EDX, OFFSET M_CONTINUE
    call WriteString
    
    call ReadInt
    cmp EAX, 1
    je UserMenu    ; Go back to User Menu
    cmp EAX, 2
    je MainMenu    ; Logout to Main Menu
    jmp ContinuePrompt

UserLogoutChoice:
    jmp MainMenu

ExitProgram:
    call CrLf
    mov eax,gray + (black * 16)
    call SetTextColor
    call CrLf
    mov EDX, OFFSET M_GOODBYE
    call WriteString
    mov eax,white + (black * 16)
    call SetTextColor
    call CrLf
    call WaitMsg
    call ExitProcess
    
main ENDP
END main