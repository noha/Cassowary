Class {
	#name : #ClNonLinearExpression,
	#superclass : #ClError,
	#category : #'Cassowary-Core-Exceptions'
}

{ #category : #initialization }
ClNonLinearExpression >> messageText [
	^ '(ExCLNonlinearExpression) The resulting expression would be nonlinear'
]
