Class {
	#name : #ClSimplexSolver,
	#superclass : #Object,
	#instVars : [
		'rows',
		'columns',
		'objective',
		'infeasibleRows',
		'stayPlusErrorVars',
		'stayMinusErrorVars',
		'editVars',
		'editConstraints',
		'editPlusErrorVars',
		'editMinusErrorVars',
		'prevEditConstants',
		'newEditConstants',
		'markerVars',
		'errorVars',
		'slackCounter',
		'artificialCounter',
		'dummyCounter'
	],
	#category : #'Cassowary-Core'
}

{ #category : #'as yet unclassified' }
ClSimplexSolver class >> epsilon [
	"this is declared as  a method for the benefit of Float, which otherwise doesn't have
		access to this constant.  (Maybe I'm doing something wrong ...)"
	^ ClKernel epsilon
]

{ #category : #'instance creation' }
ClSimplexSolver class >> new [
	^super new initialize
]

{ #category : #adding }
ClSimplexSolver >> addBounds: var lowerBound: lower upperBound: upper [
	"ACTION
		Add constraints so that lower<=var<=upper.  (nil means no  bound.)
	PARAMETERS
		var <ClVariable>
		lower <Number | nil>
		upper <Number | nil>
	"
	lower notNil ifTrue: [self addConstraint: (lower cnLEQ: var)].
	upper notNil ifTrue: [self addConstraint: (var cnLEQ: upper)].
]

{ #category : #adding }
ClSimplexSolver >> addConstraint: cn [
	"ACTION
		Add the constraint cn to the tableau.
	PARAMETERS
		cn <ClLinearConstraint>
	"
		| expr |
	"Make a new linear expression representing the constraint, replacing any basic variables 
		with their defining expressions, and adding slack and error variables as needed.  Also add
		error variables to the objective function, and index the constraint with its marker variable."
	expr := self makeExpression: cn.
	"If possible add expr directly to the appropriate tableau by choosing a subject for expr 
		(a variable to become basic) from among the current variables in expr.  If this doesn't work
		use an artificial variable.  After adding expr re-optimize."
	(self tryAddingDirectly: expr) ifFalse: [self addWithArtificialVariable: expr].
	self optimize: self objective.
	self setExternalVariables.
]

{ #category : #adding }
ClSimplexSolver >> addEditVar: v strength: s [
	"ACTION
		Add v to the collection of variables being edited.
	PARAMETERS
		v <ClVariable>
		s <ClStrength>
	"
	self addConstraint: (ClEditConstraint variable: v strength: s)
]

{ #category : #adding }
ClSimplexSolver >> addPointStays: points [
	"ACTION
		Add weak stays to the x and y parts of each point.  These have declining weights
		so that the solver will try to satisfy the x and y stays on the same point, rather than
		the x stay on one and the y stay on another.
	PARAMETERS
		v <ClVariable>
	"
		| w mult |
	mult := 2.0.  "amount to multiply by the weight each time"
	w := 1.0.
	points do: [:p |
		self addConstraint: (ClStayConstraint variable: p x strength: ClStrength weak weight: w).
		self addConstraint: (ClStayConstraint variable: p y strength: ClStrength weak weight: w).
		w := w*mult]
]

{ #category : #adding }
ClSimplexSolver >> addRow: var expr: expr [
	"ACTION
		Add the constraint var=expr to the tableau.  var is now a basic variable.  Update the column cross-indices.
	PARAMETERS
		var <ClAbstractVariable>
		expr <ClLinearExpresson>
	"
	self rows at: var put: expr.
	expr variablesAndCoefficientsDo: [:v :c | 
		(self columns at: v ifAbsentPut: [Set new]) add: var]
]

{ #category : #adding }
ClSimplexSolver >> addStay: v [
	"ACTION
		Add a weak stay to v.
	PARAMETERS
		v <ClVariable>
	"
	self addStay: v strength: ClStrength weak
]

{ #category : #adding }
ClSimplexSolver >> addStay: v strength: s [
	"ACTION
		Add a stay to v at the given strength.
	PARAMETERS
		v <ClVariable>
	"
	self addConstraint: (ClStayConstraint variable: v strength: s).
]

{ #category : #adding }
ClSimplexSolver >> addWithArtificialVariable: expr [
	"ACTION
		Add the constraint expr=0 to the inequality tableau using an artificial variable.  To do this, create an
		artificial variable av and add av=expr to the inequality tableau, then make av be 0.  (Raise an exception if
		we can't attain av=0.)
	PARAMETERS
		expr <ClLinearExpresson>
	"
		| av az azRow entryVar |
	artificialCounter := artificialCounter + 1.
 	av := ClSlackVariable newNamed: 'a' , artificialCounter printString.
	az := ClObjectiveVariable newNamed: 'az'.
	azRow := ClLinearExpression new.
	"the artificial objective is av, which we know is equal to expr (which contains only parametric variables)"
	azRow constant: expr constant.
	expr terms keysAndValuesDo: [:v :c | azRow terms at: v put: c].
	self addRow: az expr: azRow.
	self addRow: av expr: expr.
	"try to optimize av to 0"
	self optimize: az.
	"Check that we were able to make the objective value 0.  If not, the original constraint was unsatisfiable."
	(azRow constant clApproxZero) ifFalse: [ClRequiredFailure signal].
	"see if av is a basic variable"
	self rows at: av ifPresent: [:e |
		"Find another variable in this row and pivot, so that av becomes parametric.  If there isn't another variable
			in the row then the tableau contains the equation av=0 -- just delete av's row."
		e isConstant ifTrue: [self removeRow: av.  ^nil].
		entryVar := e anyVariable.
		self pivot: entryVar exitVar: av].
	"av should be parametric at this point"
	self removeParametricVar: av.
	"remove the temporary objective function"
	self removeRow: az.
]

{ #category : #adding }
ClSimplexSolver >> beginEdit [
	"ACTION
		Do any needed setup to begin editing.  The sequence of calls should be:
					solver addEditVar: v1; addEditVar: v2;  ... etc.
					solver beginEdit.
	Then repeat each time new values are provided for the editted variables:
					solver suggestValue: v1 newvalue: nv1.
					solver suggestValue: v2 newvalue: nv2.
					solver resolve.
		Then to terminate editing:
					solver endEdit.

	"

	self newEditConstants: (Array new: self editVars size).
]

{ #category : #adding }
ClSimplexSolver >> chooseSubject: expr [
	"ACTION
		We are trying to add the constraint expr=0 to the tableaux.  Try to choose a subject 
		(a variable to become basic) from among the current variables
		in expr.  If expr contains any unrestricted variables, then we must choose 
		an unrestricted variable as the subject.  Also, if the
		subject is new to the solver we won't have to do any substitutions, so we prefer new variables
		to ones that are currently noted as parametric.  If expr contains only restricted 
		variables, if there is a restricted variable with a negative coefficient that is new to the solver
		we can make that the subject.  Otherwise 
		we can't find a subject, so return nil.  (In this last case we have to add an artificial variable
		and use that variable as the subject -- this is done outside this method though.)

		Note:  in checking for variables that are new to the solver, we ignore whether a variable occurs
		in the objective function, since new slack variables are added to the objective function by 
		'makeExpression:', which is called before this method.

	PARAMETERS
		expr <ClLinearExpression>
	RETURNS
		<ClAbstractVariable | nil>
	"
		| subject foundUnrestricted foundNewRestricted col coeff |
	"The temporaries are as follows:
		subject <ClAbstractVariable | nil> -- nil or the current best subject
		foundUnrestricted <Boolean> -- true if we have found a subject that is an unrestricted variable
		foundNewRestricted <Boolean> -- true if we have found a restricted variable that is new to the solver
			(except for being in the objective function) and that has a negative coefficient."

	foundUnrestricted := false.  foundNewRestricted := false.
	expr variablesAndCoefficientsDo: [:v :c | 
		foundUnrestricted 
			ifTrue: [
				"We have already found an unrestricted variable.  The only time we will want to use v instead of
					the current choice 'subject' is if v is unrestricted and new to the solver and 'subject' isn't new.
					If this is the case just pick v immediately and return."
				v isRestricted ifFalse: [(self columns includesKey: v) ifFalse: [^v]]]
			ifFalse: [
				"we haven't found an unrestricted variable yet"
				v isRestricted 
					ifTrue: [
						"v is restricted.  If we have already found a suitable restricted variable just stick with that.
							Otherwise, if v is new to the solver and has a negative coefficient pick it.  Regarding being
							new to the solver -- if the variable occurs only in the objective function we regard it as being
							new to the solver, since error variables are added to the objective function when we make
							the expression.  We also never pick a dummy variable here."
						(foundNewRestricted not and: [v isDummy not and: [c<0.0]]) ifTrue: [
							col := self columns at: v ifAbsent: [nil].
							(col isNil or: [col size=1 and: [col includes: self objective]]) ifTrue: [
								subject := v.
								foundNewRestricted := true]]]
					ifFalse: [
						"v is unrestricted.  If v is also new to the solver just pick it now"
						(self columns includesKey: v) ifFalse: [^v].
						subject := v.
						foundUnrestricted := true]]].

	subject isNil ifFalse: [^subject].
	"subject is nil.  Make one last check -- if all of the variables in expr are dummy 
		variables, then we can pick a dummy variable as the subject."
	expr variablesAndCoefficientsDo: [:v :c | 
		v isDummy ifFalse: [^nil   "nope - no luck"].
		"if v is new to the solver tentatively make it the subject"
		(self columns includesKey: v) ifFalse: [subject := v.  coeff := c]].
	"If we get this far, all of the variables in the expression should be dummy variables.  If the
		constant is nonzero we are trying to add an unsatisfiable required constraint.  (Remember
		that dummy variables must take on a value of 0.)  Otherwise, if the constant is zero, 
		multiply by -1 if necessary to make the coefficient for the subject negative."
	(expr constant clApproxZero) ifFalse: [ClRequiredFailure signal].
	coeff > 0 ifTrue: [
		expr terms keysAndValuesDo: [:v :c | expr terms at: v put: 0.0-c]].
	^subject
]

{ #category : #adding }
ClSimplexSolver >> columns [
	"ACTION
		Return the dictionary of column cross-indices.  The keys are parametric variables and the values are 
		sets of basic variables.  For each parametric variable p, the set should include all the basic variables
		whose expression includes p.  The columns may be either restricted or unrestricted variables (they
		are intermixed in the one tableau).
	RETURNS
		<LookupTable keys: ClAbstractVariable values: (Set of ClAbstractVariable)>
	"	
	^columns
]

{ #category : #adding }
ClSimplexSolver >> columns: cols [
	"ACTION
		See 'columns'.
	PARAMETERX
		cols <LookupTable keys: ClAbstractVariable values: (Set of ClAbstractVariable)>
	"	
	columns := cols
]

{ #category : #adding }
ClSimplexSolver >> deltaEditConstant: delta plusErrorVar: plusErrorVar minusErrorVar: minusErrorVar [
	"first check if the plusErrorVar is basic"
	self rows at: plusErrorVar ifPresent: [:expr | 
		expr incrementConstant: delta.
		"error variables are always restricted -- so the row is infeasible if the constant is negative"
		expr constant < 0.0 ifTrue: [self infeasibleRows add: plusErrorVar].
		^nil].
	"check if minusErrorVar is basic"
	self rows at: minusErrorVar ifPresent: [:expr | 
		expr incrementConstant: 0.0-delta.
		expr constant < 0.0 ifTrue: [self infeasibleRows add: minusErrorVar].
		^nil].
	"Neither is basic.  So they must both be nonbasic, and will both occur in exactly the same expressions.
	 Find all the expressions in which they occur by finding the column for the minusErrorVar (it doesn't matter
	 whether we look for that one or for plusErrorVar).  Fix the constants in these expressions."
	(self columns at: minusErrorVar) do: [:basicVar || expr c |
		expr := self rows at: basicVar.
		c := expr coefficientFor: minusErrorVar.
		expr incrementConstant: c*delta.
		(basicVar isRestricted and: [expr constant < 0.0]) ifTrue: [self infeasibleRows add: basicVar]].
]

{ #category : #adding }
ClSimplexSolver >> dualOptimize [
	"We have set new values for the constants in the edit constraints.  Re-optimize using the dual simplex algorithm."
		| zRow exitVar entryVar ratio r zc |
	zRow := self rows at: objective.
	[self infeasibleRows isEmpty] whileFalse: [
		exitVar := self infeasibleRows removeFirst.
		"exitVar might have become basic after some other pivoting, so allow for the case 
		  of its not being there any longer"
		self rows at: exitVar ifPresent: [:expr |
			"make sure the row is still not feasible"
			expr constant < 0.0 ifTrue: [
				ratio := nil.
				expr variablesAndCoefficientsDo: [:v :c |
					(c>0.0 and: [v isPivotable]) ifTrue: [
						zc := zRow terms at: v ifAbsent: [nil].
						r := zc isNil ifTrue: [ClSymbolicWeight zero] ifFalse: [zc/c].
						(ratio isNil or: [r < ratio]) ifTrue: [entryVar := v.  ratio := r]]].
				ratio isNil ifTrue: [ ClInternalError signal ].
				self pivot: entryVar exitVar: exitVar]]]
]

{ #category : #adding }
ClSimplexSolver >> editConstraints [
	"An array of ClEditConstraints for the variables being edited.  These must be in the 
		same order as editVars, editPlusErrorVars, and editMinusErrorVars."
	^editConstraints
]

{ #category : #adding }
ClSimplexSolver >> editConstraints: cns [
	editConstraints := cns
]

{ #category : #adding }
ClSimplexSolver >> editMinusErrorVars [
	"The array of negative error vars for the edit constraints.  These must be in the same order
		as editPlusErrorVars, editVars, and editConstraints."
	^editMinusErrorVars
]

{ #category : #adding }
ClSimplexSolver >> editMinusErrorVars: s [
	editMinusErrorVars := s
]

{ #category : #adding }
ClSimplexSolver >> editPlusErrorVars [
	"The array of positive error vars for the edit constraints.  These must be in the same order
		as editMinusErrorVars, editVars, and editConstraints."
	^editPlusErrorVars
]

{ #category : #adding }
ClSimplexSolver >> editPlusErrorVars: s [
	editPlusErrorVars := s
]

{ #category : #adding }
ClSimplexSolver >> editVars [
	"The array of variables being edited.  These must be in the same order as editConstraints,
		editPlusErrorVars, and editMinusErrorVars."
	^editVars
]

{ #category : #adding }
ClSimplexSolver >> editVars: evars [
	"ACTION
		See editVars
	"
	editVars := evars
]

{ #category : #adding }
ClSimplexSolver >> endEdit [
	"ACTION
		Do any needed cleanup after editing.  (See beginEdit for the sequence of calls.)
	"

	self editConstraints do: [:cn | self removeConstraint: cn].
	self editVars: #( ).
	self editConstraints: #( ).
]

{ #category : #adding }
ClSimplexSolver >> errorVars [
	"ACTION
		Return a lookup table giving the error variables for a non-required constraint.

	RETURNS
		<LookupTable keys: <ClConstraint> values: <Array of: ClSlackVariable>>
	"
	^errorVars
]

{ #category : #adding }
ClSimplexSolver >> errorVars: evars [
	"ACTION
		See errorVars
	"
	errorVars := evars
]

{ #category : #adding }
ClSimplexSolver >> findEditErrorIndex: eVars [
	"find the index in editPlusErrorVars of one of the variables in eVars"
		| index |
	eVars do: [:v |
		index := self editPlusErrorVars indexOf: v.
		index > 0 ifTrue: [^index]].
	ClInternalError signal  "didn't find a variable"
]

{ #category : #adding }
ClSimplexSolver >> infeasibleRows [
	"ACTION
		Return the collection of basic variables that have infeasible rows (used when re-optimizing).
	RETURNS
		<OrderedCollection of ClSlackVariable>
	"	
	^infeasibleRows
]

{ #category : #adding }
ClSimplexSolver >> infeasibleRows: r [
	"ACTION
		See 'infeasibleRows'
	PARAMETERS
		r <OrderedCollection of ClSlackVariable>
	"	
	infeasibleRows := r
]

{ #category : #adding }
ClSimplexSolver >> initialize [
		| zRow |
	zRow := ClLinearExpression newWithSymbolicWeight.
	self rows: Dictionary new;
		columns: Dictionary new;
		objective: (ClObjectiveVariable newNamed: 'z');
		infeasibleRows: OrderedCollection new;
		prevEditConstants: Array new;
		stayPlusErrorVars: Array new;
		stayMinusErrorVars: Array new;
		editVars: Array new;
		editConstraints: Array new;
		editPlusErrorVars: Array new;
		editMinusErrorVars: Array new;
		markerVars: Dictionary new;
		errorVars: Dictionary new.
	self rows at: self objective put: zRow.
	slackCounter :=0.  artificialCounter := 0.  dummyCounter := 0.
]

{ #category : #'as yet unclassified' }
ClSimplexSolver >> makeExpression: cn [
    "ACTION
        Make a new linear expression representing the constraint cn, replacing any basic variables
        with their defining expressions.  Normalize if necessary so that the constant is non-negative.
        If the constraint is non-required give its error variables an appropriate weight in the objective function.

    PARAMETERS
        cn <ClLinearConstraint>
    "
        | expr cnExpr e slackVar dummyVar eplus eminus zRow |
    expr := ClLinearExpression new.
    cnExpr := cn expression.
    expr constant: cnExpr constant.
    cnExpr variablesAndCoefficientsDo: [:v :c |
        e := self rows at: v ifAbsent: [nil].
        e isNil ifTrue: [expr addVariable: v coefficient: c] ifFalse: [expr addExpression: e times: c]].
    "add slack and error variables as needed"
    cn isInequality
        ifTrue: [
            "cn is an inequality, so add a slack variable.  The original constraint is expr>=0, so that the
                resulting equality is expr-slackVar=0.  If cn is also non-required add a negative error variable,
                giving expr-slackVar = -errorVar, in other words expr-slackVar+errorVar=0.  Since both of these
                variables are newly created we can just add them to the expression (they can't be basic)."
            slackCounter := slackCounter + 1.
            slackVar := ClSlackVariable newNamed: 's' , slackCounter printString.
            expr terms at: slackVar put: -1.0.
            "index the constraint under its slack variable"
            self markerVars at: cn put: slackVar.
            cn isRequired ifFalse:
                [slackCounter := slackCounter + 1.
                eminus := ClSlackVariable newNamed: 'em' , slackCounter printString.
                expr terms at: eminus put: 1.0.
                "add eminus to the objective function with the appropriate weight"
                zRow := self rows at: self objective.
                zRow terms at: eminus put: cn strength symbolicWeight * cn weight.
                self errorVars at: cn put: (Array with: eminus).
                self noteAddedVariable: eminus subject: self objective]]
        ifFalse: ["cn is an equality"
            cn isRequired
                ifTrue: [
                    "Add a dummy variable to the expression to serve as a marker for this constraint.  The dummy variable
                        is never allowed to enter the basis when pivoting."
                    dummyCounter := dummyCounter + 1.
                    dummyVar := ClDummyVariable newNamed: 'd' , dummyCounter printString.
                    expr terms at: dummyVar put: 1.0.
                    self markerVars at: cn put: dummyVar]
                ifFalse: [
                    "cn is a non-required equality.  Add a positive and a negative error variable, making the
                        resulting constraint expr = eplus - eminus, in other words expr-eplus+eminus=0"
                    slackCounter := slackCounter + 1.
                    eplus := ClSlackVariable newNamed: 'ep' , slackCounter printString.
                    eminus := ClSlackVariable newNamed: 'em' , slackCounter printString.
                    expr terms at: eplus put: -1.0.
                    expr terms at: eminus put: 1.0.
                    self markerVars at: cn put: eplus.
                    zRow := self rows at: self objective.
                    zRow terms at: eplus put: cn strength symbolicWeight * cn weight.
                    self noteAddedVariable: eplus subject: self objective.
                    zRow terms at: eminus put: cn strength symbolicWeight * cn weight.
                    self errorVars at: cn put: (Array with: eplus with: eminus).
                    self noteAddedVariable: eminus subject: self objective.
                    cn isStayConstraint ifTrue: [
                        self stayPlusErrorVars: (self stayPlusErrorVars copyWith: eplus).
                        self stayMinusErrorVars: (self stayMinusErrorVars copyWith: eminus)].
                    cn isEditConstraint ifTrue: [
                        self editVars: (self editVars copyWith: cn variable).
                        self editConstraints: (self editConstraints copyWith: cn).
                        self editPlusErrorVars: (self editPlusErrorVars copyWith: eplus).
                        self editMinusErrorVars: (self editMinusErrorVars copyWith: eminus).
                        self prevEditConstants: (self prevEditConstants copyWith: cnExpr constant)]]].
    "The constant in the expression should be non-negative.  If necessary normalize the expression
        by multiplying by -1."
    expr constant < 0 ifTrue: [
        expr constant: 0.0-expr constant.
        expr terms keysAndValuesDo: [:v :c | expr terms at: v put: 0.0-c]].
    ^expr
]

{ #category : #adding }
ClSimplexSolver >> markerVars [
	"ACTION
		Return a lookup table giving the marker variable for each constraint (used when deleting a constraint).
	RETURNS
		<LookupTable keys: <ClConstraint> values: <ClAbstractVariable>
	"
	^markerVars
]

{ #category : #adding }
ClSimplexSolver >> markerVars: m [
	"ACTION
		See markerVars.
	PARAMETERS
		m <LookupTable keys: <ClConstraint> values: <ClAbstractVariable>
	"
	markerVars := m
]

{ #category : #adding }
ClSimplexSolver >> newEditConstants [
	"The array of constants for the edit constraints for the next iteration.  These must be in the same order
		as editPlusErrorVars and editMinusErrorVars"
	^newEditConstants
]

{ #category : #adding }
ClSimplexSolver >> newEditConstants: n [
	newEditConstants := n
]

{ #category : #adding }
ClSimplexSolver >> noteAddedVariable: var subject: subject [
	"ACTION
		Variable var has been added to an expression.  If the expression is in a tableau the corresponding
		basic variable is subject (or if subject is nil then it's in the objective function).  Update the column cross-indices.
	PARAMETERS
		var <ClAbstractVariable>
		subject <ClAbstractVariable | nil>
	"
	subject notNil ifTrue: [(self columns at: var ifAbsentPut: [Set new]) add: subject]
]

{ #category : #adding }
ClSimplexSolver >> noteRemovedVariable: var subject: subject [
	"ACTION
		Variable var has been removed from an expression.  If the expression is in a tableau the corresponding
		basic variable is subject (or if subject is nil then it's in the objective function).  Update the column cross-indices.
	PARAMETERS
		var <ClAbstractVariable>
		subject <ClAbstractVariable | nil>
	"
	subject notNil ifTrue: [(self columns at: var) remove: subject]
]

{ #category : #adding }
ClSimplexSolver >> objective [
	"ACTION
		Return the objective function.
	RETURNS
		<ClLinearExpression>
	"
	^objective
]

{ #category : #adding }
ClSimplexSolver >> objective: expr [
	"ACTION
		Set the objective function.
	PARAMETERS
		expr <ClLinearExpression>
	"
	objective := expr
]

{ #category : #adding }
ClSimplexSolver >> optimize: zVar [
	"ACTION
		Minimize the value of the objective.  (The tableau should already be feasible.)
	PARAMETERS
		zVar <ClObjectiveVariable>
	"
		| zRow objectiveCoeff minRatio exitVar entryVar r expr coeff |
	zRow := self rows at: zVar.
	[true] whileTrue: [
		"Find the most negative coefficient in the objective function (ignoring dummy variables).
		  If all coefficients are positive we're done"
		objectiveCoeff := nil.
		zRow variablesAndCoefficientsDo: [:v :c | 
			(v isPivotable and: [objectiveCoeff isNil or: [c < objectiveCoeff]]) ifTrue: [objectiveCoeff := c.  entryVar := v]].
		"if all coefficients were positive (or if the objective function has no pivotable variables) we are at optimum"
		objectiveCoeff isNil ifTrue: [^nil].
		objectiveCoeff approxNonNegative ifTrue: [^nil].
		"Choose which variable to move out of the basis.  Only consider pivotable basic variables (that is,
			restricted, non-dummy variables)."
		minRatio := nil.
		(self columns at: entryVar) do: [:v | v isPivotable ifTrue: [
			expr := self rows at: v.
			coeff := expr coefficientFor: entryVar.
			"only consider negative coefficients"
			coeff < 0.0 ifTrue: [
				r := 0.0 - (expr constant / coeff).
				(minRatio isNil or: [r<minRatio]) ifTrue: [minRatio := r.  exitVar := v]]]].
		"If minRatio is still nil at this point, it means that the objective function is unbounded, i.e. it can 
			become arbitrarily negative.  This should never happen in this application."
		minRatio isNil ifTrue: [ClInternalError signal].
		self pivot: entryVar exitVar: exitVar]
]

{ #category : #adding }
ClSimplexSolver >> pivot: entryVar exitVar: exitVar [
	"Do a pivot.  Move entryVar into the basis (i.e. make it a basic variable), and move exitVar out of the basis 
	 (i.e. make it a parametric variable)."
		| expr |
	"expr is the expression for the exit variable (about to leave the basis) -- so that the old tableau includes the
	 equation exitVar = expr"
	expr := self removeRow: exitVar.
	"Compute an expression for the entry variable.  Since expr has been deleted from the tableau we can
	  destructively modify it to build this expression."
	expr changeSubject: exitVar newSubject: entryVar.
	self substituteOut: entryVar expr: expr.
	self addRow: entryVar expr: expr.
]

{ #category : #adding }
ClSimplexSolver >> prevEditConstants [
	"The array of constants for the edit constraints on the previous iteration.  These must be in the same order
		as editPlusErrorVars and editMinusErrorVars"
	^prevEditConstants
]

{ #category : #adding }
ClSimplexSolver >> prevEditConstants: p [
	prevEditConstants := p
]

{ #category : #adding }
ClSimplexSolver >> removeConstraint: cn [
	"ACTION
		Remove the constraint cn to the tableau.  Also remove any error variables associated with cn.

	PARAMETERS
		cn <ClLinearConstraint>
	"
		| eVars zRow obj marker col minRatio expr coeff r exitVar 
				oldEditMinusErrorVars oldEditPlusErrorVars oldPrevEditConstants oldSize index |
	"We are about to remove a constraint.  There may be some stay constraints that were unsatisfied previously --
		if we just removed the constraint these could come into play.  Instead, reset all of the stays so that things
		should stay where they are at the moment."
	self resetStayConstants.

	"remove any error variables from the objective function"
	eVars := self errorVars removeKey: cn ifAbsent: [#( )].
	zRow := self objective.
	obj := self rows at: zRow.
	eVars do: [:v | 
		expr := self rows at: v ifAbsent: [nil].
		expr isNil
			ifTrue: [obj addVariable: v coefficient: -1.0*cn weight*cn strength symbolicWeight subject: zRow solver: self]
			ifFalse: [obj addExpression: expr times: -1.0*cn weight*cn strength symbolicWeight subject: zRow solver: self]].

	marker := self markerVars removeKey: cn.
	"try to make the marker variable basic if it isn't already"
	(self rows includesKey: marker) ifFalse: [
		"Choose which variable to move out of the basis.  Only consider restricted basic variables."
		col := self columns at: marker.
		col do: [:v | v isRestricted ifTrue: [
			expr := self rows at: v.
			coeff := expr coefficientFor: marker.
			"only consider negative coefficients"
			coeff < 0.0 ifTrue: [
				r := 0.0 - (expr constant / coeff).
				(exitVar isNil or: [r<minRatio]) ifTrue: [minRatio := r.  exitVar := v]]]].
		"If exitVar is still nil at this point, then either the marker variable has a positive coefficient in all equations,
			or it only occurs in equations for unrestricted variables.  If it does occur in an equation for a restricted
			variable, pick the equation that gives the smallest ratio.  (The row with the marker variable will become 
			infeasible, but all the other rows will still be feasible; and we will be dropping the row with the marker 
			variable.  In effect we are removing the non-negativity restriction on the marker variable.)"
		exitVar isNil ifTrue: [
			col do: [:v | v isRestricted ifTrue: [
				expr := self rows at: v.
				coeff := expr coefficientFor: marker.
				r := expr constant / coeff.
				(exitVar isNil or: [r<minRatio]) ifTrue: [minRatio := r.  exitVar := v]]]].
		exitVar isNil
			ifTrue: [
				"exitVar is still nil.  If col is empty, then exitVar doesn't occur in any equations, so just remove it.
				  Otherwise pick an exit var from among the unrestricted variables whose equation involves the 
				  marker var."
				col isEmpty
					ifTrue: [self removeParametricVar: marker]
					ifFalse: [exitVar := col asOrderedCollection first]].
			exitVar notNil ifTrue: [self pivot: marker exitVar: exitVar]].

	(self rows includesKey: marker) ifTrue: [self removeRow: marker].
	"Delete any error variables.  If cn is an inequality, it also contains a slack variable; but we use that as the
		marker variable and so it has been deleted when we removed its row."
	eVars do: [:v | v=marker ifFalse: [self removeParametricVar: v]].
	cn isStayConstraint ifTrue: [
		self stayPlusErrorVars: (self stayPlusErrorVars reject: [:v | eVars includes: v]).
		self stayMinusErrorVars: (self stayMinusErrorVars reject: [:v | eVars includes: v])].
	cn isEditConstraint ifTrue: [
		"find the index in editPlusErrorVars of the error variable for this constraint"
		index := self findEditErrorIndex: eVars.
		oldSize := self editPlusErrorVars size.
		"remove the error variables from editPlusErrorVars and editMinusErrorVars"
		oldEditPlusErrorVars := self editPlusErrorVars.
		self editPlusErrorVars: (Array new: oldSize-1).
		1 to: index-1 do: [:i | self editPlusErrorVars at: i put: (oldEditPlusErrorVars at: i)].
		index+1 to: oldSize do: [:i | self editPlusErrorVars at: i-1 put: (oldEditPlusErrorVars at: i)].
		oldEditMinusErrorVars := self editMinusErrorVars.
		self editMinusErrorVars: (Array new: oldSize-1).
		1 to: index-1 do: [:i | self editMinusErrorVars at: i put: (oldEditMinusErrorVars at: i)].
		index+1 to: oldSize do: [:i | self editMinusErrorVars at: i-1 put: (oldEditMinusErrorVars at: i)].
		"remove the constants from prevEditConstants"
		oldPrevEditConstants := self prevEditConstants.
		self prevEditConstants: (Array new: oldSize-1).
		1 to: index-1 do: [:i | self prevEditConstants at: i put: (oldPrevEditConstants at: i)].
		index+1 to: oldSize do: [:i | self prevEditConstants at: i-1 put: (oldPrevEditConstants at: i)]].

	self optimize: zRow.
	self setExternalVariables.
]

{ #category : #adding }
ClSimplexSolver >> removeParametricVar: var [
	"ACTION
		Remove the parametric variable var, updating the appropriate column and row entries.
	PARAMETERS
		var <ClAbstractVariable>
	"
		| set |
	set := self columns removeKey: var.
	set do: [:v | (self rows at: v) terms removeKey: var]
]

{ #category : #adding }
ClSimplexSolver >> removeRow: var [ 
	"ACTION
		var should be a basic variable, so that the tableau contains the constraint var=expr.  Remove this row,
		and update the column cross-indices.  Also remove it from infeasibleRows if present.  Return expr.
	PARAMETERS
		var <ClAbstractVariable>
	RETURNS
		<ClLinearExpression>
	"
		| expr |
	expr := self rows removeKey: var.
	expr terms keysDo: [:v | (self columns at: v) remove: var].
	self infeasibleRows remove: var ifAbsent: [ ].
	^expr
]

{ #category : #adding }
ClSimplexSolver >> reset [
	"ACTION
		Re-initialize this solver from the original constraints, thus getting rid of any accumulated 
		numerical problems.  (Actually I haven't observed any such problems yet, but here's the
		method anyway.)
	"
		| edits stays others i |
	edits := Array new: self editPlusErrorVars size.
	stays := OrderedCollection new.
	others := OrderedCollection new.
	self markerVars keysAndValuesDo: [:cn :v | 
		cn isEditConstraint
			ifTrue: [
				"put the edit constraint in the same place in 'edits' as it is in the current
				  array of edit error vars"
				i := self editPlusErrorVars indexOf: v ifAbsent: [self editMinusErrorVars indexOf: v ].
				edits at: i put: cn]
			ifFalse: [
				cn isStayConstraint ifTrue: [stays add: cn] ifFalse: [others add: cn]]].
	self initialize.
	"add the stays first so that variables keep their old values"
	stays do: [:cn | self addConstraint: cn].
	"add the edits in the same order they were in originally"
	edits do: [:cn | self addConstraint: cn].
	others do: [:cn | self addConstraint: cn]
]

{ #category : #adding }
ClSimplexSolver >> resetEditConstants [
	"ACTION
		Each of the non-required edits will be represented by an equation of the form
			v = c + eplus - eminus
		where v is the variable with the edit, c is the previous edit value, and eplus and eminus 
		are slack variables that hold the error in satisfying the edit constraint.  We are about to
		change something, and we want to fix the constants in the equations representing the
		edit constraints.  If one of eplus and eminus is basic, the other must occur only in the
		expression for that basic error variable.  (They can't both be basic.)  Fix the constant in
		this expression.  Otherwise they are both nonbasic.  Find all of the expressions in which
		they occur, and fix the constants in those.  See the UIST paper for details.
	"
		| delta nn pp |
	self newEditConstants size = self editPlusErrorVars size ifFalse: [
		"number of edit constants doesn't match the number of edit error variables"
		ClInternalError signal].
	1 to: self newEditConstants size do: [:i |


nn := self newEditConstants.
pp := self prevEditConstants.
nn isNil ifTrue: [self halt].
self prevEditConstants isNil ifTrue: [self halt].
 (self newEditConstants at: i)  isNil ifTrue: 
[Transcript cr; show: self newEditConstants printString.
self halt].
 (self prevEditConstants at: i) isNil ifTrue: [self halt].


		delta := (self newEditConstants at: i) - (self prevEditConstants at: i).
		self prevEditConstants at: i put: (self newEditConstants at: i).
		self 
			deltaEditConstant: delta
			plusErrorVar: (self editPlusErrorVars at: i)
			minusErrorVar: (self editMinusErrorVars at: i)].
]

{ #category : #adding }
ClSimplexSolver >> resetStayConstants [
	"ACTION
		Each of the non-required stays will be represented by an equation of the form
			v = c + eplus - eminus
		where v is the variable with the stay, c is the previous value of v, and eplus and eminus 
		are slack variables that hold the error in satisfying the stay constraint.  We are about to
		change something, and we want to fix the constants in the equations representing the stays.
		If both eplus and eminus are nonbasic they have value 0 in the current solution, meaning the 
		previous stay was exactly satisfied.  In this case nothing needs to be changed.  Otherwise one
		of them is basic, and the other must occur only in the expression for that basic error variable.
		Reset the constant in this expression to 0.
	"
		| expr |
	1 to: self stayPlusErrorVars size do: [:i | 
		expr := self rows at: (self stayPlusErrorVars at: i) ifAbsent: [
				self rows at: (self stayMinusErrorVars at: i) ifAbsent: [nil]].
		expr notNil ifTrue: [expr constant: 0.0]]
]

{ #category : #adding }
ClSimplexSolver >> resolve [
	"ACTION
		Re-solve the current collection of constraints for the new values in newEditConstants.
	"

	self infeasibleRows: OrderedCollection new.
	self resetStayConstants.
	self resetEditConstants.
	self dualOptimize.
	self setExternalVariables.
]

{ #category : #adding }
ClSimplexSolver >> resolve: cs [
	"ACTION
		Re-solve the current collection of constraints for new values for the constants of the edit variables.
	PARAMETERS
		cs <Array of Float>
	"

	self newEditConstants: cs.
	self resolve.
]

{ #category : #adding }
ClSimplexSolver >> rows [
	"ACTION
		Return the dictionary of rows in the tableau.  The keys are basic variables and the values are 
		the corresponding expressions.  Both unrestricted and restricted variables are included in the one tableau
		(i.e. the keys may be either restricted or unrestricted variables).
	RETURNS
		<LookupTable keys: ClAbstractVariable values: ClLinearExpression>
	"	
	^rows
]

{ #category : #adding }
ClSimplexSolver >> rows: r [
	"ACTION
		See 'rows'.
	PARAMETERS
		r <LookupTable keys: ClAbstractVariable values: ClLinearExpression>
	"	
	rows := r
]

{ #category : #adding }
ClSimplexSolver >> setExternalVariables [
	"ACTION
		Set the external variables known to this solver to their appropriate values.

	PARAMETERS
	"

	"Set each external basic variable to its value, and set each external parametric variable to 0.
		(It isn't clear that we will ever have external parametric variables -- every external variable
		should either have a stay on it, or have an equation that defines it in terms of other external
		variables that do have stays.  For the moment I'll put this in though.)  Variables that are internal
		to the solver don't actually store values -- their values are just implicit in the tableu -- so
		we don't need to set them."
	self rows keysAndValuesDo: [:var :expr | var isExternal ifTrue: [var value: expr constant]].
	self columns keysDo: [:var | var isExternal ifTrue: [var value: 0.0]].
]

{ #category : #adding }
ClSimplexSolver >> stayMinusErrorVars [
	"an array of negative error variables for the stay constraints.  The
	 corresponding positive error is in the same place in stayPlusErrorVars"
	^stayMinusErrorVars
]

{ #category : #adding }
ClSimplexSolver >> stayMinusErrorVars: vs [
	stayMinusErrorVars := vs
]

{ #category : #adding }
ClSimplexSolver >> stayPlusErrorVars [
	"an array of plus error variables for the stay constraints.  The
	 corresponding negative error is in the same place in stayMinusErrorVars"
	^stayPlusErrorVars
]

{ #category : #adding }
ClSimplexSolver >> stayPlusErrorVars: vs [
	stayPlusErrorVars := vs
]

{ #category : #adding }
ClSimplexSolver >> substituteOut: oldVar expr: expr [
	"replace all occurrences of oldVar with expr (including in the objective function), and update the 
	  column cross-references.  oldVar should now be a basic variable."
		| col row |
	col := self columns removeKey: oldVar.
	col do: [:v | 
		row := self rows at: v.
		row substituteOut: oldVar expr: expr subject: v solver: self.
		(v isRestricted and: [row constant<0.0]) ifTrue: [self infeasibleRows add: v]].
]

{ #category : #adding }
ClSimplexSolver >> suggestValue: var newValue: val [
	"ACTION
		We should be editting var.  Suggest a new value for it.
	PARAMETERS
		var <ClVariable>
		val <Float>
	"
	1 to: self editVars size do: [:i | 
		(editVars at: i) == var ifTrue: [self newEditConstants at: i put: val.  ^self]].
	ClInternalError signal: 'variable not currently being edited'
]

{ #category : #adding }
ClSimplexSolver >> tryAddingDirectly: expr [
	"ACTION
		We are trying to add the constraint expr=0 to the appropriate tableau.  Try to add expr directly to the tableax
		without creating an artificial variable.  Return true if successful and false if not.
	PARAMETERS
		expr <ClLinearExpresson>
	RETURNS
		<Boolean>
	"
		| subject |		
	"If possible choose a subject for expr (a variable to become basic) from among the current variables
		in expr.  If this isn't possible, add an artificial variable and use that variable as the subject."
	subject := self chooseSubject: expr.
	subject isNil ifTrue: [^false].
	expr newSubject: subject.
	(self columns includesKey: subject) ifTrue: [self substituteOut: subject expr: expr].
	self addRow: subject expr: expr.
	^true
]
