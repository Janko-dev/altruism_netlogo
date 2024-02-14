globals
[
  locx           ; x-coordinate location to spawn occupied circle
  locy           ; y-coordinate location to spawn occupied circle
  max-harshness  ; maximum amount of harshness in a given patch
  max-resource   ; maximum amount of resource in a given patch
]

turtles-own
[
  energy ; fitness of agent
]
breed [altruism-agents altruism-agent]
breed [greedy-agents greedy-agent]

patches-own
[
  resource  ; amount of resources in a given patch
  harshness ; cost of being on the patch used as a penalty
]

;;; simulation setup procedure
to setup
  clear-all
  ; define globals
  set max-harshness 100
  set max-resource 100

  setup-patches
  setup-agents
  reset-ticks
end

to setup-patches
  set locx random-xcor
  set locy random-ycor

  ; spawn circle with occupation-radius and occupation-prob
  ; all other patches get initial-patch-resource
  ask patches [
    let dist sqrt((pycor - locy)^(2) + (pxcor - locx)^(2))
    ifelse dist < occupation-radius and random-float 1.0 < occupation-prob [
      set harshness initial-patch-harshness
    ] [
      set harshness 0
    ]
    set resource initial-patch-resource
  ]

  ; diffuse harshness to 8 neighbouring patches with diffusion rate occupation-diffusion and for repeat-diffusion times
  repeat repeat-diffusion [ diffuse harshness occupation-diffusion]

  ask patches [color-patch]

end

to color-patch  ;; patch procedure
  let red-col (harshness / max-harshness * 255)
  let green-col ((resource - harshness) / 2 / max-resource * 255)
  set pcolor approximate-rgb red-col green-col 0
end

to setup-agents
  set-default-shape turtles "person"

  ; sprout initial-population agents distributed via altruism-prob
  ask n-of initial-population patches [
   sprout 1 [
      set size 2
      set energy initial-agent-energy
      ifelse (random-float 1.0 < altruism-prob) [
        set breed altruism-agents
        set color pink
      ] [
        set breed greedy-agents
        set color sky - 1
      ]
    ]
  ]
end

;;; simulation update procedure
to go
  ask turtles [
    move
    eat
    reproduce
  ]

  ask patches [
    resource-tick
    color-patch
  ]

  if count turtles = 0 [stop]
  tick
end

;;; patch update
to resource-tick  ;; patch procedure
  if random-float 1.0 < prob-gain-resource [ set resource resource + 1 ]
  if resource > max-resource [ set resource max-resource ]
end

;;; agent movement update
to move

  let picked-patch weighted-draw

  let dirx [pxcor] of picked-patch - [pxcor] of patch-here
  let diry [pycor] of picked-patch - [pycor] of patch-here

  rt atan dirx diry
  fd stride-length

  set energy energy - agent-move-cost - harshness
  if energy < 0 [ die ]
end

to-report weighted-draw
  ; get difference of resource and harshness in neighbourhood (8 surrounding patches)
  let neighborhood-utility [resource - harshness] of neighbors
  ; compute minimum utility and re-weight utilities to avoid negative values
  let min-utility min neighborhood-utility
  let weights map [i -> i - min-utility + 1] neighborhood-utility
  ; pick random value between 0 and sum of weights
  let pick random-float sum weights
  let picked-patch nobody

  ask neighbors [
    if picked-patch = nobody [
      ; pick neighbour patch if its utility is higher than the random pick
      ; else, reduce value of pick by utility of patch, and continue to next neighbour
      let weight resource - harshness - min-utility + 1
      ifelse weight > pick [
        set picked-patch self
      ][
        set pick pick - weight
      ]
    ]
  ]
  report picked-patch
end

;;; agent eat (consumption) behaviour
to eat  ;; turtle procedure
  if breed = altruism-agents [ eat-altruistic ]
  if breed = greedy-agents [ eat-greedy ]
end

to eat-altruistic  ;; turtle procedure
  if resource > altruism-resource-threshold [
    let resource-diff max list (resource - resource-energy) 0
    set resource resource-diff
    set energy energy + resource-diff
  ]
end

to eat-greedy  ;; turtle procedure
  if resource > 0 [
    let resource-diff max list (resource - resource-energy) 0
    set resource resource-diff
    set energy energy + resource-diff
  ]
end

;;; agent reproduction behaviour
to reproduce  ;; turtle procedure
  if energy > reproduction-threshold [
    set energy energy - reproduction-cost
    hatch 1
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
985
50
1543
609
-1
-1
10.8
1
10
1
1
1
0
0
0
1
-25
25
-25
25
1
1
1
ticks
30.0

BUTTON
50
30
113
63
setup
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

SLIDER
40
155
220
188
occupation-prob
occupation-prob
0
1
0.22
0.01
1
NIL
HORIZONTAL

SLIDER
40
330
220
363
initial-patch-resource
initial-patch-resource
0
100
100.0
1
1
NIL
HORIZONTAL

SLIDER
40
190
220
223
occupation-radius
occupation-radius
0
40
25.0
1
1
NIL
HORIZONTAL

SLIDER
40
365
220
398
initial-patch-harshness
initial-patch-harshness
0
100
100.0
1
1
NIL
HORIZONTAL

BUTTON
125
30
188
63
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SLIDER
270
155
465
188
altruism-prob
altruism-prob
0
1
0.68
0.01
1
NIL
HORIZONTAL

SLIDER
270
190
465
223
initial-population
initial-population
1
100
100.0
1
1
NIL
HORIZONTAL

SLIDER
40
225
220
258
occupation-diffusion
occupation-diffusion
0
1
0.32
0.01
1
NIL
HORIZONTAL

SLIDER
40
260
220
293
repeat-diffusion
repeat-diffusion
0
50
11.0
1
1
NIL
HORIZONTAL

SLIDER
270
335
465
368
stride-length
stride-length
0.01
1
0.37
0.01
1
NIL
HORIZONTAL

SLIDER
270
300
465
333
agent-move-cost
agent-move-cost
1
100
13.0
1
1
NIL
HORIZONTAL

SLIDER
270
440
465
473
altruism-resource-threshold
altruism-resource-threshold
0
100
42.2
0.1
1
NIL
HORIZONTAL

SLIDER
270
405
465
438
resource-energy
resource-energy
0
100
22.0
1
1
NIL
HORIZONTAL

SLIDER
270
515
465
548
reproduction-threshold
reproduction-threshold
0
100
51.0
1
1
NIL
HORIZONTAL

SLIDER
270
550
465
583
reproduction-cost
reproduction-cost
0
100
40.0
1
1
NIL
HORIZONTAL

SLIDER
40
400
220
433
prob-gain-resource
prob-gain-resource
0
1
0.5
0.01
1
NIL
HORIZONTAL

SLIDER
270
225
465
258
initial-agent-energy
initial-agent-energy
1
100
100.0
1
1
NIL
HORIZONTAL

TEXTBOX
40
135
235
155
Control occupied space
14
0.0
1

TEXTBOX
275
90
425
111
Agent parameters
18
0.0
0

TEXTBOX
40
90
235
131
Environment parameters
18
0.0
1

TEXTBOX
40
310
210
341
Resource and Harshness
14
0.0
1

TEXTBOX
275
135
425
153
Agent population
14
0.0
1

TEXTBOX
270
280
420
298
Agent movement
14
0.0
1

TEXTBOX
270
385
440
403
Agent energy consumption
14
0.0
1

TEXTBOX
270
495
420
513
Agent reproduction
14
0.0
1

PLOT
500
50
965
320
Agents over time
Time
Agents
0.0
10.0
0.0
100.0
true
true
"" ""
PENS
"Greedy" 1.0 0 -14454117 true "" "plot count greedy-agents"
"Altruists" 1.0 0 -2064490 true "" "plot count altruism-agents"

PLOT
500
335
965
525
Ratio Altruists over time
Time
Ratio
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"Altruism ratio" 1.0 0 -16777216 true "" "plot (count altruism-agents / count turtles)"

MONITOR
500
535
635
592
# Altruists
count altruism-agents
0
1
14

MONITOR
500
600
635
657
# Greedy agents
count greedy-agents
0
1
14

MONITOR
665
535
775
592
Altruism ratio
count altruism-agents / count turtles
4
1
14

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

### 1. Environment variables
- **Control occupied space**: during setup, xy-coordinate pair is selected at random and used as the center of the occupied space.
	- **occupation-radius**: radius of occupied circle ranging from 0 (no occupation) to 40.
   	- **occupation-prob**: probability of space within selected circle to be occupied by which the harshness of the patch is set to the maximum harshness (100)
	- **occupation-diffusion**: percentage of harshness of occupied space to be diffused amongst the 8 surrounding neighbours. range [0, 1]
	- **repeat-diffusion**: amount of times to diffuse the harshness value amongst the 8 neighbours. range [0, 50]
- **Resource and Harshness**: controls initial resources and harshness of patches and the probability for a patch to gain new resources. 
	- **initial-patch-resource**: initial amount of resources allocated to the patches. range [0, 100]
	- **initial-patch-harshness**: initial amount of harshness allocated to the patches *selected to be occupied*. Thus a subset of patches are initially given the specified harshness. Note that the initial harshness is thereafter diffused according to the corresponding parameters. range [0, 100]

### 2. Agent variables
- **Agent population**: control distribution of altruist/greedy agents and their initial conditions.
	- **altruism-prob**: probability of spawning an altruist agent
	- **initial-population**: amount of initial agents. range [1, 100]
	- **initial-agent-energt**: amount of initial energy given to each agent. range [1, 100]
- **Agent movement**: control cost and range of movement
	- **agent-move-cots**: cost of making a move in the simulation. range [1, 100]
	- **stride-length**: the amount of space that an agent can move. range [0.01, 1]
- **Agent energy consumption**: control "eating" behaviour of agents
	- **resource-energy**: amount of energy that a patch (with positive resources) gives when an agent decides to consume energy. The resource consumed is the same amount that gets added to the agent's energy reservoire. Naturally, when the consumption of resources is higher than the amount of available resources, then max(patch-resource - resource-energy, 0) is taken to distribute the energy. range [0, 100]  
	- **altruism-resource-threshold**: specifically, for altruist agents, they consume energy if and only if the resource at a given patch is higher than this threshold. This way, altruists are less greedy and confer economic benefit to other agents. range [0, 100]
- **Agent reproduction**: control rate at which agents reproduce new agents.
	- **reproduction-threshold**: threshold of current agent energy that controls if the agent is able to produce offspring. range [0, 100]
	- **reproduction-cost**: cost of energy to produce offspring. range [0, 100]

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
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
NetLogo 6.3.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="100"/>
    <metric>count altruism-agents</metric>
    <metric>count greedy-agents</metric>
    <metric>count altruism-agents / count turtles</metric>
    <metric>mean [energy] of turtles</metric>
    <enumeratedValueSet variable="altruism-resource-threshold">
      <value value="42.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-patch-resource">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="occupation-prob">
      <value value="0.22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="occupation-radius">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="agent-move-cost">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-population">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stride-length">
      <value value="0.22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-agent-energy">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-threshold">
      <value value="51"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="occupation-diffusion">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="altruism-prob">
      <value value="0.68"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="resource-energy">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="prob-gain-resource">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="repeat-diffusion">
      <value value="11"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-cost">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-patch-harshness">
      <value value="100"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
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
1
@#$#@#$#@
