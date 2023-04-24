globals[
  num-infected
  num-people
  young-death-rate
  middle-1-death-rate
  middle-2-death-rate
  old-1-death-rate
  old-2-death-rate
  num-deaths-young
  num-deaths-middle
  num-deaths-old

]
breed [ people person ]
breed [ viruses virus ]
turtles-own[
  age-group
  infected?
  infection-day
  quarantine-start-day
  vaccinated?
  quarantining?
  death-rate
]
to setup
  if ((youth-population + middle-population + older-population) > 100)
  [user-message("Population total must add to 100%")]

  clear-all
  set young-death-rate 0.002
  set middle-1-death-rate 0.01
  set middle-2-death-rate 1.4
  set old-1-death-rate 4.6
  set old-2-death-rate 15
  ifelse (social-distancing)
  [set num-people  50]
  [set num-people 100]
  ;set different types of people(vaccinated/not and different ages)
  create-people num-people * (vaccinated / 100) * (youth-population / 100)[
    set vaccinated? true
    set age-group "Youth Population"
    set-turtle-details
    set death-rate young-death-rate
  ]
  create-people num-people * (vaccinated / 100) * ((middle-population / 2) / 100)[
    set vaccinated? true
    set age-group "Middle-Age Population"
    set-turtle-details
    set death-rate middle-1-death-rate

  ]
  create-people num-people * (vaccinated / 100) * ((middle-population / 2) / 100)[
    set vaccinated? true
    set age-group "Middle-Age Population"
    set-turtle-details
    set death-rate middle-2-death-rate
  ]
  create-people num-people * (vaccinated / 100) * ((older-population / 2) / 100)[
    set vaccinated? true
    set age-group "Old-Age Population"
    set-turtle-details
    set death-rate old-1-death-rate
  ]
  create-people num-people * (vaccinated / 100) * ((older-population / 2) / 100)[
    set vaccinated? true
     set age-group "Old-Age Population"
    set-turtle-details
    set death-rate old-2-death-rate
  ]
  create-people num-people * (1 - (vaccinated / 100)) * (youth-population / 100)[
    set vaccinated? false
    set age-group "Youth Population"
    set-turtle-details
    set death-rate young-death-rate
  ]
  create-people num-people * (1 - (vaccinated / 100)) * ((middle-population / 2) / 100)[
    set vaccinated? false
    set age-group "Middle-Age Population"
    set-turtle-details
    set death-rate middle-1-death-rate
  ]
  create-people num-people * (1 - (vaccinated / 100)) * ((middle-population / 2) / 100)[
    set vaccinated? false
    set age-group "Middle-Age Population"
    set-turtle-details
    set death-rate middle-2-death-rate
  ]
  create-people num-people * (1 - (vaccinated / 100)) * ((older-population / 2) / 100)[
    set vaccinated? false
     set age-group "Old-Age Population"
    set-turtle-details
    set death-rate old-1-death-rate
  ]
  create-people num-people * (1 - (vaccinated / 100)) * ((older-population / 2) / 100)[
    set vaccinated? false
     set age-group "Old-Age Population"
    set-turtle-details
    set death-rate old-2-death-rate
  ]


  create-viruses 1 [
    set shape "circle"
    set color red
    set infected? true
    setxy random-pxcor random-pycor
  ]

  set num-infected 0
  set num-deaths-young 0
  set num-deaths-middle 0
  set num-deaths-old 0
  set num-people count people
  reset-ticks
end

to set-turtle-details
  ifelse vaccinated?
  [set shape "vaccinated-person"]
  [ set shape "person"]
    set color green

  set infected? false
  set quarantining? false
  ifelse (social-distancing)
  [
    while [any? other turtles in-radius 2] [
     setxy random-xcor random-ycor
     ]
  ]
  [setxy random-pxcor random-pycor]
end


to go
  if (youth-population + middle-population + older-population) != 100
   [user-message("Population total must add to 100%")]
  set num-infected count people with [ infected? ]


  ifelse (social-distancing)
   [
    move-people-with-social-distancing
   ]

   [
    move-people
   ]

  ask viruses
   [spread-disease]

  ifelse (quarantine-protocol)
    [implement-quarantine-protocol]
  [ask people with [ infected?]
    [ifelse ( ticks - infection-day  < 10)
    [ check-death
      spread-disease ]
     [ifelse vaccinated? [
        set shape "vaccinated-person"
        ]
        [set shape "person"]
          set color green
      set infection-day "na"
          set infected? false]]]



  tick

end

to implement-quarantine-protocol
   ask people with [ infected? ]
        [if ( ticks - infection-day  < 5)
          [spread-disease ]
        if ticks - infection-day = 5
          [ ifelse vaccinated? [
            set shape "vaccinated-quarantine-person"]
            [set shape "person-quarantine"]
            set quarantine-start-day ticks
            set quarantining? true
             ]
        if (quarantine-start-day != "na") and (ticks - quarantine-start-day < 5) and (ticks - quarantine-start-day > 0 )   ;code to add whilst quarantining(check death rate)
          [check-death]
        if ( quarantine-start-day != "na") and (ticks - quarantine-start-day > 5)
          [ifelse vaccinated? [
        set shape "vaccinated-person"
            ][set shape "person"]
            set color green
          set infection-day "na"
          set quarantine-start-day "na"
          set quarantining? false
          set infected? false]
      ;if they survive change back to healthy person
         ]

end


to check-death
  let chanceofdeath random-float 100
  if (chanceofdeath < death-rate )
  [if age-group = "Youth Population"
    [set num-deaths-young num-deaths-young + 1
    set num-people num-people - 1]
    if age-group = "Middle-Age Population"
    [set num-deaths-middle num-deaths-middle + 1
    set num-people num-people - 1]
     if age-group = "Old-Age Population"
    [set num-deaths-old num-deaths-old + 1
    set num-people num-people - 1]
   die]
end

to move-people
  ask people with [not quarantining?][
    right random 360
    forward 1
  ]
end


to move-people-with-social-distancing

  ask people with [not quarantining?][
    let validspace  false
    right random 360


    let patchx  xcor + sin(heading)
    let patchy  ycor + cos(heading)
      ask patch patchx patchy [if (count (turtles-on neighbors) < 2 )  [set validspace  true]]
    if validspace = true
      [forward 1]


  ]
end

to get-sick-chance
  let infectionchance random-float 1
  if(not infected?) and ((mask-wearing-protocol) xor ( social-distancing)) and not vaccinated?
  [if(infectionchance * 1.7 < infection-rate)
  [get-sick]
  ]
  if(not infected?) and (mask-wearing-protocol) and ( social-distancing) and not vaccinated?
  [if(infectionchance * 1.7 * 1.7 < infection-rate)
  [get-sick]
  ]
  if(not infected?) and (mask-wearing-protocol) and ( social-distancing) and vaccinated?
  [if(infectionchance * 1.7 * 1.7 * 1.91 < infection-rate)
  [get-sick]
  ]
  if(not infected?) and (not mask-wearing-protocol) and (not social-distancing) and not vaccinated?
  [if (infectionchance < infection-rate)
  [get-sick]
  ]
  if(not infected?) and (not mask-wearing-protocol) and (not social-distancing) and vaccinated?
  [if (infectionchance * 1.91 < infection-rate)
  [get-sick]
  ]
  if(not infected? ) and ((mask-wearing-protocol) xor ( social-distancing)) and vaccinated?
  [if(infectionchance * 1.7 * 1.91 < infection-rate)
  [get-sick]
  ]
end

to get-sick
  if not infected?
  [ set infected? true
    set infection-day ticks
    set color red
    ]
end

to spread-disease
  ask turtles in-radius 3[get-sick-chance]
end
@#$#@#$#@
GRAPHICS-WINDOW
209
20
646
458
-1
-1
13.0
1
10
1
1
1
0
1
1
1
-16
16
-16
16
1
1
1
ticks
30.0

BUTTON
85
404
155
437
Set Up
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
87
446
152
479
Go
go\n
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
24
28
196
61
infection-rate
infection-rate
0
1
0.8
0.1
1
NIL
HORIZONTAL

SWITCH
24
71
209
104
mask-wearing-protocol
mask-wearing-protocol
1
1
-1000

SWITCH
40
115
189
148
social-distancing
social-distancing
1
1
-1000

MONITOR
807
235
930
280
Number of Infected
num-infected
17
1
11

PLOT
662
18
940
223
Percentage of People Infected
Number of Days
Infected
0.0
10.0
0.0
100.0
true
false
"" ""
PENS
"Infected" 1.0 0 -13840069 true "" "plot (num-infected / num-people) * 100"

SLIDER
25
161
204
194
vaccinated
vaccinated
0
100
0.0
1
1
%
HORIZONTAL

MONITOR
665
233
788
278
Day Number
ticks
17
1
11

SWITCH
33
211
199
244
quarantine-protocol
quarantine-protocol
0
1
-1000

SLIDER
30
282
202
315
youth-population
youth-population
0
100
33.0
1
1
%
HORIZONTAL

SLIDER
31
320
203
353
middle-population
middle-population
0
100
34.0
1
1
%
HORIZONTAL

SLIDER
32
357
204
390
older-population
older-population
0
100
33.0
1
1
%
HORIZONTAL

MONITOR
948
241
1084
286
Young Population Deaths
num-deaths-young
17
1
11

PLOT
947
18
1233
224
Total Number of Deaths
Number of Days
Deaths
0.0
75.0
0.0
100.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot num-deaths-young + num-deaths-middle + num-deaths-old"

MONITOR
1094
241
1232
286
Middle Population Deaths
num-deaths-middle
17
1
11

MONITOR
1018
302
1149
347
Old Population Deaths
num-deaths-old
17
1
11

TEXTBOX
44
250
194
278
The populations of each category must add to 100!
11
0.0
1

TEXTBOX
663
359
1015
555
Key:\nGreen person = Healthy\nGreen person with white cross = Healthy and fully Vaccinated\nRed Person = Infected\nRed Person with white cross = Infected and fully vaccinated\nRed Person in Grey Box = Infected person Quarantining\nRed Person with white cross in Grey Box = Fully vaccinated infected person quarantining\n
11
0.0
1

MONITOR
728
301
855
346
Percentage Infected
(num-infected / num-people) * 100
0
1
11

@#$#@#$#@
## WHAT IS IT?

This is a simulation to show the spread of Covid. You can adjust different factors and choose the measures that are in place to see their effect on the spread.


## HOW TO USE IT

Please set your inputs for the simulation using the sliders and the on and the switches. The variables you can set are:

infection rate : The probability of each person being infected.

mask-wearing-protocol : This will turn on or off people wearing masks.

social-distancing : This will turn on or off whether people are social distancing.

quarantine-protocol : This will turn on or off whether people will be quarantining after testing positive.

Population settings : Using the slider choose the percentage of people in each population catgeory.

## Icons Explanation
![alt-text] (file:icons.png)
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

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

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

person-quarantine
false
15
Rectangle -7500403 true false 30 0 255 315
Circle -2674135 true false 110 5 80
Rectangle -2674135 true false 127 79 172 94
Polygon -2674135 true false 195 90 240 150 225 180 165 105
Polygon -2674135 true false 105 90 60 150 75 180 135 105
Polygon -2674135 true false 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90

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

vaccinated-person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105
Rectangle -1 true false 60 120 240 150
Rectangle -1 true false 135 0 165 300

vaccinated-quarantine-person
false
1
Rectangle -7500403 true false 30 0 255 315
Circle -2674135 true true 110 5 80
Rectangle -2674135 true true 127 79 172 94
Polygon -2674135 true true 195 90 240 150 225 180 165 105
Polygon -2674135 true true 105 90 60 150 75 180 135 105
Polygon -2674135 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -1 true false 135 0 165 270
Rectangle -1 true false 75 90 225 120

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
NetLogo 6.3.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
