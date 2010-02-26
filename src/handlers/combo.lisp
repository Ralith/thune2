(in-package :thune2)

(let ((last-messages ())
      (repetition-counts ()))
  (defhandler combo (conf channel message)
    (when (string= "PRIVMSG" (command message))
      (let ((string (car (last (parameters message)))))
        (let* ((from (first (parameters message)))
               (current (assoc from last-messages
                               :test #'string-equal)))
          (if current
              (let ((current-count (assoc from repetition-counts
                                          :test #'string-equal)))
                (if (string= string (cdr current))
                    (if current-count
                        (incf (cdr current-count))
                        (push (cons from 1) repetition-counts))
                    (progn
                      (setf (cdr current) string)
                      (when current-count
                        (setf (cdr current-count) 1))))
                (when (and current-count
                           (>= (cdr current-count) 3))
                  (send channel (reply-to conf message string))
                  (setf (cdr current-count) 0)))
              (push (cons from string)
                    last-messages)))))))
