Class {
	#name : #ClKernel,
	#superclass : #Object,
	#pools : [
		'ClConstants'
	],
	#category : #'Cassowary-Core'
}

{ #category : #'class initialization' }
ClKernel class >> initialize [ 
	self loaded
]

{ #category : #initialization }
ClKernel class >> initializeExceptions [
	"ACTION
		Note that a variable must be declared for each exception to reside
		in.  The variables are declared in the toBeLoadedCode.
	"

	ExCLError isNil
		ifTrue: [
			ExCLError :=
				(ExError newChild)
					description: '(ExCLError) An error has occured in CL';
					yourself].
	ExCLInternalError isNil
		ifTrue: [ 
			ExCLInternalError :=
				(ExCLError newChild)
					description: '(ExCLInternalError) An internal error has occurred';
					yourself].
	ExCLTooDifficult isNil
		ifTrue: [
			ExCLTooDifficult :=
				(ExCLError newChild)
					description: '(ExCLTooDifficult) The constraints are too difficult to solve';
					yourself].
	ExCLRequiredFailure isNil
		ifTrue: [
			ExCLRequiredFailure :=
				(ExCLError newChild)
					description: '(ExCLRequiredFailure) A required constraint cannot be satisfied';
					yourself].
	ExCLNotEnoughStays isNil
		ifTrue: [
			ExCLNotEnoughStays :=
				(ExCLError newChild)
					description: '(ExCLNotEnoughStays) There are not enough stays to give specific values to every variable';
					yourself].
	ExCLNonlinearExpression isNil
		ifTrue: [
			ExCLNonlinearExpression :=
				(ExCLError newChild)
					description: '(ExCLNonlinearExpression) The resulting expression would be nonlinear';
					yourself].
]

{ #category : #'as yet unclassified' }
ClKernel class >> loaded [
	"ACTION
		Set up the exceptions.
	"
	"super loaded."
	"self initializeExceptions."
	self setEpsilon.
]

{ #category : #'as yet unclassified' }
ClKernel class >> setEpsilon [
	"ACTION
		Set the shared fudge factor for use in testing floats for equality, symbolic weights for
		non-negativity, etc.  This could be changed if an application uses numbers with a very
		different scale.
	"
	ClEpsilon := 1.0e-8.

]
