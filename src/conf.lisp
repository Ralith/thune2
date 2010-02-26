(in-package :thune2)

(defun conf-value (conf key)
  "Finds the value associated in alist CONF with symbol KEY, returning nil if no such key exists."
  (cdr (assoc key conf)))

(defun load-conf (path)
  "Loads a configuration file formatted as the elements of alist."
  (with-open-file (stream path)
    (loop
       for entry = (read stream nil)
       while entry
       collect entry)))