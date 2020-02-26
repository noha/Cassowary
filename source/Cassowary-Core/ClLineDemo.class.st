Class {
	#name : #ClLineDemo,
	#superclass : #ClDemoWindow,
	#instVars : [
		'p1',
		'p2'
	],
	#category : #'Cassowary-Core'
}

{ #category : #'as yet unclassified' }
ClLineDemo >> constraintPointsDo: aBlock [

	aBlock value: p1.
	aBlock value: p2
]

{ #category : #'as yet unclassified' }
ClLineDemo >> drawArea [

	self setForegroundColor: 0.
	buffer
		drawLine: gc
		x1: p1 x value rounded
		y1: p1 y value rounded
		x2: p2 x value rounded
		y2: p2 y value 
]

{ #category : #'as yet unclassified' }
ClLineDemo >> initialize [

	super initialize.
	p1 := (ClVariable newWith: 10.0 name: 'p1x') @ (ClVariable newWith: 20.0 name: 'p1y').
	p2 := (ClVariable newWith: 110.0 name: 'p2x') @ (ClVariable newWith: 220.0 name: 'p2y').
	cs addStay: p1 x.
	cs addStay: p1 y.
	cs addStay: p2 x.
	cs addStay: p2 y.
]

{ #category : #'as yet unclassified' }
ClLineDemo >> title [

	^'Line Demo'
]
