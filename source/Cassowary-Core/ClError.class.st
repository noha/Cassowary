Class {
	#name : #ClError,
	#superclass : #Error,
	#category : #'Cassowary-Core-Exceptions'
}

{ #category : #initialization }
ClError >> messageText [
	^ '(ExCLError) An error has occured in CL'
]
