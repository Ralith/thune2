(asdf:defsystem :thune2
  :description "An IRC bot"
  :depends-on (:ircl :alexandria)
  :components
  ((:file "package")
   (:module "src"
            :depends-on ("package")
            :components
            ((:file "conf")
             (:file "irc")
             (:file "main" :depends-on ("conf" "irc"))))))