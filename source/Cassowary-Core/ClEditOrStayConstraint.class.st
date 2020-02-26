Class {
	#name : #ClEditOrStayConstraint,
	#superclass : #ClConstraint,
	#instVars : [
		'variable'
	],
	#category : #'Cassowary-Core'
}

{ #category : #'as yet unclassified' }
ClEditOrStayConstraint class >> variable: v strength: s [
	^self variable: v strength: s weight: 1.0
]

{ #category : #'as yet unclassified' }
ClEditOrStayConstraint class >> variable: v strength: s weight: w [
		| cn |
	cn := self new.
	cn variable: v; strength: s; weight: w.
	^cn
]

{ #category : #accessing }
ClEditOrStayConstraint >> expression [
		| e |
	e := ClLinearExpression new.
	e constant: self variable value.
	e terms at: self variable put: -1.0.
	^e
]

{ #category : #accessing }
ClEditOrStayConstraint >> variable [
	^variable
]

{ #category : #accessing }
ClEditOrStayConstraint >> variable: v [
	variable := v
]
