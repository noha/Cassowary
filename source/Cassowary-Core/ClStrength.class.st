Class {
	#name : #ClStrength,
	#superclass : #Object,
	#instVars : [
		'name',
		'symbolicWeight'
	],
	#classVars : [
		'MediumStrength',
		'RequiredStrength',
		'StrongStrength',
		'WeakStrength'
	],
	#category : #'Cassowary-Core'
}

{ #category : #private }
ClStrength class >> initializeAfterLoad [
	"ACTION
		Initialize the class variables to the pre-defined strengths.
	"
		| s m w |

	RequiredStrength := self new.  
	RequiredStrength name: 'required'.

	s := ClSymbolicWeight new.  s at: 1 put: 1.0.  s at: 2 put: 0.0.  s at: 3 put: 0.0.
	StrongStrength := self new.
	StrongStrength name: 'strong'; symbolicWeight: s.

	m := ClSymbolicWeight new.  m at: 1 put: 0.0.  m at: 2 put: 1.0.  m at: 3 put: 0.0.
	MediumStrength := self new.
	MediumStrength name: 'medium'; symbolicWeight: m.

	w := ClSymbolicWeight new.  w at: 1 put: 0.0.  w at: 2 put: 0.0.  w at: 3 put: 1.0.
	WeakStrength := self new.
	WeakStrength name: 'weak'; symbolicWeight: w.
]

{ #category : #private }
ClStrength class >> medium [

	^MediumStrength
]

{ #category : #private }
ClStrength class >> nLevels [
	"return the number of non-required strengths"
	^3
]

{ #category : #private }
ClStrength class >> required [

	^RequiredStrength
]

{ #category : #private }
ClStrength class >> strengthsDo: block [
	"ACTION
		Evaluation the block for each defined strength, strongest to weakest.

	PARAMETERS
		block <Block value: ClStrength>
	"

	block
		value: RequiredStrength;
		value: StrongStrength;
		value: MediumStrength;
		value: WeakStrength
]

{ #category : #private }
ClStrength class >> strong [

	^StrongStrength
]

{ #category : #private }
ClStrength class >> weak [

	^WeakStrength
]

{ #category : #testing }
ClStrength >> isRequired [

	^self == RequiredStrength
]

{ #category : #printing }
ClStrength >> name [
	^name
]

{ #category : #printing }
ClStrength >> name: n [
	name := n
]

{ #category : #printing }
ClStrength >> printOn: strm [

	strm nextPutAll: self name
]

{ #category : #printing }
ClStrength >> symbolicWeight [	
	^symbolicWeight
]

{ #category : #printing }
ClStrength >> symbolicWeight: w [
	symbolicWeight := w
]
