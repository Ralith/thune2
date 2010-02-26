(in-package :thune2)

(defmacro alist-set (alist key value &key test)
  (with-gensyms (old)
    (once-only (key)
      `(let ((,old (assoc ,key ,alist ,@(when test `(:test ,test)))))
         (if ,old
             (setf (cdr ,old) ,value)
             (push (cons ,key ,value) ,alist))))))
