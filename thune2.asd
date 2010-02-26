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
             (:file "handler" :depends-on ("utils"))
             (:module "handlers" :depends-on ("handler") :components
                      ((:file "autojoin")))
             (:file "main" :depends-on ("conf" "handler"))))))
