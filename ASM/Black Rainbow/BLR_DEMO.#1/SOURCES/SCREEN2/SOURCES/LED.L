; --------
; FLASHLED
; --------

 lea $ffff8800,a0
 moveq #10,d0
 move.b d0,(a0)
 move.b (a0),d0
 cmpi.b #$e,d0
 blt led_off
led_on:
 move.b #14,(a0)
 move.b (a0),d0
 andi.b #$f9,d0
 move.b d0,2(a0)
 bra.s fin
led_off:
 move.b #14,(a0)
 move.b (a0),d0
 ori.b #6,d0
 move.b d0,2(a0)
fin:
 rts
 end

 