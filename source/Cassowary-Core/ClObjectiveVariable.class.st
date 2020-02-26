Class {
	#name : #ClObjectiveVariable,
	#superclass : #ClAbstractVariable,
	#category : #'Cassowary-Core'
}

{ #category : #testing }
ClObjectiveVariable >> isExternal [
	"ACTION
		Return true if this a variable known outside the solver.  (We need to give such variables a value after solving
		is complete.)

	RETURNS
		<Boolean>
	"

	^false
]

{ #category : #testing }
ClObjectiveVariable >> isPivotable [
	"ACTION
		Return true if we can pivot on this variable.

	RETURNS
		<Boolean>
	"

	^false
]

{ #category : #testing }
ClObjectiveVariable >> isRestricted [
	"ACTION
		Return true if this is a restricted (or slack) variable.  Such variables are constrained to be 
		non-negative and occur only internally to the simplex solver.

	RETURNS
		<Boolean>
	"

	^false
]
