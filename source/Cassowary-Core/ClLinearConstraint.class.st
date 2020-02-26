Class {
	#name : #ClLinearConstraint,
	#superclass : #ClConstraint,
	#instVars : [
		'expression'
	],
	#category : #'Cassowary-Core'
}

{ #category : #accessing }
ClLinearConstraint >> expression [
	"ACTION
		Return my linear expression.  (For linear equations, this constraint represents
		expression=0; for linear inequalities it represents expression>=0.)
	RETURNS
		<ClLinearExpression>
	"
	^expression
]

{ #category : #accessing }
ClLinearConstraint >> expression: expr [
	expression := expr
]
