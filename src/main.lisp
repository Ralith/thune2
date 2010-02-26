(in-package :thune2)

(defun main (&aux
             (conf (load-conf "./thune2.conf"))
             (connection (ircl:connect (conf-value conf :server))))
  (unwind-protect (progn 
                    (login connection
                           (conf-value conf :nick) (conf-value conf :user) (conf-value conf :real-name))
                    (apply #'join connection (conf-value conf :channels))
                    (sleep 10))
    (quit connection)))
