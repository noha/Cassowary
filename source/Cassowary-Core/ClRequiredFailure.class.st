Class {
	#name : #ClRequiredFailure,
	#superclass : #ClError,
	#category : #'Cassowary-Core-Exceptions'
}

{ #category : #initialization }
ClRequiredFailure >> messageText [
	^ '(ExCLRequiredFailure) A required constraint cannot be satisfied'
]
