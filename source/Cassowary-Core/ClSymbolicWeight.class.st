Class {
	#name : #ClSymbolicWeight,
	#superclass : #Object,
	#type : #variable,
	#classVars : [
		'Zero'
	],
	#category : #'Cassowary-Core'
}

{ #category : #'instance creation' }
ClSymbolicWeight class >> initialize [
	"ACTION
		Initialize the class variables to the pre-defined strengths.
	"

	Zero := self new.
	1 to: Zero size do: [:i | Zero at: i put: 0.0].
]

{ #category : #'instance creation' }
ClSymbolicWeight class >> new [
	^self basicNew: ClStrength nLevels
]

{ #category : #'instance creation' }
ClSymbolicWeight class >> zero [
	^Zero
]

{ #category : #arithmetic }
ClSymbolicWeight >> * n [
	"Multiply this symbolic weight by n (n should be a number)"
		| result |
	n isNumber ifFalse: [ClInternalError signal].
	result := self class new.
	1 to: self size do: [:i | result at: i put: n*(self at: i)].
	^result
]

{ #category : #arithmetic }
ClSymbolicWeight >> + n [
	"Add this symbolic weight to n (which must also be a symbolic weight)"
		| result |
	n isSymbolicWeight  ifFalse: [ClInternalError signal].
	result := self class new.
	1 to: self size do: [:i | result at: i put: (self at: i) + (n at: i)].
	^result
]

{ #category : #arithmetic }
ClSymbolicWeight >> - n [
	"Subtract n from this symbolic weight (n must also be a symbolic weight)"
		| result |
	n isSymbolicWeight  ifFalse: [ClInternalError signal].
	result := self class new.
	1 to: self size do: [:i | result at: i put: (self at: i) - (n at: i)].
	^result
]

{ #category : #arithmetic }
ClSymbolicWeight >> / n [
	"Divide this symbolic weight by n (n should be a number)"
		| result |
	n isNumber ifFalse: [ClInternalError signal].
	result := self class new.
	1 to: self size do: [:i | result at: i put: (self at: i)/n].
	^result
]

{ #category : #arithmetic }
ClSymbolicWeight >> < n [
		| a b |
	n isSymbolicWeight  ifFalse: [ClInternalError signal].
	1 to: self size do: [:i | 
		a := self at: i.  
		b := n at: i.
		a<b ifTrue: [^true].
		a>b ifTrue: [^false]
		"they're equal ... keep going"].
	"all elements were equal"
	^false
]

{ #category : #arithmetic }
ClSymbolicWeight >> <= n [
		| a b |
	n isSymbolicWeight  ifFalse: [ClInternalError signal].
	1 to: self size do: [:i | 
		a := self at: i.  
		b := n at: i.
		a<b ifTrue: [^true].
		a>b ifTrue: [^false]
		"they're equal ... keep going"].
	"all elements were equal"
	^true
]

{ #category : #arithmetic }
ClSymbolicWeight >> = n [
	n isSymbolicWeight  ifFalse: [^false].
	1 to: self size do: [:i | 
		(self at: i) = (n at: i) ifFalse: [^false]].
	"all elements were equal"
	^true
]

{ #category : #arithmetic }
ClSymbolicWeight >> > n [
		| a b |
	n isSymbolicWeight  ifFalse: [ClInternalError signal].
	1 to: self size do: [:i | 
		a := self at: i.  
		b := n at: i.
		a>b ifTrue: [^true].
		a<b ifTrue: [^false]
		"they're equal ... keep going"].
	"all elements were equal"
	^false
]

{ #category : #arithmetic }
ClSymbolicWeight >> >= n [
		| a b |
	n isSymbolicWeight  ifFalse: [ClInternalError signal].
	1 to: self size do: [:i | 
		a := self at: i.  
		b := n at: i.
		a>b ifTrue: [^true].
		a<b ifTrue: [^false]
		"they're equal ... keep going"].
	"all elements were equal"
	^true
]

{ #category : #arithmetic }
ClSymbolicWeight >> approxNonNegative [
	"return true if this symbolic weight is non-negative.  Allow coefficients that are within epsilon of
		0 to count as 0"
		| a nepsilon |
	nepsilon := 0.0 - ClKernel epsilon.
	1 to: self size do: [:i | 
		a := self at: i.  
		a<nepsilon ifTrue: [^false].
		a> ClKernel epsilon ifTrue: [^true]].
	^true
]

{ #category : #arithmetic }
ClSymbolicWeight >> clApprox: s [
	"Return true if this symbolic weight is approximately equal to s. 
		The argument s must be another symbolic weight -- we can't
		compare symbolic weights with ordinary numbers."
	s isSymbolicWeight ifFalse: [ClInternalError signal].
	1 to: self size do: [:i | 
		((self at: i) clApprox: (s at: i)) ifFalse: [^false]].
	^true
]

{ #category : #arithmetic }
ClSymbolicWeight >> clApproxZero [
	"return true if this symbolic weight is approximately zero"
	^self clApprox: Zero
]

{ #category : #arithmetic }
ClSymbolicWeight >> isSymbolicWeight [
	^true
]

{ #category : #arithmetic }
ClSymbolicWeight >> printOn: strm [
	strm nextPutAll: '['.
	(self at: 1) printOn: strm.
	2 to: self size do: [:i | strm nextPutAll: ','.  (self at: i) printOn: strm].
	strm nextPutAll: ']'
]
