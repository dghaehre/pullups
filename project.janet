(declare-project
  :name "pullups"
  :description ""
  :dependencies ["https://github.com/joy-framework/joy"
                 "https://github.com/janet-lang/json"
                 "https://github.com/dghaehre/janet-utils"
                 {:url "https://github.com/ianthehenry/judge.git" :tag "v2.4.0"}
                 {:repo "https://github.com/brandonchartier/janet-uuid" :tag "b831d1bfb94d6400e8bf8c6cc60628159b218064"}
                 {:repo "https://github.com/joy-framework/cipher" :tag "56e3770f3324f5c58073afbb85ecb103bab8f9f8"}
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
