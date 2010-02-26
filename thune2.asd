(asdf:defsystem :thune2
  :description "An IRC bot"
  :depends-on (:ircl :alexandria :chanl)
  :components
  ((:file "package")
   (:module "src"
            :depends-on ("package")
            :components
            ((:file "utils")
             (:file "conf")
             (:file "irc")
             (:file "handler" :depends-on ("utils"))
             (:file "main" :depends-on ("conf" "irc" "handler"))))))
