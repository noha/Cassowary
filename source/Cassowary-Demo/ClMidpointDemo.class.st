Class {
	#name : #ClMidpointDemo,
	#superclass : #ClDemoWindow,
	#instVars : [
		'p1',
		'p2',
		'm1'
	],
	#category : #'Cassowary-Demo'
}

{ #category : #'as yet unclassified' }
ClMidpointDemo >> constraintPointsDo: aBlock [

	aBlock value: p1.
	aBlock value: p2.
	aBlock value: m1.
]

{ #category : #'as yet unclassified' }
ClMidpointDemo >> drawArea [

	self setForegroundColor: 0.

	buffer
		drawLine: gc
		x1: p1 x value rounded
		y1: p1 y value rounded
		x2: p2 x value rounded
		y2: p2 y value rounded.
	buffer
		drawLine: gc
		x1: m1 x value rounded
		y1: m1 y value rounded -1
		x2: m1 x value rounded
		y2: m1 y value rounded +1.
]

{ #category : #'as yet unclassified' }
ClMidpointDemo >> initialize [

	super initialize.
	p1 := (ClVariable newWith: 100.0) @ (ClVariable newWith: 100.0).
	p2 := (ClVariable newWith: 200.0) @ (ClVariable newWith: 100.0).
	m1 := (ClVariable newWith: 150.0) @ (ClVariable newWith: 100.0).

	p1 x name: 'p1x'.
	p1 y name: 'p1y'.
	p2 x name: 'p2x'.
	p2 y name: 'p2y'.
	m1 x name: 'm1x'.
	m1 y name: 'm1y'.

	"add stays on the corner points"
	cs addPointStays: (Array with: p1 with: p2).

	"set up the midpoint constraints"
	cs addConstraint: (p1 x + p2 x cnEqual: 2.0 * m1 x).
	cs addConstraint: (p1 y + p2 y cnEqual: 2.0 * m1 y).
]

{ #category : #'as yet unclassified' }
ClMidpointDemo >> title [

	^'Midpoint Demo'
]
