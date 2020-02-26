Class {
	#name : #ClEditConstraint,
	#superclass : #ClEditOrStayConstraint,
	#category : #'Cassowary-Core'
}

{ #category : #'as yet unclassified' }
ClEditConstraint class >> variable: aVariable value: aValue strength: aStrength [

	^(self variable: aVariable strength: aStrength)
		value: aValue;
		yourself
]

{ #category : #accessing }
ClEditConstraint >> isEditConstraint [
	"RETURNS
		<Boolean>
	"
	^true
]
