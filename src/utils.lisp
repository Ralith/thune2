(in-package :thune2)

(defmacro alist-set (alist key value &key test)
  "If KEY exists in the alist at PLACE, its value is set to VALUE; otherwise, (KEY . VALUE) is pushed to PLACE."
  (with-gensyms (old)
    (once-only (key)
      `(let ((,old (assoc ,key ,alist ,@(when test `(:test ,test)))))
         (if ,old
             (setf (cdr ,old) ,value)
             (push (cons ,key ,value) ,alist))))))

(defun reply-target (conf message)
  "Returns the most appropriate channel or nick to receive a reply to MESSAGE."
  (let ((target (first (parameters message))))
    (if (string= target (conf-value conf :nick))
        (nick (prefix message))
        target)))

(defun reply-to (conf message reply)
  "Generates a message that will send REPLY in a reply to MESSAGE."
  (make-message (command message) (reply-target conf message) reply))

(defun substitute-string (sequence old-pattern new-pattern)
  "Return SEQUENCE with all instances of OLD-PATTERN replaced with NEW-PATTERN."
  (let ((position (search old-pattern sequence))
        (result (copy-seq sequence)))
    (loop while position do
         (setf result
               (concatenate 'string
                            (subseq result 0 position)
                            new-pattern
                            (subseq result (+ position (length old-pattern)))))
         (setf position (search old-pattern result)))
    result))

(defun emotep (message)
  "Determines if MESSAGE is an IRC emote."
  (let ((string (car (last (parameters message))))
        (end (1+ (length "ACTION"))))
    (and (ctcpp message)
         string
         (> (length string) end)
         (string= (subseq string 1 end)
                  "ACTION"))))

(defun ctcpp (message)
  "Determines if MESSAGE is an IRC CTCP."
  (let* ((string (second (parameters message)))
         (length (length string)))
    (when (> length 0)
      (char= (code-char 1)
             (aref string 0) (aref string (1- length))))))

;;; TODO: Take a list of var-factor pairs
(defmacro %format-interval-distribute (vars factors)
  "Distributes (FIRST VARS) amongst (REST VARS) such that the value of each VAR is less than its corresponding FACTOR.  The factor corresponding to the last element of VARS, if any, is ignored to ensure support for large values."
  (let ((stack (gensym))
        (result (gensym))
        (remainder (gensym)))
   `(let ((,stack (quote ,factors)))
      ,@(mapcar (lambda (lower higher)
                  `(multiple-value-bind (,result ,remainder)
                       (floor ,lower (pop ,stack))
                     (setf ,higher ,result)
                     (setf ,lower ,remainder)))
                vars (rest vars)))))

(defmacro %format-interval-string (vars names)
  "Returns a human-readable string of the values of VARS referred to with their respective NAMES."
  (let ((in-string (gensym))
        (string (gensym)))
    `(let ((,in-string nil)
           (,string))
       ,@(mapcar (lambda (var name)
                  (let ((control-string (format nil "~~a ~a~~:p" name)))
                    `(when (> ,var 0)
                       (setf ,string
                             (concatenate 'string
                                          ,string
                                          (when ,in-string ", ")
                                          (format nil ,control-string ,var)))
                       (setf ,in-string t))))
                 vars names)
       ,string)))

(defun format-interval (seconds)
  "Returns a human-readable string representing the duration SECONDS in years, months, weeks, days, hours, minutes, and seconds, omitting zero values."
  (if (< seconds 1)
      "no time"
      (let ((years) (months) (weeks) (days) (hours) (minutes))
        (%format-interval-distribute (seconds minutes hours days weeks months years)
                                     (60 60 24 7 4 12))
        (%format-interval-string (years months weeks days hours minutes seconds)
                                 ("year" "month" "week" "day" "hour" "minute" "second")))))


(defmacro strcase (string &body cases)
  `(cond
     ,@(mapcar (lambda (case &aux
                         (key (first case))
                         (code (second case)))
                 
                 `(,(cond
                     ((listp key)
                      `(or ,@(mapcar (curry #'list 'string= string)
                                     key)))
                     ((eq key t) t)
                     (t `(string= ,string ,key)))
                    ,code))
               cases)))
