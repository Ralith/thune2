(in-package :thune2)
(declaim (optimize (debug 3)))

(let ((seen ()))
  (defhandler seen (conf channel message)
    (declare (ignore conf) (ignore channel))
    (when (typep (prefix message) 'user)
     (let* ((nick (nick (prefix message))))
       (alist-set seen nick message :test #'string-equal))))

  (defcommand seen (conf channel message)
    "Replies with the time since provided nick has been seen, and what s/he was doing at the time."
    (let* ((nick (command-args message))
           (last (cdr (assoc nick seen :test #'string-equal))))
      (send
       channel
       (reply-to
        conf message
        (if (string= nick (conf-value conf :nick))
            "sup"
            (if last
                (format nil "Last saw ~a ~a ago, ~a"
                        nick
                        (format-interval (- (get-universal-time) (received last)))
                        (strcase (command last)
                          (("PRIVMSG" "NOTICE")
                           (format nil "speaking to ~a, ~a."
                                   (first (parameters last))
                                   (if (ctcpp last)
                                       (if (emotep last)
                                           (format nil "emoting \"* ~a ~a\""
                                                   nick
                                                   (let* ((string (second (parameters last)))
                                                          (text-start (1+ (position #\Space string))))
                                                     (when (> (length string) text-start) (subseq string text-start (1- (length string))))))
                                           (format nil "sending a CTCP \"~a\"" (let ((string (second (parameters last))))
                                                                                 (subseq string 1 (1- (length string))))))
                                       (format nil "saying \"~a\"" (second (parameters last))))))
                          ("PART"
                           (format nil "leaving ~a, saying ~a."
                                   (first (parameters last))
                                   (if (second (parameters last))
                                       (format nil "\"~a\"" (second (parameters last)))
                                       "nothing.")))
                          ("JOIN"
                           (format nil "joining ~a." (first (parameters last))))
                          ("QUIT"
                           (format nil "quitting, saying ~a."
                                   (if (first (parameters last))
                                       (format nil "\"~a\"" (first (parameters last)))
                                       "nothing.")))
                          ("NICK"
                           (format nil "changing nick to \"~a\"."
                                   (first (parameters last))))
                          (t "doing something strange.")))
                (format nil "I've never seen anyone going by \"~a\"." nick))))))))