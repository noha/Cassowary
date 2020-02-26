Class {
	#name : #ClAbstractVariable,
	#superclass : #Object,
	#instVars : [
		'name'
	],
	#category : #'Cassowary-Core'
}

{ #category : #'instance creation' }
ClAbstractVariable class >> newNamed: n [
	"ACTION
		Create a new variable named n.

	PARAMETERS
		n <String>

	RETURNS
		new
	"

	^self new
		name: n;
		yourself
]

{ #category : #testing }
ClAbstractVariable >> isDummy [
	"ACTION
		Return true if this a dummy variable (used as a marker variable for required equality constraints).  Such 
		variables aren't allowed to enter the basis when pivoting.

	RETURNS
		<Boolean>
	"

	^false
]

{ #category : #testing }
ClAbstractVariable >> isExternal [
	"ACTION
		Return true if this a variable known outside the solver.  (We need to give such variables a value after solving
		is complete.)

	RETURNS
		<Boolean>
	"

	self subclassResponsibility
]

{ #category : #testing }
ClAbstractVariable >> isPivotable [
	"ACTION
		Return true if we can pivot on this variable.

	RETURNS
		<Boolean>
	"

	self subclassResponsibility
]

{ #category : #testing }
ClAbstractVariable >> isRestricted [
	"ACTION
		Return true if this is a restricted (or slack) variable.  Such variables are constrained to be 
		non-negative and occur only internally to the simplex solver.

	RETURNS
		<Boolean>
	"

	self subclassResponsibility
]

{ #category : #testing }
ClAbstractVariable >> name [
	"RETURNS
		<String> | nil
	"
	^name
]

{ #category : #testing }
ClAbstractVariable >> name: n [
	"PARAMETERS
		n <String>
	"
	name := n
]

{ #category : #testing }
ClAbstractVariable >> printOn: aStream [
	"ACTION
		Prints a semi-descriptive representation to the stream, using the
		name if there is one, and otherwise the hash number of this object.

	EXAMPLES
		x[10.0]					- - w/ name
		x[0.0,100]			-- w/ name, bounds but no value yet
		CV#345(10.0)		- - w/o name

	PARAMETERS
		aStream <WriteStream on <String>>
	"

	self name isNil
		ifTrue: [aStream nextPutAll: 'CV#' , self basicHash printString]
		ifFalse: [aStream nextPutAll: self name].
]
