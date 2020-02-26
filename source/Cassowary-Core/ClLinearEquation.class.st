Class {
	#name : #ClLinearEquation,
	#superclass : #ClLinearConstraint,
	#category : #'Cassowary-Core'
}

{ #category : #printing }
ClLinearEquation >> printOn: strm [
	self strength printOn: strm.
	strm nextPutAll: '('.
	expression printOn: strm.
	strm nextPutAll: '=0)'.
]
