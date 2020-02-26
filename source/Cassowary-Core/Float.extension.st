Extension { #name : #Float }

{ #category : #'*Cassowary-Core' }
Float >> approxNonNegative [
	^self > (0.0 - ClSimplexSolver epsilon)
]

{ #category : #'*Cassowary-Core' }
Float >> clApprox: x [
	"ACTION
		Test whether I am approximately equal to the argument.

	PARAMETERS
		x <Float>

	RETURNS
		<Boolean>
	"

	| epsilon |

	epsilon := ClSimplexSolver epsilon.
	self = 0.0 ifTrue: [^x abs < epsilon].
	x = 0.0 ifTrue: [^self abs < epsilon].
	^(self - x) abs < (self abs * epsilon)
]

{ #category : #'*Cassowary-Core' }
Float >> clApproxZero [
	"ACTION
		Test whether I am approximately zero.

	RETURNS
		<Boolean>
	"

	^self clApprox: 0.0
]
