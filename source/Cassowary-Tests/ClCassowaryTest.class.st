Class {
	#name : #ClCassowaryTest,
	#superclass : #TestCase,
	#pools : [
		'ClConstants'
	],
	#category : #'Cassowary-Tests'
}

{ #category : #adding }
ClCassowaryTest >> testAddDelete1 [

	| x solver result c10 c10again c20 |

	x := ClVariable new name: 'x'.

	solver := ClSimplexSolver new.
	solver addConstraint: (x cnEqual: 100.0 strength: ClStrength weak).
	c10 := x cnLEQ: 10.0.
	c20 := x cnLEQ: 20.0.
	solver addConstraint: c10; addConstraint: c20.
	result := (x value clApprox: 10.0).
	solver removeConstraint: c10.
	result := result & (x value clApprox: 20.0).
	solver removeConstraint: c20.
	result := result & (x value clApprox: 100.0).
	c10again := x cnLEQ: 10.0.
	solver addConstraint: c10; addConstraint: c10again.
	result := result & (x value clApprox: 10.0).
	solver removeConstraint: c10.
	result := result & (x value clApprox: 10.0).
	solver removeConstraint: c10again.
	result := result & (x value clApprox: 100.0).

	self assert: result
]

{ #category : #adding }
ClCassowaryTest >> testAddDelete2 [

"
	| c |
c := ClCassowaryTester new.
c haltFirst: false.
c addDelete2.
"

		| x y solver result c10 c10again c20 cxy |

	x := ClVariable new name: 'x'.
	y := ClVariable new name: 'y'.

	solver := ClSimplexSolver new.
	solver addConstraint: (x cnEqual: 100.0 strength: ClStrength weak).
	solver addConstraint: (y cnEqual: 120.0 strength: ClStrength strong).
	c10 := x cnLEQ: 10.0.
	c20 := x cnLEQ: 20.0.
	solver addConstraint: c10; addConstraint: c20.
	result := (x value clApprox: 10.0) & (y value clApprox: 120.0).
	solver removeConstraint: c10.
	result := result & (x value clApprox: 20.0) & (y value clApprox: 120.0).
	cxy := 2*x cnEqual: y.
	solver addConstraint: cxy.
	result := result & (x value clApprox: 20.0) & (y value clApprox: 40.0).
	solver removeConstraint: c20.
	result := result & (x value clApprox: 60.0) & (y value clApprox: 120.0).
	solver removeConstraint: cxy.
	result := result & (x value clApprox: 100.0) & (y value clApprox: 120.0).

	self assert: result
]

{ #category : #adding }
ClCassowaryTest >> testAddDelete3 [
	| x solver result c1 c2 |

	x := ClVariable new name: 'x'.

	solver := ClSimplexSolver new.
	c1 := (x cnEqual: 100.0 strength: ClStrength weak weight: 5).  "notice weight=5 for this one"
	c2 := (x cnEqual: 200.0 strength: ClStrength weak).
	solver addConstraint: c1; addConstraint: c2.
	result := (x value clApprox: 100.0).
	solver removeConstraint: c1.
	result := result & (x value clApprox: 200.0).

	self assert: result
]

{ #category : #adding }
ClCassowaryTest >> testEdit1 [

	| x y solver result  |

	x := ClVariable newWith: 20.0 name: 'x'.
	y := ClVariable newWith: 30.0 name: 'y'.

	"set up solver with a weak stay on x, required 10<=x<=100, and required x=2*y"
	solver := ClSimplexSolver new.
	solver addConstraint: (ClStayConstraint variable:  x strength: ClStrength weak).
	solver addConstraint: (x cnGEQ: 10); addConstraint: (x cnLEQ: 100).
	solver addConstraint: (x cnEqual: 2*y).
	result := (x value clApprox: 20.0) & (y value clApprox: 10.0).

	"now edit y"
	solver addEditVar: y strength: ClStrength strong.
	solver beginEdit.
	solver suggestValue: y newValue: 35.0.
	solver resolve.
	result := result & (x value clApprox: 70.0) & (y value clApprox: 35.0).
	solver suggestValue: y newValue: 80.0.   "this is bigger than y can be"
	solver resolve.
	result := result & (x value clApprox: 100.0) & (y value clApprox: 50.0).
	solver suggestValue: y newValue: 25.0.
	solver resolve.
	result := result & (x value clApprox: 50.0) & (y value clApprox: 25.0).

	solver endEdit.
	"x and y shouldn't change"
	result := result & (x value clApprox: 50.0) & (y value clApprox: 25.0).

	"edit x"
	solver addEditVar:x strength: ClStrength strong.
	solver beginEdit.
	solver suggestValue: x newValue: 44.0.
	solver resolve.
	result := result & (x value clApprox: 44.0) & (y value clApprox: 22.0).
	solver endEdit.

	Transcript cr; 
		show: 'ClCassowaryTester edit1 result='; 
		show: (result ifTrue: ['passed'] ifFalse: ['failed']); 
		cr.
]

{ #category : #adding }
ClCassowaryTest >> testInconsistent1 [

	"inconsistent constraints:
		req'd	x=10
		req'd	x=5
	"

	| x solver signalled |

	x := ClVariable new name: 'x'.

	solver := ClSimplexSolver new.
	solver addConstraint: (x cnEqual: 10.0).
	signalled := false.
	[solver addConstraint: (x cnEqual: 5.0)] on: ClRequiredFailure do: [:signal | signalled := true. signal return: false].

	self assert: signalled

]

{ #category : #adding }
ClCassowaryTest >> testInconsistent2 [

	"inconsistent constraints:
		req'd	x>=10
		req'd	x<=5
	"

	| x solver signalled |

	x := ClVariable new name: 'x'.

	solver := ClSimplexSolver new.
	solver addConstraint: (x cnGEQ: 10.0).
	signalled := false.
	[solver addConstraint: (x cnLEQ: 5.0)] on: ClRequiredFailure do: [:signal | signalled := true. signal return: false].

	self assert: signalled

]

{ #category : #adding }
ClCassowaryTest >> testStay1 [

	| x solver result stay |

	x := ClVariable newWith: 20.0 name: 'x'.

	"set up solver with a weak stay on x, required 10<=x<=100, and required x=2*y"
	solver := ClSimplexSolver new.
	stay := ClStayConstraint variable:  x strength: ClStrength weak.
	solver addConstraint: stay.
	result := (x value clApprox: 20.0).
	solver removeConstraint: stay.

	self assert: result
]

{ #category : #adding }
ClCassowaryTest >> testTwoSolutions [
	"
		req'd   x<=y
		req'd   y=x+3
 		weak   x=10
		weak   y=10

		The solution is x=7, y=10  or x=10, y=13 "

	| x y solver result |

	x := ClVariable new name: 'x'.
	y := ClVariable new name: 'y'.

	solver := ClSimplexSolver new.
	solver addConstraint: (x cnLEQ: y).
	solver addConstraint: (y cnEqual: x+3.0).
	solver addConstraint: (x cnEqual: 10.0 strength: ClStrength weak).
	solver addConstraint: (y cnEqual: 10.0 strength: ClStrength weak).

	result :=
		(x value clApprox: 10.0) & (y value clApprox: 13.0)
			or: [	(x value clApprox: 7.0) & (y value clApprox: 10.0) ].

	self assert: result

]

{ #category : #adding }
ClCassowaryTest >> testWeighted1 [

	| x solver result c15 c20 |

	x := ClVariable new name: 'x'.

	solver := ClSimplexSolver new.
	c15 := x cnEqual: 15.0 strength: ClStrength weak.
	c20 := x cnEqual: 20.0 strength: ClStrength weak weight: 2.
	solver addConstraint: c15.
	result := x value clApprox: 15.0.
	solver addConstraint: c20.
	result := result & (x value clApprox: 20.0).
	solver removeConstraint: c20.
	result := result & (x value clApprox: 15.0).

	self assert: result

]
