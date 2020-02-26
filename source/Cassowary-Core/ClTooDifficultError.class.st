Class {
	#name : #ClTooDifficultError,
	#superclass : #ClError,
	#category : #'Cassowary-Core-Exceptions'
}

{ #category : #initialization }
ClTooDifficultError >> messageText [
	^ '(ExCLTooDifficult) The constraints are too difficult to solve'
]
