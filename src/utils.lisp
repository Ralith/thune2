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
