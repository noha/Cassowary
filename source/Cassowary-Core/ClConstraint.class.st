Class {
	#name : #ClConstraint,
	#superclass : #Object,
	#instVars : [
		'strength',
		'weight'
	],
	#pools : [
		'ClConstants'
	],
	#category : #'Cassowary-Core'
}

{ #category : #accessing }
ClConstraint >> expression [
	"ACTION
		Return my linear expression.  (For linear equations, this constraint represents
		expression=0; for linear inequalities it represents expression>=0.)
	RETURNS
		<ClLinearExpression>
	"
	self subclassResponsibility
]

{ #category : #accessing }
ClConstraint >> isEditConstraint [
	"RETURNS
		<Boolean>
	"
	^false
]

{ #category : #accessing }
ClConstraint >> isInequality [
	"ACTION
		Return true if this is an inequality constraint and false if it is an equality constraint.  The default is that it is not.
	RETURNS
		<Boolean>
	"
	^false
]

{ #category : #accessing }
ClConstraint >> isRequired [
	"ACTION
		Return true if my strength is 'required'.

	RETURNS
		<Boolean>
	"

	^self strength isRequired
]

{ #category : #accessing }
ClConstraint >> isStayConstraint [
	"RETURNS
		<Boolean>
	"
	^false
]

{ #category : #accessing }
ClConstraint >> strength [
	"RETURNS
		<ClStrength>
	"

	^strength
]

{ #category : #accessing }
ClConstraint >> strength: s [
	"PARAMETERS
		s <ClStrength>
	"

	strength := s
]

{ #category : #accessing }
ClConstraint >> weight [
	"RETURNS
		<Float>
	"

	^weight
]

{ #category : #accessing }
ClConstraint >> weight: w [
	"PARAMETERS
		w <Float>
	"

	weight := w
]
