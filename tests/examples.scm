(define my-test-suite (test-suite-wrapper "Example Suite"))
(define ttest (test my-test-suite))
(ttest #f "this should fail")
(ttest #f "this should also fail")
(ttest #f "this should also fail2")
(ttest #t "this should pass")

(define my-test-suite2 (test-suite-wrapper "Example Suite2"))
(define ttest2 (test my-test-suite2))
(ttest2 #t "this should pass")
(ttest2 #t "this should also pass")