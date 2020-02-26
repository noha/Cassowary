Class {
	#name : #ClElasticBoundedLineDemo,
	#superclass : #ClBoundedLineDemo,
	#category : #'Cassowary-Demo'
}

{ #category : #enumerating }
ClElasticBoundedLineDemo >> initialize [

	super initialize.
	cs addConstraint: (p2 y - p1 y cnEqual: 200.0 strength: ClStrength medium).
]
