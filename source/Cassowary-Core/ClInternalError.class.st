Class {
	#name : #ClInternalError,
	#superclass : #ClError,
	#category : #'Cassowary-Core-Exceptions'
}

{ #category : #initialization }
ClInternalError >> messageText [
	^ '(ExCLInternalError) An internal error has occurred'
]
