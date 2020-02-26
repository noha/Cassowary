Class {
	#name : #ClLinearInequality,
	#superclass : #ClLinearConstraint,
	#category : #'Cassowary-Core'
}

{ #category : #accessing }
ClLinearInequality >> isInequality [
	"ACTION
		Return true if this is an inequality constraint and false if it is an equality constraint.
	RETURNS
		<Boolean>
	"
	^true
]

{ #category : #printing }
ClLinearInequality >> printOn: strm [
	self strength printOn: strm.
	strm nextPutAll: '('.
	expression printOn: strm.
	strm nextPutAll: '>=0)'.
]
