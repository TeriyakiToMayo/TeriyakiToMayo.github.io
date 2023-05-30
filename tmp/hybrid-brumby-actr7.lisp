; windows 
; (load "E:/Programs/ACT-R IDE/ACT-R Source/load-act-r.lisp") 
; (load "E:/Programs/ACT-R/tutorial/playground/hybrid-brumby-actr7.lisp") 
; mac 
; (load "/Users/zhentian/Documents/ACT-R all/actr7.x/load-act-r.lisp") 
; (load "/Users/zhentian/Documents/ACT-R all/ACT-R/tutorial/playground/hybrid-brumby-actr7.lisp") 

; set device here, then use (main) to test 
(defparameter *device-type* 'windows) 

(defun get-path ()
	(if (eq *device-type* 'windows)
		(progn
			(list 
				"E:/Programs/ACT-R/tutorial/playground/"
				"E:/Programs/ACT-R/tutorial/playground/hybrid-brumby-actr7.lisp" 
			)
		)
		
		(progn
			(list 
				"/Users/zhentian/Documents/ACT-R all/ACT-R/tutorial/playground/"
				"/Users/zhentian/Documents/ACT-R all/ACT-R/tutorial/playground/hybrid-brumby-actr7.lisp" 
			)
		)
	)
)


;;;;;- ACL in package -;;;;;;
;;;;;(in-package cg-user);;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#|----------------------------------------------------

                  Exemplar Similarity
      Based on Anderson & Betz (2001) ACT-R 4 model
Adopted for ACT-R 6 to fit data from Hahn, Prat-Sala & Pathos

                    Duncan Brumby 
                      Feb. 2006
                 Brumby@cs.drexel.edu


Notes: 

Hahn, Prat-Sala & Pathos

General method

Stimuli were simple line drawing of geometric shapes that varied across 6 feature values.
For simplification stimuli are represented as a list of six string values, e.g.
    '("1" "4" "5" "2" "5" "2")

Order: 
   Main trainig - 
       Three rounds of *training* set - these were good examples of rule compliant items
       Encode and then press space bar - internal judgement??
   Test cycle -
       24 items sampled from 96 test items - 6 of each *c-high* *c-low* *n-high-_* *n-low-_*
       Respond to each - "k" for compliant and "d" for non-compliant
       One trainig cycle ... *training* set once only


Big change in the analyse function. Now only calculates RTs for correct selections


Expt. 1 and 2 manipulate whether non-compliant on 3 or 1 rule        


Exemplar route now only retrieves training instances ... leads to strong similarity effect. generally not a bad fit. 

rule route checks only relevant features. 




For experiment there was a 2/26 probability that accuracy feedback would be incongurent to actual accuracy ... 
build function that 

-----------------------------------------------------|#

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Global Variables

(defvar *block* nil
  "hold the current block number")

(defvar *results* nil 
  "Structured list that holds all results") 

(defvar *meta-results* nil)

(defvar *start-time* nil 
  "timer for trial i")

(defvar *done-trial* nil 
  "control state for trial presentation")

(defvar *condition-trial* nil
  "experimental condition from which current test stimuli was sampled")

(defvar *do-training* nil
  "simple tag for controlling whether it is training or experimental trials")

(defvar *training* nil
  "training stimuli - embedded list where each stimuli contains features 1 - 6")

(defvar *c-high* nil 
  "rule-compliant-low-similarity")

(defvar *c-low* nil 
  "rule-compliant-low-similarity")

(defvar *n-high* nil 
  "define later depending on condition")

(defvar *n-low* nil
  "define later depending on condition")

(defvar *n-high-3* nil
  "rule-noncompliant-3-feats-high-similarity")

(defvar *n-low-3* nil
  "rule-noncompliant-3-feats-low-similarity")

(defvar *n-high-1* nil
  "rule-noncompliant-1-feats-high-similarity")

(defvar *n-low-1* nil
  "rule-noncompliant-1-feats-low-similarity")

(defvar *route* nil
  "exemplar or rule route to classification")

(defvar *rule-ft-counter* nil 
  "no longer used")

(defvar *random-walk-step* nil
  "hacked solution ... ")

(defvar *count-yes* nil
  "hacked ..." )

(defvar *count-no* nil)

(defvar *random-walk-threshold* nil) 

(defvar *foo* nil
  "whatever use variable for debug") 

(defvar *rule-RT* nil
  "whatever use variable for debug") 

(defvar *exemplar-RT* nil
  "whatever use variable for debug") 

(defvar *response-RT* nil)

(defvar *retrieval-check* nil)
(defvar *retrieve-RT* nil)

(defvar *pp* nil)

(defvar *n-trials* nil)

(defvar *rule-successes* nil)
(defvar *exemplar-successes* nil)
(defvar *successes* nil)


(defvar *path* nil)
(defvar *output-path* nil)

(setf *path* (nth 0 (get-path))) 


;;;Define a structure to hold results for given trial
(defstruct response condition rt accuracy route block pp)

;;;reload THIS file
(defun l () 
	(gc)
	(load (nth 1 (get-path)))
)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Experimental Stimuli

(setf *training* 
'(("1" "4" "1" "3" "1" "1") ("1" "4" "1" "3" "2" "1") ("1" "4" "1" "3" "3" "1")
  ("1" "4" "1" "3" "4" "1") ("2" "4" "1" "3" "1" "1") ("2" "4" "1" "3" "2" "1")
  ("2" "4" "1" "3" "3" "1") ("2" "4" "1" "3" "4" "1") ("3" "4" "1" "3" "1" "1")
  ("3" "4" "1" "3" "2" "1") ("3" "4" "1" "3" "3" "1") ("3" "4" "1" "3" "4" "1")))

(setf *c-high* 
      '(("1" "4" "2" "3" "1" "1") ("1" "4" "3" "3" "2" "1") ("1" "4" "4" "3" "3" "1")
        ("1" "4" "5" "3" "4" "1") ("1" "4" "6" "3" "1" "1") ("1" "4" "2" "3" "2" "1")
        ("1" "4" "3" "3" "3" "1") ("1" "4" "4" "3" "4" "1") ("2" "4" "5" "3" "1" "1")
        ("2" "4" "6" "3" "2" "1") ("2" "4" "2" "3" "3" "1") ("2" "4" "3" "3" "4" "1")
        ("2" "4" "4" "3" "1" "1") ("2" "4" "5" "3" "2" "1") ("2" "4" "6" "3" "3" "1")
        ("2" "4" "2" "3" "4" "1") ("3" "4" "3" "3" "1" "1") ("3" "4" "4" "3" "2" "1")
        ("3" "4" "5" "3" "3" "1") ("3" "4" "6" "3" "4" "1") ("3" "4" "2" "3" "1" "1")
        ("3" "4" "3" "3" "2" "1") ("3" "4" "4" "3" "3" "1") ("3" "4" "5" "3" "4" "1")))

(setf *c-low* 
      '(("4" "4" "2" "3" "5" "1") ("4" "4" "2" "3" "6" "1") ("4" "4" "3" "3" "5" "1")
        ("4" "4" "3" "3" "6" "1") ("4" "4" "4" "3" "5" "1") ("4" "4" "4" "3" "6" "1")
        ("4" "4" "5" "3" "6" "1") ("4" "4" "6" "3" "5" "1") ("5" "4" "2" "3" "5" "1")
        ("5" "4" "2" "3" "6" "1") ("5" "4" "3" "3" "6" "1") ("5" "4" "4" "3" "5" "1")
        ("5" "4" "5" "3" "5" "1") ("5" "4" "5" "3" "6" "1") ("5" "4" "6" "3" "5" "1")
        ("5" "4" "6" "3" "6" "1") ("6" "4" "2" "3" "6" "1") ("6" "4" "3" "3" "5" "1")
        ("6" "4" "4" "3" "5" "1") ("6" "4" "4" "3" "6" "1") ("6" "4" "5" "3" "5" "1")
        ("6" "4" "5" "3" "6" "1") ("6" "4" "6" "3" "5" "1") ("6" "4" "6" "3" "6" "1")))

(setf *n-high-3* 
      '(("1" "4" "1" "3" "1" "2") ("1" "4" "1" "3" "2" "2") ("1" "4" "1" "3" "3" "3")
        ("1" "4" "1" "3" "4" "3") ("2" "4" "1" "1" "1" "1") ("2" "4" "1" "1" "2" "1")
        ("2" "4" "1" "2" "3" "1") ("2" "4" "1" "2" "4" "1") ("3" "1" "1" "3" "1" "1")
        ("3" "1" "1" "3" "2" "1") ("3" "2" "1" "3" "3" "1") ("3" "2" "1" "3" "4" "1")
        ("1" "4" "1" "1" "1" "1") ("1" "4" "1" "1" "2" "1") ("1" "4" "1" "2" "3" "1")
        ("1" "4" "1" "2" "4" "1") ("2" "1" "1" "3" "1" "1") ("2" "1" "1" "3" "2" "1")
        ("2" "2" "1" "3" "3" "1") ("2" "2" "1" "3" "4" "1") ("3" "4" "1" "3" "1" "2")
        ("3" "4" "1" "3" "2" "2") ("3" "4" "1" "3" "3" "3") ("3" "4" "1" "3" "4" "3")))

(setf *n-low-3* 
      '(("4" "4" "1" "3" "5" "2") ("4" "4" "1" "3" "6" "3") ("5" "4" "1" "1" "5" "1")
        ("5" "4" "1" "2" "6" "1") ("6" "1" "1" "3" "5" "1") ("6" "2" "1" "3" "6" "1")
        ("4" "4" "1" "1" "5" "1") ("4" "4" "1" "2" "6" "1") ("5" "1" "1" "3" "5" "1")
        ("5" "2" "1" "3" "6" "1") ("6" "4" "1" "3" "5" "2") ("6" "4" "1" "3" "6" "3")
        ("4" "2" "1" "3" "5" "1") ("4" "1" "1" "3" "6" "1") ("5" "4" "1" "3" "5" "3")
        ("5" "4" "1" "3" "6" "2") ("6" "4" "1" "2" "5" "1") ("6" "4" "1" "1" "6" "1")
        ("4" "4" "1" "3" "5" "3") ("4" "4" "1" "3" "6" "2") ("5" "4" "1" "2" "5" "1")
        ("5" "4" "1" "1" "6" "1") ("6" "2" "1" "3" "5" "1") ("6" "1" "1" "3" "6" "1")))

(setf *n-high-1* 
      '(("1" "1" "1" "3" "1" "1") ("1" "2" "1" "3" "2" "1") ("1" "3" "1" "3" "3" "1")
        ("1" "5" "1" "3" "4" "1") ("1" "6" "1" "3" "1" "1") ("1" "1" "1" "3" "2" "1")
        ("1" "2" "1" "3" "3" "1") ("1" "3" "1" "3" "4" "1") ("2" "5" "1" "3" "1" "1")
        ("2" "6" "1" "3" "2" "1") ("2" "1" "1" "3" "3" "1") ("2" "2" "1" "3" "4" "1")
        ("2" "3" "1" "3" "1" "1") ("2" "5" "1" "3" "2" "1") ("2" "6" "1" "3" "3" "1")
        ("2" "1" "1" "3" "4" "1") ("3" "2" "1" "3" "1" "1") ("3" "3" "1" "3" "2" "1")
        ("3" "5" "1" "3" "3" "1") ("3" "6" "1" "3" "4" "1") ("3" "1" "1" "3" "1" "1")
        ("3" "2" "1" "3" "2" "1") ("3" "3" "1" "3" "3" "1") ("3" "5" "1" "3" "4" "1")))

(setf *n-low-1* 
      '(("4" "1" "1" "3" "6" "1") ("4" "2" "1" "3" "5" "1") ("4" "2" "1" "3" "6" "1")
        ("4" "3" "1" "3" "5" "1") ("4" "5" "1" "3" "5" "1") ("4" "5" "1" "3" "6" "1")
        ("4" "6" "1" "3" "5" "1") ("4" "6" "1" "3" "6" "1") ("5" "1" "1" "3" "5" "1")
        ("5" "1" "1" "3" "6" "1") ("5" "2" "1" "3" "5" "1") ("5" "3" "1" "3" "5" "1")
        ("5" "3" "1" "3" "6" "1") ("5" "5" "1" "3" "5" "1") ("5" "6" "1" "3" "5" "1")
        ("5" "6" "1" "3" "6" "1") ("6" "1" "1" "3" "5" "1") ("6" "1" "1" "3" "6" "1")
        ("6" "2" "1" "3" "5" "1") ("6" "2" "1" "3" "6" "1") ("6" "3" "1" "3" "6" "1")
        ("6" "5" "1" "3" "5" "1") ("6" "5" "1" "3" "6" "1") ("6" "6" "1" "3" "5" "1")))

(defun add-condition-info (cond-name cond-lis)
  ;;Add condition info to each list, 
  ;; '(cond f1 f2 f3 f4 f5 f6)
  (let ((original cond-lis)
        (new nil))
    (mapcar #'(lambda (x) (setf new (cons (cons cond-name x) new))) original)
    new))

(defun setup-rule-difficulty (diff)
  ;;diff is either 1 or 3
  ;;first add the condition info to above ... opps.  
  (setf *training* (add-condition-info 'training *training*))
  (setf *c-high* (add-condition-info 'c-high (permute-list *c-high*)))
  (setf *c-low* (add-condition-info 'c-low (permute-list *c-low*)))
  (setf *n-high-1* (add-condition-info 'n-high *n-high-1*))
  (setf *n-low-1* (add-condition-info 'n-low *n-low-1*))
  (setf *n-high-3* (add-condition-info 'n-high *n-high-3*))
  (setf *n-low-3* (add-condition-info 'n-low *n-low-3*))
  ;;alter depending on condition ... 
  (if (= diff 1)
    (progn (setf *n-high* *n-high-1*) (setf *n-low* *n-low-1*))
    (progn (setf *n-high* *n-high-3*) (setf *n-low* *n-low-3*))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Running the experiment
;;;
;;; Displays an instance on the screen
;;; For example, 
;;;
;;; "4" "5" "3" "5" "5" "1"
;;;
;;; Waits for response: "k" for yes belongs to category, "d" for no does not belong to category, or "t" for test
;;;
;;; The accuracy and RT for response are stored along with actual condition information
;;;



(defun main ()
	(setf *successes* (reverse '(
					;(150 25) 
					;(150 70) 
                    ;(150 80) (150 100) 
                    ;(150 125) (150 150) 
                    ;(125 150) (100 150) 
					;(150 150)
                    ;(80 150) 
                    ;(70 150)  ;;new
                    (63 150)  ;;new
                    ;(60 150) (25 150)
	)))
  	(do-exp-with-successes *successes* 1))

;;;(ccl::set-preferred-size-resource desired-size-in-bytes)


(defun do-exp-with-successes (lis c)
  (cond ((null lis) nil)
        (t 
         (setf *exemplar-successes* (caar lis))
         (setf *rule-successes* (cadar lis))
		; (write *exemplar-successes*)
         (l)
         (format t "~%do: ~s" c )
         (g 3 50) ;20) ;42)
         (print-simple (format nil "Data-RT~sPro~s.csv" (car (sgp :rt)) c))
         (do-exp-with-successes (cdr lis) (1+ c)))))



(defun print-simple (output)
;; print csv file of all data
  (setf *output-path* (open (format nil "~a~a" *path* output) 
                            :direction :output
                            :if-exists :supersede))
   (format *output-path* "pp,block,cond,error,rt,route")
   (mapcar #'(lambda (x)
               (when (not (equal (response-CONDITION x) 'TRAINING))
                 (format *output-path* "~%~s,~s,~s,~s,~5,0F,~s"
                         (response-PP x)
                         (response-BLOCK x)
                         (response-CONDITION x)
                         (if (= (response-ACCURACY x) 1) 0 1)
                         (response-RT x)
                         (response-ROUTE x)
                         ))) 
           *results*)
   (close *output-path*)
   )

	

(defun test (c)
  ;;1 = single-feature rule, else three-feature rule
  (l)
  (setf *results* nil)
  (dotimes (i 1)
    (l) 
    (setup-rule-difficulty c)
    (do-exp i)))

(defun g (c n) 
  ;;1 = single-feature rule, else three-feature rule
  ;(l)                   ;; load the model
  (setf *results* nil)  ;;clear main collect variables
  (setf *rule-RT* nil)
  (setf *exemplar-RT* nil)
  (setf *response-RT* nil)
  (setf *retrieve-RT* nil)
  (setf *n-trials* n)
  (dotimes (i n) ;;42)
    (l) 
    (setup-rule-difficulty c)
    (do-exp i)
    (format t "|"))
  ;(analyze-data)
  )


(defun do-exp (i)
  ;;note that the dm perfect must be altered to reflect rule condition c
 
  (setf *pp* (1+ i))

  (setf *random-walk-threshold* 1) ;;steps in the rw
    
    ;;reset act-r
    (reset)
  
    ;;do main training
    (dotimes (i 1)
      (setf *do-training* 1)
      (do-trials (permute-list *training*)))
    
    (dotimes (i 4)
      ;;do experimental trials - random sample of six stimuli from each condition
      
      (setf *block* i)
      
      (setf *do-training* 0)
      (do-trials (get-exp-block-trials-list))
    
      (setf *do-training* 1)
      (do-trials (permute-list *training*))))


(defun do-trials (lis)
  (cond ((null lis) nil)
        (t (do-trial (car lis)) (do-trials (cdr lis)))))
  

(defun do-trial (stimuli)

  ;;setup the experimental window and make act-r process it
  (let ((window (open-exp-window "similarity" :visible nil :width 700 :height 300)))

    (install-device window)

    ;;(setf *start-time* (get-time)) ;;; we are going to estimate the stimuli encoding time. 
    (setf *done-trial* nil)
    (setf *condition-trial* (if (= *do-training* 1) 'training (first stimuli))) ;;this so we can add non-confor as training 
    (setf *route* nil)

    (add-text-to-exp-window window (second stimuli) :width 40 :x 100 :y 150)
    (add-text-to-exp-window window (third stimuli) :width 40 :x 200 :y 150)
    (add-text-to-exp-window window (fourth stimuli) :width 40 :x 300 :y 150)
    (add-text-to-exp-window window (fifth stimuli) :width 40 :x 400 :y 150)
    (add-text-to-exp-window window (sixth stimuli) :width 40 :x 500 :y 150)
    (add-text-to-exp-window window (seventh stimuli) :width 40 :x 600 :y 150)
    
;    (proc-display :clear t)
    
;    window 
    
    (run 6000)
    (when (equal *done-trial* t)
      (clear-exp-window)))
)

(defun get-exp-block-trials-list ()
  ;;get a list of 24 trial stimuli, 6 from each condition 
  (let* ((c-high (get-list-n (permute-list *c-high*) 0 6))
         (c-low (get-list-n (permute-list *c-low*) 0 6))
         (n-high (get-list-n (permute-list *n-high*) 0 6))
         (n-low (get-list-n (permute-list *n-low*) 0 6))
         (list-1 (append c-high c-low n-high n-low)))
    (permute-list list-1))) 


(defun get-non-compliant-block-trials-list ()
  ;;get a list of 24 trial stimuli, 6 from each condition 
  (let* ((n-high (get-list-n (permute-list *n-high*) 0 6))
         (n-low (get-list-n (permute-list *n-low*) 0 6))
         (list-1 (append n-high n-low)))
    (permute-list list-1))) 


(defun get-list-n (lis i n)
  ;;returns the first N elements from a list LIS
  ;;BEWARE this does not check that n is not greater than (length lis)
  (cond ((= i n) nil)
        (t (cons (car lis) (get-list-n (cdr lis) (1+ i) n)))))
  
#| 
(defmethod rpm-window-key-event-handler ((win rpm-window) key)
  ;;deal with key-presses and recording responses
  ;;For :judgements 
  ;;1 is 'yes' response to category membership 
  ;;0 is 'no' response to category membership
  (let* ((letter (string key))
         (time (get-time)))
    (setf *done-trial* t)
    (when (= *do-training* 0) (setf *response-RT* (cons (- (get-time) *foo*) *response-RT*)))
    (push (make-response :condition *condition-trial* 
                         :rt        (- time *start-time*) 
                         :accuracy (if (= (evaluate-response *condition-trial*) 
                                          (if (equal letter "k") 1 0))
                                     1 0)
                         :route *route*
                         :block *block*
                         :pp *pp*)
          *results*)))
|# 

(defun respond-to-key-press (model key)
	(declare (ignore model))
	 
	; (write key)
	 
	;;deal with key-presses and recording responses
	;;For :judgements 
	;;1 is 'yes' response to category membership 
	;;0 is 'no' response to category membership
	(let* 
		(
			(letter (string key))
			(time (get-time))
		)
		(setf *done-trial* t)
		(when (= *do-training* 0) (setf *response-RT* (cons (- (get-time) *foo*) *response-RT*)))
		(push 
			(make-response :condition *condition-trial* 
                         :rt        (- time *start-time*) 
                         :accuracy (if (= (evaluate-response *condition-trial*) 
                                          (if (equal letter "k") 1 0))
                                     1 0)
                         :route *route*
                         :block *block*
                         :pp *pp*)
			*results*
		)
	)
)

(add-act-r-command "my-key-press-cmd" 'respond-to-key-press "Deals with key press event") 
(monitor-act-r-command "output-key" "my-key-press-cmd") 


(defun analyze-data ()
  ;;main data analysis function 
  (let ((trial-per-condition 0)
        (blocks (my-list 0 *block*))
        (accuracy nil)
        (temp-accuracy nil))
    
    ;;find the number of trials per condition ... just to note there are actually six, but hey representation allows for variation
    (mapcar #'(lambda (x) (when (and (equal (response-condition x) 'c-high) (equal (response-block x) 0))
                            (setf trial-per-condition (1+ trial-per-condition)))) 
            *results*)
    
    ;;give the average rt for each condition
    ;(format t "~%~%c-high-1	c-high-2	c-high-3	c-high-4	c-low-1	c-low-2	c-low-3	c-low-4	n-high-1	n-high-2	n-high-3	n-high-4	n-low-1	n-low-2	n-low-3	n-low-4")

    (dotimes (pp *n-trials*)
      (format *output-path* "~%")
      (mapcar #'(lambda (j) 
                  (let ((mean nil)
                        (pp (1+ pp))
                        (cond-accuracy nil))
                    (mapcar #'(lambda (x) 
                                (let* ((temp (mapcar #'(lambda (y)
                                                         ;;RT analysis includes only correct response trials
                                                         (if (and (equal (response-condition y) j)
                                                                  (equal (response-block y) x)
                                                                  (equal (response-accuracy y) 1)
                                                                  (= (response-pp y) pp)
                                                                  )
                                                           (response-rt y) 
                                                           0)) 
                                                     *results*))
                                       (i (float (mydiv (apply #'+ temp) (my-length temp 0)))))
                                  
                                  ;(format t "~%block:~s, condition:~s,	~5,2F" j x (mean (ignore-zero temp)))
                                  
                                  (format *output-path* "~5,2F," (mean (ignore-zero temp)))

                                  (setf cond-accuracy (cons (length (ignore-zero temp)) cond-accuracy))
                                  (setf mean (cons i mean))))
                            blocks)
                    (setf temp-accuracy (cons (apply #'+ (mapcar #'(lambda (x) (- 6 x)) cond-accuracy)) temp-accuracy))
                    ;(format t "~%accuracy: ~s" (apply #'+ (mapcar #'(lambda (x) (- 6 x)) cond-accuracy)))
                    ;;(format t "~%~5,2F" (float (mydiv (apply #'+ mean) (length mean))))
                    ))
              '(c-high c-low n-high n-low))

      (setf accuracy (cons (reverse temp-accuracy) accuracy))
      (setf temp-accuracy nil)
      )
    ;(format t "~%(c-high	c-low	n-high	n-low)")
    (nl-print (reverse accuracy))
    ))


(defun prop ()
  (let ((sum 0) (rule-count 0))
    (mapcar #'(lambda (y) 
                (setf rule-count (+ (if (equal (response-route y) 'rule) 1 0) rule-count))
                (setf sum (+ (if (equal (response-route y) 'exemplar) 1 0) sum))) 
            *results*)
    ;(format t "~%~5,2F" 
    (float (/ rule-count (+ sum rule-count))))
  ;;(spp choose-rule-route choose-exemplar-route)
  )




;(defun pprint-results ()
;  (format *output-path* "~%~%~F,~F" *ret* (prop))
;  (analyze-data))





(defun nl-print (lis)
  (cond ((null lis) nil)
        (t (format *output-path* "~%") 
           (cvs-format (car lis))
           (nl-print (cdr lis)))))

(defun cvs-format (lis) 
  (cond ((null lis) nil)
        (t (format *output-path* "~s," (car lis))
           (cvs-format (cdr lis)))))
  

(defun ignore-zero (lis)
  (cond ((null lis) nil)
        ((= (car lis) 0) (ignore-zero (cdr lis)))
        (t (cons (car lis) (ignore-zero (cdr lis))))))

(defun mydiv (x y)
  (if (= y 0) 0 (/ x y)))

(defun my-length (lis c)
  (cond ((null lis) c)
        ((= (car lis) 0) (my-length (cdr lis) c))
        (t (my-length (cdr lis) (1+ c)))))



(defun my-list (i n)
  (cond ((> i n) nil)
        (t (cons i (my-list (1+ i) n )))))


(defun mean (lis)
  (float (mydiv (apply #'+ lis) (length lis))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Hacked function calls for model

(defun accuracy ()
  ;;NOTE : FOR EXP4
  ;;we are reversing the true accuracy on 10% of trials. 
  ;;returns t when stimuli classified as rule conforming when it 
  ;;was actually from a rule conforming condition
  ;(tpa (if (= (response-accuracy (car *results*)) 1) t nil)))
  (if (= (response-accuracy (car *results*)) 1) t nil))
;(let ((response (response-judgement (car *results*)))
;        (correct (evaluate-response *condition-trial*)))
;    (if (= response correct) t nil)))

(defun evaluate-response (condition)
  ;;returns 1 when trial is from a rule conforming condition
  (if (or (equal condition 'c-high) 
          (equal condition 'c-low)
          (equal condition 'training))
    1 0))

(defun winner (y n)
  ;;for the yes and no counts 
  ;;return the response key for larger of the 
  ;;winning counts
  (if (> y n) 1 0))


(defun tpa (arg)
  ;;given arg t or nil ...
  ;;return arg 90% and the opposite value 10%
  (let ((foo (permute-list (my-list 0 9))))
    (if (= (car foo) 0) 
      (if (equal arg t) nil t)
       arg)))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; ACT-R Model

(clear-all)

(define-model model-1
  
  ;;set the output traces 
  (sgp :v nil :act t :trace-detail low :show-focus nil :needs-mouse nil)
  
  ;;behavior controls ... 
  (sgp :esc t :mp 1 :er t :ul t :randomize-time t)
  
  ;;set parameters 
  ;;default values unless specified here (taken from Anderson and Betz)
  ;;note: default for mismatch penalty :mp is 1 ... 45 was given by A&B
  ;(sgp :ans 0.5 :egs 1.50 :rt -1.5 :lf 1.5 :bll .01 :ut -20) ;;:bll .05) ;;1.5

  ;;; could adjust the lf parameter to better fit the model to RT data? 

  (sgp :ans 0.5 :egs 0.50 :lf 1 :bll .5 :ut -20 :rt 0.0)  ;;rt = 0   :rt 2 
  ;(sgp-fct (list :rt *ret*))


  (sgp :declarative-num-finsts 20 :declarative-finst-span 20.0)

  (sgp :ms 1 :md -1 :mp 1)
  
  ;;default visual-location
  (set-visloc-default :attended new screen-x lowest)

  (chunk-type stimuli ft1 ft2 ft3 ft4 ft5 ft6 temp state)
  (chunk-type exemplar ft1 ft2 ft3 ft4 ft5 ft6 category)
  (chunk-type rule ft1 ft2 ft3 ft4 ft5 ft6 fts)
  (chunk-type ft st val)
  (chunk-type apply-rule r1 r2 r3 r4 r5 r6 s1 s2 s3 s4 s5 s6 match mismatch fts count)
  
  (add-dm 
   
   ;;three feature rule
   ;;;;;OLD (perfect ISA rule ft2 four ft4 three ft6 one)
   (perfect ISA rule ft1 "blank" ft2 four ft3 "blank" ft4 three ft5 "blank" ft6 one fts 3)
  
   ;;single feature rule
   ;;;;;OLD (perfect ISA rule ft2 four)
   ;(perfect ISA rule ft1 "blank" ft2 four ft3 "blank" ft4 "blank" ft5 "blank" ft6 "blank" fts 1)

   (one isa chunk) (two isa chunk) (three isa chunk) 
   (four isa chunk) (five isa chunk) (six isa chunk)
   (attend isa chunk) (attending isa chunk) (choose isa chunk) (loop isa chunk)
   (retrieve-exemplar isa chunk) (retrieve-rule isa chunk) (guess isa chunk) 
   (wait isa chunk) (set-correct isa chunk) (add-feat isa chunk)
   
   
   (goal isa stimuli temp "0" state attend))
  
  (set-base-levels (perfect 5));1000 -1000))

;;;;;;;;;;
;; Encode the current stimuli 

;; could the model learn which features to encode ... 
;; would defeat the whole point of exemplars though
;; for now assume all features are exhaustively attended

;; One interesting thought would be to only specify :attended nil
;; then terminate when that returns error ... given loss control structure should learn search?? 

(P attend 
   =goal> 
      ISA    stimuli
      state  attend 
   =visual-location> 
      ISA    visual-location
   ?visual>
      state  free
==>
   +visual> 
      ISA    move-attention
      screen-pos =visual-location
   =goal> 
      state  attending
)

(P encode-1
   ;;use a temp slot to stop pm here
   =goal> 
      ISA   stimuli
      temp  =old
      state attending
   =visual> 
      ISA   text 
      value "1"
==>
   =goal> 
      temp  one
      state add-feat
)

(P encode-2
   ;;use a temp slot to stop pm here
   =goal> 
      ISA   stimuli
      temp  =old
      state attending
   =visual> 
      ISA   text 
      value "2"
==>
   =goal> 
      temp  two
      state add-feat
)

(P encode-3
   ;;use a temp slot to stop pm here
   =goal> 
      ISA   stimuli
      temp  =old
      state attending
   =visual> 
      ISA   text 
      value "3"
==>
   =goal> 
      temp  three
      state add-feat
)

(P encode-4
   ;;use a temp slot to stop pm here
   =goal> 
      ISA   stimuli
      temp  =old
      state attending
   =visual> 
      ISA   text 
      value "4"
==>
   =goal> 
      temp  four
      state add-feat
)

(P encode-5
   ;;use a temp slot to stop pm here
   =goal> 
      ISA   stimuli
      temp  =old
      state attending
   =visual> 
      ISA   text 
      value "5"
==>
   =goal> 
      temp  five
      state add-feat
)

(P encode-6
   ;;use a temp slot to stop pm here
   =goal> 
      ISA   stimuli
      temp  =old
      state attending
   =visual> 
      ISA   text 
      value "6"
==>
   =goal> 
      temp  six
      state add-feat
)


(P feat-1 
   =goal> 
      ISA   stimuli
      ft1   nil
      ft2   nil 
      ft3   nil
      ft4   nil
      ft5   nil
      ft6   nil
      temp  =val
      state add-feat
==>
   =goal>
      state  attend
      ft1    =val
   +visual-location>
      ISA   visual-location 
      :attended nil
      > screen-x 190
      < screen-x 210
)

(P feat-2
   =goal> 
      ISA   stimuli
      ft1   =ft1
      ft2   nil
      ft3   nil
      ft4   nil
      ft5   nil
      ft6   nil
      temp  =val
      state add-feat
==>
   =goal>
      state  attend
      ft2    =val   
   +visual-location>
      ISA   visual-location 
      :attended nil
      > screen-x 290
      < screen-x 310
)

(P feat-3
   =goal> 
      ISA   stimuli
      ft1   =ft1
      ft2   =ft2
      ft3   nil
      ft4   nil
      ft5   nil
      ft6   nil
      temp  =val
      state add-feat
==>
   +visual-location>
      ISA   visual-location 
      :attended nil
      > screen-x 390
      < screen-x 410
   =goal>
      state  attend
      ft3    =val
)

(P feat-4
   =goal> 
      ISA   stimuli
      ft1   =ft1 
      ft2   =ft2 
      ft3   =ft3
      ft4   nil
      ft5   nil
      ft6   nil
      temp  =val
      state add-feat
==>
   +visual-location>
      ISA   visual-location 
      :attended nil
      > screen-x 490
      < screen-x 510
   =goal>
      state  attend
      ft4    =val
)

(P feat-5
   =goal> 
      ISA   stimuli
      ft2   =ft2 
      ft3   =ft3
      ft4   =ft4
      ft5   nil
      ft6   nil
      temp  =val
      state add-feat
==>
   +visual-location>
      ISA   visual-location 
      :attended nil
      > screen-x 590
      < screen-x 610
   =goal>
      state  attend
      ft5    =val
)

(P feat-6
   ;;finish encoding
   ;;set success flag
   ;;for simplisty set timer here also
   =goal> 
      ISA   stimuli
      ft1   =ft1
      ft2   =ft2 
      ft3   =ft3
      ft4   =ft4
      ft5   =ft5
      ft6   nil
      temp  =val
      state add-feat
==>
 ;;basically disregarding stimuli encoding time ... can later estimate as single parameter. 
 !eval! (setf *start-time* (- (get-time) 555)) ;;555)) ;; 185)) ;; ;235))
 ;!eval! (setf *start-time* (get-time))
 !eval! (setf *foo* (get-time))
   =goal>
      ft6    =val   
      state  choose
)
(spp feat-6 :reward 20)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Deal with training trials

(P do-training-trials 
   =goal> 
      ISA   stimuli
      ft1   =ft1
      ft2   =ft2 
      ft3   =ft3
      ft4   =ft4
      ft5   =ft5
      ft6   =ft6
      state    choose
   ?manual> 
      state free
 !eval! (= *do-training* 1)
==>
;; !eval! (format t "~%Doing training")
 !bind! =category (evaluate-response *condition-trial*)
   +manual>
      ISA      press-key
      key      "t"
   =goal>
      ft1      nil
      ft2      nil 
      ft3      nil
      ft4      nil
      ft5      nil
      ft6      nil
      state    nil
   +goal> 
      ISA      exemplar 
      ft1      =ft1
      ft2      =ft2
      ft3      =ft3
      ft4      =ft4
      ft5      =ft5
      ft6      =ft6
      category =category
)


(P credit-success-for-training-trials
;; This is hacked up, but reflects perfect feedback
   =goal>
      ISA      exemplar
      category =cat
   ?manual>
      state    free
 !eval! (= *do-training* 1)
==>
   +goal>
      ISA      stimuli
      temp     "0"
      state    attend
)
(spp credit-success-for-training-trials :reward 20)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Exemplar route 

;;; Anderson and Betz suggest that mutiple retrievals on random walk or single winner takes-all  
;;; are infact equivilant ... except for timing info. 
;;; for now i have just implemented winner-takes-all ... random walk would just iterate this process controlling retrievals. 

(P choose-exemplar-route 
   =goal> 
      ISA   stimuli
      ft1   =ft1
      ft2   =ft2 
      ft3   =ft3
      ft4   =ft4
      ft5   =ft5
      ft6   =ft6
      state choose
  !eval! (= *do-training* 0)
==>
;; !eval! (format t "~%Exemplar route with ~s item, " (if (equal =ft2 'four) 'compliant 'noncompliant)) ;;this is hardcoded for easy rule
 !eval! (setf *route* 'exemplar)
 !eval! (setf *count-yes* 0) ;;init and then increment? 
 !eval! (setf *count-no* 0)
 !eval! (setf *retrieval-check* (get-time))
    +retrieval> 
      ISA     exemplar
      ft1     =ft1
      ft2     =ft2 
      ft3     =ft3
      ft4     =ft4
      ft5     =ft5
      ft6     =ft6
      :recently-retrieved reset
   =goal> 
      state retrieve-exemplar
)

(P done-walk-yes
   =goal> 
      ISA       stimuli 
      state     retrieve-exemplar
   =retrieval> 
      ISA       exemplar 
   ?manual> 
      state    free
==>
 ;;!eval!  (format t "~%exemplar RT: ~s" (- (get-time) *foo*))
 !eval! (setf *exemplar-RT* (cons (- (get-time) *foo*) *exemplar-RT*))
 !eval! (setf *foo* (get-time))
 !eval! (setf *retrieve-RT* (cons (- (get-time) *retrieval-check*) *retrieve-RT*))
   +manual> 
     ISA       punch
     hand      right
     finger    middle
   =goal>
      state    wait
)


(P done-walk-no
   =goal> 
      ISA       stimuli 
      state     retrieve-exemplar
      state    retrieve-exemplar
   ?retrieval>
      state    error
   ?manual> 
      state    free
==>
 ;;!eval!  (format t "~%exemplar RT: ~s" (- (get-time) *foo*))
 !eval! (setf *exemplar-RT* (cons (- (get-time) *foo*) *exemplar-RT*))
 !eval! (setf *foo* (get-time))
 !eval! (setf *retrieve-RT* (cons (- (get-time) *retrieval-check*) *retrieve-RT*))
   +manual> 
     ISA       punch
     hand      left
     finger    middle
   =goal>
      state    wait
)




   
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Rule route 

(P choose-rule-route
   =goal> 
      ISA   stimuli
      state choose
 !eval! (= *do-training* 0)
==>
; !eval! (format t "~%Doing rule ")
 !eval! (setf *route* 'rule)
 !eval! (setf *rule-ft-counter* 0)
 !eval! (setf *retrieval-check* (get-time))
   +retrieval> 
      ISA   rule
   =goal>
      state retrieve-rule
)


(P failure-to-retrieve-rule-yes
   ;;we might think about a rule learning paradigm to get it upto baselevel
   ;;can enter a loop where context is given to retrieve rule until it can be recalled with bl
   ;;alternatively just set bl so does not fail! 
   =goal> 
      ISA      stimuli
      state    retrieve-rule
   ?retrieval>
      state    error
   ?manual> 
      state    free
==>
;  !eval! (format t "~%Failure to retrieve rule")
!eval! (setf *retrieve-RT* (cons (- (get-time) *retrieval-check*) *retrieve-RT*))
   +manual> 
     ISA       punch
     hand      right
     finger    middle 
   =goal>
      state    wait
)


(P failure-to-retrieve-rule-no
   ;;we might think about a rule learning paradigm to get it upto baselevel
   ;;can enter a loop where context is given to retrieve rule until it can be recalled with bl
   ;;alternatively just set bl so does not fail! 
   =goal> 
      ISA      stimuli
      state    retrieve-rule
   ?retrieval>
      state    error
   ?manual> 
      state    free
==>
;  !eval! (format t "~%Failure to retrieve rule")
 !eval! (setf *foo* (get-time))
!eval! (setf *retrieve-RT* (cons (- (get-time) *retrieval-check*) *retrieve-RT*))
   +manual> 
     ISA       punch
     hand      left
     finger    middle 
   =goal>
      state    wait
)

(P retrieved-rule
   ;;kill the current goal
   ;;move to rule application structure
   =goal> 
      ISA   stimuli
      ft1   =s1
      ft2   =s2
      ft3   =s3
      ft4   =s4
      ft5   =s5
      ft6   =s6 
      state retrieve-rule
   =retrieval>
      ISA   rule
      ft1   =r1
      ft2   =r2
      ft3   =r3
      ft4   =r4
      ft5   =r5
      ft6   =r6
      fts   =n 
==>
!eval! (setf *retrieve-RT* (cons (- (get-time) *retrieval-check*) *retrieve-RT*))
   =goal> 
      ft1   nil
      ft2   nil
      ft3   nil
      ft4   nil
      ft5   nil
      ft6   nil
      temp  nil
      state nil
   +goal> 
      ISA   apply-rule
      r1    =r1
      r2    =r2
      r3    =r3
      r4    =r4
      r5    =r5
      r6    =r6
      s1    =s1
      s2    =s2
      s3    =s3
      s4    =s4
      s5    =s5
      s6    =s6
      fts   =n
      match 0
      mismatch 0
      count 0
     
)

;;; for the rule route each feature is checked in turn

;; matching rule features
;; Note the setting of the matching ft to "blank" on the RHS on the rule 
;; simply set a flag that feature has been checked ... therefore stopping condition is implicit. 

(P feature1-matches-rule
   =goal> 
      ISA   apply-rule
      s1    =val
      r1    =val
      match =n
      count =c
 !bind! =c1 (1+ =c)
 !bind! =n1 (1+ =n)
==> 
   =goal>
      r1    "blank"
      match =n1
      count =c1
)

(P feature2-matches-rule
   =goal> 
      ISA   apply-rule
      s2    =val
      r2    =val
      match =n
      count =c
 !bind! =c1 (1+ =c)
 !bind! =n1 (1+ =n)
==> 
   =goal>
      r2    "blank"
      match =n1
      count =c1
)

(P feature3-matches-rule
   =goal> 
      ISA   apply-rule
      s3    =val
      r3    =val
      match =n
      count =c
 !bind! =c1 (1+ =c)
 !bind! =n1 (1+ =n)
==> 
   =goal>
      r3    "blank"
      match =n1
      count =c1
)

(P feature4-matches-rule
   =goal> 
      ISA   apply-rule
      s4   =val
      r4    =val
      match =n
      count =c
 !bind! =c1 (1+ =c)
 !bind! =n1 (1+ =n)
==> 
   =goal>
      r4    "blank"
      match =n1
      count =c1
)

(P feature5-matches-rule
   =goal> 
      ISA   apply-rule
      s5    =val
      r5    =val
      match =n
      count =c
 !bind! =c1 (1+ =c)
 !bind! =n1 (1+ =n)
==> 
   =goal> 
      r5    "blank"
      match =n1
      count =c1
)

(P feature6-matches-rule
   =goal> 
      ISA   apply-rule
      s6    =val
      r6    =val
      match =n
      count =c
 !bind! =c1 (1+ =c)
 !bind! =n1 (1+ =n)
==> 
   =goal> 
      r6    "blank"
      match =n1
      count =c1
)

;;;mismatch 

(P feature1-mismatches-rule
   =goal> 
      ISA   apply-rule
     - s1    =val
      r1    =val
      mismatch =n
      count =c
 !bind! =c1 (1+ =c)
 !bind! =n1 (1+ =n)
 !eval! (not (equal =val "blank"))
==> 
   =goal>
      r1    "blank"
      mismatch =n1
      count =c1
)

(P feature2-mismatches-rule
   =goal> 
      ISA   apply-rule
     - s2    =val
      r2    =val
      mismatch =n
      count =c
 !bind! =c1 (1+ =c)
 !bind! =n1 (1+ =n)
 !eval! (not (equal =val "blank"))
==> 
   =goal>
      r2    "blank"
      mismatch =n1
      count =c1
)

(P feature3-mismatches-rule
   =goal> 
      ISA   apply-rule
     - s3    =val
      r3    =val
      mismatch =n
      count =c
 !bind! =c1 (1+ =c)
 !bind! =n1 (1+ =n)
 !eval! (not (equal =val "blank"))
==> 
   =goal>
      r3    "blank"
      mismatch =n1
      count =c1
)

(P feature4-mismatches-rule
   =goal> 
      ISA   apply-rule
     - s4   =val
      r4    =val
      mismatch =n
      count =c
 !bind! =c1 (1+ =c)
 !bind! =n1 (1+ =n)
 !eval! (not (equal =val "blank"))
==> 
   =goal>
      r4    "blank"
      mismatch =n1
      count =c1
)

(P feature5-mismatches-rule
   =goal> 
      ISA   apply-rule
     - s5    =val
      r5    =val
      mismatch =n
      count =c
 !bind! =c1 (1+ =c)
 !bind! =n1 (1+ =n)
 !eval! (not (equal =val "blank"))
==> 
   =goal>
      r5    "blank"
      mismatch =n1
      count =c1
)

(P feature6-mismatches-rule
   =goal> 
      ISA   apply-rule
     - s6    =val
      r6    =val
      mismatch =n
      count =c
 !bind! =c1 (1+ =c)
 !bind! =n1 (1+ =n)
 !eval! (not (equal =val "blank"))
==> 
   =goal>
      r6    "blank"
      mismatch =n1
      count =c1
)

;;;

;;note still need to use =c as max counter so that this choice points is exluded
;;until all the features of the rule have been checked. 

(P rule-matched
   =goal> 
      ISA      apply-rule
      s1       =s1
      s2       =s2
      s3       =s3
      s4       =s4
      s5       =s5
      s6       =s6
      match    =n1
      mismatch =n2
      count    =c
      fts      =c
   ?manual> 
      state free
 !eval! (>= =n1 1)
 !eval! (= =n2 0)
==>
; !eval! (format t " ft2 ~s (4), all-feats-match-rule match: ~s, mismatch: ~s." =s2 =n1 =n2)
; !eval!  (format t "~%rule RT: ~s" (- (get-time) *foo*))
!eval! (setf *rule-RT* (cons (- (get-time) *foo*) *rule-RT*))
 !eval! (setf *foo* (get-time))
   +manual> 
     ISA       punch
     hand      right
     finger    middle
   +goal> 
      ISA      stimuli
      ft1      =s1
      ft2      =s2
      ft3      =s3
      ft4      =s4
      ft5      =s5
      ft6      =s6
      state    wait
)

(P rule-mismatched
   =goal> 
      ISA      apply-rule
      s1       =s1
      s2       =s2
      s3       =s3
      s4       =s4
      s5       =s5
      s6       =s6
      match    =n1
      mismatch =n2
      count    =c
      fts      =c 
   ?manual> 
      state free
 !eval! (or (= =n1 0) (> =n2 0))
==>
; !eval! (format t " ft2 ~s (4), rule missed match: ~s, mismatch: ~s." =s2 =n1 =n2)
; !eval!  (format t "~%rule RT: ~s" (- (get-time) *foo*))  
!eval! (setf *rule-RT* (cons (- (get-time) *foo*) *rule-RT*))
 !eval! (setf *foo* (get-time))
   +manual> 
     ISA       punch
     hand      left
     finger    middle
   +goal> 
      ISA      stimuli
      ft1      =s1
      ft2      =s2
      ft3      =s3
      ft4      =s4
      ft5      =s5
      ft6      =s6
      state    wait
)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Evaluate response 

;;; first check accuracy for learning mechanisms 
;;; then provide feedback so correct exemplars are stored

(P correct
   =goal> 
      ISA     stimuli
      state   wait
   ?manual> 
      state   free
 !eval! (equal t (accuracy))
==>
;; !eval! (format t " correct")
   =goal> 
      ft1      nil
      ft2      nil
      ft3      nil
      ft4      nil
      ft5      nil
      ft6      nil
      temp     nil
      state    nil
   +goal>
      ISA      stimuli
      temp     "0"
      state    attend
)
(spp correct :reward 20)

(P incorrect 
   =goal> 
      ISA     stimuli
      state   wait
   ?manual> 
      state   free
 !eval! (equal nil (accuracy))
==>
;; !eval! (format t " incorrect")
   =goal> 
      ft1      nil
      ft2      nil
      ft3      nil
      ft4      nil
      ft5      nil
      ft6      nil
      temp     nil
      state    nil
   +goal>
      ISA      stimuli
      temp     "0"
      state    attend
)
(spp correct :reward 20)
(spp incorrect :reward 0)

(spp-fct (list 'choose-rule-route :u *rule-successes*))
(spp-fct (list 'choose-exemplar-route :u *exemplar-successes*))


;(spp choose-rule-route :successes 1500 :failures 100 :efforts 100)
;(spp choose-exemplar-route :successes 500 :failures 100 :efforts 100)  ;1000 :failures 100 :efforts 100)



; (setf *actr-enabled-p* t)
(goal-focus goal)) 









