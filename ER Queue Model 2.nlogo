globals [
  minx
  miny
  maxx
  maxy
  desks-x
]

breed [patients patient]
breed [desks desk]
breed [lamplights lamplight]
breed [people person]


patients-own [ status desk-target weigh-time ]
desks-own [ status ]

to setup
  clear-all
  reset-ticks

  ; Set Global Variables
  let x-value 15
  let y-value 10
  set minx x-value * -1
  set miny y-value * -1
  set maxx x-value
  set maxy y-value
  set desks-x maxx - 5


  create-lamplights 1 [
    set shape "line"
    set color red
    set size 2
    set heading 360
  ]

  ; Set desks
  let position-desks-y maxy + 2

  foreach [1 2 3 4 5] [ temp ->
    set position-desks-y position-desks-y - 3
    create-people 1 [
      set shape "square"
      set color green
      setxy desks-x position-desks-y
    ]

    set position-desks-y position-desks-y - 1
    create-desks 1 [
      set shape "x"
      set heading random 90
      setxy desks-x position-desks-y
      set-desk-status self "close"
    ]
  ]


end

to go


  ask desks [
    ask desks-here[

      if count desks with [status = "open"] != param-opened-desk [
        ifelse count desks with [status = "open"] < param-opened-desk
        [ if status = "close" or status = "closing" [ set-desk-status self "open" ] ]
        [ if status = "open" [ set-desk-status self "closing" ] ]
      ]

      if status = "closing" [
        let desk-cor ycor
        if not any? patients with [desk-target = desk-cor]
        [ set-desk-status self "close" ]
      ]

    ]
  ]



  ask patients [

    if status = "line"
    [
      move-ahead self

      if any? other lamplights-on patch-ahead 1
        [ set-patient-status self "next" ]
    ]

    if status = "next"
    [
      let chasing-y-cordinate 300

      ask desks with [status = "open"] [
        ask desks-here [
          set chasing-y-cordinate ycor

          if any? patients with [desk-target = chasing-y-cordinate]
          [ set chasing-y-cordinate 300 ]
        ]
      ]

      if chasing-y-cordinate != 300
      [
        set-patient-status self "chasing"
        set desk-target chasing-y-cordinate
        move-ahead self
      ]

    ]

    if status = "chasing"
    [
      ifelse desk-target = ycor
      [set heading 90]
      [
        ifelse desk-target < ycor
        [set heading 180]
        [set heading 360]
      ]

      ifelse xcor = desks-x
      [ set-patient-status self "weighing" ]
      [ move-ahead self ]
    ]

    if status = "weighing"
    [
      set weigh-time weigh-time - 1
      if weigh-time <= 0
      [
        set-patient-status self "weighed"
        set desk-target 300
      ]
    ]

    if status = "weighed"
    [
      move-ahead self
      if xcor > maxx
      [ set-patient-status self "die" ]
    ]

    if status = "die" [die]
  ]

  tick
end


; >>> ask patients [ move-ahead self ]
to move-ahead [ patient-will-move ]
  ask patient-will-move [
    if not any? other patients-on patch-ahead 1
    [ fd 1 ]
  ]
end

; >>> ask desks [set-patients-status self "chasing"]
to set-desk-status [ desk-to-set new-status ]
  ask desk-to-set [set status new-status]

  ifelse new-status = "open"
  [ ask desk-to-set [set color green] ]
  [
    ifelse new-status = "closing"
    [ ask desk-to-set [set color yellow] ]
    [
      ifelse new-status = "close"
      [ ask desk-to-set [set color red] ]
      [ ask desk-to-set [set color 25] ]
    ]
  ]

  ask desk-to-set [set status new-status]
end


; >>> ask patients [set-patients-status self "chasing"]
to set-patient-status [ patient-to-set new-status ]
  ask patient-to-set [set status new-status]

  ifelse new-status = "line"
  [ ask patient-to-set [set color white] ]
  [
    ifelse new-status = "next"
    [ ask patient-to-set [set color red] ]
    [
      ifelse new-status = "chasing"
      [ ask patient-to-set [set color yellow] ]
      [
        ifelse new-status = "weighing"
        [ ask patient-to-set [set color blue] ]
        [
          ifelse new-status = "weighed"
          [ ask patient-to-set [set color green] ]
          [ ask patient-to-set [set color 25] ]
        ]
      ]
    ]
  ]

  ask patient-to-set [set status new-status]
end


to create-no-of-patients
  create-patients slider-patients [
    set color white
    set shape "person"
    set heading 90
    setxy minx 0
    set status "line"
    set desk-target 300
    set weigh-time random service-time
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
377
10
1238
510
-1
-1
25.84211
1
15
1
1
1
0
0
0
1
-16
16
-9
9
0
0
1
ticks
90

BUTTON
186
23
332
69
Simulate
go
T
1
T
OBSERVER
NIL
G
NIL
NIL
1

BUTTON
41
23
187
69
Setup
setup
NIL
1
T
OBSERVER
NIL
S
NIL
NIL
1

BUTTON
228
116
374
182
Create Patients
create-no-of-patients
NIL
1
T
OBSERVER
NIL
C
NIL
NIL
1

SLIDER
18
116
224
149
slider-patients
slider-patients
0
100
83
1
1
patients
HORIZONTAL

SLIDER
18
148
224
181
service-time
service-time
0
150
84
1
1
seconds
HORIZONTAL

TEXTBOX
23
287
362
516
Patient:\nWhite: Patients on the line\nRed: Next patient to be served\nYellow: Moving to the service desk\nBlue: Getting served\nGreen: Already served and going to the next step i.e. triage\n\nDesk Colors:\nGreen: Open desk\nYellow: Closing (last patient will be attended)\nRed: Not working
11
0
1

SLIDER
18
214
245
247
param-opened-desk
param-opened-desk
0
5
1
1
1
open desk
HORIZONTAL

MONITOR
269
208
369
253
total patients
count patients
17
1
11

TEXTBOX
10
86
335
121
Select the number of patients to be served and maximum service time.
11
15
1

TEXTBOX
9
199
189
227
Select the amount of opened tolls
11
0
1
@#$#@#$#@
## WHAT IS IT?

This system model shows how patients queue at check in at an emergency department.

## HOW IT WORKS

Patients arrive for check in and enter the queue. The wait to be served by an open check in desk followed by entry to the service desk followed by leaving checkin and entering the next system, such as triage.

## HOW TO USE IT

Set the sliders to number of patients, service time and parameter of open desks available.

## THINGS TO NOTICE

The impact of open desks available on service time and volume.

## THINGS TO TRY

Run the simulation with various settings on the sliders and speed.

## EXTENDING THE MODEL

This model could be extended to include various levels of emergency urgency.

## NETLOGO FEATURES

Color coding of patients as they pass through the system and service desks.

## RELATED MODELS


## CREDITS AND REFERENCES
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.4.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0
-0.2 0 0 1
0 1 1 0
0.2 0 0 1
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@

@#$#@#$#@
