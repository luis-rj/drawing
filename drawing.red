Red [
	Author: "Toomas Vooglaid"
	Last-version: 2018-03-18
	File: %drawing.red
	Needs: 'View
]
system/view/auto-sync?: off
system/state/trace: 20
clear-reactions
ctx: context [
	env: self
	step: 0
	last-step: 0
	last-mode: none
	start?: true
	figure: none;'line
	figures*: #()
	primary: #()
	secondary: #() 
	layers*: 1
	figure-prop: #(
		line: 		[copy _points  [pair! some pair!]]
		box: 		[set  _top-left pair! set _bottom-right pair!]  ; add corner
		circle: 	[set  _center   pair! set _radius [integer! | float!]]
		polygon:	[copy _points  [pair! pair! some pair!]]
		ellipse:	[set  _top-left pair! set _dimensions pair!]
		arc:		[set  _center   pair! set _radius pair! set _begin integer! set _sweep integer! opt 'closed]
		text:		[set  _position pair! string!]
		image: 		[[image! | word!] set _top-left pair! opt [set _bottom-right pair!]]
	)
	figure-move-points: #(
		line: 		[all]
		box: 		[2 3]  
		circle: 	[2]
		ellipse:	[2]
		polygon:	[all]
		arc:		[2]
		text:		[2]
		image: 		[3 4]
		curve:		[all]
		spline:		[all]
	)
	figure-points: [
		line: 		[keep some pair!]
		box: 		[keep [pair! pair!]]  
		circle: 	[keep pair!]
		ellipse:	[keep pair!]
		polygon:	[keep some pair!]
		arc:		[keep pair!]
		text:		[keep pair!]
		image: 		[[image! | word!] keep pair! opt [keep pair!]]
		curve:		[keep some pair!]
		spline:		[keep some pair!]
	]
	flatten: function [block [any-block!] /with out /local b][
		out: any [out clear []] 
		foreach b block [either any-block? b [flatten/with b out][append out b]] 
		out
	] 
	color-word: [
		  'Red    | 'white   | 'transparent | 'black  | 'gray    | 'aqua    | 'beige  | 'blue 
		| 'brick  | 'brown   | 'coal        | 'coffee | 'crimson | 'cyan    | 'forest | 'gold 
		| 'green  | 'ivory   | 'khaki       | 'leaf   | 'linen   | 'magenta | 'maroon | 'mint 
		| 'navy   | 'oldrab  | 'olive       | 'orange | 'papaya  | 'pewter  | 'pink   | 'purple 
		| 'reblue | 'rebolor | 'sienna      | 'silver | 'sky     | 'snow    | 'tanned | 'teal 
		| 'violet | 'water   | 'wheat       | 'yello  | 'yellow  | 'glass
	]
	system/words/transparent: 255.255.255.254 ; ????
	colors: exclude sort extract load help-string tuple! 2 [glass]
; DideC -->
	pallette: [
		title "Select color" origin 1x1 space 1x1
		style clr: base 15x15 on-down [dn?: true] on-up [
			if dn? [
				either event/shift? [
					append env/color-bag face/extra
				][
					env/color: either empty? env/color-bag [
						face/extra
					][
						append env/color-bag face/extra
					]
					unview
				]
			]
		]
	]
	x: 0
	color: none
	color-bag: copy []
	dn?: none

	make-pallette: has [j][
		clear color-bag
		foreach j colors [
			append pallette compose/deep [
				clr (j) extra (to-lit-word j)
			]
			if (x: x + 1) % 9 = 0 [append pallette 'return]
		]
	]
; <-- DideC

	make-pallette
	color: black
	select-color: does [clear color-bag view/flags pallette [modal popup]]

	; --> new color-picker
	make-color: func [i][
		sector: i - 1 / 64 + 1
		switch sector [
			1 [as-rgba 255 0 i - 1 * 4 0]
			2 [as-rgba 255 - (i - 1 % 64 * 4) 0 255 0]
			3 [as-rgba 0 i - 1 % 64 * 4 255 0]
			4 [as-rgba 0 255 255 - (i - 1 % 64 * 4) 0]
			5 [as-rgba i - 1 % 64 * 4 255 0 0]
			6 [as-rgba 255 255 - (i - 1 % 64 * 4) 0 0]
		]
	]
	drw: copy [rotate -30 150x150 pen off ] 
	collect/into [
		repeat i 6 * 64 [
			keep reduce [
				'rotate i - 1 * 0.9375 150x150 
				compose [
					fill-pen (make-color i) 
					arc 150x150 128x128 0 1 closed
				]
			]
		]
	] drw 
	append drw [
		fill-pen radial 0.0.0.0 0.0.0.255 150x150 128 
		circle 150x150 128
	]
	alpha-val: 0
	grey-val: 0
	last-color: copy "pick a color"
	sz: 300x300
	palette2: make image! sz
	draw palette2 drw
	dn?: false
	request-color: has [colors value alpha grey disc disc2 found clr dn?][
		colors: copy []
		view/flags compose/deep [
			value: text data [last-color]
			text 30x24 "alpha:"
			alpha: slider with [data: env/alpha-val]
				react later [
					found: disc2/draw
					while [found: find next found block!][
						found/1/2/4: to integer! alpha/data * 255
					]
					show disc2
				]
			return 
			grey: slider 24x300 with [data: env/grey-val]
				on-up [
					;palette2: make image! sz
					draw palette2 disc2/draw 
					disc/image: palette2
				]
				react later [
					change/part at tail disc2/draw -7 reduce [
						as-rgba v: to integer! grey/data * 255 v v 0
						as-rgba v v v 255
					] 2
					show disc2
				] 
			disc: image palette2  
			at 44x44 disc2: box white 300x300 all-over 
				on-over [
					clr: pick palette2 event/offset
					attempt [clr/4: to integer! alpha/data * 255]
					value/text: form clr
				] 
				on-down [dn?: true] 
				on-up [
					if dn? [
						clr: pick palette2 event/offset
						clr/4: to integer! alpha/data * 255
						either event/shift? [
							append colors clr
						][
							env/color: either empty? colors [
								clr
							][  
								append colors clr
							]
							env/alpha-val: alpha/data
							env/grey-val: grey/data
							env/last-color: form clr
							unview
						]
					]
				]
				draw [(drw)]
		][modal popup] 
	]
	; <-- new color-picker
	
comment {
	sz: 150x150
	grad-palette: make image! sz
	draw grad-palette compose [
		pen off
		fill-pen linear red orange yellow green aqua blue purple
		box 0x0 (sz)
		fill-pen linear white glass black 0x0 (as-pair 0 sz/y)
		box 0x0 (sz)
	]
	request-color: has [dn? sz colors][; Adapted from @greggirwin's %red-paint-with-time-travel.red
		colors: copy []
		view/flags [
			title "Select color"
			image grad-palette on-down [dn?: true] on-up [
				if dn? [
					either event/shift? [
						append colors pick grad-palette event/offset
					][
						env/color: either empty? colors [
							pick grad-palette event/offset
						][  
							append colors pick grad-palette event/offset
						]
						unview
					]
				]
			]
		][modal popup]
	]
}
	skip-colors: 0
	set-gradient: func [pen type pos1][
		either block? env/color [
			skip-colors: length? env/color
			either selection-start/2 = 'push [
				either found-format: find/last/tail selection-start/3 pen [;find-deep selection-start/3 type [
					switch step [
						1 [
							parse found-format [s: [
								if (any [find color-word s/1 tuple? s/1]) skip e: 
							| 	thru ['pad | 'repeat | 'reflect] e: ; | 'tile | 'flip-x | 'flip-y | 'flip-xy | 'clamp] e:
							] (
								change/part s append insert env/color type reduce switch type [
									linear [[pos1 pos1 'pad]] 
									radial [[pos1 0 pos1 'pad]]
									diamond [[pos1 pos1 pos1 'pad]]
								] e
							)]
							skip-colors: skip-colors + 4
						]
						2 [
							found-format: find found-format pair!
							change/part found-format reduce switch type [
								linear [[pos1 pos1]] 
								radial [[pos1 0 pos1]]
								diamond [[pos1 pos1 pos1]]
							] pick [2 3] type = 'linear
							skip-colors: 1 + index? found-format
						]
					]
				][
					insert selection-start/3 append append reduce [pen type] env/color reduce switch type [
						linear [[pos1 pos1 'pad]] 
						radial [[pos1 0 pos1 'pad]]
						diamond [[pos1 pos1 pos1 'pad]]
					]
					skip-colors: skip-colors + 4
				]
			][
				change/part next selection-start 
					append/only copy [push] 
						append append append reduce [pen type] env/color reduce switch type [
						linear [[pos1 pos1 'pad]] 
						radial [[pos1 0 pos1 'pad]]
						diamond [[pos1 pos1 pos1 'pad]]
					] 
					copy/part next selection-start selection-end 
					selection-end
				skip-colors: skip-colors + 4
			]
			env/step: 2
		][probe "Use shift while gathering at least two colors! Select last color w/o shift."]
	]
	result: none
	write-program: has [result][
		prg-win: view/flags/no-wait [
			title "Program figure" 
			below
			result: area 300x100 
			return
			button "OK" [result: result/text unview]
			button "Cancel" [result: copy "" unview]
		][modal popup resize]
		prg-win/actors: [
			on-resize: func [f e][
				result/size: result/parent/size
				show result
			]
		]
		do-events
		result
	]
	ask-new-name: has [result][
		view/flags [
			title "Enter new name" 
			result: field focus hint "New name" 
			on-enter [result: result/text unview]
			button "OK" [result: result/text unview]
		][modal popup] 
		result
	]
	show-warning: func [msg][view/flags compose [title "Warning!" text (msg) button "OK" [unview]][modal popup]]
	load-file: has [result][
		view/flags [
			title "Enter location of file" 
			result: field 150x20 hint "File location" 
			button "Local file.." [
				result/text: to-red-file request-file 
				show result
			] 
			return
			button "OK" [
				result: either url? result/data [
					load result/data
				][
					result/data
				] 
				unview
			]
			button "Cancel" [
				result: none 
				unview
			]
		][modal popup] 
		result
	]
	show-draw: does [
		view/options/flags compose [
			title "Edit draw" 
			below
			result: area 300x200 (mold canvas/draw)
			return
			button "Show" [canvas/draw: load result/text select-figure show canvas] ;new-line/all  false
			button "Close" [unview]
		][
			offset: win/offset + 600x0 
			actors: object [
				on-resizing: func [face event][
					result/size: result/parent/size - 90x20
					result/parent/pane/2/offset/x: result/offset/x + result/size/x + 10
					result/parent/pane/3/offset/x: result/offset/x + result/size/x + 10
					show result/parent
				]
			]
		][resize]
	]
	show-console: does [write-clipboard mold append/only copy [view] append/only compose [box white (canvas/size) draw] canvas/draw]
	action: 'draw
	last-action: none
	canvas: none
	layers: figs: figs1: group: subgroup: subgroup2: none
	sep1: sep2: sep3: sep4: none
	select-layer: func [/pos selected][
		selected: any [selected layers/selected]
		if selected [
			canvas: get to-word pick layers/data layers/selected
			figs/data: canvas/extra/figs
			select-figure
			show [drawing-panel figs-panel]
		]
	]
	selection-start: none
	selection-end: none
	selected-figure: none
	select-figure: func [/pos selected][; returns new `selected` for figs while deleting 
		either empty? figs/data [
			selection-start: tail canvas/draw
			selection-end: tail canvas/draw
		][
			selected: any [selected figs/selected]
			if selected [
				selected-figure/text: pick figs/data selected
				show selected-figure
				selection-start: find-figure selected 
				either selected = length? figs/data [
					selection-end: length? selection-start
					either 1 < selected [selected - 1][none]  ;??? Check it!
				][
					selection-end: find next selection-start load pick figs/data selected + 1
					selected
				]
			]
			figure: secondary/(selected-figure/text)
			if select-fig/data [show-selected/sel]
		]
	]
	load-figure: func [fig][load pick figs/data fig]; Can be word! or block! (in case it is `pen`, `fill-pen` or `line-width`)
	find-figure: func [selected /tail /local figure found][
		either word? figure: load-figure selected [
			either tail [
				skip find-deep canvas/draw figure figure-length/pos selected
			][
				find-deep canvas/draw figure
			]
		][
			either found: find/reverse at figs/data selected form figure [
				n: 1
				while [found: find/reverse found form figure][n: n + 1]
				found: next find canvas/draw figure
				loop n [found: next find found figure]
				either tail [skip back found length? figure][back found]
			][
				found: find canvas/draw figure
				either tail [skip found length? figure][found]
			]
		]
	]
	find-deep: func [block needle /local found s][
		unless found: find block needle [
			parse block [
				some [to block! s: if (found: find-deep s/1 needle) break | skip]
			]
		]
		found
	]
	offset: func [_1 _2][offset? find-figure _1 find-figure _2]
	first-selected?: func [list /pos selected][selected: any [selected list/selected] selected = 1]
	second-selected?: func [list /pos selected][selected: any [selected list/selected] selected = 2]
	last-selected?: func [list /pos selected][selected: any [selected list/selected] selected = length? list/data]
	last-but-one-selected?: func [list /pos selected][selected: any [selected list/selected] (length? list/data) = (selected + 1)]
	next-figure: none
	redraw: does [canvas/draw: canvas/draw show canvas]
	figure-length: func [/pos selected /local figure selection][
		selected: any [selected figs/selected]
		figure: load first selection: at figs/data selected
		any [
			all [word? figure last-selected?/pos figs selected length? find-figure selected]
			all [word? figure offset selected selected + 1]
			length? figure
		]
	]
	adjust-pens: has [found][
		if found: find/last canvas/draw 'line-width [pen-width/data: found/2 show pen-width]
		if found: find/last canvas/draw 'pen 		[pen-color/color: found/2 show pen-color]
		if found: find/last canvas/draw 'fill-pen   [fill-color/color: found/2 show fill-color]
	]
	join: cap: none
	line-joins: copy []
	format-local: func [param value][
		either selection-start/2 = 'push [
			either found-format: find/last selection-start/3 param [
				either all [
					find [pen fill-pen] param 
					not any [find color-word found-format/2 tuple? found-format/2]
				][
					parse next found-format [s: thru ['pad | 'repeat | 'reflect] e: (change/part s value e)]
				][
					change next found-format value
				]
			][
				insert selection-start/3 reduce [param value]
			]
		][
			change/part next selection-start 
				append/only copy [push] 
					append reduce [param value] 
						copy/part next selection-start selection-end 
				selection-end
		]
		env/action: 'draw 
		recalc-info
		redraw 
	]
	foreach join [miter bevel round] [
		append line-joins compose/deep [
			box 22x22 with [extra: (to-lit-word join)] draw [
				pen gray box 0x0 21x21 pen black line-join (join) anti-alias off line-width 5 line 4x4 15x15 4x15
			][
				switch/default action [
					insert [] ; TBD
					line-join [format-local 'line-join face/extra]
				][
					append canvas/draw [line-join (join)]
					append figs/data form [line-join (join)]
					figs/selected: length? figs/data
					select-figure 
					show figs
				]
			]
		]
	]
	line-caps: copy []
	foreach cap [flat square round] [
		append line-caps compose/deep [
			box 22x22 with [extra: (to-lit-word cap)] draw [
				pen gray box 0x0 21x21 pen black line-cap (cap) anti-alias off line-width 5 line 5x10 16x10
			][
				switch/default action [
					insert [] ; TBD
					line-cap [format-local 'line-cap face/extra]
				][
					append canvas/draw [line-cap (cap)]
					append figs/data form [line-cap (cap)]
					figs/selected: length? figs/data
					select-figure 
					show figs
				]
			]
		]
	]
	move-in-list: func [list to-position][
		;selected: list/selected 
		in-list: at list/data list/selected
		switch/default to-position [
			front 		[unless last-selected? list		[move in-list tail in-list] list/selected: length? list/data]
			forward 	[unless last-selected? list		[move in-list next in-list] list/selected: list/selected + 1]
			backward 	[unless first-selected? list	[move in-list back in-list] list/selected: list/selected - 1]
			back 		[unless first-selected? list	[move in-list head in-list] list/selected: 1]
		][
			move in-list at list/data to-position
		]
	]
	move-selection: func [position /from pos1 /to pos2 /local tmp][
		switch position [
			front [
				unless last-selected? figs [
					move/part selection-start tail selection-start figure-length
					move-in-list figs 'front
				]
			]
			forward [
				unless last-selected? figs [
					move/part selection-start either last-but-one-selected? figs [
						tail selection-start
					][
						back find-figure/tail figs/selected + 1
					]
					figure-length
					move-in-list figs 'forward
				]
			]
			backward [
				unless first-selected? figs [
					move/part selection-start find-figure figs/selected - 1 figure-length
					move-in-list figs 'backward
				]
			]
			back [
				unless first-selected? figs [
					either canvas/draw/1 = 'matrix [
						move/part selection-start at canvas/draw 3 figure-length
					][
						move/part selection-start head selection-start figure-length
					]
					move-in-list figs 'back
				]
			]
			before [
				case [
					pos1 + 1 = pos2 [
						move/part selection-start find-figure/tail pos2 figure-length/pos pos1
						move at figs/data pos1 at figs/data pos2 + 1
					]
					pos2 = length? figs/data [
						move/part selection-start tail selection-start figure-length/pos pos1
						move at figs/data pos1 tail figs/data
					]
					'else [
						move/part selection-start find-figure/tail pos2 figure-length/pos pos1
						move at figs/data pos1 at figs/data pos2 + 1
					]
				]
				figs/selected: pos2
			]
			swap [
				if pos1 < pos2 [tmp: pos2 pos2: pos1 pos1: tmp]
				select-figure/pos pos1
				figs/selected: pos2
				move/part selection-start find-figure pos2 figure-length/pos pos1
				select-figure
				either pos1 = length? figs/data [
					move/part selection-start tail selection-start figure-length
				][
					move/part selection-start skip find-figure pos1 + 1 -1 figure-length
				]
				swap at figs/data pos1 at figs/data pos2
			]
		]
		select-figure 
		show [figs canvas] 
		adjust-pens
	]
	move-layer: func [position /from pos1 /to pos2 /local tmp nope][
		switch position [
			front [
				unless nope: last-selected? layers [
					move at drawing-panel/pane layers/selected at drawing-panel/pane pos2: length? layers/data
					move-in-list layers 'front
				]
			]
			forward [
				unless nope: last-selected? layers [
					move at drawing-panel/pane layers/selected at drawing-panel/pane pos2: layers/selected + 1
					move-in-list layers 'forward
				]
			]
			backward [
				unless nope: first-selected? layers [
					move at drawing-panel/pane layers/selected at drawing-panel/pane pos2: layers/selected - 1
					move-in-list layers 'backward
				]
			]
			back [
				unless nope: first-selected? layers [
					move at drawing-panel/pane layers/selected head drawing-panel/pane
					move-in-list layers 'back
					pos2: 1
				]
			]
			before [
				if pos1 > pos2 [pos2: pos2 + 1]
				move at drawing-panel/pane pos1 at drawing-panel/pane pos2
				move at layers/data pos1 at layers/data pos2
			]
			swap [
				if pos1 < pos2 [tmp: pos2 pos2: pos1 pos1: tmp]
				swap at drawing-panel/pane pos1 at drawing-panel/pane pos2
				swap at layers/data pos1 at layers/data pos2
			]
		]
		unless nope [
			env/layers/selected: pos2
			env/canvas: drawing-panel/pane/:pos2
			env/figs/data: canvas/extra/figs
			show [drawing-panel figs-panel] 
		]
	]
	insert-manipulation: func [type][
		either selection-start/2 = 'push [
			insert selection-start/3 switch type [
				translate 	[[translate 0x0]]
				scale 		[[scale 1 1]]
				skew		[[skew 0 0]]
				rotate		[[rotate 0 0x0]]
				transform	[if integer? selection-end [selection-end: selection-end + 6] [transform 0x0 0 1 1 0x0]]
			]
		][
			change/part next selection-start 
				append/only copy [push] 
					append copy switch type [
						translate 	[[translate 0x0]]
						scale 		[[scale 1 1]]
						skew		[[skew 0 0]]
						rotate		[[rotate 0 0x0]]
						transform	[if integer? selection-end [selection-end: selection-end + 6] [transform 0x0 0 1 1 0x0]]
					]	copy/part next selection-start selection-end
				selection-end
		]
	]
	;insert-grid: func [][]
	;new-manipulation: func [type][
	;	insert-manipulation type
	;	action: type
	;	step: 1
	;]
	new-transformation: does [
		unless all [selection-start/2 = 'push selection-start/3/1 = 'transform] [
			insert-manipulation 'transform
		]
	]
	in-group?: false
	show-group-rule: [
		[['transform | 'translate | 'scale | 'skew | 'rotate] to block! | ahead block!] (in-group?: true) into show-group-rule to end
	|	if (in-group?) collect some [
			s: set-word! keep (to-string s/1) | ['line-width | 'fill-pen | 'pen] keep (form copy/part s 2) | skip
		] (in-group?: false)
	]
	show-figs-rule: [
	;	[['transform | 'translate | 'scale | 'skew | 'rotate] to block! | ahead block!] (in-group?: true) into show-group-rule to end
	;|	if (in-group?) 
		collect some [
			s: set-word! keep (to-string s/1) | ['line-width | 'fill-pen | 'pen] keep (form copy/part s 2) | skip
		] 
	;	(in-group?: false)
	;]
	]
	get-group-elements: does [] ;???
	remove-transformations: does [
		while [
			find/match [transform translate scale skew] first next selection-start 			
		][
			change/part next selection-start first find selection-start block! find/tail selection-start block!
		]
	]
	unwrap-group: does [
		remove-transformations
		head selection-start
		selection-start/2
	]
	count: 0
	
	; Grid-layer
	grid-layer: none
	; Edit-layer
	;found-transformations: found-formatting: 
	;found-figures: make block! 10
	edit-layer: selection-layer: edit-points-panel: none
	copied-fig: copy []
	figure-points2: [
		some [s: 
			set-word!
		|	keep 'transform keep [pair! number! number! number! pair!] into figure-points2
		|	keep 'translate keep pair! into figure-points2
		|	keep 'scale keep [number! number!] into figure-points2
		|	keep 'skew keep [number! number!] into figure-points2
		| 	keep 'rotate keep [number! pair!] into figure-points2
		|	keep 'line keep [pair! some pair!]
		|	keep 'box keep pair! keep pair! opt keep integer!
		|	keep 'polygon keep [pair! pair! some pair!]
		|	keep 'circle keep [pair! 1 2 number!]
		|	keep 'ellipse keep [pair! pair!]
		|	keep 'arc keep [pair! pair! integer! integer!] opt 'closed
		|	keep 'curve keep [pair! pair! 1 2 pair!]
		|	keep 'spline keep [pair! some pair! opt 'closed]
		|	keep 'image [image! | word!] keep [pair! opt pair!]
		|	keep 'text keep pair! string!
		| 	skip
		]
	]
	bind-figure-points: does [
		clear copied-fig
		;foreach [fig points] parse copied-fig: copy/part selection-start selection-end [collect figure-points] [
		;	probe reduce [fig points]
			
			;append drawing-panel/pane layout/only compose [
			;	at (point - 5) box 11x11 loose draw [pen blue fill-pen 254.254.254.254 circle 5x5 5]
			;]
		;]
		parse copy/part selection-start selection-end [collect into copied-fig figure-points2]
		insert edit-layer/draw flatten head insert copied-fig [pen blue]
		;append drawing-panel/pane layout/only compose/deep [
		;	at 0x0 box (drawing-panel/size) draw [(drw)] 
		;]
		show drawing-panel
	]
	remove-pen: func [blk /local rule][
		parse blk rule: [some [
			remove [
				;['line-width integer!] 
			;| 	
				['pen [
				 	color-word 
				| 	tuple!
				|	word! thru ['pad | 'repeat | 'reflect] 
				]]
			]	
		|	ahead block! into rule
		| 	skip
		]]
		blk
	]
	show-selected: func [/new /sel /local found len pos][
		if any [new sel][clear at selection-layer/draw 4]
		case [
			new [append selection-layer/draw copy/deep/part next selection-start selection-end]
			sel	[append selection-layer/draw remove-pen copy/deep/part next selection-start selection-end]
			'else [change/part at selection-layer/draw 4 remove-pen copy/deep/part next selection-start selection-end tail selection-layer/draw]
		]
		selection-layer/draw: selection-layer/draw
		show selection-layer
	]
	
	a-rate: none
	tick: 0
	phase: 1
	
	tab-pan: none
	drawing-panel-tab: none
	animations: scenes: none
	info-panel: options-panel: drawing-panel: figs-panel: anim-panel: none

	over-xy: over-params: current-drawing: current-action: current-step: none
	current-zoom: none
	recalc-info: has [i p][
		repeat i length? p: info-panel/pane [
			j: i - 1
			if i > 1 [p/:i/offset/x: p/(i - 1)/offset/x + p/(i - 1)/size/x + 5]
			p/:i/size/x: size-text p/:i
		]
		show info-panel
	]
	
	ortho?: cx: cy: none
	grid: g-size: g-angle: none
	select-fig: points: none
	
	imag: none
	_Matrix: none
	
	format: 1 ; line-width
	found-format: none
	drawing-on-grid?: func [shift?][any [all [grid/data not shift?] all [not grid/data shift?]]]
	current-pen: current-type: current-gradient: none ; for gradients
	
	pen-width: pen-color: pen-color2: fill-color: fill-color2: none
	
	format-params: [pen fill-pen line-width line-join line-cap]
	manipulation-params: [transform translate scale skew rotate]
	format-or-manipulation-params: append copy format-params copy manipulation-params
	figure-proper: none
	move?: none
	move-points: copy []
	moveable: none
	find-figure-proper: func [/in block][
		block: any [block selection-start]
		find-deep block select primary pick figs/data figs/selected
	]
	ff: none
	delete: func [face][
		put primary pick face/data face/selected none
		sel: select-figure 
		remove at face/data face/selected
		remove/part selection-start selection-end
		face/selected: sel
		select-figure
		show [face canvas]
	]
	rename: func [face][
		new-name: ask-new-name
		either find face/data new-name [
			show-warning "Name should be unique!"
		][
			primary/:new-name: primary/(pick face/data face/selected)
			put primary pick face/data face/selected none
			change at face/data face/selected new-name
			change selection-start to-set-word new-name
			selected-figure/text: new-name
			show selected-figure
			show face
		]
	]
	win: layout/options compose/deep [
		title "Drawing pad"
		size 600x500
		tab-pan: tab-panel  [
			"Drawing" [
				drawing-panel-tab: panel [
					across 
					info-panel: panel 480x20 [
						origin 0x0 space 4x0
						over-xy: text 10x20
						over-params: text 20x20
						current-zoom: text 20x20
						current-action: text 40x20
						current-drawing: text 80x20
						current-step: text 40x20
					]
					return
					edit-options-panel: panel 480x30 [
						origin 0x0 space 4x0
						text 50x20 "Selected:" 
							selected-figure: text 80x20 
						grid: check "Grid:" 45x20 [grid-layer/visible?: face/data poke find grid-layer/draw pair! 1 g-size/data show grid-layer]
							g-size: field 40x20 "10x10" [poke find grid-layer/draw pair! 1 g-size/data show grid-layer]
							g-angle: field 20x20 "10" text 5x20 "°" 
							g-step: field 40x20 "5x5" 
						select-fig: check "Select" [
							selection-layer/visible?: face/data 
							if all [face/data not empty? figs/data][show-selected/sel]
							show selection-layer
						]
						points: check hidden "Points" 						
					]
					return
					;below
					options-panel: panel 80x300 [
						origin 0x0 space 0x0
						style f: button 25x25 [
							env/figure: face/extra 
							start?: true 
							action: 'draw
							step: 0
							current-action/text: form action
							current-drawing/text: form face/extra
							current-step/text: rejoin ["Step: " step]
							current-zoom/text: "z: 1"
							recalc-info
						]
						f with [extra: 'line 		image: (draw 23x23 [line 5x5 17x17])]
						f with [extra: 'polyline 	image: (draw 23x23 [line 5x5 8x17 13x5 17x17])]
						f with [extra: 'arc 		image: (draw 23x23 [arc 11x13 6x6 -180 180])]
						return
						f with [extra: 'box 		image: (draw 23x23 [fill-pen snow box 5x7 17x15])]
						f with [extra: 'square 		image: (draw 23x23 [fill-pen snow box 5x5 17x17])]
						f with [extra: 'polygon 	image: (draw 23x23 [fill-pen snow polygon 5x8 11x5 17x8 14x17 8x17])]
						return
						f with [extra: 'ellipse 	image: (draw 23x23 [fill-pen snow ellipse 5x6 13x10])]
						f with [extra: 'circle 		image: (draw 23x23 [fill-pen snow circle 11x11 6])]
						f with [extra: 'sector 		image: (draw 23x23 [fill-pen snow arc 5x11 12x6 -25 50 closed])]
						return
						f with [extra: 'paragram 		image: (draw 23x23 [fill-pen snow polygon 5x5 17x9 17x17 5x13])];fill-pen snow polygon 5x7 11x11 11x17 5x13])]
						f with [extra: 'parachain 	image: (draw 23x23 [
							fill-pen snow 
								polygon 5x5 9x9 9x17 5x13 
								polygon 9x9 13x5 13x13 9x17
								polygon 13x5 17x9 17x17 13x13
						])]
						f with [extra: 'paratriple 	image: (draw 23x23 [
							fill-pen snow 
								polygon 5x7 11x11 11x17 5x13 
								polygon 5x7 11x3 17x7 11x11 
								polygon 11x11 17x7 17x13 11x17
						])]
						return
						f with [extra: 'curve		image: (draw 23x23 [curve 5x11 11x2 17x17])]
						f with [extra: 'cubicCurve		image: (draw 23x23 [curve 5x11 9x0 13x23 17x11])]
						f with [extra: 'spline		image: (draw 23x23 [spline 5x7 5x17 7x17 9x11 13x11 15x17 17x17 17x7])];[spline 6x7 8x7 10x15 12x15 14x7 16x7 17x11 11x12 5x11 closed])]
						return
						f with [extra: 'freehand 	image: (draw 23x23 [line 5x5 7x5 7x8 10x8 10x6 13x6 13x9 17x9 17x12 14x12 14x17 17x17])]
						f with [extra: 'program 
							image: (draw 23x23 [line 5x5 10x5 line 5x7 14x7 line 5x9 10x9 line 5x11 17x11 line 7x13 10x13 line 7x15 12x15 line 5x17 8x17])
						]
						f with [extra: 'splineC		image: (draw 23x23 [fill-pen snow spline 11x5 5x11 5x17 7x17 9x11 13x11 15x17 17x17 17x11 closed])];[spline 6x7 8x7 10x15 12x15 14x7 16x7 17x11 11x12 5x11 closed])]
						return 
						f with [extra: 'image 		image: (draw 23x23 compose [
							image (load/as read/binary %frame-with-picture_1f5bc.png 'png) -3x-3 25x25
							;https://emojipedia-us.s3.amazonaws.com/thumbs/160/emoji-one/44/frame-with-picture_1f5bc.png
						])] on-up [imag: load-file env/figure: 'image]
						f with [extra: 'ortho-grid image: (draw 23x23 [box 5x5 17x17 line 8x5 8x17 line 11x5 11x17 line 14x5 14x17 line 5x8 17x8 line 5x11 17x11 line 5x14 17x14])]
						;f with [extra: 'radial-grid image: (draw 23x23 [])]
						f with [extra: 'layer image: (draw 23x23 [fill-pen snow polygon 5x17 9x10 17x10 13x17 polygon 5x12 9x5 17x5 13x12])][
							;env/canvas/extra/figs: figs/data
							;clear figs/data
							append layers/data ff: rejoin ["layer" layers*: layers* + 1]
							insert at drawing-panel/pane -2 + length? drawing-panel/pane layout/only probe head insert at copy/deep [
								at 0x0 box glass draw [matrix [1 0 0 1 0 0]] with [
									extra: make map! reduce ['figs copy []] 
									size: is [drawing-panel/size]
									actors: object [
										on-time: func [face event /local r-center angle scale-x scale-y translate][
											;if all [action = 'animate step = 2 selection-start/2 = 'transform] [
											;	selection-start/4: anim-step: anim-step + 1
											;	show face
											;]
											do probe bind bind load animations edit-layer env
											show canvas
										]
									]
								]
							] 3 to-set-word ff
							env/canvas: get to-word ff
							figs: figs1
							figs/data: canvas/extra/figs
							layers/visible?: sep1/visible?: true
							layers/size/y: layers/size/y + 20
							sep1/offset/y: layers/size/y
							figs/offset/y: sep1/offset/y + sep1/size/y
							figs/size/y: figs/size/y - 60
							layers/selected: length? layers/data
							
							;win/size: win/size + 0x0
							show [drawing-panel figs-panel]
							selection-start: at canvas/draw 3 selection-end: tail canvas/draw
							;redraw
						]
						return
						do [current-drawing/text: rejoin ["draw line"] ];recalc-info] Causes error in start-up!
						return below
						group-box "pen" [
							origin 2x10 space 2x2
							pen-width: field 22x22 "1" [
								switch/default action [
									insert [] ; TBD
									line-width [
										format-local 'line-width face/data
										unless find/part at selection-start 4 'line-width selection-end [
											either last-selected? figs [
												append selection-start reduce ['line-width format]
											][
												insert back selection-end reduce ['line-width format]
											]
										]
										face/data: format show face 
										;env/action: 'draw recalc-info
										;show canvas
									]
								][
									append canvas/draw reduce ['line-width face/data] 
									append figs/data form reduce ['line-width face/data] 
									figs/selected: length? figs/data
									select-figure 
									show figs
								]
							]
							pen-color: base 22x22 black draw [pen gray box 0x0 21x21][
								if block? color [env/color: color/1]
								select-color 
								switch/default action [
									insert [] ; TBD
									pen [
										format-local 'pen color
										env/color: format 
									]
									pen-linear	or
									pen-radial	or
									pen-diamond [face/color: format]
								][
									if not word? color [env/color: 'black]
									append canvas/draw reduce ['pen color]
									append figs/data form reduce ['pen color]
									figs/selected: length? figs/data
									select-figure 
									show figs
								]
								face/color: either word? color [get color][color]
								show face  
							] 
							pen-color2: base 22x22 black draw [pen gray box 0x0 21x21][
								request-color 
								switch/default action [
									insert [] ; TBD
									pen [
										format-local 'pen color
										env/color: format 
									]
									pen-linear	or
									pen-radial	or
									pen-diamond [face/color: format]
								][
									append canvas/draw reduce ['pen color]
									append figs/data form reduce ['pen color]
									figs/selected: length? figs/data
									select-figure 
									show figs
								]
								face/color: color
								show face  
							] 
							;return
							;(gradient-pens)
							return
							(line-joins) 
							return
							(line-caps)
						]
						group-box "fill" [
							origin 2x10 space 2x2
							fill-color: base 22x22 0.0.0.254 draw [pen gray box 0x0 21x21][
								if block? color [env/color: color/1]
								select-color 
								switch/default action [
									insert []
									fill [
										format-local 'fill-pen color
										env/color: format 
									]
									fill-linear 	or
									fill-radial 	or
									fill-diamond 	[];face/color: format]
									background [
										env/canvas/color: either word? env/color [get env/color][color]
										show canvas
									]
								][
									if not word? color [env/color: 'black]
									append canvas/draw reduce ['fill-pen color]
									append figs/data form reduce ['fill-pen color] 
									figs/selected: length? figs/data
									select-figure 
									show figs
									face/color: color;either word? color [get color][color]
								]
								show face
							]
							fill-color2: base 22x22 snow draw [pen gray box 0x0 21x21][
								request-color
								switch/default action [
									insert []
									fill [
										format-local 'fill-pen color
										face/color: env/color: format 
									]
									fill-linear 	or
									fill-radial 	or
									fill-diamond 	[face/color: format]
									background [
										env/canvas/color: either word? env/color [get env/color][color]
										show canvas
									]
								][
									append canvas/draw reduce ['fill-pen color]
									append figs/data form reduce ['fill-pen color] 
									figs/selected: length? figs/data
									select-figure 
									show figs
									face/color: color 
								]
								show face
							]
							;return
							;(gradient-fills)
						]
						button "clear" [
							clear at canvas/draw 3
							canvas/draw/2: [1 0 0 1 0 0]
							clear at selection-layer/draw 3
							selection-layer/draw/2: [1 0 0 1 0 0]
							show [canvas selection-layer]
							;probe length? figs/data

							foreach-face/with figs-panel [
								clear face/data 
								either face/extra = 'figs1 [
									face/size/y: face/parent/size/y
								][face/visible?: false]
							][2 < index? find face/parent/pane face]
							show figs-panel

							foreach key keys-of figures* [figures*/:key: none]

							pen-width/data: 1
							pen-color/color: 0.0.0
							fill-color/color: 254.254.254.254
							show [pen-width pen-color fill-color]
							
							action: 'draw figure: 'line
							foreach-face info-panel [clear face/text] 
							current-action/text: "draw" current-drawing/text: "line"
							recalc-info
						]
					]
					;return
					drawing-panel: panel 300x300 [
						origin 0x0 space 0x0
						style layer: box glass draw [matrix [1 0 0 1 0 0]] with [extra: #()]
						style edit: base white 300x300 all-over
						;rate 1;none
							draw [matrix [1 0 0 1 0 0]];_Matrix: 
							with [
								actors: object [
									pos1: 0x0
									pos-tmp: 0x0
									last-pos: 0x0		; for arcs and sectors
									last-offset: 0x0  	; for grid
									pre-diff: 0x0
									pre-angle: 0
									last-cur-angle: 0
									direction: none
									sector: none
									;fig-start: none
									on-wheel: func [face event /local sl][
										unless face/draw/1 = 'matrix [
											insert face/draw [matrix [1 0 0 1 0 0]]
											insert canvas/draw [matrix [1 0 0 1 0 0]]
										]
										;_Matrix: face/draw
										select-figure
										fc: face ;canvas 
										ev: fc/offset
										; find face offset on screen
										until [fc: fc/parent ev: ev - fc/offset fc/type = 'window]
										; cursor offset on face
										ev: event/offset + ev
										; current center of coordinates (COC)
										dr: as-pair _Matrix/2/5 _Matrix/2/6
										; cursor offset from COC (i.e. relative to COC)
										df: dr - ev
										; increased offset from COC
										df+: as-pair to-integer round df/x / 1.1 to-integer round df/y / 1.1
										; decreased offset from COC
										df-: as-pair to-integer round df/x * 1.1 to-integer round df/y * 1.1
										; add cursor offset to new offset
										dr+: df+ + ev
										dr-: df- + ev
										_Matrix/2: canvas/draw/2: selection-layer/draw/2: grid-layer/draw/2: reduce [
											either 0 > event/picked [_Matrix/2/1 / 1.1][_Matrix/2/1 * 1.1]
											0 0
											either 0 > event/picked [_Matrix/2/4 / 1.1][_Matrix/2/4 * 1.1]
											either 0 > event/picked [dr+/x][dr-/x]
											either 0 > event/picked [dr+/y][dr-/y]
										]
										current-zoom/text: rejoin ["z: " round/to _Matrix/2/1 .01]
										recalc-info
										show [face canvas grid-layer selection-layer]
									]
									on-alt-down: func [face event][
										pos1: event/offset
										;if face/draw/1 = 'matrix [
											mxpos: as-pair _Matrix/2/5 _Matrix/2/6
											pos1: as-pair to-integer round pos1/x / _Matrix/2/1 to-integer round pos1/y / _Matrix/2/4
											pos1: subtract pos1 mxpos / _Matrix/2/1
										;]
										if drawing-on-grid? event/shift? [
											pos1/x: round/to pos1/x g-size/data/x pos1/y: round/to pos1/y g-size/data/y
										]
										switch action [
											draw [
												switch figure [
													parachain [
														switch step [
															3 or 4 [
																append selection-start 
																	append/dup copy [polygon] 
																		copy/part skip tail selection-start -3 2 2
																reverse skip tail selection-start -2
															]
														]
													]
												]
											]
										]
									]
									on-key-down: func [face event][;probe event/flags
										switch event/key [
											#"M" [env/action: 'move]
											#"T" [env/action: either find event/flags 'control ['t-translate]['translate] 	env/step: 1]
											#"S" [env/action: either find event/flags 'control ['t-scale]	 ['scale] 		env/step: 1]
											#"K" [env/action: 'skew 														env/step: 1]
											#"R" [env/action: either find event/flags 'control ['t-rotate]	 ['rotate]		env/step: 1]
											delete [env/delete figs]
											#"N" [env/rename figs]
											#"G" [env/action: 'group]
										]
										show [edit-layer canvas figs]
									]
									on-down: func [face event /local code pen type strt][
										pos1: event/offset
										;if face/draw/1 = 'matrix [
											mxpos: as-pair _Matrix/2/5 _Matrix/2/6
											pos1: as-pair to-integer round pos1/x / _Matrix/2/1 to-integer round pos1/y / _Matrix/2/4
											pos1: subtract pos1 mxpos / _Matrix/2/1
										;]
										if drawing-on-grid? event/shift? [
											pos1/x: round/to pos1/x g-size/data/x pos1/y: round/to pos1/y g-size/data/y
										]
										switch action [
											draw [
												switch/default figure [
													polyline or polygon or spline [
														unless start? [
															env/step: 2
															either last-action = 'insert [
																next-figure: insert next-figure pos1
															][
																append selection-start pos1
															]
														]
													]
													splineC [
														unless start? [
															switch step [
																1 [
																	either last-action = 'insert [
																		next-figure: insert next-figure reduce [pos1 'closed]
																	][
																		append selection-start reduce [pos1 'closed]
																	]
																	env/step: 2
																]
																2 [
																	either last-action = 'insert [
																		next-figure: next insert back next-figure pos1
																	][
																		insert back tail selection-start pos1
																	]
																]
															]
														]
													]
													paragram []
													parachain [
														unless start? [
															switch step [
																3 or 4 [ 
																	; Make new polygon from duplicated positions 3 and 4, then swap values of first two positions
																	append selection-start 
																		append/dup copy [polygon] 
																			copy/part skip tail selection-start -2 2 2
																	reverse skip tail selection-start -4 2
																]
															]
														]
													]
													paratriple [
														unless start? [
															switch step [
																3 [ 
																	; Make new polygon from duplicated positions 3 and 4, then swap values of first two positions
																	append selection-start 
																		append/dup copy [polygon] 
																			copy/part skip tail selection-start -2 2 2
																	reverse skip tail selection-start -4 2
																	append selection-start 
																		append/dup copy [polygon] 
																			copy/part skip tail selection-start -8 2 2
																	reverse skip tail selection-start -2
																]
															]
														]
													]
													arc or sector [
														if step = 1 [env/step: 2]
														if step = 3 [env/step: 0 start?: true]
													]
													program [
														unless empty? code: write-program [
															if start? [
																either figures*/:figure [
																	figures*/:figure: figures*/:figure + 1
																][
																	figures*/:figure: 1
																]
																ff: rejoin [figure figures*/:figure]
																secondary/:ff: figure
																either last-action = 'insert [
																	insert figs/data ff
																][
																	append figs/data ff 
																	figs/selected: length? figs/data 
																]
																show figs
																selected-figure/text: ff 
																show selected-figure
																either last-action = 'insert [
																	insert next-figure reduce [
																		to-set-word ff do bind bind load code self env
																	]
																][
																	append selection-start reduce [
																		to-set-word ff do bind bind load code self env
																	] 
																]
																select-figure
																redraw
																start?: false 
																show canvas
															]
														]
													]
													image [
														unless empty? imag [
															if start? [
																either figures*/:figure [
																	figures*/:figure: figures*/:figure + 1
																][
																	figures*/:figure: 1
																]
																ff: rejoin [figure figures*/:figure]
																either last-action = 'insert [
																	insert figs/data ff
																][
																	append figs/data ff 
																	figs/selected: length? figs/data 
																]
																show figs
																primary/:ff: secondary/:ff: 'image
																selected-figure/text: ff 
																show selected-figure
																
																either last-action = 'insert [
																	insert next-figure reduce [
																		to-set-word ff 'image imag pos1
																	]
																][
																	append selection-start reduce [
																		to-set-word ff 'image imag pos1 
																	] 
																] 
																env/step: 1
																select-figure
																redraw
																start?: false 
																;show canvas
															]
														]
													]
													curve or cubicCurve [if step = 1 [env/step: 2]]
												][
													start?: true
												]
											]
											move [
												either find format-or-manipulation-params selection-start/1 [
													move?: false
												][
													if figure-proper: find-figure-proper [
														moveable: select figure-move-points figure-proper/1
														move?: true
													]
												]
											]
											;t-rotate or t-scale [
											;	if step = 1 [selection-start/3/2: pos1]
											;	env/step: 2
											;]
											t-translate [
												if step = 2 [
													pre-diff: pos1 - event/offset + selection-start/3/6 ;?? last pos1?
												]
											]
											pen-linear or pen-radial or pen-diamond or fill-linear or fill-radial or fill-diamond [
												set [pen type] split form action #"-"
												env/current-pen: pick [fill-pen pen] pen = "fill"
												env/current-type: to-word type
												if find [pen-radial pen-diamond fill-radial fill-diamond] action [
													if step = 3 [poke current-gradient skip-colors + 1 pos1 redraw]
												]
											]
											;animate [
												;if all [selection-start/2 = 'transform][
												;	probe selection-start/3: event/offset ; For rotation
												;	pos1: event/offset 
													;probe canvas/rate: 10
												;]
												;env/step: 2 
											;] 
										] 
									]
									on-over: func [face event /local mx pos2 draw-form ff i j pnum diff diff2 len wf][
										either drawing-on-grid? event/shift? [
											over-xy/text: rejoin ["x: " round/to event/offset/x g-size/data/x " y: " round/to event/offset/y g-size/data/y]
										][
											over-xy/text: rejoin ["x: " event/offset/x " y: " event/offset/y]
										]
										recalc-info
										if all [any [event/down? event/alt-down?] not find [program] figure][
											either all [start? action = 'draw event/down?]  [
												unless figure [figure: 'line]
												draw-form: switch/default figure [
													square 	 	['box] 
													polyline 	['line]
													sector		['arc]
													freehand	['line]
													paragram	or
													parachain 	or
													paratriple	['polygon]
													ortho-grid	['box]
													cubicCurve	['curve]
													splineC		['spline]
												][figure]
												; Synchronize figs list --->
												either figures*/:figure [
													figures*/:figure: figures*/:figure + 1
												][
													figures*/:figure: 1
												]
												ff: rejoin [figure figures*/:figure]
												; Synchronize db
												primary/:ff: draw-form
												secondary/:ff: figure
												either last-action = 'insert [
													insert at figs/data figs/selected ff
												][
													append figs/data ff
													figs/selected: length? figs/data 
												]
												show figs
												;<--- figs
												selected-figure/text: ff 
												show selected-figure
												either last-action = 'insert [
													next-figure: insert next-figure reduce [
														to-set-word ff 
															draw-form pos1 switch/default figure [
																ellipse [0x0]
																circle  [0]
																arc	or sector [0x0]
															][pos1]
													]
												][
													append selection-start reduce [
														to-set-word ff 
															draw-form pos1 switch/default figure [
																ellipse or arc or sector [0x0]
																circle  [0]
															][pos1]
													]
												]
												if find [polygon spline splineC arc sector freehand paragram parachain paratriple curve cubicCurve] figure [env/step: 1]
												either last-action = 'insert [
													switch figure [
														polygon 		[next-figure: insert next-figure pos1] 
														;spline 			[next-figure: insert next-figure pos1] 
														;splineC			[next-figure: insert next-figure reduce [pos1 'closed]]
														arc				[next-figure: insert next-figure [180 1]]
														sector			[next-figure: insert next-figure [180 1 closed]]
														paragram	or
														parachain 	or
														paratriple 		[next-figure: insert next-figure reduce [pos1 pos1]]
														curve			[next-figure: insert next-figure pos1]
														cubicCurve		[next-figure: insert next-figure reduce [pos1 pos1]]
													]
												][
													switch figure [
														polygon 		[append selection-start pos1] 
														;spline 			[append selection-start pos1]
														;splineC			[append selection-start reduce [pos1 'closed]]
														arc				[append selection-start [180 1]]
														sector			[append selection-start [180 1 closed]]
														paragram	or
														parachain 	or
														paratriple		[append selection-start reduce [pos1 pos1]]
														curve			[append selection-start pos1]
														cubicCurve		[append selection-start reduce [pos1 pos1]]
													]
												]
												select-figure
												;if attempt [template/:figure] [
												;	obj/(wf: to-word ff): template/:figure
													;obj/:wf/source: next find obj/:wf/source selection-start 
												;]
												case [
													find [arc sector] figure [
														insert-manipulation 'rotate
														selection-start/3/3: pos1
														direction: 'cw
														sector: 'positive
													]
													figure = 'ortho-grid [
														;probe selection-start
														change/part next selection-start 
															append/only copy [push]
																append either empty? g-step/text [
																	append/only reduce ['fill-pen 'pattern g-size/data 0x0 g-size/data 'tile] 
																				reduce ['pen 'silver 'line 0x0 as-pair 0 g-size/data/y 'line 0x0 as-pair g-size/data/x 0]
																][
																	append/only reduce ['fill-pen 'pattern g-step/data * g-size/data 0x0 g-step/data * g-size/data 'tile] 
																		collect [
																			keep reduce ['pen 'gray 'line 0x0 as-pair g-step/data/x * g-size/data/x 0 'pen 'silver]
																			repeat i g-step/data/y - 1 [
																				keep reduce ['line as-pair 0 i * g-size/data/y as-pair g-step/data/x * g-size/data/x i * g-size/data/y]
																			]
																			keep reduce ['pen 'gray 'line 0x0 as-pair 0 g-step/data/y * g-size/data/y 'pen 'silver]
																			repeat i g-step/data/x - 1 [
																				keep reduce ['line as-pair i * g-size/data/x 0 as-pair i * g-size/data/x g-step/data/y * g-size/data/y]
																			]
																		]
																]
																next copy/part selection-start selection-end
															selection-end
													]
												]
												if select-fig/data [show-selected/new]; probe reduce ["new:" selection-layer/draw]]
												start?: false
											][	
												pos2: event/offset
												if face/draw/1 = 'matrix [
													mxpos: as-pair _Matrix/2/5 _Matrix/2/6
													pos2: as-pair to-integer round pos2/x / _Matrix/2/1 to-integer round pos2/y / _Matrix/2/4
													pos2: subtract pos2 mxpos / _Matrix/2/1
												]
												diff: pos2 - pos1
												if drawing-on-grid? event/shift? [
													pos2/x: round/to pos2/x g-size/data/x pos2/y: round/to pos2/y g-size/data/y
												]
												if pos2 <> pos-tmp [
													either event/ctrl? [
														either ortho? [
															either cx [pos2/x: cx][pos2/y: cy] 
														][
															ortho?: on either lesser? absolute diff/x absolute diff/y [cx: pos1/x cy: none][cy: pos1/y cx: none]
														]
													][
														ortho?: off cx: cy: none
													] 
													diff: pos2 - pos1
													ang: round/to 180 / pi * arctangent2 diff/y diff/x either drawing-on-grid? event/shift? [g-angle/data][.1]
													hyp: sqrt add diff/x ** 2 diff/y ** 2
													over-params/text: rejoin ["d: " diff " r: " round/to hyp .1 " α: " ang]
													recalc-info
													either action = 'draw [
															len: either last-action = 'insert [offset? selection-start next-figure][length? selection-start]
															if event/down? [
																case [
																	all [figure = 'polygon step = 1][; triangle?
																		poke selection-start len - 1 pos2
																		poke selection-start len 	 pos2
																	]
																	find [paragram parachain paratriple] figure [
																		switch step [
																			1 [ 
																				poke selection-start len - 2 pos2 	
																				poke selection-start len - 1 pos2
																				
																			]
																			2 [ 
																				df: pos2 - first skip tail selection-start -3 
																				poke selection-start len - 1 pos2 
																				poke selection-start len df + first skip tail selection-start -4 
																			]
																			3 or 4 [ 
																				switch figure [
																					parachain [
																						df: pos2 - first skip tail selection-start -3 
																						poke selection-start len - 1 pos2
																						poke selection-start len  df + first skip tail selection-start -4
																					]
																					paratriple [
																						df: pos2 - first skip tail selection-start -8 
																						poke selection-start len - 6 pos2
																						poke selection-start len - 5 df + first skip tail selection-start -9
																						df: pos2 - first skip tail selection-start -8 
																						poke selection-start len - 1 pos2 ; 
																						poke selection-start len df + first skip tail selection-start -4
																					]
																				]
																			]
																		]
																	]
																	find [arc sector] figure [
																		switch step [
																			1 [
																				pre-angle: 180 + round/to 180 / pi * arctangent2  diff/y diff/x either drawing-on-grid? event/shift? [g-angle/data][1] ; 
																				selection-start/3/2: 180 + round/to 180 / pi * arctangent2  diff/y diff/x either drawing-on-grid? event/shift? [g-angle/data][1]
																				last-cur-angle: 180 + round/to 180 / pi * arctangent2  diff/y diff/x either drawing-on-grid? event/shift? [g-angle/data][1]
																				selection-start/3/6: as-pair i: sqrt add power diff/x 2 power diff/y 2 i
																			]
																			2 [	
																				diff: event/offset - last-pos
																				cur-angle: round/to 180 / pi * arctangent2 diff/y diff/x either drawing-on-grid? event/shift? [g-angle/data][1]
																				diff2: cur-angle - pre-angle
																				case [
																					all [last-cur-angle > 170 	cur-angle < -170]	[sector: pick ['negative 'positive] direction = 'cw]
																					all [last-cur-angle < -170 	cur-angle > 170]	[sector: pick ['positive 'negative] direction = 'cw]
																					all [pre-angle - 180 - last-cur-angle >= 0 pre-angle - 180 - cur-angle < 0]	[direction: 'cw  sector: 'positive]
																					all [pre-angle - 180 - last-cur-angle < 0 pre-angle - 180 - cur-angle >= 0]	[direction: 'ccw sector: 'negative]
																				]
																				last-cur-angle: cur-angle
																				poke selection-start/3 8 case [
																					all [direction = 'cw  sector = 'negative][540 + diff2]
																					all [direction = 'ccw sector = 'positive][-180 + diff2]
																					'else [180 + diff2]
																				]
																				;selection-start/4: selection-start/4
																				redraw
																			]
																		]
																	]
																	figure = 'program []
																	figure = 'freehand [
																		if pos2 <> pos1 [
																			switch step [
																				1 [poke selection-start len pos2 pos1: pos2 env/step: 2]
																				2 [append selection-start pos2 pos1: pos2]
																			]
																		]
																	]
																	figure = 'image [
																		switch step [
																			1 [append selection-start pos2 env/step: 2]
																			2 [poke selection-start len pos2]
																		]
																	]
																	figure = 'ortho-grid [
																		;probe selection-start/3
																		poke selection-start/3 length? selection-start/3 pos2
																	]
																	find [curve cubicCurve] figure [
																		switch step [
																			1 [
																				poke selection-start len pos2
																				;poke selection-start len - 1 pos1 + pos2 / 2
																			]
																			2 [ 
																				poke selection-start len - 1 pos2 
																			]
																		]
																	]
																	all [figure = 'splineC  step = 2] [
																		;poke selection-start len - 2 pos2
																		poke selection-start len - 1 pos2
																	]
																	'else [
																		poke selection-start len switch/default figure [
																			square [dim: max diff/x diff/y pos1 + as-pair dim dim]
																			ellipse [diff]
																			circle [sqrt add power diff/x 2 power diff/y 2]
																		][pos2]
																	]
																]
															]
															if event/alt-down? [
																case [
																	find [parachain paratriple] figure [
																		switch step [
																			3 or 4 [ ; Move positions positions 3 and 4 of new polygon 
																				either figure = 'parachain [
																					df: pos2 - first skip tail selection-start -3 
																					poke selection-start len - 1 pos2 ; 
																					poke selection-start len df + first skip tail selection-start -4
																				][]
																			]
																		]
																	]
																	figure = 'cubicCurve [
																		if step = 2 [
																			poke selection-start len - 2 pos2
																		]
																	]
																]
																last-mode: 'alt-down
															]
															select-figure
															;redraw
															;show face
													][
														if event/down? [
															switch action [
																move [
																	if move? [
																		clear move-points
																		parse next figure-proper reduce [
																			'collect 'into 'move-points 
																			either find [parachain paratriple] figure [
																				[some [keep pair! | 'polygon]]
																			][
																				select figure-points figure-proper/1
																			]
																		]
																		if block? move-points/1 [move-points: move-points/1]
																		either moveable/1 = 'all [
																			either find [parachain paratriple] figure [
																				forall move-points [
																					x: divide -1 + index? move-points 4
																					poke figure-proper x + 1 + index? move-points move-points/1 + diff
																				]
																			][
																				forall move-points [poke figure-proper 1 + index? move-points move-points/1 + diff]
																			]
																		][
																			either figure-proper/1 = 'arc [
																				forall move-points [poke figure-proper -1 move-points/1 + diff poke figure-proper pick moveable index? move-points move-points/1 + diff]
																			][
																				forall move-points [poke figure-proper pick moveable index? move-points move-points/1 + diff]
																			]
																		]
																		pos1: pos2
																	]
																]
																translate [
																	switch step [
																		1 [insert-manipulation action env/step: 2]
																		2 [selection-start/3/2: diff]
																	]
																]
																scale [
																	switch step [
																		1 [insert-manipulation action env/step: 2]
																		2 [
																			selection-start/3/2: add 1 diff/x / 100.0 
																			selection-start/3/3: add 1 diff/y / 100.0
																		]
																	]
																]
																skew [
																	switch step [
																		1 [insert-manipulation action env/step: 2]
																		2 [
																			selection-start/3/2: diff/x 
																			selection-start/3/3: diff/y
																		]
																	]
																]
																rotate [
																	switch step [
																		1 [insert-manipulation action selection-start/3/3: pos1 env/step: 2]
																		2 [
																			selection-start/3/2: round/to 180 / pi * arctangent2  diff/y diff/x 
																				either drawing-on-grid? event/shift? [g-angle/data][.1]
																		]
																	]
																]
																t-rotate [
																	switch step [
																		1 [new-transformation selection-start/3/2: pos1 env/step: 2]
																		2 [
																			selection-start/3/3: round/to 180 / pi * arctangent2  diff/y diff/x 
																				either drawing-on-grid? event/shift? [g-angle/data][.1]
																		]
																	]
																]
																t-scale [
																	switch step [
																		1 [new-transformation selection-start/3/2: pos1 env/step: 2]
																		2 [
																			selection-start/3/4: add 1 diff/x / 100.0
																			selection-start/3/5: add 1 diff/y / 100.0
																		]
																	]
																]
																t-translate [
																	switch step [
																		1 [new-transformation selection-start/3/2: pos1 env/step: 2]
																		2 [selection-start/3/6: diff + pre-diff]
																	]
																]
																;animate [
																;	if all [step = 2 canvas/rate] [
																;		canvas/rate: either 0 < diff/x [canvas/rate + diff/x][0:0:1 + divide absolute diff/x 10]
																;	]
																;]
																pen-linear or 
																pen-radial or
																pen-diamond or
																fill-linear or
																fill-radial or
																fill-diamond [
																	switch step [
																		1 [ 
																			set-gradient current-pen current-type pos1 env/step: 2
																			env/current-gradient: find/last selection-start/3 current-pen
																		]
																		2 [ 
																			poke current-gradient skip-colors switch current-type [
																				linear [pos2] 
																				radial [hyp] 
																				diamond [pos2]
																			]
																		]
																		3 [poke current-gradient skip-colors + 1 pos2]
																	]
																]
															]
															last-mode: 'down
														]
													]
													;if attempt [template/:figure] [
													;	obj/(wf: to-word ff): template/:figure
														;obj/:wf/source: next find obj/:wf/source selection-start 
													;]
													if select-fig/data [show-selected]
												]
												pos-tmp: pos2
											]
											redraw
										]
									]
									on-alt-up: func [face][
										switch action [
											draw [
												switch figure [
													parachain [
														switch step [
															3 [env/last-step: step env/step: step + 1]
															4 [env/last-step: 4]
														]
													]
												]
											]
										]
									]
									on-up: func [face][
										if all [last-action = 'insert not find [polygon polyline paragram parachain paratriple spline splineC] figure] [last-action: none]
										switch action [
											t-rotate [env/step: 1]
											draw [
												switch figure [
													arc or sector [
														if step = 2 [env/step: 3]
													]
													image [env/step: 0 start?: true show face] ; In case image was set by a click, i.e. without on-over
													paragram [
														switch step [
															1 [env/step: 2]
															2 [env/step: 0 env/start?: true env/action: 'draw]
														]
													]
													parachain [
														switch step [
															1 or 2 or 3 [env/last-step: step env/step: step + 1]
															4 [env/last-step: 4]
														]
													]
													paratriple [
														switch step [
															1 or 2 [env/last-step: step env/step: step + 1]
															3 [env/step: 0 env/start?: true env/action: 'draw]
														]
													]
												]
											]
											pen-radial or pen-diamond or fill-radial or fill-diamond [if step = 2 [env/step: 3]]
										]
										last-pos: pos1
										probe canvas/draw
										env/win/selected: face show win
									]
								]
							]
						;at 0x0 drawing-bg: box white ;230.230.235
						layer1: layer 255.255.255.0 with [
							actors: object [
								on-time: func [face event /local r-center angle scale-x scale-y translate][
									;if all [action = 'animate step = 2 selection-start/2 = 'transform] [
									;	selection-start/4: anim-step: anim-step + 1
									;	show face
									;]
									do bind bind load animations self env
									show canvas
								]
							]
						]
						do [
							env/canvas: layer1 
							selection-start: at canvas/draw 2 
							selection-end: tail canvas/draw
						]
						;at 0x0 edit-panel: panel 0.0.0.254 [
							;origin 0x0 space 0x0 
						at 0x0 selection-layer: box hidden with [
							draw: [matrix [1 0 0 1 0 0] [line-join bevel line-width 2 pen 80.150.255]]
						]
						at 0x0 grid-layer: box hidden with [
							draw: append append/only append [matrix [1 0 0 1 0 0] pen off fill-pen pattern] env/g-size/data 
								[fill-pen cyan circle 0x0 .5] append [box 0x0] canvas/size
						]
						at 0x0 edit-layer: edit transparent
						do [_Matrix: edit-layer/draw]
						;]
					]
					;return
					figs-panel: panel 100x300 [
						style fig-list: text-list 100x300 data [] ;265
							with [
								menu: [
									"Format" [	
										"Line" [
											"Width" 	line-width
											"Join" 		line-join
											"Cap"		line-cap
										]
										"Pen" [
											"Color" 	pen
											"Linear"	pen-linear
											"Radial"	pen-radial
											"Diamond"	pen-diamond
										;	"Pattern" 	pen-pattern
										;	"Bitmap"	pen-bitmap
										;	"Off"		pen-off
										]
										"Fill" [
											"Color" 	fill
											"Linear"	fill-linear
											"Radial"	fill-radial
											"Diamond"	fill-diamond
										;	"Pattern" 	fill-pattern
										;	"Bitmap"	fill-bitmap
										;	"Off"		fill-off
										]
										;"Anti-alias"	anti-alias
									]
									"Move-z" [
										"Back" 			back 
										"Backward" 		backward 
										"Forward" 		forward 
										"Front" 		front 
										"---"
										"Before"		before 
										"Swap"			swap
									]
									"Move (M)"			move 
									"Manipulate" [
										"Translate (T)"	translate
										"Scale (S)"		scale
										"Skew (K)"		skew 
										"Rotate (R)"	rotate
									;	"Undo last"		undo-manipulation ; TBD Delete latest manipulation
									;	"Undo all"		undo-manipulations ; TBD Delete all manipulations
									]
									"Transform" [
										"Translate (Ctrl-T)" t-translate
										"Scale (Ctrl-S)"	 t-scale
										"Rotate (Ctrl-R)" 	 t-rotate
										"Undo" [
											"Rotate"	undo-t-rotate
											"Scale"		undo-t-scale
											"Translate"	undo-t-translate
											"All"		undo-transforms
										]
									];"---"
									;"Show transformations" show-transform	; TBD Show in separate window (like group elements), from where they can be edited
									;"Hide transformations" hide-transform	; TBD
									;"Animate" [
									;	"Translate" 	a-translate
									;	"Scale"			a-scale
									;	"Skew"			a-skew
									;	"Rotate"		a-rotate
									;]
									;"Stop"			stop-animation
									"Grouping" [
										"Group"		group
										"Show elements"	show-group
										"Hide elements"	hide-group
									;	"Ungroup"		ungroup		; TBD Remove group transformations and replace group with elementary contents
									]
									;"Insert"		insert ;?? New one just before current one; TBD
									"Clone"			clone
									"Rename (N)"		rename
									"Delete (Del)" 	delete
									;"3D" [
									;	"Rotate" ["x" d3-x-rotate "y" d3-y-rotate "z" d3-z-rotate] ; TBD
									;	"Translate" ["x" d3-x-translate "y" d3-y-translate "z" d3-z-translate] ; TBD
									;]
								]
								actors: object [
									pos: 0x0
									last-selected: none
									last-length: none
									last-tail: none
									;on-down: func [face event][
									;	pos: event/offset
									;]
									on-wheel: func [face event][probe event/flags
										either find event/flags 'control [
											move-selection pick [backward forward] 0 < event/picked
										][
											switch event/picked [
												1  [unless face/selected = 1 					[face/selected: face/selected - 1]]
												-1 [unless face/selected = length? face/data 	[face/selected: face/selected + 1]]
											]
											show face
											select-figure
										]
									]
									on-menu: func [face event /local sel elements point figure][
										env/action: 'draw
										switch event/picked [
											line-width 		[env/format: pen-width/data env/action: 'line-width]
											line-join 		or
											line-cap 		[env/action: event/picked]
											
											pen 			or
											pen-linear 		or
											pen-radial 		or
											pen-diamond 	or
											fill			or
											fill-linear 	or
											fill-radial 	or
											fill-diamond 	[env/format: color env/action: event/picked env/step: 1]
											
											pen-pattern 	[]
											pen-bitmap 		[]
											pen-off 		[]
											
											fill-pattern 	[]
											fill-bitmap 	[]
											fill-off 		[]
											
											anti-alias 		[]
											
											back 			[move-selection 'back]
											backward 		[move-selection 'backward]
											forward 		[move-selection 'forward]
											front 			[move-selection 'front]
											before 			[env/action: 'before] 
											swap 			[env/action: 'swap]
											
											move [env/action: 'move]
											translate or scale or skew or rotate [env/action: event/picked env/step: 1];[new-manipulation event/picked]
											undo-manipulation 	[]
											undo-manipulations 	[]
											t-rotate or t-scale or t-translate [env/action: event/picked env/step: 1];[new-transformation event/picked]
											undo-t-rotate 		or ;[if all [selection-start/2 = 'push found: find selection-start/3 'transform][found/2: 0x0 found/3: 0] show canvas]
											undo-t-scale 		or ;[if all [selection-start/2 = 'push found: find selection-start/3 'transform][found/4: found/5: 1] show canvas]
											undo-t-translate 	or ;[if all [selection-start/2 = 'push found: find selection-start/3 'transform][found/6: 0x0] show canvas]
											undo-transforms 	[
												if all [
													selection-start/2 = 'push 
													found: find selection-start/3 'transform
												][
													switch event/picked [
														undo-t-rotate 		[found/2: 0x0 found/3: 0]
														undo-t-scale 		[found/4: found/5: 1]
														undo-t-translate 	[found/6: 0x0]
														undo-transforms 	[change next found [0x0 0 1 1 0x0]]
													]
												]
												redraw ;show canvas
											]
											;animate [env/action: 'animate env/step: 1 canvas/rate: 10]
											stop-animation [canvas/rate: none env/step: 1]

											a-translate	[
												unless selection-start/3/1 <> 'translate [
													insert-manipulation 'translate ;new-manipulation 'translate ???
												]
											]

											group 		[env/action: 'group]
											show-group 	[
												if elements: parse next selection-start show-group-rule [
													group/data: elements
													group/size/y: min 20 * length? elements 240
													face/size/y: face/parent/size/y - face/offset/y - group/size/y - sep2/size/y
													sep2/offset/y: figs1/offset/y + figs1/size/y
													group/offset: as-pair face/offset/x face/offset/y + face/size/y + sep2/size/y
													sep2/visible?: yes
													group/visible?: yes
													show group show face show sep2
												]
											]
											hide-group 	[
												foreach fig next find figs-panel/pane figs [
													fig/visible?: no
												]
												figs1/size/y: figs1/parent/size/y - figs1/offset/y
												show figs-panel
											]
											ungroup 	[
												;either block? selection-start/2 [;probe selection-start/2
													replace face/data pick face/data face/selected parse next selection-start show-group-rule
													selection-end: offset? selection-start selection-end
													change/part selection-start unwrap-group selection-end ; first get to-word selection-start/1
													select-figure
													show [face canvas]
												;][
												;	show-warning 
												;	either find [transform translate scale skew rotate] selection-start/2 [
												;		"Please remove transformations first!"
												;	][
												;		"This is not a group!"
												;	]
												;]
											] ; TBD
											rename 		[env/rename face]
											insert 		[
												env/last-action: 'insert 
												next-figure: selection-start
											]
											clone 		[
												figure: select secondary pick figs/data figs/selected
												figures*/:figure: figures*/:figure + 1
												ff: rejoin [figure figures*/:figure]
												primary/:ff: select primary pick figs/data figs/selected
												secondary/:ff: figure
												append selection-start append reduce [to-set-word ff] copy/deep/part next selection-start selection-end
												append figs/data ff
												figs/selected: length? figs/data
												show figs
												select-figure
												selected-figure/text: ff
												show selected-figure
												if select-fig/data [show-selected/new]
												redraw
											]
											delete 		[env/delete face]
											d3 			[new-transformation event/picked]
										]
										current-action/text: form action
										recalc-info
									]
									on-down: func [face event][env/figs: face]
									on-select: func [face event][
										switch action [
											group [last-selected: face/selected]
											before or swap [
												last-selected: face/selected
												last-length: figure-length
											]
										]
									]
									on-change: func [face event /local new-selected new-group][
										switch/default action [
											group [
												new-selected: find-figure/tail face/selected
												either figures*/group [figures*/group: figures*/group + 1][figures*/group: 1]
												new-group: rejoin ['group figures*/group]
												change/part selection-start 
													append/only 
														copy reduce [to-set-word new-group] 
														copy/part selection-start new-selected ;/copy/deep ??
													new-selected 
												change/part at face/data last-selected new-group face/selected - last-selected + 1
												face/selected: last-selected
												select-figure
												show face show canvas
												env/action: 'draw
											]
											before [
												move-selection/from/to 'before last-selected face/selected
												show face show canvas
												env/action: 'draw
											]
											swap [
												move-selection/from/to 'swap last-selected face/selected
												show face show canvas
												env/action: 'draw
											]
										][select-figure]
									]
								]
							]
						style sep: box loose 30x10 
						draw [pen gray line 0x4 30x4 line 0x6 30x6] hidden on-drag [
							face/offset/x: 35
							idx: index? find face/parent/pane face
							prev: face/parent/pane/(idx - 1)
							nex:  face/parent/pane/(idx + 1)
							tot: 0
							foreach-face/with figs-panel [tot: tot + face/size/y][face/visible? = yes];prev/size/y + face/size/y + nex/size/y
							prev/size/y: face/offset/y - prev/offset/y
							nex/offset/y: face/offset/y + face/size/y
							nex/size/y: tot - prev/size/y - face/size/y
							show figs-panel
						] 
						at 0x0 layers: text-list 100x30 hidden data ["layer1"]
							with [
								extra: 'layers
								menu: [
									"Move-z" [
										"Back" 			back 
										"Backward" 		backward 
										"Forward" 		forward 
										"Front" 		front 
										"---"
										"Before"		before 
										"Swap"			swap
									]
									"Toggle visibility"	visible
									"Background"		background
									;"Clone"				clone
									"Rename"			rename
									"Delete" 			delete
								]
								actors: object [
									last-selected: none
									on-wheel: func [face event][
										move-layer pick [backward forward] 0 < event/picked
									]
									on-select: func [face event][last-selected: face/selected]
									on-change: func [face event /local new-selected new-group][
										switch/default action [
											before [
												move-layer/from/to 'before last-selected face/selected
												;show [drawing-panel figs-panel]
												env/action: 'draw
											]
											swap [
												move-layer/from/to 'swap last-selected face/selected
												;show [drawing-panel figs-panel]
												env/action: 'draw
											]
										][select-layer]
									]
									on-menu: func [face event /local sel new-name name][
										switch event/picked [
											back 		[move-layer 'back]
											backward 	[move-layer 'backward]
											forward 	[move-layer 'forward]
											front 		[move-layer 'front]
											before 		[env/action: 'before] 
											swap 		[env/action: 'swap]
											visible [
												sel: face/selected
												drawing-panel/pane/:sel/visible?: not drawing-panel/pane/:sel/visible? 
												show drawing-panel
											]
											background [
												env/format: env/color 
												env/action: 'background
												;select-color 
											]
											rename [
												new-name: ask-new-name
												either find face/data new-name [
													show-warning "Name should be unique!"
												][
													do reduce [
														to-set-word new-name to-get-word name: pick face/data face/selected
														unset to-lit-word name
													]
													change at face/data face/selected new-name
													show face
												]
											]
											delete [
												remove at drawing-panel/pane face/selected 
												sel: either face/selected = length? face/data [face/selected - 1][face/selected]
												remove at face/data face/selected
												face/selected: sel
												env/canvas: get to-word pick face/data face/selected
												figs/data: canvas/extra/figs
												show [drawing-panel figs-panel]
											]
										]
									]
								]
							]
						at 35x0 sep1: sep
						at 0x0 figs1: fig-list with [extra: 'figs1] do [env/figs: figs1 env/canvas/extra/figs: figs/data]
						at 35x0 sep2: sep
						at 0x0 group: fig-list with [extra: 'group] hidden
						at 35x0 sep3: sep
						at 0x0 subgroup: fig-list with [extra: 'subgroup] hidden
						at 35x0 sep4: sep
						at 0x0 subgroup2: fig-list with [extra: 'subgroup2] hidden
						;across space 1x10
						;button 25x25 with [image: (draw 23x23 [fill-pen black polygon 10x17 12x17 12x8 14x8 11x5 8x8 10x8])][
							
						;]
						;button 25x25 with [image: (draw 23x23 [fill-pen black polygon 10x5 12x5 12x14 14x14 11x17 8x14 10x14])]
					]
					return
					anim-panel: panel 300x25 [
						origin 0x0 space 4x0
						text 30x23 "Rate:" a-rate: field 30x23 with [data: 10][canvas/rate: face/data]
						button "Animate" [
							insert clear body-of :env/canvas/actors/on-time [tick: tick + 1]
							append body-of :env/canvas/actors/on-time bind bind bind append load animations/text [show face] :env/canvas/actors/on-time env/canvas/actors env
							canvas/rate: a-rate/data
							show canvas
							;append canvas/draw clear []
						] 
						button "Stop" [canvas/rate: none] 
						button "Continue" [canvas/rate: a-rate/data show canvas]
					]
				]
			]
			"Animation" [
				animations: area 520x420
			]
			"Scenes" [
				;scenes: none
			]
		]
	][
		menu: [
			"File" [
				"New" 	new
				"Open" 	open
				"Save"	save
				"Save as .." save-as
				"Export as .." export
			]
			"View" ["Draw window" draw "Draw console" console]
			"Help" help
		]
		actors: object [
			save-file-as: does [
				win/extra: request-file/save
				save-file
				win/text: to-local-file last split-path win/extra
				show win
			]
			save-file: does [save win/extra append/only insert/only next [draw animations] canvas/draw animations/text]
			on-menu: func [face event /local loaded][
				switch event/picked [
					open [
						win/extra: request-file
						loaded: load win/extra
						canvas/draw: select loaded 'draw
						animations/text: select loaded 'animations
						win/text: to-local-file last split-path win/extra
						redraw
						figs/data: parse canvas/draw show-figs-rule
						figs/selected: 1
						select-figure
						show win;[canvas figs animations]
					]
					save [either win/extra [save-file][save-file-as]]
					save-as [save-file-as]
					draw [show-draw]
					console [show-console]
					export [save file: request-file/save/file/filter %export.png ["png" "*.png" "jpeg" "*.jpg" "gif" "*.gif"] draw canvas/size canvas/draw]
					help [
						view/flags [
text "See Readme:" field 300x24 "https://github.com/toomasv/drawing/blob/master/README.md" return
text 500x450 {Just few notes for current version: To draw simple figures click on canvas and drag. To draw "poly-" figures (polyline and polygon) click and drag first line, then release and click and drag again to add lines. For manipulations (inserts separate `translate`, `scale`, `skew` and `rotate`) and transformations (inserts single `transform`) click and drag:

* for rotation, click sets the rotation center, drag creates "lever" (preferably drag initially away from center in 0 direction, i.e to right) to rotate the figure
* for scaling, click sets the start of scaling, drag scales in relation to 0x0 coordinates (I will implement "local" scaling, i.e. in relation to coordinates set by click)
* for skewing, again, click sets start, drag skews in relation to 0x0 (intend to implement "local" skewing)
* for translation, click sets start, drag translates.

Holding down control-key while drawing, switches on `ortho` mode, resulting in orthogonal (vertical or horizontal) lines. (As an interesting effect, if you hold control-key down while starting new line *after drawing an orthogonal line* the new line is drawn from starting  point orthogonally to the last line. To avoid this, start line in normal mode and press `control` only after starting. I have not decided yet whether to consider this as a bug or as a feature.)

Sift-key controls the grid-mode. If "Grid" is not checked, holding down `shift` switches grid-mode temporarily on, if it is checked, `shift` switches it temporarily off. Grid steps can be changed on edit-options-panel. (In second field, grid for angles is set (arc degrees to step)).

Wheel-rotation zooms in and out. New figures are inserted correctly under cursor in zoomed views.

Pictures are inserted either from web (paste url into field) or from local file-system. First click after "OK" on file-selection window sets the top-left position for the picture, second click inserts picture - or - click and drag inserts picture to dragged dimensions. (Some bug, which I haven't succeeded to weed out, requires two mouse presses, instead of one. Working on this.)
} text 500x450 {
Wheel rotation above figures-list on right now moves the selected figure up or down in z-order.

Local formatting for figures can be now selected from contextual menu on figures-list. E.G. to change pen color, select `Format->Pen->Color` and then select color from left side pen-color-picker.

Draw-block can be seen/copied/edited by clicking "View->Draw window" (opens window with draw-block) or "View->Draw console" (makes VID code which may be pasted into console with `do [..]`) on main menu.

To play with animations, you have to:

* first insert transformation (not manipulation!) for the figure, i.e. select figure and from menu select transformation and then click on canvas to set it (take eg. Transform->Translate", click on canvas and drag jst a little bit, relase),
* then add animation descriptions to the "Animation" tab (print figure name, slash, 2, slash, number of <transformed attribute>, i.e number according to transformation syntax. 

Can also use this: 

```
set [r-center angle scale-x scale-y translate][2 3 4 5 6]
square1/2/:angle: tick
``` 

to change angle (i.e. nimate rotation); `tick` is preset reserved word counting time ticks,
* click "Animate" button on "Drawing" tab
}
							button "OK" [unview]
						][modal popup]
					]
				]
			]
			on-resizing: func [face event][
				tab-pan/size: win/size - 17
				foreach tab tab-pan/pane [
					tab/size: tab/parent/size; - 10;23x45
				]
				drawing-panel-tab/offset: 0x0
				drawing-panel-tab/size: drawing-panel-tab/parent/size - 4x20
				info-panel/size/y: info-panel/parent/size/y - info-panel/offset/y - 10
				options-panel/size/y: options-panel/parent/size/y - options-panel/offset/y - 10
				drawing-panel/size: 			;edit-panel/size: 
					drawing-panel/parent/size - drawing-panel/offset - 120x50
				foreach-face drawing-panel [face/size: drawing-panel/size]
				canvas/size: drawing-panel/size ; grid-layer/size: selection-layer/size: edit-layer/size: 
				poke grid-layer/draw length? grid-layer/draw canvas/size
				figs-panel/offset/x: figs-panel/parent/size/x - 110
				figs-panel/size/y: figs-panel/parent/size/y - figs-panel/offset/y - 15
				figs1/size/y: figs-panel/size/y
				anim-panel/offset/x: anim-panel/parent/offset/x + 100
				anim-panel/offset/y: anim-panel/parent/size/y - 38
				anim-panel/size/x: drawing-panel/size/x
				animations/offset: 0x0
				animations/size: animations/parent/size - 5x25
				show win 
			]
		]
	]
	win-view: view/flags win [resize] ; /no-wait
]
