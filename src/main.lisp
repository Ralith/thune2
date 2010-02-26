(in-package :thune2)

(defun main (&aux
             (conf (load-conf "./thune2.conf"))
             (connection (ircl:connect (conf-value conf :server))))
  (ircl:send-message connection (ircl:make-message "NICK" (conf-value conf :nick)))
  (ircl:send-message connection (ircl:make-message "USER"
                                                   (conf-value conf :user)
                                                   "." "."
                                                   (conf-value conf :real-name)))
  (ircl:send-message connection (ircl:make-message "JOIN"
                                                   (reduce (lambda (accum channel)
                                                             (concatenate 'string
                                                                          accum "," channel))
                                                           (conf-value conf :channels))))
  (sleep 10)
  (ircl:send-message connection (ircl:make-message "QUIT")))
