; Symbolic Representation for Music

; This is the main file for the system allowing the user to
; call the enviornment and began to input musical notes and chords. 
; going to use notes in midi, need one value
; define intervals in terms of semitones


; other methods
; outside of new-piece function
; interval
; chord
; measure
; transpose
; invert -> chords
; note
; valid-pitch?
; valid-octave?
; valid-time?
; measure?
; chord?
; interval?
; note?

; note data structure -> '(note a# 5 0.25)
; note operatiosn car-caddr -> get-pitch etc...
; 
(define (get-last-elem lst)
  (list-ref lst (- (length lst) 1)))

(interval-associations)

(define (get-pitch-list-from-key key)
  (define (add-to-list lst)
    (if (= (length lst) 7)
      lst
      (add-to-list (append lst (list (get-next-pitch (get-last-elem lst)))))))
  (add-to-list (list (get-pitch key))))


(define (get-value note-string)
  (let 
    ((pitch-value (attach-semitone (get-pitch note-string)))
    (accent-value (get-accent-count (get-accent note-string))))
      (modded-val (+ pitch-value accent-value))))

(define (adjust-accents lst newlst note-value tones)
  (if (not (pair? lst))
    newlst
    (adjust-accents 
      (cdr lst) 
      (append newlst (list (add-accent (car lst) note-value))) 
      (modded-val (+ note-value (car tones)))
      (cdr tones))))

(define (get-scale key tones)
  (adjust-accents (get-pitch-list-from-key key) `() (get-value key) tones))


(define (new-piece #!optional pitch-str time-sig)
  ; creates a new piece in the key of "key" with 
  ; the time signature given by "time"
  (define cent-notes-table
    (make-eq-hash-table))

  (run)
  (define-cell piece)
  (eq-put! piece 'type 'piece)
  (eq-put! piece 'pitch #\C)
  (eq-put! piece 'accent (list "b" 0))
  (eq-put! piece 'octave 4)
  (eq-put! piece 'numer-time 4)
  (eq-put! piece 'denom-time 4)
  (eq-put! piece 'measures '())
  (eq-put! piece 'cent-notes-table cent-notes-table)

  ; key handle string, symbol
  ; generic time 
  ; defaults to 4/4
  ; (define time "")
  ; (update-time time)
  ; should handle integer, string, symbol
  ; assume for now only one time sig
  ; change to tagged list later if multiple time sig
  ; '(
  ;    (4/4 note1 note2 note3 note4)
  ;    (4/4 note1 note2 note3 note4)
  ;    (2/4 note1 note2)
  ;    (3/4 note1 note2)
  ;  )
  ; if want to get measure do list->vector first

  ; type checkers for cells
  (define (key? symb)
    (eq? symb 'key))
  (define (time? symb)
    (eq? symb 'time))
  (define (octave? symb)
    (eq? symb 'octave))
  (define (measures? symb)
    (eq? symb 'measures))
  (define (table? symb)
    (eq? symb 'table))

  ; type checkers for cell data
  ; TODO make more strict
  (define (key-type? data)
    ; only symbols and strings
    ; why not chars? -- ugly
    (displaym "key-type" data)
    (or (symbol? data) (string? data)))

  (define (time-type? data)
    ; only strings
    ; with the proper structure
    (string? data))
  (define (octave-type? data)
    ; numbers or symbols and strings
    ; that can become numbers
    valid-octave?)
  (define (measures-type? data)
    ; only lists of measures
    (list? data))


  (define no-op (lambda (label . args) 
    (displaym "No Generic Handler Found For" label args) ; debugging
    #f))
  ; generics
  (define (get-key x)
    (displaym "get-key")
    (key-name piece)
  )

  (define (get-cent-notes-table x)
    (displaym "get cent notes table")
    (display piece)
    (display (get-pitch piece))
    (cent-notes-table-get piece)
  )

  (define (get-time x)
    (displaym "get-time")
    (time-name piece)
  )

(define (fill-cent-notes-table)
  (for-each
    (lambda (note)
      (hash-table/put! cent-notes-table (get-value note) note))
    (get-scale (get-key piece) major-tones))
)

  (define get
    (make-generic-operator 1))

  (defhandler get 
    get-key key?)
  (defhandler get
    get-cent-notes-table table?)
  (defhandler get 
    get-time time?)
  (defhandler get 
    (lambda(x) (eq-get piece x)) octave?)
  (defhandler get 
    (lambda(x) (eq-get piece x)) measures?)
  (defhandler get 
    (lambda(x)
      (no-op "Get" x)) default-object?)

  (define (set-data type value)
    (displaym "set-data piece" piece)
    (displaym "set-data type" type)
    (displaym "set-data coerced" value)
    (if (not (eqv? #f value))
      (eq-put! piece 'data value)
      (displaym "Invalid Value for " type value)))

  (define (set-pitch-sym type pitch-str)
    (set-pitch-str type (symbol->string pitch-str))
  )

  (define (set-pitch-str type pitch-str)
    (if (valid-pitch? pitch-str)
      (begin 
        (eq-put! piece 'pitch (get-pitch pitch-str))
        (eq-put! piece 'accent (get-accent pitch-str))
        (if (equal? "" (str:get-octave-str pitch-str))
          #f
          (eq-put! piece 'octave (get-octave pitch-str))
        )
      )
      (displaym "Invalid Pitch String" pitch-str)
    )
  )  

  (define (set-time type time-str)
    (if (valid-time? time-str)
      (let*
        (
          (backslash-index (string-search-forward "/" time-str))
          (numer (string->number (string-head time-str backslash-index)))
          (denom (string->number (string-tail time-str (+ 1 backslash-index))))
        )
        (eq-put! piece 'numer-time numer)
        (eq-put! piece 'denom-time denom)
      )
      (displaym "Invalid Time String" time-str)
    )
  )

  (define set
    (make-generic-operator 2))
  (defhandler set 
    set-pitch-str key? string?)
  (defhandler set 
    set-pitch-sym key? symbol?)
  (defhandler set 
    set-time time? string?)
  (defhandler set 
    (lambda(type val) 
      (set-data type val)) octave? octave-type?)
  (defhandler set 
    (lambda(type val) 
      (set-data type val)) measures? measures-type?)
  (defhandler set 
    (lambda(type val)
      (no-op "Set" type val)) any? default-object?)


  ; method dispatch
  (define (method-dispatch tag . args)
    (cond 
         ((eq? tag 'get) (apply get args))
         ((eq? tag 'set) (apply set args))
         ; ((eq? tag 'add) (apply add args))
         (else (displaym "ERROR: \n\t Method Not Found" tag))
    )
  )



  (set 'key pitch-str)
  ; (displaym "Before" (get 'time))
  (set 'time time-sig)
  ; (displaym "After" (get 'time))
  ; (set 'octave (get-octave key-sig))
  ; (time:update time)

  (fill-cent-notes-table)

  method-dispatch
)


(define (convert-note note-str piece)
  (let ((newnote (hash-table/get (piece 'get 'table) (get-value note-str) "null")))
    (if (not (equal? newnote "null"))
      newnote
      note-str)))
  