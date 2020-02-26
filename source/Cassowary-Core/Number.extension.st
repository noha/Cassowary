Extension { #name : #Number }

{ #category : #'*Cassowary-Core' }
Number >> asLinearExpression [
	"ACTION
		Coerce this number to a linear expression.

	RETURNS
		<ClLinearExpression>
	"
		| expr |
	expr := ClLinearExpression new.
	expr constant: self asFloat.
	^expr
]

{ #category : #'*Cassowary-Core' }
Number >> cnEqual: expr [
	"ACTION
		Return a linear constraint self=expr with strength=required and weight=1.

	PARAMETERS
		expr <ClLinearExpression | ClVariable | Number>

	RETURNS
		<ClLinearEquation>
	"
	^self cnEqual: expr strength: ClStrength required weight: 1.0
]

{ #category : #'*Cassowary-Core' }
Number >> cnEqual: expr strength: s [
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

{ #category : #'*Cassowary-Core' }
Number >> cnEqual: expr strength: s weight: w [
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

{ #category : #'*Cassowary-Core' }
Number >> cnGEQ: expr [
	"ACTION
		Return a linear constraint self>=expr with strength=required and weight=1.

	PARAMETERS
		expr <ClLinearExpression | ClVariable | Number>

	RETURNS
		<ClLinearInequality>
	"
	^self cnGEQ: expr strength: ClStrength required weight: 1.0
]

{ #category : #'*Cassowary-Core' }
Number >> cnGEQ: expr strength: s [
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

{ #category : #'*Cassowary-Core' }
Number >> cnGEQ: expr strength: s weight: w [
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

{ #category : #'*Cassowary-Core' }
Number >> cnLEQ: expr [
	"ACTION
		Return a linear constraint self<=expr with strength=required and weight=1.

	PARAMETERS
		expr <ClLinearExpression | ClVariable | Number>

	RETURNS
		<ClLinearInequality>
	"
	^self cnLEQ: expr strength: ClStrength required weight: 1.0
]

{ #category : #'*Cassowary-Core' }
Number >> cnLEQ: expr strength: s [
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
