Class {
	#name : #ClNotEnoughStays,
	#superclass : #ClError,
	#category : #'Cassowary-Core-Exceptions'
}

{ #category : #initialization }
ClNotEnoughStays >> messageText [
	^ '(ExCLNotEnoughStays) There are not enough stays to give specific values to every variable'
]
