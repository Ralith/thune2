(in-package :thune2)

(defvar *handlers* ()
  "Alist of handler names and function specifiers.")

(defun add-handler (name function)
  "Configures a handler identified by NAME calling FUNCTION for use, overriding the previous function, if any."
  (alist-set *handlers* name function))

(defun remove-handler (name)
  "Removes handler identified by NAME."
  (setf *handlers* (remove name *handlers* :key #'car)))

(defmacro defhandler (name args &body body)
  "Defines and configures for use a new handler."
  `(add-handler ',name (lambda ,args ,@body)))

(defun call-handlers (channel message)
  "Spawns all handlers on MESSAGE."
  (mapcar (lambda (handler)
            (pexec (:name (format nil "Message handler: ~a" (car handler)))
              (funcall (cdr handler) channel message)))
          *handlers*))
