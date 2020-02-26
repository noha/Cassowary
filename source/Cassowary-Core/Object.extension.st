Extension { #name : #Object }

{ #category : #'*Cassowary-Core' }
Object >> clApprox: x [
	"ACTION
		Test whether I am approximately equal to the argument.

	PARAMETERS
		x <Object>

	RETURNS
		<Boolean>

	NOTES
		The default is just an equality test."

	^self = x
]

{ #category : #'*Cassowary-Core' }
Object >> isSymbolicWeight [
	^false
]
