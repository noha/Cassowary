Class {
	#name : #ClKernel,
	#superclass : #Object,
	#category : #'Cassowary-Core'
}

{ #category : #'as yet unclassified' }
ClKernel class >> epsilon [
	"ACTION
		Set the shared fudge factor for use in testing floats for equality, symbolic weights for
		non-negativity, etc.  This could be changed if an application uses numbers with a very
		different scale.
	"
	^ 1.0e-8.

]
