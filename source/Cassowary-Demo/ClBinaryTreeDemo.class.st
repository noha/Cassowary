Class {
	#name : #ClBinaryTreeDemo,
	#superclass : #ClDemoWindow,
	#instVars : [
		'nodes',
		'lines',
		'height'
	],
	#category : #'Cassowary-Demo'
}

{ #category : #'accessing structure variables' }
ClBinaryTreeDemo class >> height: h [
		| demo |
	demo := self basicNew.
	demo height: h.
	demo initialize.
	^demo
]

{ #category : #enumerating }
ClBinaryTreeDemo >> childrenAndParentsDo: block [
	"evaluate a block for all children and parents, starting with leaves and going up the tree"
		| parentcount left right parent |
	height to: 2 by: -1 do: [:h |
		parentcount := 2 raisedTo: h-2.
		1 to: parentcount do: [:i | 
			left := nodes at: (100*h)+(2*i)-1.
			right := nodes at: (100*h)+(2*i).
			parent := nodes at: (100*(h-1))+i.
			block value: left value: right value: parent]]
]

{ #category : #enumerating }
ClBinaryTreeDemo >> constraintPointsDo: aBlock [

	nodes do: [:each | aBlock value: each]
]

{ #category : #enumerating }
ClBinaryTreeDemo >> createConstraints [
		| sorted inset spacing winWidth winHeight root |

	"Add stays on each node.  Accumulate the nodes children first, so that the weights
		on the parents are stronger than those on the children."
	sorted := OrderedCollection new.
	self childrenAndParentsDo: [:lc :rc :p |
		(sorted includes: lc) ifFalse: [sorted add: lc].
		(sorted includes: rc) ifFalse: [sorted add: lc].
		root := p  "we need this at the end"].
	sorted add: root.
	cs addPointStays: sorted.

	inset := self inset.
	spacing := self spacing.
	winWidth := self initialExtent x.
	winHeight := self initialExtent y.
	self childrenAndParentsDo: [:lc :rc :p |
		"we need the root at the end"   root := p.
		"children are at equal height"
		cs addConstraint: (lc y cnEqual: rc y).
		"children are below parents"
		cs addConstraint: (p y + spacing cnLEQ: lc y).
		cs addConstraint: (p y + spacing cnLEQ: rc y).
		"parent is centered in the x coordinate between children"
		cs addConstraint: ( (0.5*lc x) + (0.5*rc x) cnEqual: p x).
		"each node lies within the window"
		cs addBounds: lc x lowerBound: inset upperBound: winWidth-inset.
		cs addBounds: rc x lowerBound: inset upperBound: winWidth-inset.
		cs addBounds: lc y lowerBound: inset upperBound: winHeight-inset.
		cs addBounds: rc y lowerBound: inset upperBound: winHeight-inset].
	cs addBounds: root x lowerBound: inset upperBound: winWidth-inset.
	cs addBounds: root y lowerBound: inset upperBound: winHeight-inset.
]

{ #category : #enumerating }
ClBinaryTreeDemo >> drawArea [

	self setForegroundColor: 0.
	lines do: [:each |
		buffer
			drawLine: gc
			x1: each first x value rounded
			y1: each first y value rounded
			x2: each last x value rounded
			y2: each last y value rounded].
	self setForegroundColor: 5.
	nodes do: [:each |
		buffer
			fillRectangle: gc
			x: (each x value rounded - 5)
			y: (each y value rounded - 5)
			width: 10
			height: 10]
]

{ #category : #enumerating }
ClBinaryTreeDemo >> height: h [
	height := h
]

{ #category : #enumerating }
ClBinaryTreeDemo >> initialExtent [
	"ACTION
		Return the initial size for the overall window.
	"

	^500 @ 300
]

{ #category : #enumerating }
ClBinaryTreeDemo >> initialize [
		| xspace yspace index nleaves nodecount left right px |
	xspace :=20.  
	yspace := 20.

	super initialize.
	nodes := LookupTable new.
	
	"create the leaves"
	nleaves := 2 raisedTo: height-1.
	1 to: nleaves do: [:i | index := 100*height + i.  nodes at: index put: 
			((ClVariable newWith: (xspace*i) asFloat name: 'n' , index printString , 'x') @ 
			  (ClVariable newWith: (yspace*height) asFloat name: 'n' , index printString , 'y'))].

	"create the other nodes"
	height-1 to: 1 by: -1 do: [:h |
		nodecount := 2 raisedTo: h-1.
		1 to: nodecount do: [:i | 
			left := nodes at: (100*(h+1))+(2*i)-1.  
			right := nodes at: (100*(h+1))+(2*i).
			px := (left x value + right x value) * 0.5.
			index := 100*h+ i.  nodes at: index put: 
			((ClVariable newWith: px name: 'n' , index printString , 'x') @ 
			  (ClVariable newWith: yspace*h name: 'n' , index printString , 'y'))]].

	lines := OrderedCollection new.
	self childrenAndParentsDo: [:lc :rc :p | 
		lines add: (Array with: p with: lc).
		lines add: (Array with: p with: rc)].

	self createConstraints
]

{ #category : #enumerating }
ClBinaryTreeDemo >> inset [
	^10.0
]

{ #category : #enumerating }
ClBinaryTreeDemo >> spacing [
	^10.0
]

{ #category : #enumerating }
ClBinaryTreeDemo >> title [

	^'Binary Tree Demo'
]
