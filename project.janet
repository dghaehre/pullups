(declare-project
  :name "pullups"
  :description ""
  :dependencies ["https://github.com/joy-framework/joy"
                 "https://github.com/janet-lang/sqlite3"]
  :author ""
  :license ""
  :url ""
  :repo "")

(phony "dev" []
  (os/shell "find . -name '*.janet' | entr -r -s \"janet ./src/main.janet\""))

(phony "server" []
    (os/shell "janet ./src/main.janet"))

(declare-executable
  :name "app"
  :entry "./src/main.janet")
