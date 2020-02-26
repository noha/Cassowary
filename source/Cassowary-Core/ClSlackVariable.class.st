Class {
	#name : #ClSlackVariable,
	#superclass : #ClAbstractVariable,
	#category : #'Cassowary-Core'
}

{ #category : #testing }
ClSlackVariable >> isExternal [
	"ACTION
		Return true if this a variable known outside the solver.  (We need to give such variables a value after solving
		is complete.)

	RETURNS
		<Boolean>
	"

	^false
]

{ #category : #testing }
ClSlackVariable >> isPivotable [
	"ACTION
		Return true if we can pivot on this variable.

	RETURNS
		<Boolean>
	"

	^true
]

{ #category : #testing }
ClSlackVariable >> isRestricted [
	"ACTION
		Return true if this is a restricted (or slack) variable.  Such variables are constrained to be 
		non-negative and occur only internally to the simplex solver.

	RETURNS
		<Boolean>
	"

	^true
]
