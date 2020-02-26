Class {
	#name : #ClVariable,
	#superclass : #ClAbstractVariable,
	#instVars : [
		'value'
	],
	#classVars : [
		'ExCLNonlinearExpression'
	],
	#category : #'Cassowary-Core'
}

{ #category : #'as yet unclassified' }
ClVariable class >> newWith: val [
	"ACTION
		Create a new variable with val as its initial value.

	PARAMETERS
		val <Object>

	RETURNS
		new
	"

	^self new
		value: val;
		yourself
]

{ #category : #'instance creation' }
ClVariable class >> newWith: val name: n [
	"ACTION
		Create a new variable with val as its initial value and name n.

	PARAMETERS
		val <Object>
		n <String>

	RETURNS
		new
	"

	^self new
		value: val;
		name: n;
		yourself
]

{ #category : #arithmetic }
ClVariable >> * expr [
	^self asLinearExpression * expr
]

{ #category : #arithmetic }
ClVariable >> + expr [
	^self asLinearExpression + expr
]

{ #category : #arithmetic }
ClVariable >> - expr [
	^self asLinearExpression - expr
]

{ #category : #arithmetic }
ClVariable >> / expr [
	^self asLinearExpression / expr
]

{ #category : #arithmetic }
ClVariable >> @ obj [
	"ACTION
		A convenience method for creating point pairs of
		constrainable variables.  Mostly used in graphic
		constraints where the x and y dimensions are
		constrained separately.

	PARAMETERS
		obj <Object>

	RETURNS
		<Point of <self> obj>
	"

	^Point x: self y: obj
]

{ #category : #arithmetic }
ClVariable >> asLinearExpression [
	"ACTION
		Coerce this variable to be a linear expression.

	RETURNS
		<ClLinearExpression>
	"
		| expr |
	expr := ClLinearExpression new.
	expr terms at: self put: 1.0.
	^expr
]

{ #category : #arithmetic }
ClVariable >> cnEqual: expr [
	"ACTION
		Return a linear constraint self=expr with strength=required and weight=1.

	PARAMETERS
		expr <ClLinearExpression | ClVariable | Number>

	RETURNS
		<ClLinearEquation>
	"
	^self cnEqual: expr strength: ClStrength required weight: 1.0
]

{ #category : #arithmetic }
ClVariable >> cnEqual: expr strength: s [
	"ACTION
		Return a linear constraint self=expr of strength s and weight=1.

	PARAMETERS
		expr <ClLinearExpression | ClVariable | Number>
		s <ClStrength>

	RETURNS
		<ClLinearEquation>
	"

	^self cnEqual: expr strength: s weight: 1.0
]

{ #category : #arithmetic }
ClVariable >> cnEqual: expr strength: s weight: w [
	"ACTION
		Return a linear constraint self=expr of strength s and weight w.

	PARAMETERS
		expr <ClLinearExpression | ClVariable | Number>
		st <ClStrength>
		w <Float>

	RETURNS
		<ClLinearEquation>
	"
		| cn |
	cn := ClLinearEquation new.
	cn expression: self-expr; strength: s; weight: w.
	^cn
]

{ #category : #arithmetic }
ClVariable >> cnGEQ: expr [
	"ACTION
		Return a linear constraint self>=expr with strength=required and weight=1.

	PARAMETERS
		expr <ClLinearExpression | ClVariable | Number>

	RETURNS
		<ClLinearInequality>
	"
	^self cnGEQ: expr strength: ClStrength required weight: 1.0
]

{ #category : #arithmetic }
ClVariable >> cnGEQ: expr strength: s [
	"ACTION
		Return a linear constraint self>=expr of strength s and weight=1.

	PARAMETERS
		expr <ClLinearExpression | ClVariable | Number>
		s <ClStrength>

	RETURNS
		<ClLinearInequality>
	"
	^self cnGEQ: expr strength: s weight: 1.0
]

{ #category : #arithmetic }
ClVariable >> cnGEQ: expr strength: s weight: w [
	"ACTION
		Return a linear constraint self>=expr of strength s and weight w.

	PARAMETERS
		expr <ClLinearExpression | ClVariable | Number>
		st <ClStrength>
		w <Float>

	RETURNS
		<ClLinearEquation>
	"
		| cn |
	cn := ClLinearInequality new.
	cn expression: self-expr; strength: s; weight: w.
	^cn
]

{ #category : #arithmetic }
ClVariable >> cnLEQ: expr [
	"ACTION
		Return a linear constraint self<=expr with strength=required and weight=1.

	PARAMETERS
		expr <ClLinearExpression | ClVariable | Number>

	RETURNS
		<ClLinearInequality>
	"
	^self cnLEQ: expr strength: ClStrength required weight: 1.0
]

{ #category : #arithmetic }
ClVariable >> cnLEQ: expr strength: s [
	"ACTION
		Return a linear constraint self<=expr of strength s and weight 1.

	PARAMETERS
		expr <ClLinearExpression | ClVariable | Number>
		s <ClStrength>

	RETURNS
		<ClLinearInequality>
	"
	^self cnLEQ: expr strength: s weight: 1.0
]

{ #category : #arithmetic }
ClVariable >> cnLEQ: expr strength: s weight: w [
	"ACTION
		Return a linear constraint self<=expr of strength s and weight w.

	PARAMETERS
		expr <ClLinearExpression | ClVariable | Number>
		st <ClStrength>
		w <Float>

	RETURNS
		<ClLinearEquation>
	"
		| cn |
	cn := ClLinearInequality new.
	cn expression: expr-self; strength: s; weight: w.
	^cn
]

{ #category : #arithmetic }
ClVariable >> divFrom: aNumber [
	"ACTION
		We should return a new linear expression (aNumber/self) -- but since the result must be linear, 
		this is always an error.

	RETURNS
		<ClLinearExpression>
	"
	ExCLNonlinearExpression signal
]

{ #category : #arithmetic }
ClVariable >> isExternal [
	"ACTION
		Return true if this a variable known outside the solver.  (We need to give such variables a value after solving
		is complete.)

	RETURNS
		<Boolean>
	"

	^true
]

{ #category : #arithmetic }
ClVariable >> isPivotable [
	"ACTION
		Return true if we can pivot on this variable.

	RETURNS
		<Boolean>
	"

	^false
]

{ #category : #arithmetic }
ClVariable >> isRestricted [
	"ACTION
		Return true if this is a restricted (or slack) variable.  Such variables are constrained to be 
		non-negative and occur only internally to the simplex solver.

	RETURNS
		<Boolean>
	"

	^false
]

{ #category : #arithmetic }
ClVariable >> printOn: aStream [
	"ACTION
		See superclass method.
	PARAMETERS
		aStream <WriteStream on <String>>
	"

	super printOn: aStream.
	aStream nextPutAll: '['.  self value printOn: aStream.  aStream nextPutAll: ']'
]

{ #category : #arithmetic }
ClVariable >> subtractFrom: aNumber [
	"ACTION
		Return a new linear expression (aNumber-self).

	RETURNS
		<ClLinearExpression>
	"
	^ -1.0*self + aNumber
]

{ #category : #arithmetic }
ClVariable >> value [
	"ACTION
		Return the current value I hold.

	RETURNS
		<Number>
	"

	^value
]

{ #category : #arithmetic }
ClVariable >> value: v [
	"ACTION
		Set my value.

	PARAMETERS
		v <Number>
	"

	value := v
]
