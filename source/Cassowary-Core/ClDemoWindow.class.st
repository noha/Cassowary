Class {
	#name : #ClDemoWindow,
	#superclass : #Object,
	#instVars : [
		'shell',
		'main',
		'form',
		'da',
		'gc',
		'gcw',
		'buffer',
		'grabPoint',
		'dragPoint',
		'cs',
		'errorPixel',
		'editX',
		'editY'
	],
	#pools : [
		'CgConstants',
		'ClConstants',
		'CwConstants'
	],
	#category : #'Cassowary-Core'
}

{ #category : #'as yet unclassified' }
ClDemoWindow class >> makeDemos [

	"statements to build various demos"

	ClBoundedLineDemo new open.
	ClElasticBoundedLineDemo new open.
	ClQuadDemo new open.
	ClMidpointDemo new open.
	ClBoundedQuadDemo new open.
	ClCrossedQuadDemo new open.
	ClElasticQuadDemo new open.
	"ClTreeDemo1 new open.
	ClTreeDemo2 new open."
	ClBoxesDemo new open.
	"ClSequenceDiagramDemo1 new open."
	(ClBinaryTreeDemo height: 4) open.
]

{ #category : #'as yet unclassified' }
ClDemoWindow class >> new [

	^super new initialize
]

{ #category : #'as yet unclassified' }
ClDemoWindow >> beginManipulation [
	"ACTION
		This method is called when a constrainable point is starting to
		be manipulated, i.e., upon mouse down.  The constrainable
		point is stored in the 'dragPoint' instance variable, and the
		corresponding plan for moving that point is stored in the 'plan'
		instance variable.

		The order of messages is:
			1. #beginManipulation
			2-N. #manipulationMoveTo:
			N+1. #endManipulation
	"

	self constraintPointsDo: [:p |
		dragPoint == p ifTrue: [
			cs addEditVar: p x strength: ClStrength strong.
			cs addEditVar: p y strength: ClStrength strong.
			cs beginEdit.
			^nil]].

	 "drag point not found"
	self error 
]

{ #category : #'as yet unclassified' }
ClDemoWindow >> button1Motion: aWidget clientData: clientData callData: callData [

	dragPoint isNil ifTrue: [^self].
	self manipulationMoveTo: callData point
]

{ #category : #'as yet unclassified' }
ClDemoWindow >> buttonPress: aWidget clientData: clientData callData: callData [

	grabPoint isNil ifTrue: [^self].
	self drawGrabBox.
	dragPoint := grabPoint.
	grabPoint := nil.

	self beginManipulation
]

{ #category : #'as yet unclassified' }
ClDemoWindow >> buttonRelease: aWidget clientData: clientData callData: callData [

	dragPoint isNil ifTrue: [^self].
	dragPoint := nil.

	self endManipulation
]

{ #category : #'as yet unclassified' }
ClDemoWindow >> constraintPointsDo: aBlock [
	"ACTION
		Evaluate this block for each of the constrainable points in this demo.
		Constrainable points are those that can be manipulated by the mouse.
		A constraint point is a Point object whose x and y instance variables
		hold instances of ClVariable.

	PARAMETERS
		aBlock <[:<Point of <ClVariable>> | ...]>
	"
]

{ #category : #'as yet unclassified' }
ClDemoWindow >> createForm [

	da := form createDrawingArea: 'da' argBlock: nil.
	da manageChild.
	da setValuesBlock: [:w |
		w
			bottomAttachment: XmATTACHFORM;
			topAttachment: XmATTACHFORM;
			rightAttachment: XmATTACHFORM;
			leftAttachment: XmATTACHFORM].
	da
		addCallback: XmNexposeCallback
			receiver: self
			selector: #exposeArea:clientData:callData:
			clientData: nil;
		addCallback: XmNresizeCallback
			receiver: self
			selector: #resizeArea:clientData:callData:
			clientData: nil;
		addEventHandler: Button1MotionMask
			receiver: self
			selector: #button1Motion:clientData:callData:
			clientData: nil;
		addEventHandler: ButtonPressMask
			receiver: self
			selector: #buttonPress:clientData:callData:
			clientData: nil;
		addEventHandler: ButtonReleaseMask
			receiver: self
			selector: #buttonRelease:clientData:callData:
			clientData: nil;
		addEventHandler: PointerMotionMask
			receiver: self
			selector: #pointerMotion:clientData:callData:
			clientData: nil
]

{ #category : #'as yet unclassified' }
ClDemoWindow >> createWindow [

	| destroy |
	shell :=
		CwTopLevelShell
			createApplicationShell: 'shell'
			argBlock: [:w |
				w
					title: self title;
					width: self initialExtent x;
					height: self initialExtent y].
	main := shell createMainWindow: 'main' argBlock: nil.
	main manageChild.
	form := main createForm: 'form' argBlock: nil.
	form manageChild.
	shell
		addCallback: XmNdestroyCallback
		receiver: self
		selector: #destroyWindow:clientData:callData:
		clientData: nil.
	self createForm!

destroy
	"ACTION
		This method is called when the window is closing.
	"
]

{ #category : #'as yet unclassified' }
ClDemoWindow >> destroyWindow: aWidget clientData: clientData callData: callData [

	gc isNil
		ifFalse: [
			gc freeGC.
			gc := nil].
	gcw isNil
		ifFalse: [
			gcw freeGC.
			gcw := nil].
	buffer isNil
		ifFalse: [
			buffer freePixmap.
			buffer := nil].
	self destroy
]

{ #category : #'as yet unclassified' }
ClDemoWindow >> drawArea [
	"ACTION
		Draw the demo.
	"
]

{ #category : #'as yet unclassified' }
ClDemoWindow >> drawBackground [
	"ACTION
		Draw the background of the demo.
	"

	gc setForeground: 15.
	buffer fillRectangle: gc x: 0 y: 0 width: buffer width height: buffer height
]

{ #category : #'as yet unclassified' }
ClDemoWindow >> drawGrabBox [

	| r pv endManipulation |

	pv := grabPoint x value rounded @ grabPoint y value rounded.
	gcw
		setFunction: GXhighlight;
		setLineAttributes: 3 lineStyle: LineSolid capStyle: CapButt joinStyle: JoinMiter;
		setForeground: 0.
	r := (pv - self grabThreshold) corner: (pv + self grabThreshold).
	da window drawRectangle: gcw x: r origin x y: r origin y width: r width height: r height.
	gcw setFunction: GXcopy
]

{ #category : #'as yet unclassified' }
ClDemoWindow >> endManipulation [
	"ACTION
		This method is called when a constrainable point is ending
		being manipulated, i.e., upon mouse up.  The constrainable
		point is stored in the 'dragPoint' instance variable, and the
		corresponding plan for moving that point is stored in the 'plan'
		instance variable.

		The order of messages is:
			1. #beginManipulation
			2-N. #manipulationMoveTo:
			N+1. #endManipulation
	"
	cs endEdit.
	self redraw.
]

{ #category : #'as yet unclassified' }
ClDemoWindow >> exposeArea: aWidget clientData: clientData callData: callData [

	buffer isNil ifTrue: [self resizeArea: aWidget clientData: clientData callData: nil].
	buffer
		copyArea: aWidget window
		gc: gcw
		srcX: 0
		srcY: 0
		width: buffer width
		height: buffer height
		destX: 0
		destY: 0.
	grabPoint := nil
]

{ #category : #'as yet unclassified' }
ClDemoWindow >> grabThreshold [

	^7 @ 7
]

{ #category : #'as yet unclassified' }
ClDemoWindow >> initialExtent [
	"ACTION
		Return the initial size for the overall window.
	"

	^300 @ 300
]

{ #category : #'as yet unclassified' }
ClDemoWindow >> initialize [
	"ACTION
		Initialize the demo structures before the widgets are created.
	"

	cs := ClSimplexSolver new.
	errorPixel := nil
]

{ #category : #'as yet unclassified' }
ClDemoWindow >> manipulationMoveTo: aPoint [
	"ACTION
		This method is called when a constrainable point is manipulated
		using the mouse, i.e., during mouse motion.  aPoint is the
		location of the mouse and thus the new requested location of
		the constrainable point.  The constrainable
		point is stored in the 'dragPoint' instance variable, and the
		corresponding plan for moving that point is stored in the 'plan'
		instance variable.

		The order of messages is:
			1. #beginManipulation
			2-N. #manipulationMoveTo:
			N+1. #endManipulation

	PARAMETERS
		aPoint <Point of <Number>>
	"
	cs suggestValue: dragPoint x newValue: aPoint x asFloat.
	cs suggestValue: dragPoint y newValue: aPoint y asFloat.
	cs resolve.
	self redraw
]

{ #category : #'as yet unclassified' }
ClDemoWindow >> open [

	self createWindow.
	shell realizeWidget
]

{ #category : #'as yet unclassified' }
ClDemoWindow >> pointerMotion: aWidget clientData: clientData callData: callData [

	| r |

	dragPoint isNil
		ifTrue: [
			self constraintPointsDo: [:p | | pv th |
				th := self grabThreshold * 2.
				pv := p x value rounded @ p y value rounded.
				(((pv - th) corner: (pv + th)) containsPoint: callData point)
					ifTrue: [
						grabPoint == p ifTrue: [^self].
						grabPoint notNil ifTrue: [self drawGrabBox].
						grabPoint := p.
						self drawGrabBox.
						^self].
				grabPoint notNil ifTrue: [self drawGrabBox].
				grabPoint := nil]]
]

{ #category : #'as yet unclassified' }
ClDemoWindow >> redraw [

	self drawBackground.
	self drawArea.
	self exposeArea: da clientData: nil callData: nil
]

{ #category : #'as yet unclassified' }
ClDemoWindow >> resizeArea: aWidget clientData: clientData callData: callData [

	buffer isNil
		ifFalse: [
			buffer freePixmap.
			buffer := nil].
	gc isNil
		ifFalse: [
			gc freeGC.
			gc := nil].
	gcw isNil ifTrue: [gcw := aWidget window createGC: None values: nil].
	buffer :=
		aWidget window createPixmap: aWidget width height: aWidget height depth: aWidget window depth.
	gc := buffer createGC: None values: nil.
	self drawBackground.
	self drawArea
]

{ #category : #'as yet unclassified' }
ClDemoWindow >> setForegroundColor: c [

	gc setForeground: (errorPixel isNil ifTrue: [c] ifFalse: [errorPixel])
]

{ #category : #'as yet unclassified' }
ClDemoWindow >> title [
	"ACTION
		Return the title for the overall window.
	"

	^'demo'
]
