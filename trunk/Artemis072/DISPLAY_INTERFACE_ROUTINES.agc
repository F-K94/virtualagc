### FILE="Main.annotation"
## Copyright:	Public domain.
## Filename:	DISPLAY_INTERFACE_ROUTINES.agc
## Purpose:	Part of the source code for Artemis (i.e., Colossus 3),
##		build 072.  This is for the Command Module's (CM)
##		Apollo Guidance Computer (AGC), we believe for
##		Apollo 15-17.
## Assembler:	yaYUL
## Contact:	Jim Lawton <jim DOT lawton AT gmail DOT com>
## Website:	www.ibiblio.org/apollo/index.html
## Page scans:	www.ibiblio.org/apollo/ScansForConversion/Artemis072/
## Mod history:	2009-08-18 JL	Adapted from corresponding Comanche 055 file.
## 		2010-01-31 JL	Removed obsolete meta-comment.
## 		2010-02-01 JL	Fixed build errors.
##		2010-02-11 JL	Fixed error on p1465.

## Page 1448

# DISPLAYS CAN BE CLASSIFIED INTO THE FOLLOWING CATEGORIES -
#
#	1. PRIORITY DISPLAYS - DISPLAYS WHICH TAKE PRIORITY OVER ALL OTHER DISPLAYS. USUALLY THESE DISPLAYS ARE SENT
#	   OUT UNDER CRITICAL ALARM CONDITIONS.
#	2. EXTENDED VERB DISPLAYS - ALL EXTENDED VERBS AND MARK ROUTINES SHOULD USE EXTENDED VERB (MARK) DISPLAYS.
#	3. NORMAL DISPLAYS - ALL MISSION PROGRAM DISPLAYS WHICH INTERFACE WITH THE ASTRONAUT DURING THE NORMAL
#	   SEQUENCE OF EVENTS.
#	4. MISC. DISPLAYS - ALL DISPLAYS NOT HANDLED BY THE DISPLAY INTERFACE ROUTINES. THESE INCLUDE SUCH DISPLAYS AS
#	   MM DISPLAYS AND SPECIAL PURPOSE DISPLAYS HANDLED BY PINBALL.
#	5. ASTRONAUT INITIATED DISPLAYS - ALL DISPLAYS INITIATED EXTERNALLY.
#
# THE FOLLOWING TERMS ARE USED TO DESCRIBE THE STATUS OF DISPLAYS -
#
#	1. ACTIVE - THE DISPLAY WHICH IS (1) BEING DISPLAYED TO THE ASTRONAUT AND WAITING FOR A RESPONSE OR
#	   (2) WAITING FIRST IN LINE FOR THE ASTRONAUT TO FINISH USING THE DSKY OR (3) BEING DISPLAYED ON THE DSKY
#	   BUT NOT WAITING FOR A RESPONSE.
#	2. INACTIVE - A DISPLAY WHICH HAS (1) BEEN ACTIVE BUT WAS INTERRUPTED BY A DISPLAY OF HIGHER PRIORITY,
#	   (2) BEEN PUT INTO THE WAITING LIST AT TIME IT WAS REQUESTED DUE TO THE FACT A HIGHER PRIORITY DISPLAY
#	   WAS ALREADY GOING, (3) BEEN INTERRUPTED BY THE ASTRONAUT (CALLED A PINBRANCH CONDITION, SINCE THIS TYPE
#	   OF INACTIVE DISPLAY IS USUALLY REACTIVATED ONLY BY PINBALL) OR (4) A DISPLAY WHICH HAS FINISHED BUT STILL
#	   HAS INFO SAVED FOR RESTART PURPOSES.
#
# DISPLAY PRIORITIES WORK AS FOLLOWS -
#
#	INTERRUPTS -
#		1. THE ASTRONAUT CAN INTERRUPT ANY DISPLAY WITH AN EXTERNAL DISPLAY REQUEST.
#		2. INTERNAL DISPLAYS CAN NOT BE SENT OUT WHEN THE ASTRONAUT IS USING THE DSKY.
#		3. PRIORITY DISPLAYS INTERRUPT ALL OTHER TYPES OF INTERNAL DISPLAYS. A PRIORITY DISPLAY INTERRUPTING ANOTHER
#		   PRIORITY DISPLAY WILL CAUSE AN ABORT UNLESS BIT14 IS SET FOR THE LINUS ROUTINE.
#		4. A MARK DISPLAY INTERRUPTS ANY NORMAL DISPLAY.
#		5. A MARK THAT INTERRUPTS A MARK COMPLETELY REPLACES IT.
#
# 	ORDER OF WAITING DISPLAYS -
#		1.  ASTRONAUT EXTERNAL USE
#		2.  PRIORITY
#		3.  INTERRUPTED MARK
#		4.  INTERRUPTED NORMAL
#
#		5.  MARK TO BE REQUESTED (SEE DESCRIPTION OF ENDMARK)
#		6.  MARK WAITING
#		7.  NORMAL WAITING
#
## Page 1449
# THE DISPLAY ROUTINES ARE INTENDED TO SERVE AS AN INTERFACE BETWEEN THE USER AND PINBALL.  THE
# FOLLOWING STATEMENTS CAN BE MADE ABOUT NORMAL DISPLAYS AND PRIORITY DISPLAYS (A DESCRIPTION OF MARK ROUTINES
# WILL FOLLOW LATER):
#
#	1.  ALL ROUTINES THAT END IN R HAVE AN IMMEDIATE RETURN TO THE USER.  FOR ALL FLASHING DISPLAYS THIS RETURN
#	    IS TO THE USERS CALL CADR +4.  FOR THE ONLY NON-FLASHING IMMEDIATE RETURN DISPLAY (GODSPR) THIS RETURN
#	    IS TO THE USERS CALLING LOC +1.
#	2.  ALL ROUTINES NOT ENDING IN R DO NOT DO AN IMMEDIATE RETURN TO THE USER.
#	3.  ALL ROUTINES THAT END IN R START A SEPARATE JOB (MAKEPLAY) WITH USERS JOB PRIORITY.
#	4.  ALL ROUTINES NOT ENDING IN R BRANCH DIRECTLY TO MAKEPLAY WHICH MAKES THESE DISPLAYS A PART OF THE
#	    USERS JOB.
#	5.  ALL DISPLAY ROUTINES ARE CALLED VIA BANKCALL.
#	6.  TO RESTART A DISPLAY THE USER WILL GENERALLY USE A PHASE OF ONE WITH DESIRED RESTART GROUP (SEE
#	    DESCRIPTION OF RESTARTS).
#	7.  ALL FLASHING DISPLAYS HAVE 3 RETURNS TO THE USER FROM ASTRONAUT RESPOSES.  A TERMINATE (V34) BRANCHES
#	    TO THE USERS CALL CADR +1.  A PROCEED (V33) BRANCHES TO THE USERS CALL CADR +2.  AN ENTER OR RECYCLE
#	    (V32) BRANCHES TO THE USERS CALL CADR +3.
#	8.  ALL ROUTINES MUST BE USED UNDER EXECUTIVE CONTROL
#
# A DESCRIPTION OF EACH ROUTINE WITH AN EXAMPLE FOLLOWS:
#
# GODSPR IS THE SAME AS GODSP ONLY RETURN IS TO THE USER.
#
#			CAF	VXXNYY
#			TC	BANKCALL
#			CADR	GODSPR
#			...	...		# IMMEDIATE RETURN OF GODSPR
#
# GOFLASH DISPLAYS A FLASHING VERB NOUN WITH NO IMMEDIATE RETURN TO THE USER. 3 RETURNS ARE POSSIBLE FROM
# THE ASTRONAUT (SEE NO. 7 ABOVE).
#
#			CAF	VXXNYY		# VXX NYY WILL BE A FLASHING VERB NOUN.
#			TC	BANKCALL
#			CADR	GOFLASH
#			...	...		# TERMINATE RETURN
#			...	...		# PROCEED RETURN
#			...	...		# ENTER OR RECYCLE RETURN
#
# GOPERF1 IS ENTERED WITH DESIRED CHECKLIST VALUE IN A.  GOPERF1 WILL DISPLAY THIS VALUE IN R1 BY MEANS OF A
# V01 N25. A FLASHING PLEASE PERFORM ON CHECKLIST (V50 N25) IS THEN DISPLAYED.  NO IMMEDIATE RETURN IS MADE TO
# USER (SEE NO. 7 ABOVE).
# GOPERF1 BLANKS REGISTERS R2 AND R3
#
#			CAF	OCTXX		# CODE FOR CHECKLIST VALUE XX
#			TC	BANKCALL
#			CADR	GOPERF1
#			...	...		# TERMINATE RETURN
#			...	...		# PROCEED RETURN
## Page 1450
#			...	...		# ENTER RETURN
#
# GOPERF3 IS USED FOR A PLEASE PERFORM ON A PROGRAM NUMBER.  THE DESIRED PROGRAM NO. IS ENTERED IN A.  GOPERF3
# DISPLAYS THE NO. BY MEANS OF A V06 N07 FOLLOWED BY A FLASHING V50 N07 FOR A PLEASE PERFORM. NO IMMEDIATE RETURN
# IS MADE TO THE USER (SEE NO. 7 ABOVE).
# GOPERF3 BLANKS REGISTERS R2 AND R3
#
#			CAF	DECXX		# REQUEST PERFORM ON PXX
#			TC	BANKCALL
#			CADR	GOPERF3
#			...	...		# TERMINATE RETURN
#			...	...		# PROCEED RETURN
#			...	...		# ENTER RETURN
#
# GOPERF4 IS USED FOR A PLEASE PERFORM ON AN OPTION. THE DESIRED OPTION IS ENTERED IN A AND STORED IN OPTION1.
# GOPERF4 DISPLAYS R1 AND R2 BY MEANS OF A V04N06 FOLLOWED BY A FLASHING V50N06 FOR A PLEASE PERFORM. NO
# IMMEDIATE RETURN IS MADE TO THE USER (SEE NO. 7 ABOVE).
#
#			CAF	OCTXX		# REQUEST PERFORM ON OPTION XX
#			TC	BANKCALL
#			CADR	GOPERF4
#			...	...		# TERMINATE RETURN
#			...	...		# PROCEED RETURN
#			...	...		# ENTER RETURN
#
# GOPERF4 BLANKS REGISTER R3.
#
# GODSPRET IS USED TO DISPLAY A VERB NOUN ARRIVING IN A WITH A RETURN TO THE USER AFTER THE DISPLAY HAS BEEN SENT
# OUT.
#
#			CAF	VXXNYY
#			TC	BANKCALL
#			CADR	GODSPRET
#			...	...		# RETURN TO USER.
#
# REGODSP IS USED TO DISPLAY A VERB NOUN ARRIVING IN A.  REGODSP IS THE SAME AS GODSP ONLY REGODSP REPLACES ANY
# ACTIVE NORMAL DISPLAY IF ONE WAS ACTIVE.
#
#			CAF	VXXNYY
#			TC	BANKCALL
#			CADR	REGODSP
#
# REFLASH IS THE SAME AS GOFLASH ONLY REFLASH REPLACES ANY ACTIVE NORMAL DISPLAY IF ONE WAS ACTIVE.
#
#			CAF	VXXNYY		# VXX NYY WILL BE A FLASHING VERB NOUN
#			TC	BANKCALL
#			CADR	REFLASH
#			...	...		# TERMINATE RETURN
## Page 1451
#			...	...		# PROCEED RETURN
#			...	...		# ENTER RETURN
#
# GOFLASHR IF SAME AS GOFLASH ONLY AN IMMEDIATE RETURN IS MADE TO THE USERS CALL CADR +4.
#
#			CAF	VXXNYY
#			TC	BANKCALL
#			CADR	GOFLASHR
#			...	...		# TERMINATE RETURN
#			...	...		# PROCEED RETURN
#			...	...		# ENTER OR RECYCLE RETURN
#
#			...	...		# IMMEDIATE RETURN FROM GOFLASHR
#
# GOPERF1R IS THE SAME AS GOPERF1 ONLY GOPERF1R HAS AN IMMEDIATE RETURN TO USERS CALL CADR +4.
# GOPERF1R BLANKS REGISTERS R2 AND R3
#
#			CAF	OCTXX		# CODE FOR CHECKLIST VALUE XX.
#			TC	BANKCALL
#			CADR	GOPERF1R
#			...	...		# TERMINATE RETURN
#			...	...		# PROCEED RETURN
#			...	...		# ENTER RETURN
#
#			...	...		# IMMEDIATE RETURN FROM GOPERF1R
#
# GOPERF3R IS THE SAME AS GOPERF3 ONLY AN IMMEDIATE RETURN IS MADE TO USERS CALL CADR +4.
# GOPERF3R BLANKS REGISTERS R2 AND R3
#
#			CAF	PROGXX		# PERFORM PROGRAM XX
#			TC	BANKCALL
#			CADR	GOPERF3R
#			...	...		# TERMINATE RETURN
#			...	...		# PROCEED RETURN
#			...	...		# ENTER RETURN
#
#			...	...		# GOPERF3R IMMEDIATELY RETURNS HERE
#
# GOPERF4R IS THE SAME AS GOPERF4 ONLY AN IMMEDIATE RETURN IS MADE TO USERS CALL CADR +4.
#
#			CAF	OCTXX		# REQUEST PERFORM ON OPTIONXX
#			TC	BANKCALL
#			CADR	GOPERF4R
#			...	...		# TERMINATE RETURN
#			...	...		# PROCEED RETURN
#			...	...		# ENTER RETURN
#
#			...	...		# IMMEDIATE RETURN TO USER
#
## Page 1452
# GOPERF4R BLANKS REGISTER R3.
#
# REFLASHR IS THE SAME AS REFLASH ONLY AN IMMEDIATE RETURN IS MADE TO THE USERS CALL CADR +4.
#
#			CAF	VXXNYY		# VXX NYY WILL BE A FLASHING VERB NOUN
#			TC	BANKCALL
#			CADR	REFLASHR
#			...	...		# TERMINATE RETURN
#			...	...		# PROCEED RETURN
#			...	...		# ENTER RETURN
#
#			...	...		# IMMEDIATE RETURN TO USER
#
# REGODSPR IS THE SAME AS REGODSP ONLY A RETURN (IMMEDIATE) IS MADE TO THE USER.
#
#			CAF	VXXNYY
#			TC	BANKCALL
#			CADR	REGODSPR
#
#			...	...		# IMMEDIATE RETURN TO USER
#
## Page 1453
# GOMARK IS USED TO DISPLAY A MARK VERB NOUN ARRIVING IN A. NO RETURN IS MADE TO THE USER.
#
# GOMARKR IS THE SAME AS GOMARK ONLY RETURN IS TO THE USER.
#
# GOMARKF DISPLAYS A FLASHING MARK VERB NOUN WITH NO IMMEDIATE RETURN TO THE USER. 3 RETURNS ARE POSSIBLE FORM
# THE ASTRONAUT (SEE NO. 7 ABOVE).
# GOXDSPF = GOMARKF
#
#			CAF	VXXNYY		# VXXNYY WILL BE A FLASHING MARK VERB NOUN
#			TC	BANKCALL
#			CADR	GOMARKF		# OTHER EXTENDED VERBS USE CADR GOXDSPF
#			...	...		# TERMINATE RETURN
#			...	...		# PROCEED RETURN
#			...	...		# ENTER OR RECYCLE RETURN
#
# GOMARKFR IS THE SAME AS GOMARKF ONLY AN IMMEDIATE RETURN IS MADE TO THE USER CALL CADR +4.
#
# GOMARK1 IS USED FOR A PLEASE PERFORM ON A MARK REQUEST WITH ONLY 1 ASTRONAUT RETURN TO THE USER. NO IMMEDIATE
# RETURN IS MADE. THE DESIRED MARK PLEASE PERFORM VERB AND DESIRED NOUN IS ENTERED IN A. GOMARK1 DISPLAYS R1, R2, R
# MEANS OF A V05NYY FOLLOWED BY A FLASHING V5XNYY FOR A PLEASE PERFORM. THE ASTRONAUT WILL RESPOND WITH A MARK
# OR MARK REJECT OR AN ENTER. THE ENTER IS THE ONLY ASTRONAUT RESPONSE THAT WILL COME BACK TO THE USER.
#
#			CAF	V5XNYY		# X=1,2,3,4	Y=NOUN
#			TC	BANKCALL
#			CADR	GOMARK1
#
#			...	...		# ENTER RETURN
#
# *** IF BLANKING DESIRED ON NON-R ROUTINES, NOTIFY DISPLAYER.
#
# GOMARK1R IS THE SAME AS A GOMARK1 ONLY AN IMMEDIATE RETURN IS MADE TO THE USERS CALL CADR +2.
#
#			CAF	V5XNYY		# X=1,2,3,4	YY=NOUN
#			TC	BANKCALL
#			CADR	GOMARK1R
#
#			...	...		# ASTRONAUT ENTER RETURN
#			...	...		# IMMEDIATE RETURN TO USER
#
# GOMARK2 IS THE SAME AS GOMARK1 ONLY 3 RETURNS ARE MADE TO THE USER FROM THE ASTRONAUT.
#
#			CAF	V5XNYY		# X=1,2,3,4	YY=NOUN
#			TC	BANKCALL
#			CADR	GOMARK2
#			...	...		# TERMINATE RETURN
#			...	...		# PROCEED RETURN
#			...	...		# ENTER RETURN
#
# GOMARK4 IS THE SAME AS GOMARK3 ONLY R2 AND R3 ARE BLANKED AND R1 IS DISPLAYED IN OCTAL.
#
#			CAF	V5XNYY		# X=1,2,3,4	YY=NOUN
#			TC	BANKCALL
## Page 1454
#			CADR	GOMARK4
#			...	...		# TERMINATE RETURN
#			...	...		# PROCEED RETURN
#			...	...		# ENTER RETURN
#
# EXDSPRET IS USED TO DISPLAY A VERB NOUN ARRIVING IN A WITH A RETURN MADE TO THE USER AFTER THE DISPLAY HAS BEEN
# SENT OUT.
#
#			CAF	VXXNYY
#			TC	BANKCALL
#			CADR	EXDSPRET
#
#			...	...		# RETURN TO USER
#
# KLEENEX CLEANS OUT ALL MARK DISPLAYS (ACTIVE AND INACTIVE). A RETURN IS MADE TO THE USER AFTER THE MARK DISPLAYS
# HAVE BEEN CLEANED OUT.
#
#			TC	BANKCALL
#			CADR	KLEENEX
#
#			...	...		# RETURN TO USER
#
# MARKBRAN IS A SPECIAL PURPOSE ROUTINE USED FOR SAVING JOB VAC AREAS (SEE DESCRIPTION OF MARKBRAN BELOW).
#
#			TC	BANKCALL
#			CADR	MARKBRAN
#
#			...	...		# BAD RETURN IF MARK DISPLAY NOT ACTIVE
#
#						# (GOOD RETURN TO IMMEDIATE RETURN LOC OF
#						# LAST FLASHING MARK R ROUTINE)
#
# PINBRNCH REESTABLISHES THE LAST ACTIVE FLASHING DISPLAY. IF THERE IS NO ACTIVE FLASHING DISPLAY, THE DSKY IS
# BLANKED AND CONTROL IS SENT TO ENDOFJOB.
#
#				TC	POSTJUMP
#				CADR	PINBRNCH
#
# PRIODSP IS USED AS A PRIORITY DISPLAY.  IT WILL DISPLAY A GOFLASH TYPE DISPLAY WITH THREE POSSIBLE RETURNS FROM
# THE ASTRONAUT (SEE NO. 7 ABOVE).
#
# THE MAIN PURPOSE OF PRIODSP IS TO REPLACE THE PRESENT DISPLAY WITH A DISPLAY OF HIGHER PRIORITY AND TO
# PROVIDE A MEANS FOR RESTORING THE OLD DISPLAY WHEN THE PRIORITY DISPLAY
# IS RESPONDED TO BY THE ASTRONAUT.
#
# THE FORMER DISPLAY IS RESTORED BY AN AUTOMATIC BRANCH TO WAKE UP THE DISPLAY THAT WAS INTERRUPTED BY THE
# PRIO DISPLAY.
#
#			CAF	VXXNYY		# VXXNYY WILL BE A FLASHING VERB NOUN
#			TC	BANKCALL
## Page 1455
#			CADR	PRIODSP
#			...	...		# TERMINATE RETURN
#			...	...		# PROCEED RETURN
#			...	...		# ENTER OR RECYCLE RETURN
#
# PRIODSPR IS THE SAME AS PRIODSP ONLY AN IMMEDIATE RETURN IS MADE TO THE USERS CALL CADR +4.
#
#			CAF	VXXNYY		# VXXNYY WILL BE A FLASHING VERB NOUN
#			TC	BANKCALL
#			CADR	PRIODSPR
#			...	...		# TERMINATE RETURN
#			...	...		# PROCEED RETURN
#			...	...		# ENTER OR RECYCLE RETURN
#
#			...	...		# IMMEDIATE RETURN
#
# PRIOLARM DOES A V05N09 PRIODSPR.
#
# CLEANDSP CLEANS OUT ALL NORMAL DISPLAYS (ACTIVE AND INACTIVE). A RETURN IS MADE TO THE USER AFTER NORMAL
# DISPLAYS ARE CLEANED OUT.
#
#			TC	BANKCALL
#			CADR	CLEANDSP
#
#			...	...		# RETURN TO USER

## Page 1456
#
# GENERAL INFORMATION
# ------- -----------
#
# ALARM OR ABORT EXIT MODES--
#
#		PRIOBORT	TC	ABORT
#				OCT	1502
#
# PRIOBORT IS BRANCHED TO WHEN (1) A NORMAL DISPLAY IS REQUESTED AND ANOTHER NORMAL DISPLAY IS ALREADY ACTIVE
# (REFLASH AND REGODSP ARE EXCEPTIONS) OR (2) A PRIORITY DISPLAY IS REQUESTED WHEN ANOTHER PRIORITY DISPLAY IS
# ALREADY ACTIVE (A PRIORITY WITH LINUS BIT14 IS AN EXCEPTION).
#
# ERASABLE INITIALIZATION REQUIRED--
#
#	ACCOMPLISHED BY FRESH START-	1. FLAGWRD4 (USED EXCLUSIVELY BY DISPLAY INTERFACE ROUTINES)
#					2. NVSAVE = NORMAL VERB AND NOUN REGISTER.
#					3. EBANKTEM = NORMAL INACTIVE FLAGWORD (ALSO CONTAINS NORMALS EBANK).
#
#					5. R1SAVE = MARKBRAN CONTROL WORD
#					4. RESTREG = PRIORITY 30 AND SUPERBANK 3.
#
# OUTPUT--
#
#	NVWORD = PRIO VERB AND NOUN
#	NVWORD +1 (MARKNV) = MARK VERB AND NOUN
#	NVWORD +2 (NVSAVE) = NORMAL VERB AND NOUN
#
#	DSPFLG (EBANKSAV) = PRIO FLAGWORD (INCLUDING EBANK)
#	DSPFLG +1 (MARKEBAN) = MARK FLAGWORD (INCLUDING EBANK)
#	DSPFLG +2 (EBANKTEM) = NORMAL FLAGWORD (INCLUDING EBANK)
#
#	CADRFLSH = PRIO USER'S CALL CADR +1 LOCATION
#	CADRFLSH +1 (MARKFLSH) = MARK USER'S CALL CADR +1 LOCATION
#	CADRFLSH +2 (TEMPFLSH) = NORMAL USER'S CALL CADR +1 LOCATION
#
#	PRIOTIME = TIME EACH PRIO REQUEST FIRST SENT OUT
#	OPTION1 = DESIRED OPTION FROM GOPERF4
#	FLAGWRD4 = BIT INFO FOR CONTROL OF ALL DISPLAY ROUTINES
#	DSPTEM1 = R1 INFO FOR ASTRONAUT FROM PERFORM DISPLAYS (NORMAL)
#
# SUBROUTINES USED-- NVSUB, FLAGUP, FLAGDOWN, ENDOFJOB, BLANKSUB, ABORT, JOBWAKE, JOBSLEEP, FINDVAC, PRIOCHNG,
# JAMTERM, NVSUBUSY, FLASHON, ENDIDLE, CHANG1, BANKJUMP, MAKECADR, NOVAC,
#
# DEBRIS-- (STORED INTO)
#	TEMPORARY TEMPORARIES- A, Q, L, MPAC +2, MPAC +3, MPAC +4, MPAC +5, MPAC +6, RUPREG2, RUPTREG3, CYL,
#		EBANK, RUPTREG4, LOC, BANKSET, MODE, MPAC, MPAC +1	4, FACEREG
#	ERASABLES (SHARED AND USED WITH OTHER PROGRAMS) CADRSTOR, DSPLIST, LOC, DSPTEM1, OPTION1
#	ERASABLES (USED ONLY BY DISPLAY ROUTINES)- NVWORD,+1,+2, DSPFLAG,+1,+2, CADRFLSH,+1,+2, PRIOTIME, FLAGWRD4,
## Page 1457
#		R1SAVE, MARK2PAC,
#
# DEBRIS-- (USED BUT NOT STORED INTO)- NOUNREG, VERBREG, LOCCTR, MONSAVE1
#
# FLAGWORD DESCRIPTIONS--
#	FLAGWRD4- SEE DESCRIPTION UNDER LOG SECTION ERASABLE ASSIGNMENTS
#
#	DSPFLG, DSPFLG+1, DSPFLG+2-
#	---------------------------
#	BITS 1	BLANK R1
#	     2	BLANK R2
#	     3	BLANK R3
#	     4	FLASHING DISPLAY REQUESTED
#	     5	PERFORM DISPLAY REQUESTED
#	     6	-----			EXDSPRET		GODSPRET
#	     7	PRIO DISPLAY		-----			-----
#	     8	-----			MARK MONITOR PERF	-----
#	     9	EBANK
#	    10	EBANK
#	    11	EBANK
#	    12	-----			-----			V99PASTE
#	    13	2ND PART OF PERFORM
#	    14	REFLASH OR REDO		-----			REFLASH OR REDO
#	    15	-----			MARK REQUEST		-----
#
# RESTARTING DISPLAYS--
#
# RULES FOR THE DSKY OPERATOR--
#
#	1. PROCEED AND TERMINATE SERVE AS RESPONSES TO REQUESTS FOR OPERATOR RESPONSE (FLASHING Y/N).  AS LONG
#	   AS THERE IS ANY REQUEST AWAITING OPERATOR RESPONSE, ANY USE OF PROCEED OR TERMINATE WILL SERVE AS
#	   RESPONSES TO THAT REQUEST.  CARE SHOULD BE EXERCISED IN ATTEMPTING TO KILL AN OPERATOR INITIATED MONITOR
#	   WITH PROCEED AND TERMINATE FOR THIS REASON.
#	2. THE ASTRONAUT MUST RESPOND TO A PRIORITY DISPLAY NO SOONER THAN 5 SECONDS FROM THE TIME THE MISSION
#	   PROGRAM SENT OUT THE REQUEST FOR OPERATOR RESPONSE (THE ASTRONAUT WOULD SEE THIS DISPLAY FOR LESS TIME
#	   DUE TO TIME IT TAKES TO GET DISPLAY SENT OUT.)  IF THE ASTRONAUT RESPONDS TOO SOON, THE PRIORITY DISPLAY
#	   IS SENT OUT AGAIN---AND AGAIN UNTIL AN ACCUMULATED 5 SECS FROM TIME THE FIRST PRIORITY DISPLAY WAS SENT
#	   OUT. THE SAME 5 SEC. DELAY WILL OCCUR AT 163.84 SECS OR IN ANY MULTIPLE OF THAT TIME DUE TO PROGRAM
#	   CONSIDERATION.
#	3. KEY RELEASE BUTTON-
#	   A) IF THE KEY RELEASE LIGHT IS ON, IT SIMPLY RELEASES THE KEYBOARD AND DISPLAY FOR INTERNAL USE.
#	   B) IF THE KEY RELEASE LIGHT IS OFF, AND IF SOME REQUEST FOR OPERATOR RESPONSE (FLASHING V/N) IS STILL
#	      AWAITING RESPONSE THEN IT RE-ESTABLISHES THE DISPLAYS THAT ORIGINALLY REQUESTED RESPONSE.
#	   IF AN OPERATOR WANTS THEREFORE TO RE-ESTABLISH BUT CONDITION (A) IS ENCOUNTERED, A SECOND DEPRESSION OF
#	   KEY RELEASE BUTTON MAY BE NECESSARY.
#	4. IT IS IMPORTANT TO ANSWER ALL REQUESTS FOR OPERATOR RESPONSE.
#	5. IT IS ALWAYS GOOD PRACTICE TO TERMINATE AN EXTENDED VERB BEFORE ASKING FOR ANOTHER ONE OR THE SAME ONE
#	   OVER AGAIN.
#
# SPECIAL CONSIDERATONS -
## Page 1458
#	1. MPAC +2 SAVED ONLY IN MARK DISPLAYS
#	2. GODSP(R),REGODSP(R),GOMARK(R) ALWAYS TURN ON THE FLASH IF ENTERED WITH A PASTE VERB REQUEST.
#	3. ALL NORMAL DISPLAYS ARE RESTARTABLE EXCEPT GODSP(R), REGODSP(R)
#	4. ALL EXTENDED VERBS WITH DISPLAYS SHOULD START WITH A TC TESTXACT AND FINISH WITH A TC ENDEXT.
#	5. GODSP(R) AND REGODSP(R) MUST BE IN THE SAME EBANK AND SUPERBANK AS THE LAST NORMAL DISPLAY RESTARTED
#	   BY A .1 RESTART PHASE CHANGE.
#	6. IN ORDER TO SET UP A NON DISPLAY .1 RESTART POINT, THE USER MUST MAKE CERTAIN THAT RESTREG CONTAINS THE
#	   CORRECT PRIORITY AND SUPERBANK AND THAT EBANKTEM CONTAINS THE CO
#	7. IF CLEANDSP IS RESTARTED VIA A .1 PHASE CHANGE, CAF ZERO SHOULD BE EXECUTED BEFORE THE TC BANKCALL

## Page 1459
# CALLING SEQUENCE FOR BLANKING
#		CAF	BITX		# X=1,2,3 BLANK R1,R2,R3 RESPECTIVELY
#		TC	BLANKET
#		...	...		# RETURN TO USER HERE
#
# IN ORDER TO USE BLANKET CORRECTLY, THE USER MUST USE A DISPLAY ROUTINE THAT ENDS IN R FIRST FOLLOWED BY THE CALL
# TO BLANKET AT THE IMMEDIATE RETURN LOC.

		SETLOC	FFTAG4
		BANK

		COUNT*	$$/DSPLA
BLANKET		TS	MPAC +6
		CS	PLAYTEM4
		MASK	MPAC +6
		INDEX	MPAC +5
		ADS	PLAYTEM4

		TC	Q

ENDMARK		TC	CLEARMRK
		TC	POSTJUMP
		CADR	MARKOVER

CLEARMRK	CAF	ZERO
		TS	EXTVBACT

		CS	XDSPBIT
		MASK	FLAGWRD4
		TS	FLAGWRD4

		TC	Q

# *** ALL EXTENDED VERB ROUTINES THAT HAVE AT LEAST ONE FLASHING DISPLAY MUST TCF ENDMARK OR TCF ENDEXT WHEN
# FINISHED.

VNFLASH		XCH	L
		CAF	VNCADR
		TCF	VNGODSP

VNFLASHR	XCH	L
		CAF	VNRCADR
VNGODSP		INCR	Q		# BECAUSE OF RESTARTS
		LXCH	PLAYTEM1
		TCF	SWCALL

VNCADR		CADR	VNFLSH
VNRCADR		CADR	VNFLSHR

		SETLOC	DISPLAYS
		BANK
## Page 1460

		COUNT	10/DSPLA

# NTERONLY IS USED TO DIFFERENTIATE THE MARK ROUTINE WITH ONLY ONE RETURN TO THE USER FROM THE MARKING ROUTINE WITH
# 3 RETURNS TO THE USER.  THIS ROUTINE IS ONLY USED BY GOMARK1 AND GOMARK1R.

KLEENEX		CAF	ZERO		# CLEAN OUT EXTENDED VERBS
GOMARKF		TS	PLAYTEM1	# ENTRANCE FOR MARK GOFLASH

		CAF	MARKFMSK	# MARK,FLASH
		TCF	GOFLASH2

GOMARK2		TS	PLAYTEM1	# MARK GOPERFS-3 AST. RETURNS
MARKFORM	CAF	MPERFMSK	# MARK, PERFORM, FLASH
		TCF	GOFLASH2

GOMARK4		TS	PLAYTEM1
		CAF	MARK4MSK	# MARK,PERFORM,FLASH,BLANK
		TCF	GOFLASH2

GOMARKFR	TS	PLAYTEM1	# ENTRANCE FOR MARK GOFLASHR

		CAF	MARKFMSK
		TCF	GODSPRS

MARKMONR	TS	PLAYTEM1	# USED FOR MARK MONITOR
		CAF	MARK3MSK
		TCF	GOFLASH2
MAKEMARK	CAF	ONE
		TC	COPIES

		CA	FLAGWRD4	# IS NORM OR PRIO BUSY OR WAITING
		MASK	OCT34300
		CCS	A
		TCF	CHKPRIO

		CA	FLAGWRD4	# IS MARK SLEEPING DUE TO ASTRO BUSY?
		MASK	MRKNVBIT
		EXTEND
		BZF	MARKPLAY	# NO

		TCF	ENDOFJOB

MARKPLAY	CS	FIVE		# RESET MARK OVER NORM, SET MARK
		MASK	FLAGWRD4
		AD	XDSPBIT
		TS	FLAGWRD4
GOGOMARK	ZL			# PERFORM
		CS	MARKFLAG
		MASK	DCMKPERF
		CCS	A
		TCF	+5
## Page 1461
		CA	MARKNV
		MASK	MID7
		TS	L
		TCF	+5
		CS	MARKFLAG
		MASK	PERFRQST
		CCS	A
		TCF	MARKCOP
		CS	MARKNV
		TS	MARKNV

MARKCOP		CAF	ONE		# MARK INDEX
		TS	COPINDEX
		TCF	NVDSP +1
COPYTOGO	CA	MPAC2SAV
		TS	MPAC +2

COPYPACS	INDEX	COPINDEX
		CAF	PRIOOCT
		TS	GENMASK

		INDEX	COPINDEX
		CAF	EBANKSAV
		TS	TEMPOR2		# ACTIVE EBANK AND FLAG

		TS	EBANK

		TC	Q

# PINCHEK CHECKS TO SEE IF THE CURRENT MARK REQUEST IS MADE BY THE ASTRONAUT WHILE INTERUPTING A GOPLAY DISPLAY
# (A NORMAL OR A PRIO). IF THE ASTRONAUT TRIES TO MARK DURING A PRIO, THE CHECK FAIL LIGHT GOES ON AND THE MARK
# REQUEST IS ENDED. IF HE TRIES TO MARK DURING A NORM, THE MARK IS ALLOWED. IN THIS CASE THE NORM IS PUT TO SLEEP
# UNTIL ALL MARKING IS FINISHED.
#
# IF THE MARK REQUEST COMES FROM THE PROGRAM DURING A TIME THE ASTRONAUT IS NOT INTERRUPTING A NORMAL OR A
# PRIO, THE MARK REQUEST IS PUT TO SLEEP UNTIL THE PRESENT ACTIVE DISPLAY IS RESPONDED TO BY THE ASTRONAUT.

CHKPRIO		CA	FLAGWRD4	# MARK ATTEMPT DURING PRIO
		MASK	14,12,7
		CCS	A
		TCF	MARSLEEP

		CAF	MKOVBIT		# SET MARK OVER NORM
		TC	UPENT2

		TCF	SETNORM

MARKPERF	CA	MARKNV
		MASK	VERBMASK
		TCF	NV50DSP

## Page 1462
GODSP		TS	PLAYTEM1

GODSP2		CAF	DSPONLY
		TCF	GOFLASH2

GODSPRET	TS	PLAYTEM1	# ENTRANCE FOR A GODSP WITH A PASTE

		CAF	RETDSPY		# SET BIT6 TO RETURN TO USER AFTER NVSUB
		TCF	GOFLASH2

GODSPR		TS	PLAYTEM1

GODSPR1		CAF	DSPONLY
GODSPR2		TS	PLAYTEM4

		CAF	ZERO		# * DONT MOVE
		TCF	GODSPRS1

# CLEANDSP IS USED FOR CLEARING OUT A NORMAL DISPLAY THAT IS PRESENTLY ACTIVE OR A NORMAL DISPLAY THAT IS
# SET UP TO BE STARTED OR RESTARTED.
#
# NORMALLY THE USER WILL NOT NEED TO USE THIS ROUTINE SINCE A NEW NORMAL DISPLAY AUTOMATICALLY CLEARS OUT AN
# OLD DISPLAY.
#
# CALLING SEQUENCE FOR CLEANDSP-
#
#		TC	BANKCALL
#		CADR	CLEANDSP

CLEANDSP	CAF	ZERO
REFLASH		TS	PLAYTEM1

		CAF	REDOMASK	# FLASH AND PERMIT
		TCF	GOFLASH2

REGODSP		TS	PLAYTEM1

		CAF	REFLSH
		TCF	GOFLASH2

REGODSPR	TS	PLAYTEM1

		CAF	REFLSH
		TCF	GODSPR2

CLOCPLAY	TS	PLAYTEM1
		CAF	CLOCKCON
		TCF	GOFLASH2
VNFLSH		TC	UPFLAG
		ADRES	VNFLAG
## Page 1463
		TCF	GOFLASH +1

VNFLSHR		TC	UPFLAG
		ADRES	VNFLAG
		CAF	FLSHRQST
		TS	PLAYTEM4	# IT'S A FLASHING DISPLAY
		CAF	ZERO		# RETURN TO CALLER'S Q +1
		TCF	GODSPRS1

GOFLASH		TS	PLAYTEM1

 +1		CAF	FLSHRQST	# LEAVE ONLY FLASH BIT SET
GOFLASH2	TS	PLAYTEM4

		TC	SAVELOCS

		TCF	MAKEPLAY	# BRANCH DIRECT WITH NO SEPARATE JOB CALL

PRIODSPR	TS	PLAYTEM1

		CAF	BITS7+4
		TCF	GODSPRS

PRIODSP		TS	PLAYTEM1

SETPRIO		CAF	BITS7+4
		TCF	GOFLASH2

MAKEPRIO	CAF	ZERO
		TS	COPINDEX

		TC	LINUSCHR
		TCF	HIPRIO		# LINUS RETURN
		CA	FLAGWRD4
		MASK	BIT14+7		# IS PRIO IN ENDIDLE OR BUSY
		CCS	A
		TCF	PRIOBORT	# YES, ABORT

HIPRIO		CA	FLAGWRD4	# MARK ACTIVE
		MASK	BIT15+9
		EXTEND
		BZF	ASKIFNRM	# NO

SETMARK		CAF	ZERO
		TCF	JOBXCHS

ASKIFNRM	CA	FLAGWRD4	# NORMAL ACTIVE
		MASK	BIT13+8
		EXTEND
		BZF	OKTOCOPY	# NO
## Page 1464

SETNORM		CAF	ONE
		TCF	JOBXCHS

OKTOCOPY	TC	COPYNORM
		TC	WITCHONE

		TC	JOBWAKE

		TC	XCHTOEND

REDOPRIO	CA	TIME1		# SAVE TIME PRIODSP SENT OUT
		TS	PRIOTIME

KEEPPRIO	CAF	ZERO		# START UP PRIO DISPLAY
		TCF	PRIOPLAY

MAKEPLAY	CA	PRIORITY	# SAVE USERS PRIORITY
		MASK	PRIO37
		TS	USERPRIO

		CAF	PRIO33		# RAISE PRIORITY FOR FAST JOBS AFTER WAKE
		TC	PRIOCHNG

		CA	PLAYTEM4	# IS IT MARK OR PRIO OR NORM
		MASK	BITS15+7
		CCS	A
		TCF	MAKEPRIO	# ITS PRIO
		TCF	IFLEGAL
		TCF	MAKEMARK	# ITS MARK

IFLEGAL		CAF	TWO
		TS	COPINDEX

		TC	LINUSCHR

		TCF	OKTOPLAY	# LINUS RETURN
		CS	EBANKTEM
		MASK	FLSHRQST
		CCS	A
		TCF	OKTOPLAY	# NO

		CA	FLAGWRD4	# WAS NORM ASLEEP
		MASK	NBUSMASK	# ARE ANY NORMS ASLEEP
		EXTEND
		BZF	OKTOPLAY	# NO

PRIOBORT	TC	POODOO
		OCT	21502		# ILLEGAL FLASHING DISPLAY

OKTOPLAY	TC	COPIES2
## Page 1465
		CA	USERPRIO
		EXTEND
		ROR	SUPERBNK
		TS	RESTREG

		CA	FLAGWRD4	# PRIO OR MARK GOING
		MASK	PMMASK
		CCS	A
		TCF	GOSLEEPS	# YES

		TCF	+2
		TCF	GOSLEEPS	# MARK GOING

# COULD PUT NORM BUSY CHECK HERE TO SAVE TIME

		TC	WITCHONE	# IS IT NVSUB BUSY, ENDIDLE OR NOONE
		TC	JOBWAKE

		TC	XCHTOEND

PLAYJUM1	CAF	TWO
PRIOPLAY	TS	COPINDEX

		TCF	GOPLAY

EXDSPRET	TS	PLAYTEM1

		CAF	BIT15+6
		TCF	GOFLASH2

GOPERF1		TS	NORMTEM1	# STORE DESIRED CHECKLIST VALUE
		CAF	V01N25		# USED TO DISPLAY CHECKLIST VALUE IN R1

GOPERFS		TS	PLAYTEM1

		CAF	PERFMASK	# LEAVE ONLY FLASH, PERFORM, BLANKING
		TCF	GOFLASH2

GOPERF4		TS	OPTION1		# DESIRED OPTION CODE

		CAF	V04N06
		TS	PLAYTEM1

		CAF	PERF4MSK	# FLASH, PERFORM, AND BLANK R3
		TCF	GOFLASH2

GOFLASHR	TS	PLAYTEM1

		CAF	FLSHRQST	# LEAVE ONLY FLASH BIT SET
GODSPRS		TS	PLAYTEM4
## Page 1466
		CAF	THREE

GODSPRS1	INHINT			# IMMEDIATE RETURN IS CALL CADR +4
		TS	RUPTREG3

		CA	PRIORITY	# MAKE DISPLAY ONE HIGHER THAN USER
		MASK	PRIO37
		TS	NEWPRIO

		CA	PLAYTEM4	# IS THIS A FLASHING R DISPLAY
		MASK	FLSHRQST
		CCS	A
		TCF	VACDSP		# YES, MAKE DSPLAY JOB A VAC
		CA	NEWPRIO		# NO, MAKE DSPLAY JOB A NOVAC
		TC	NOVAC
		EBANK=	WHOCARES
		2CADR	MAKEPLAY

		TCF	BOTHJOBS

VACDSP		CA	BBANK
		EXTEND
		ROR	SUPERBNK
		TS	L
		CAF	MAKEGEN
		TC	SPVAC

BOTHJOBS	TC	SAVELOCS	# COPY TEMPS INTO PERMANENT REGISTERS

		EXTEND			# SAVE NVWORD AND USERS MPAC +2
		DCA	MPAC +1
		INDEX	LOCCTR
		DXCH	MPAC +1

		EXTEND			# SAVE USERS CADR, FLAGS AND EBANK
		DCA	MPAC +3
		INDEX 	LOCCTR
		DXCH	MPAC +3

		CA	LOCCTR
		TS	MPAC +5

		TC	SAVELOCR
		RELINT

		TCF	BANKJUMP	# CALL CADR +4

GOPERF1R	TS	NORMTEM1	# DESIRED CHECKLIST VALUE

		CAF	V01N25		# DISPLAYS CHECKLIST VALUE IN R1

## Page 1467

GOPERFRS	TS	PLAYTEM1

		CAF	PERFMASK	# LEAVE ONLY FLASH, PERFORM, BLANKING
		TCF	GODSPRS

GOPERF2R	TS	PLAYTEM1	# DESIRED VERB-NOUN TO DISPLAY R1,R2,R3

		CAF	PERF2MSK
		TCF	GODSPRS

SAVELOCS	INHINT

		CS	EBANK7		# GETS ALL EBANK BITS OFF
		MASK	PLAYTEM4
		AD	EBANK
		TS	PLAYTEM4

SAVELOCR	LXCH	Q

		TC	MAKECADR
		TS	PLAYTEM3

		AD	RUPTREG3	# NOT USED FOR NON R ROUTINES
		TC	L

COPYNORM	CAF	ZERO
COPIES		TS	COPINDEX
COPIES2		CA	PLAYTEM4	# FLAGWORD
		INDEX	COPINDEX
		TS	EBANKSAV	# EQUIV TO DSPFLG

		MASK	CADRMASK	# FLASH AND GODSPRET
		EXTEND
		BZF	SKIPADD

		CA	PLAYTEM3
		INDEX	COPINDEX
		TS	CADRFLSH

SKIPADD		CA	PLAYTEM1	# VERB NOUN
		INDEX	COPINDEX
		TS	NVWORD

		TCF	RELINTQ

GOSLEEPS	INDEX	COPINDEX
		CA	PRIOOCT
		MASK	WAITMASK
		TC	UPENT2
		CS	ONE
## Page 1468
		AD	COPINDEX
		TS	FACEREG

XCHSLEEP	INDEX	FACEREG
		CAF	WAKECADR
		TC	JOBWAKE		# FIND CADR IN JOB AREA

		TC	XCHTOEND	# CAUSES AWAKENED JOB TO GO TO ENDOFJOB

		INDEX	FACEREG		# REPLACE SAME CADR BUT NEW JOB AREA
		CAF	WAKECADR
		TCF	JOBSLEEP

JOBXCHS		TS	FACEREG		# CONTROLS TYPE OF DISPLAY PUT TO SLEEP
		TC	WITCHONE
		TC	JOBWAKE
		CA	FACEREG
		INDEX	LOCCTR
		TS	FACEREG

		CAF	XCHQADD
		TC	XCHNYLOC

		INDEX	FACEREG
		CA	MARKOCT
		MASK	IDLESLEP
		TC	DOWNENT2
		INDEX	FACEREG		# BIT SHOWS PRIO INTERRUPTED NORM OR MARK
		CA	MRUPTBIT	# BIT5 FOR MARK, BIT4 FOR NORMAL
		TC	UPENT2		# FLAG ROUTINE DOES RELINT
		CA	FLAGWRD4
		MASK	MKOVBIT		# IF BIT 3 THEN MARK OVER NORM
		CCS	A
GENMARK		TC	MARKPLAY	# USED AS GENADR FOR JOBWAKE
		TCF	OKTOCOPY

MARKWAKE	CAF	ZERO
WAKEPLAY	TS	TEMPOR2

		INDEX	TEMPOR2
		CA	BITS5+11
		TC	DOWNENT2
		INDEX	TEMPOR2
		CAF	WAKECADR
		TC	JOBWAKE

		TCF	ENDRET

# ALL .1 RESTARTS BRANCH DIRECTLY TO INITDSP. NORMAL DISPLAYS ARE THE ONLY DISPLAYS ALLOWED TO USE .1 RESTARTS
# INITDSP FIRST RESTORES THE EBANK AND THE SUPERBANK TO THE MOST RECENT NORMAL EBANK AND SUPERBANK.
## Page 1469
# IF THE MOST RECENT NORMAL DISPLAY REQUEST WAS NOT FINISHED, CONTROL IS SENT BACK TO THE LAST NORMAL USER.
# OTHERWISE THE NORMAL DISPLAY SET UP IN THE NORMAL DISPLAY REGS IS STARTED UP IMMEDIATELY.

INITDSP		CA	EBANKTEM	# RESTORE MOST RECENT NORMAL EBANK
		TS	EBANK

		CA	RESTREG		# SUPERBANK AND JOB PRIORITY
		EXTEND			# RESTORE SUPERBANK
		WRITE	SUPERBNK	# CHAN 07
		MASK	PRIO37
		TC	PRIOCHNG

		CS	THREE
		AD	TEMPFLSH
		TCF	BANKJUMP

PINBRNCH	RELINT			# FOR GOPIN USERS
		CA	MARK2PAC	# NEEDED TO SAVE MPAC +2 FOR MARK USERS
		TS	MPAC +2		# ONLY

		CA	FLAGWRD4	# PINBRANCH CONDITION
		MASK	PINMASK
		CCS	A
		TCF	+3
		TCF	ERASER		# ** NOTHING IN ENDIDLE
		TCF	MARKPLAY

NORMBNCH	TC	UPFLAG		# SET PINBRANCH BIT
		ADRES	PINBRFLG

		CAF	PRIODBIT	# PRIO INTERRUPTED
		MASK	FLAGWRD4
		CCS	A
		TCF	KEEPPRIO

		TCF	PLAYJUM1

NVDSP		ZL
		TC	COPYPACS
		CA	TEMPOR2		# SET UP BLANK BITS FOR NVMONOPT IN CASE
		MASK	SEVEN		# USER REQUESTS BLANKING MONITOR
		ADS	L
		CS	2NDPERF
		INDEX	COPINDEX
		MASK	DSPFLG
		INDEX	COPINDEX
		TS	DSPFLG

		MASK	DCMKPERF
		CCS	A
## Page 1470
		CA	OCT2600
		TS	TEM1

		CA	MPAC +2
		TS	MPAC2SAV

		TS	MARK2PAC	# * FOR DISK ONLY *
		INDEX	COPINDEX
		CCS	NVWORD
		TCF	NVDSP1
		TCF	CLEANEND
		CS	MARKNV
		TS	MARKNV		# IN CASE MARKPLAY AWAKENED AFTER SLEEPING
		MASK	LOW7
		AD	V05N00M1
		AD	TEM1
NVDSP1		AD	ONE
NV50DSP		TC	NVMONOPT
		TCF	REST		# IF BUSY
		TC	FLASHOFF	# IN CASE OF EXTENDED VERB NON FLASH

		TC	COPYTOGO	# MPACS DESTROYED BY NVSUB
		CAF	OCT700
		TC	DOWNENT2
		
BLANKCHK	CA	TEMPOR2		# BLANK BITS 1,2,3 IF SET
		TC	BLANKSUB
		TCF	NVDSP
PERFCHEK	CAF	PERFRQST	# BIT5 FOR PERFORM
		MASK	TEMPOR2
		CCS	A		# IS THIS A GOPERF DISPLAY
		TCF	1STOR2ND	# YES

GOANIDLE	CAF	FLSHRQST
		MASK	TEMPOR2
		CCS	A
		TCF	FLASHSUB	# IT IS

		CS	TEMPOR2		# IS THIS A GODSPRET
		MASK	RETDSPY
		CCS	A
		TCF	ISITN00

		INDEX	COPINDEX
		CA	CADRFLSH
		TS	MPAC +3
		TCF	ENDIT

ISITN00		INDEX	COPINDEX	# IS THIS A PASTE
		CA	NVWORD
## Page 1471
		MASK	LOW7		# CHECK MADE FOR PINBRNCH AND PRIO ON MARK
		EXTEND
		BZF	FLASHSUB	# YES, ASSUME PASTE ALWAYS ON FLASH

		TCF	ENDOFJOB	# NOT FLASH, NOT GOPERF, THEREFORE EXIT

1STOR2ND	CA	TEMPOR2
		MASK	2NDPERF
		CCS	A
		TCF	GOANIDLE	# SECOND

		CA	2NDPERF
		INDEX	COPINDEX
		ADS	DSPFLG

		ZL
		EXTEND			# IS IT MARK
		BZMF	MARKPERF	# YES

		MASK	V99PSTE
		EXTEND
		BZF	V50PASTE
		CS	NVWORD1		# NVOWRD1= -0 IS V97.  NVWORD1= -400 IS V99
		AD	V97N00
		TCF	NV50DSP
V50PASTE	CAF	V50N00
		TCF	NV50DSP		# DISPLAY SECOND PART OF GOPERF

WITCHONE	CS	BIT5		# TURN OFF KEY RELEASE LIGHT
		EXTEND
		WAND	DSALMOUT

		CA	FLAGWRD4
		MASK	NVBUSMSK	# IS IT NVSUB ASLEEP
		CCS	A
		CAF	ONE
		TS	L
		CAF	ZERO
		INDEX	L
		XCH	CADRSTOR

		TC	Q

XCHTOEND	CAF	ENDINST		# TC ENDOFJOB REPLACES GENADR IN LOC FOR
XCHNYLOC	XCH	LOCCTR		# WAS THIS ADDRESS SLEEPING
		EXTEND
		BZMF	RELINTQ		# NO
		XCH	LOCCTR		# YES
		INDEX	LOCCTR
		TS	LOC

## Page 1472

RELINTQ		TCF	REQ		# BACK TO USER
CLEANEND	CAF	PRIO32		# ONE LOWER THAN DISPLAYS SLEEPING
		TC	FINDVAC
		EBANK=	NVSAVE
		2CADR	JAMTERM

		TCF	FLASHSUB +1

ISITPRIO	CA	FLAGWRD4
		MASK	ITISMASK	# IS PINBRFLG, MARKIDFLG SET
		EXTEND
		BZF	PRIOBORT
		TCF	ENDOFJOB

REST		CCS	CADRSTOR	# IS SOMEONE IN ENDIDLE
		TCF	ENDOFJOB	# YES
		TCF	RESTSLEP

		TCF	ENDOFJOB

RESTSLEP	CA	GENMASK		# SET NVSLEEP BITS
		MASK	NVBUSMSK
		TC	UPENT2
NVSUBUSY	TC	ISCADR+0
		TC	RELDSPON
		INDEX	COPINDEX
		CAF	NVCADR
		TS	DSPLIST
		TC	JOBSLEEP
FLASHSUB	TC	FLASHON

 +1		CA	COPINDEX	# COPINDEX DESTROYED BY ENDIDLE
		TS	COPMPAC

		CA	GENMASK
		MASK	IDLEMASK
		TC	UPENT2
		CCS	CADRSTOR	# SEE IF SOMEONE ALREADY IN ENDIDLE
		TCF	ISITPRIO
		TCF	+2
		TCF	ISITPRIO

ENDIDLE		TC	ISCADR+0
		CA	ENDIDRET
		TS	CADRSTOR
		TC	JOBSLEEP
IDLERET1	CS	LOWLOAD
		AD	MPAC		# VERBREG
		EXTEND
## Page 1473
		DIM	A
		EXTEND
		BZF	LOADITIS	# V21 OR V22 OR V23 ON DSKY
OKTOENT		CA	FLAGWRD4	# CHECK NATURE OF ENDIDLE RETURN
		MASK	BIT15/14
		CCS	A
		TCF	TIMECHEK	# PRIO ENDIDLE RETURN
		TCF	NORMRET		# NORMAL ENDIDLE RETURN
		TCF	MARKRET		# MARK ENDIDLE RETURN

TIMECHEK	CA	NVWORD
		EXTEND
		BZF	NORMRET
		
		CS	TIME1
		AD	PRIOTIME
		CCS	A
		COM
		AD	OCT37776
		AD	ONE
		AD	-2SEC
		EXTEND
		BZMF	KEEPPRIO

		TCF	NORMRET

NORMWAKE	CAF	ONE
		TCF	WAKEPLAY


ENDRET		CCS	LOADSTAT	# -0=V32 OR E, -1=V33 OR PRO, -2=V34
		TCF	ENDOFJOB	# +1=ENDMARK
ENDIDRET	CADR	IDLERET1	# CANNOT GET HERE
		TCF	+1
		CA	FLAGWRD4	# IS IT A VNFLASH
		MASK	VNBIT		#    (BIT2)
		AD	COPMPAC		#   AND A NORMAL DISPLAY
		AD	NEG4
		EXTEND
		BZF	VNRET
		CA	LOADSTAT
		AD	TWO
ENDRET1		INDEX	COPMPAC
		AD	CADRFLSH
ENDRET2		TS	MPAC +3

		CA	GENMASK		# REMOVE ENDIDLE AND PINBRANCH BITS
		MASK	PINIDMSK
		TC	DOWNENT2
		CS	THREE		# BLANK EVERYTHING EXCEPT MM
		TC	NVSUB
## Page 1474
		TCF	+1

ENDIT		CA	USERPRIO	# RETURN TO USERS PRIORITY
		MASK	PRIO37
		TC	PRIOCHNG
		CA	MPAC +3
		TCF	BANKJUMP

VNRET		TC	DOWNFLAG
		ADRES	VNFLAG
		CA	LOADSTAT
		AD	ONE
		CCS	A
		CAF	NEG3		# LOADOSTAT.-0
		TCF	ENDRET1		# CANNOT GET HERE VIA CCS
		TCF	TERMFLSH	# LOADSTAT=-2
		CS	ONE		# COMPENSATE FOR INCREMENTED Q IN LEAD-IN
		TCF	ENDRET1		# LOADSTAT=-1
TERMFLSH	CAF	GOPOOCAD
		TCF	ENDRET2


LINUSCHR	CS	PLAYTEM4	# IS THIS A LINUS
		MASK	REFLSH
		CCS	A
		TCF	Q+1		# NO
		CS	PLAYTEM3	# YES, IS IT ALREADY IN ENDIDLE
		INDEX	COPINDEX
		AD	CADRFLSH
		EXTEND
		BZF	+2		# YES

		TC	Q		# NO
		CCS	DSPLOCK		# IS THE ASTRONAUT BUSY
		TC	ENDOFJOB	# END THE NEW DISPLAY, ITS ALREADY ACTIVE
		TC	Q

# MORE LOGIC COULD BE INCORPORATED HERE TO MAKE SURE A RECYCLE IS A RECYCLE AND CONVERSELY THAT A LOAD IS A LOAD.
#
# LASTPLAY CHECKS TO SEE IF (1) THE LAST NORMAL DISPLAY WAS EITHER INTERRUPTED BY A PRIO OR A MARK (MARK
# COULD ONLY HAPPEN DURING PINBRANCH) OR IF (2) THE LAST NORMAL DISPLAY WAS REQUESTED WHILE A HIGHER PRIORITY
# DISPLAY WAS GOING, RESULTING IN THE NORMAL BEING PUT TO SLEEP.
#
# IF EITHER OF THE ABOVE 2 CONDITIONS EXISTS, THE NORMAL DISPLAY IS AWAKENED TO GO TO PLAYJUM1 WHICH STARTS
# UP THE MOST RECENT VALID NORMAL DISPLAY. IF THESE 2 CONDITIONS DO NOT EXIST, CONTROL GOES TO PLAYJUM1 WHICH IS
# STARTED IMMEDIATELY WITH THE ASSUMPTION THAT THE MOST RECENT NORMAL DISPLAY IS ALREADY IN ENDIDLE (DURING A
# PINBRNCH) OR THAT A RESTART HAS OCCURRED AND THE DISPLAY CAN BE STARTED AS A .1 RESTART.

MARKRET		CAF	MKOVBIT
		TC	DOWNENT2
## Page 1475
		TCF	ENDRET

MARKOVER	CAF	ONE
		TS	LOADSTAT
		CA	FLAGWRD4	# IS ENDIDFLG SET
		MASK	BIT13-14	# IS NORMAL OR PRIO IN ENDIDLE
		CCS	A
		TCF	NORMBNCH

NORMRET		CA	FLAGWRD4	# IS MARK SLEEPING
		MASK	BITS5+11	# OR WAITING
		CCS	A
		TCF	MARKWAKE

		CA	FLAGWRD4	# NO
		MASK	BITS4+10	# IS NORMAL INTERRUPTED OR WAITING
		CCS	A
		TCF	NORMWAKE	# YES

		CAF	FLSHRQST	# NO, WAS IT A FLASH REQUEST
		AD	RETDSPY		# OR GODSPRET
		MASK	EBANKTEM
		CCS	A
		TCF	ENDRET		# YES
		CA	NVSAVE
		EXTEND
		BZF	ENDRET

		CAF	PRIO15
		TC	NOVAC
		EBANK=	NVWORD
		2CADR	PLAYJUM1


		TCF	ENDRET

MARSLEEP	CA	FLAGWRD4	# IS MARK ALREADY ON
		MASK	BITS5+11
		CCS	A
		TCF	ENDOFJOB	# YES
		TCF	GOSLEEPS

LOADITIS	INDEX	COPMPAC
		CA	NVWORD
		MASK	LOW7
		COM
		AD	MPAC +1		# NOUNREG
		EXTEND
		BZF	OKTOENT		# NO, THEN LOAD IS VALID
		TCF	PINBRNCH	# YES, ACCEPT LOAD BUT ASK FOR LAST AGAIN

## Page 1476
ERASER		CS	THREE		# BLANK EVERYTHING EXCEPT MM
		TC	NVSUB
		TCF	ENDOFJOB
		TCF	ENDOFJOB

PERFMASK	OCT	0036		# FLASH,PERFORM,BLANK R2 AND R3
V01N25		VN	00125
V50N00		VN	5000
PERF2MSK	EQUALS	BITS4&5		# (OCTAL 30)   FLASH, PERFORM
PERF4MSK	EQUALS	OCT14		# FLASH, BLANK R3
REDOMASK	OCT	20010		# BITS 4 AND 14
MARK4MSK	OCT	40036		# MARK,PERFORM,FLASH,BLANK 2 AND 3
NVCADR		CADR	REDOPRIO
WAKECADR	CADR	MARKPLAY
		CADR	PLAYJUM1

NBUSMASK	OCT	11210
PMMASK		OCT	66521
VERBMASK	=	MID7		# (OCT 37600)
V05N00M1	OCT	1177		# V05 MINUS ONE
GOXDSPF		EQUALS	GOMARKF
ENDEXT		EQUALS	ENDMARK
MPAC2SAV	EQUALS	BANKSET
NVBUSMSK	OCT	700
MPERFMSK	OCT	40030		# BIT 15,5,4 FOR MARK,PERFORM,FLASH
OCT34300	OCT	34300
BITS15+7	OCT	40100
BITS5+11	OCT	2020		# * DONT MOVE
BITS4+10	OCT	1010		# * DONT MOVE
LOWLOAD		EQUALS	VBSP2LD
CADRMASK	EQUALS	OCT50
PINMASK		EQUALS	13,14,15
GOPLAY		EQUALS	NVDSP
#PRIOSAVE	EQUALS	R1SAVE
COPMPAC		EQUALS	MPAC +3
TEMPOR2		EQUALS	MPAC +4
COPINDEX	EQUALS	LOC
USERPRIO	EQUALS	MODE
GENMASK		EQUALS	MPAC +6
PRIOOCT		OCT	20144		# PRIO
MARKOCT		OCT	42424		# MARK
		OCT	11254		# NORM

IDLESLEP	OCT	74700
LINUS		EQUALS	BLANKET
FACEREG		EQUALS	MPAC
PLAYTEM1	EQUALS	MPAC +1
PLAYTEM3	EQUALS	MPAC +3
PLAYTEM4	EQUALS	MPAC +4
MAKEGEN		GENADR	MAKEPLAY
## Page 1477
BIT13+8		OCT	10200
V97N00		VN	09700		# PASTE FOR V97 OR V99
BIT14+7		OCT	20100
CLOCKCON	OCT	24030		# FLASH, PERFORM, V99 OR V97 PASTE,REFLASH
PINIDMSK	OCT	74040
IDLEMASK	EQUALS	HIGH4
ITISMASK	EQUALS	BIT15+6		# *** ENDIDLE ALLOW ***
MARKFMSK	EQUALS	OT40010
XCHQADD		GENADR	XCHSLEEP
WAITMASK	EQUALS	PRIO3		# (OCTAL 3000)
OCT700		EQUALS	NVBUSMSK
GOPOOCAD	CADR	TCGOPOOH
MARK3MSK	OCT	40210
MKRQST		=	BIT15
REFLSH		=	BIT14
2NDPERF		=	BIT13
V99PSTE		=	BIT12
DCMKPERF	=	BIT8
PRIODSPY	=	BIT7
RETDSPY		=	BIT6
PERFRQST	=	BIT5
FLSHRQST	=	BIT4
BLNKR3		=	BIT3
BLNKR2		=	BIT2
BLKNR1		=	BIT1
DSPONLY		=	ZERO
