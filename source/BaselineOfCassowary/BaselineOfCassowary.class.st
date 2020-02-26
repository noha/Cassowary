Class {
	#name : #BaselineOfCassowary,
	#superclass : #BaselineOf,
	#classVars : [
		'Initialized'
	],
	#category : #BaselineOfCassowary
}

{ #category : #baseline }
BaselineOfCassowary >> baseline: spec [
	<baseline>

	spec for: #common do: [ 
		
		spec package: 'Cassowary-Core'.
		spec package: 'Cassowary-Tests' with: [spec requires: #('Cassowary-Core')].
		spec package: 'Cassowary-Demo' with: [spec requires: #( 'Cassowary-Core')].
	
		spec 
			group: 'default' with: #('Core' 'Tests' 'Demo');
			group: 'Core' with: #('Cassowary-Core');
			group: 'Tests' with: #('Cassowary-Tests');
			group: 'Demo' with: #('Cassowary-Demo') ]
]
