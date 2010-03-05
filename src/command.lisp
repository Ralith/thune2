(in-package :thune2)
(declaim (optimize (debug 3)))

(defun add-command (name function)
  "Configures a command identified by NAME calling FUNCTION for use, overriding the previous function, if any."
  (add-handler (symbolicate 'command- name)
               #'(lambda (conf channel message)
                   (when (eq name (command-called conf message))
                     (funcall function conf channel message)))))

(defun remove-command (name)
  "Removes command identified by NAME."
  (remove-handler (symbolicate 'command- name)))

(defmacro defcommand (name args &body body)
  "Defines and configures for use a new command."
  (assert (= (length args) 3))
  `(add-command ',name (lambda ,args ,@body)))

(defun command-called (conf message &aux
                       (text (car (last (parameters message))))
                       (end (position #\Space text)))
  "Which, if any, command MESSAGE calls."
  (when (and end (< end (length text))
             (eq (aref text 0) (conf-value conf :cmdchar)))
    (find-symbol (string-upcase (subseq text 1 end)))))

(defun command-args (message &aux
                     (text (car (last (parameters message))))
                     (start (position #\Space text)))
  "The argument string of command-form message MESSAGE, if any."
  (when (and start (< start (length text)))
    (subseq text (1+ start))))

