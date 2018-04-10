

# 320x240, 1024 bytes/row, 2 bytes per pixel: DE1-SoC
.equ WIDTH, 319
.equ HEIGHT, 239
.equ X_OFFSET, 10
.equ Y_OFFSET, 1
.equ PIXELBUFFER, 0x08000000 # Pixel buffer. Same on all boards.
.equ AMP_START, 210

.text
.global FillLine
.global FillColour
.global WritePixel
.global FillSegment

FillSegment:
    subi sp, sp, 20
    stw r15, 0(sp)
    stw r16, 4(sp)
    stw r17, 8(sp)
    stw r18, 12(sp)
    stw ra, 16(sp)
    
    mov r18, r4
    mov r16, r5
    movi r2, AMP_START #get row index for height
    sub r15, r2, r6
    bge r15, r0, start_segment #check if number is larger
        mov r15, r0
        
    # Two loops to draw each pixel
    start_segment:  movi r17, AMP_START
        1:  mov r4, r16
            mov r5, r17
            mov r6, r18
            call WritePixel     # Draw one pixel
            subi r17, r17, 1
            bge r17, r15, 1b
    
    ldw r15, 0(sp) 
    ldw r16, 4(sp)
    ldw r17, 8(sp)
    ldw r18, 12(sp)
    ldw ra, 16(sp)
    addi sp, sp, 20
    ret


# r4: colour
FillColour:
    subi sp, sp, 16
    stw r16, 0(sp)      # Save some registers
    stw r17, 4(sp)
    stw r18, 8(sp)
    stw ra, 12(sp)
    
    mov r18, r4
    
    # Two loops to draw each pixel
    movi r16, WIDTH
    1:  movi r17, HEIGHT
        2:  mov r4, r16
            mov r5, r17
            mov r6, r18
            call WritePixel     # Draw one pixel
            subi r17, r17, 1
            bge r17, r0, 2b
        subi r16, r16, 1
        bge r16, r0, 1b
    
    ldw ra, 12(sp)
    ldw r18, 8(sp)
    ldw r17, 4(sp)
    ldw r16, 0(sp)    
    addi sp, sp, 16
    ret
    
    
# r4: colour
# r5: col

FillLine:
    subi sp, sp, 16
    stw r16, 0(sp)      # Save some registers
    stw r17, 4(sp)
    stw r18, 8(sp)
    stw ra, 12(sp)
    
    mov r18, r4
    mov r16, r5
    # Two loops to draw each pixel
    1:  movi r17, HEIGHT
        2:  mov r4, r16
            mov r5, r17
            mov r6, r18
            call WritePixel     # Draw one pixel
            subi r17, r17, 1
            bge r17, r0, 2b
    
    ldw ra, 12(sp)
    ldw r18, 8(sp)
    ldw r17, 4(sp)
    ldw r16, 0(sp)    
    addi sp, sp, 16
    ret

# r4: col (x)
# r5: row (y)
# r6: colour value
WritePixel:   
    slli r5, r5, X_OFFSET #make space for col offset
    slli r4, r4, Y_OFFSET #offset
    add r5, r5, r4 #add offset together
    movia r4, PIXELBUFFER 
    add r5, r5, r4 #offset the pixel buffer
    sthio r6, 0(r5)
    ret