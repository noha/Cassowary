Class {
	#name : #ClElasticQuadDemo,
	#superclass : #ClBoundedQuadDemo,
	#category : #'Cassowary-Demo'
}

{ #category : #adding }
ClElasticQuadDemo >> addAdditionalConstraints [

	super addAdditionalConstraints.
	"add constraints to keep it from turning inside out"
	cs addConstraint: (p4 x+10 cnLEQ: p3 x).
	cs addConstraint: (p4 x+10 cnLEQ: p1 x).
	cs addConstraint: (p3 x+10 cnLEQ: p2 x).
	cs addConstraint: (p1 x+10 cnLEQ: p2 x).

	cs addConstraint: (p1 y+10 cnLEQ: p2 y).
	cs addConstraint: (p1 y+10 cnLEQ: p4 y).
	cs addConstraint: (p4 y+10 cnLEQ: p3 y).
	cs addConstraint: (p2 y+10 cnLEQ: p3 y).

	"add medium constraints to keep the quadrilateral's original shape"
	cs addConstraint: (p2 y cnEqual: p4 y strength: ClStrength medium).
	cs addConstraint: (p2 x - p4 x cnEqual: 200.0 strength: ClStrength medium).
	cs addConstraint: (p1 x cnEqual: p3 x strength: ClStrength medium).
	cs addConstraint: (p3 y - p1 y cnEqual: 200.0 strength: ClStrength medium).
]

{ #category : #accessing }
ClElasticQuadDemo >> title [

	^'Elastic Quadrilateral Demo'
]
