(in-package :thune2)

(defhandler revenge (conf channel message &aux (nick (conf-value conf :nick)))
  (let ((string (car (last (parameters message)))))
    (when (and (emotep message)
               (search nick string))
      (send channel
            (reply-to conf message
                      (substitute-string string
                                         nick (nick (prefix message))))))))