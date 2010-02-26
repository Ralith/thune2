(in-package :thune2)

(defmacro alist-set (alist key value &key test)
  "If KEY exists in the alist at PLACE, its value is set to VALUE; otherwise, (KEY . VALUE) is pushed to PLACE."
  (with-gensyms (old)
    (once-only (key)
      `(let ((,old (assoc ,key ,alist ,@(when test `(:test ,test)))))
         (if ,old
             (setf (cdr ,old) ,value)
             (push (cons ,key ,value) ,alist))))))

(defun reply-target (conf message)
  "Returns the most appropriate channel or nick to receive a reply to MESSAGE."
  (let ((target (first (parameters message))))
    (if (string= target (conf-value conf :nick))
        (nick (prefix message))
        target)))

(defun reply-to (conf message reply)
  "Generates a message that will send REPLY in a reply to MESSAGE."
  (make-message (command message) (reply-target conf message) reply))
