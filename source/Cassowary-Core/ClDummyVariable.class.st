Class {
	#name : #ClDummyVariable,
	#superclass : #ClAbstractVariable,
	#category : #'Cassowary-Core'
}

{ #category : #testing }
ClDummyVariable >> isDummy [
	"ACTION
		Return true if this a dummy variable (used as a marker variable for required equality constraints).  Such 
		variables aren't allowed to enter the basis when pivoting.

	RETURNS
		<Boolean>
	"

	^true
]

{ #category : #testing }
ClDummyVariable >> isExternal [
	"ACTION
		Return true if this a variable known outside the solver.  (We need to give such variables a value after solving
		is complete.)

	RETURNS
		<Boolean>
	"

	^false
]

{ #category : #testing }
ClDummyVariable >> isPivotable [
	"ACTION
		Return true if we can pivot on this variable.

	RETURNS
		<Boolean>
	"

	^false
]

{ #category : #testing }
ClDummyVariable >> isRestricted [
	"ACTION
		Return true if this is a restricted (or slack) variable.  Such variables are constrained to be 
		non-negative and occur only internally to the simplex solver.

	RETURNS
		<Boolean>
	"

	^true
]
