(in-package :thune2)

(defun login (connection nick user real-name)
  (ircl:send-message connection (ircl:make-message "NICK" nick))
  (ircl:send-message connection (ircl:make-message "USER" user "." "." real-name)))

(defun join (connection &rest channels)
  (ircl:send-message connection
                     (ircl:make-message "JOIN"
                                        (reduce (lambda (accumulator channel)
                                                  (concatenate 'string
                                                               accumulator "," channel))
                                                channels))))

(defun quit (connection &optional reason)
  (ircl:send-message connection (ircl:make-message "QUIT" (or reason ""))))
