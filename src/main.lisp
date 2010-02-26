(in-package :thune2)

(defun main (&aux
             (conf (load-conf "./thune2.conf"))
             (connection (ircl:connect (conf-value conf :server)))
             (to-send (make-instance 'unbounded-channel)))
  ;; Queue login
  (mapc (curry #'send to-send)
        (list (make-message "NICK" (conf-value conf :nick))
              (make-message "USER" (conf-value conf :user) "." "." (conf-value conf :real-name))))
  ;; Establish autojoin handler
  (add-handler 'autojoin
               (lambda (channel message)
                 (when (string= "001" (command message)) ;RPL_WELCOME; see RFC2812 section 5.1
                   (send channel
                         (make-message "JOIN"
                                       (reduce (lambda (accum channel)
                                                 (concatenate 'string
                                                              accum "," channel))
                                               (conf-value conf :channels)))))))
  ;; Spawn main threads
  (pexec (:name "Receiver")
    (handler-bind
        ((error
          (lambda (e)
            (send to-send (make-message "QUIT" (format nil "Error: ~a" e))))))
      (handler-case (loop
                       for (message raw) = (multiple-value-list (get-message connection))
                       while message
                       do
                       (format t "-> ~a~%" raw)
                       (call-handlers to-send message))
        (end-of-file ()
          (format t "Disconnected.~%")
          (send to-send nil))))
    (format t "Receive thread terminating.~%"))
  (pexec (:name "Sender")
    (loop
       for message = (recv to-send)
       while message
       do
       (format t "<- ~a~%" (message->string message))
       (send-message connection message))
    (format t "Send thread terminating.~%"))
  ;; Idle and quit
  (sleep 10)
  (send to-send (make-message "QUIT")))
