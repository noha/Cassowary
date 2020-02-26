Class {
	#name : #ClLinearExpression,
	#superclass : #Object,
	#instVars : [
		'constant',
		'terms'
	],
	#category : #'Cassowary-Core'
}

{ #category : #'instance creation' }
ClLinearExpression class >> new [

	^super new
		initialize;
		yourself
]

{ #category : #'instance creation' }
ClLinearExpression class >> newWithSymbolicWeight [
		| x |
	x := self new.
	x constant: ClSymbolicWeight zero.
	^x
]

{ #category : #arithmetic }
ClLinearExpression >> * x [
	"ACTION
		Return a new linear expression formed by multiplying self by x.  (Note that this result must be linear.)

	RETURNS
		<ClLinearExpression>
	"
		| expr n result |
	"if this expression is just a constant then we can just multiply by it"
	self isConstant ifTrue: [^x*self constant].
	"otherwise multiply by x"
	x isNumber ifTrue: [n := x asFloat]
		ifFalse: [expr := x asLinearExpression.
			x isConstant ifFalse: [ ClNonLinearExpression signal  "result would be non-linear"].
			n := x constant].
	result := ClLinearExpression new.
	result constant: n*self constant.
	self terms keysAndValuesDo: [:v :c | result terms at: v put: n*c].
	^result
]

{ #category : #arithmetic }
ClLinearExpression >> + x [
	"ACTION
		Return a new linear expression formed by adding x to self.

	RETURNS
		<ClLinearExpression>
	"
		| expr result |
	expr := x asLinearExpression.
	"make a new linear expression to hold the result"
	result := ClLinearExpression new.
	result constant: self constant + expr constant.
	self terms keysAndValuesDo: [:v :c | result terms at: v put: c].
	expr variablesAndCoefficientsDo: [:v :c | result addVariable: v coefficient: c].
	^result
]

{ #category : #arithmetic }
ClLinearExpression >> - x [
	"ACTION
		Return a new linear expression formed by subtracting x from self.

	RETURNS
		<ClLinearExpression>
	"
		| expr result |
	expr := x asLinearExpression.
	"make a new linear expression to hold the result"
	result := ClLinearExpression new.
	result constant: self constant - expr constant.
	self terms keysAndValuesDo: [:v :c | result terms at: v put: c].
	expr variablesAndCoefficientsDo: [:v :c | result addVariable: v coefficient: 0.0-c].
	^result
]

{ #category : #arithmetic }
ClLinearExpression >> / x [
	"ACTION
		Return a new linear expression formed by dividing self by x.  (Note that this result must be linear.)

	RETURNS
		<ClLinearExpression>
	"
		| expr |
	expr := x asLinearExpression.
	expr isConstant ifFalse: [ ClNonLinearExpression signal  "result would be non-linear"].
	^self * (1.0/expr constant)
]

{ #category : #arithmetic }
ClLinearExpression >> addExpression: expr times: n [
	"ACTION
		Add n*expr to this expression for another expression expr.

	PARAMETERS
		expr <ClLinearExpression>
		n <Number>
	"
	self incrementConstant: n*expr constant.
	expr terms keysAndValuesDo: [:v :c |
		self addVariable: v coefficient: n*c].
]

{ #category : #arithmetic }
ClLinearExpression >> addExpression: expr times: n subject: subject solver: solver [
	"ACTION
		Add n*expr to this expression for another expression expr.  Notify the solver if
		a variable is added or deleted from this expression.

	PARAMETERS
		expr <ClLinearExpression>
		n <Number>
		subject: <ClAbstractVariable>
		solver <ClSimplexSolver | nil>
	"
	self incrementConstant: n*expr constant.
	expr terms keysAndValuesDo: [:v :c |
		self addVariable: v coefficient: n*c subject: subject solver: solver].
]

{ #category : #arithmetic }
ClLinearExpression >> addVariable: v coefficient: c [
	"ACTION
		Add a term c*v to this expression.  If the expression already contains a
		term involving v, add c to the existing coefficient.  If the new coefficient
		is approximately 0, delete v.

	PARAMETERS
		v <ClVariable>
		c <Number>
	"

	| newCoeff |

	(self terms includesKey: v)
		ifTrue: [
			newCoeff := c + (self terms at: v).
			(newCoeff clApproxZero)
				ifTrue: [
					self terms removeKey: v.
					^self]
				ifFalse: [self terms at: v put: newCoeff]]
		ifFalse: [self terms at: v put: c].
]

{ #category : #arithmetic }
ClLinearExpression >> addVariable: v coefficient: c subject: subject solver: solver [
	"ACTION
		Add a term c*v to this expression.  If the expression already contains a
		term involving v, add c to the existing coefficient.  If the new coefficient
		is approximately 0, delete v.  Notify the solver if v appears or disappears from this
		expression.

	PARAMETERS
		v <ClVariable>
		c <Number>
		subject <ClAbstractVariable>
		solver <ClSimplexSolver>
	"

	| newCoeff |

	(self terms includesKey: v)
		ifTrue: [
			newCoeff := c + (self terms at: v).
			newCoeff clApproxZero
				ifTrue: [
					self terms removeKey: v.
					solver noteRemovedVariable: v subject: subject.
					^self]
				ifFalse: [self terms at: v put: newCoeff]]
		ifFalse: [
			self terms at: v put: c.
			solver noteAddedVariable: v subject: subject].
]

{ #category : #arithmetic }
ClLinearExpression >> anyVariable [
	"ACTION
		Return a variable in this expression.  (It is an error if this expression is constant).

	Returns
		<ClAbstractVariable>
	"

	self terms keysDo: [:v | ^v].
	"signal an error if this expression is constant"
	ClInternalError signal
]

{ #category : #arithmetic }
ClLinearExpression >> asLinearExpression [
	^self
]

{ #category : #arithmetic }
ClLinearExpression >> changeSubject: oldSubject newSubject: newSubject [
	"ACTION
		This linear expression currently represents the equation oldSubject=self.
		Destructively modify it so that it represents the equation newSubject=self.
		Precondition: newSubject currently has a nonzero coefficient in this expression.
	PARAMETERS
		oldSubject <ClAbstractVariable>
		newSubject <ClAbstractVariable>
	NOTES
		Suppose this expression is c + a*newSubject + a1*v1 + ... + an*vn.
		Then the current equation is oldSubject = c + a*newSubject + a1*v1 + ... + an*vn.
		The new equation will be newSubject = -c/a + oldSubject/a - (a1/a)*v1 - ... - (an/a)*vn.
		Note that the term involving newSubject has been dropped.
	"
		| reciprocal nreciprocal |
	"remove newSubject from my dictionary of terms, saving the reciprocal of its coefficient"
	reciprocal := 1.0 / (self terms removeKey: newSubject).
	nreciprocal := 0.0 - reciprocal.
	self constant: nreciprocal * self constant.
	self terms keysAndValuesDo: [:v :c | self terms at: v put: c*nreciprocal].
	self terms at: oldSubject put: reciprocal.
]

{ #category : #arithmetic }
ClLinearExpression >> cnEqual: expr [
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
ClLinearExpression >> cnEqual: expr strength: s [
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
ClLinearExpression >> cnEqual: expr strength: s weight: w [
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
ClLinearExpression >> cnGEQ: expr [
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
ClLinearExpression >> cnGEQ: expr strength: s [
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
ClLinearExpression >> cnGEQ: expr strength: s weight: w [
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
ClLinearExpression >> cnLEQ: expr [
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
ClLinearExpression >> cnLEQ: expr strength: s [
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
ClLinearExpression >> cnLEQ: expr strength: s weight: w [
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
ClLinearExpression >> coefficientFor: var [
	"ACTION
		Return the coefficient corresponding to variable var, i.e.,
		the 'ci' corresponding to the 'vi' that var is:
			v1*c1 + v2*c2 + .. + vn*cn + c

	PARAMETERS
		var <ClVariable>

	RETURNS
		<Number>
	"

	^self terms at: var ifAbsent: [0.0]
]

{ #category : #arithmetic }
ClLinearExpression >> constant [
	"ACTION
		Return the constant part of this expression, i.e., the 'c' in:
			c + a1*v1 + a2*v2 + .. + an*vn

	RETURNS
		<Number>
	"

	^constant
]

{ #category : #arithmetic }
ClLinearExpression >> constant: c [
	"ACTION
		See #constant

	PARAMETERS
		c <Number>
	"
	constant := c
]

{ #category : #arithmetic }
ClLinearExpression >> divFrom: aNumber [
	"ACTION
		Return a new linear expression (aNumber/self).  Since the result must be linear, this is permissible
		only if self is a constant.

	RETURNS
		<ClLinearExpression>
	"
	self isConstant ifTrue: [^aNumber / self constant].
	"result would be non-linear"
	ClNonLinearExpression signal
]

{ #category : #arithmetic }
ClLinearExpression >> incrementConstant: c [
	"ACTION
		Increment the constant part of this expression by c.

	PARAMETERS
		c <Number>
	"

	self constant: self constant + c
]

{ #category : #arithmetic }
ClLinearExpression >> initialize [
	"ACTION
		Initialize this linear expression to 0.
	"

	self
		constant: 0.0;
		terms: Dictionary new.
	^self
]

{ #category : #arithmetic }
ClLinearExpression >> isConstant [
	"ACTION
		Return true if this expression is a constant (i.e. it contains no variables).

	RETURNS
		<Boolean>
	"

	^self terms isEmpty
]

{ #category : #arithmetic }
ClLinearExpression >> newSubject: subject [
	"ACTION
		This linear expression currently represents the equation self=0.  Destructively modify it so 
		that subject=self represents an equivalent equation.  Precondition: subject must be one
		of the variables in this expression.
	PARAMETERS
		subject <ClAbstractVariable>
	NOTES
		Suppose this expression is c + a*subject + a1*v1 + ... + an*vn, representing 
		c + a*subject + a1*v1 + ... + an*vn = 0.
		The modified expression will be subject = -c/a - (a1/a)*v1 - ... - (an/a)*vn, representing
		subject = -c/a - (a1/a)*v1 - ... - (an/a)*vn.
		Note that the term involving subject has been dropped.
	"
		| nreciprocal |
	"remove subject from my dictionary of terms, saving the negative of the reciprocal of its coefficient"
	nreciprocal := 0.0 - (1.0 / (self terms removeKey: subject)).
	self constant: nreciprocal * self constant.
	self terms keysAndValuesDo: [:v :c | self terms at: v put: c*nreciprocal].
]

{ #category : #arithmetic }
ClLinearExpression >> printOn: strm [
		| sortedKeys |
	self constant printOn: strm.
	sortedKeys := self terms keys asSortedCollection: 
		[:v1 :v2 | v1 name isNil or: [v2 name isNil or: [v1 name <= v2 name]]].
	sortedKeys do: [:v |
		strm nextPut: $+.
		(self terms at: v) printOn: strm.
		strm nextPut: $*.
		v printOn: strm].
]

{ #category : #arithmetic }
ClLinearExpression >> substituteOut: var expr: expr subject: subject solver: solver [
	"ACTION
		Replace var with a symbolic expression expr that is equal to it.  If a variable has been added to this
		expression that wasn't there before, or if a variable has been dropped from this expression 
		because it now has a coefficient of 0, inform the solver.

	PRECONDITIONS
		var occurs with a non-zero coefficient in this expression.

	PARAMETERS
		var <ClAbstractVariable>
		expr <ClLinearExpression>
		subject <ClAbstractVariable>
		solver <ClSimplexSolver>
	"
		| multiplier oldCoeff newCoeff |
	multiplier := self terms removeKey: var.
	self incrementConstant: multiplier * expr constant.
	expr terms keysAndValuesDo: [:v :c |
		oldCoeff := self terms at: v ifAbsent: [nil].
		oldCoeff isNil 
			ifTrue: [
				self terms at: v put: multiplier*c.  solver noteAddedVariable: v subject: subject]
			ifFalse: [
				newCoeff := oldCoeff + (multiplier*c).
				(newCoeff clApproxZero)
					ifTrue: [self terms removeKey: v.  solver noteRemovedVariable: v subject: subject]
					ifFalse: [self terms at: v put: newCoeff]]].
]

{ #category : #arithmetic }
ClLinearExpression >> subtractFrom: aNumber [
	"ACTION
		Return a new linear expression (aNumber-self).

	RETURNS
		<ClLinearExpression>
	"
	^ -1.0*self + aNumber
]

{ #category : #arithmetic }
ClLinearExpression >> terms [
	"ACTION
		Return the 'terms' dictionary.  The keys in the dictionary will be
		variables and the values will be numbers (the corresponding
		coefficients).  If 'terms' contains variables v1, ... , vn and 
		coefficients a1, ... an, then this object represents the linear expression
			constant + a1*v1 + ... + an*vn
		Note that the coefficients should all be non-zero -- if there
		were going to be a zero coefficient, that term should be dropped 
		from the linear expression.

	RETURNS
		<LookupTable of <ClVariable> -> <Number>>
	"

	^terms
]

{ #category : #arithmetic }
ClLinearExpression >> terms: t [
	"ACTION
		See #terms

	PARAMETERS
		<LookupTable>
	"
	terms := t
]

{ #category : #arithmetic }
ClLinearExpression >> variablesAndCoefficientsDo: aBlock [
	"ACTION
		Evaluate aBlock with each variable-coefficient pair as arguments.

	PARAMETERS
		aBlock <Block [ClConstrainableVariable,Number] >
	"

	self terms keysAndValuesDo: [:v :c | aBlock value: v value: c]
]
