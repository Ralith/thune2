(in-package :thune2)
(defhandler autojoin (conf channel message)
  (when (string= "001" (command message)) ; RPL_WELCOME, defined in RFC2812 section 5.1
    (send channel
          (make-message "JOIN"
                        (reduce (lambda (accum channel)
                                  (concatenate 'string
                                               accum "," channel))
                                (conf-value conf :channels))))))
