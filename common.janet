(defn common/name-to-path
  [name]
  name)

(defn valid-contest-name?
  "Is given name valid?"
  [name]
  (let [names @["admin" "blog" "about" "terms" "login"]]
    (and
      (< 3 (length name))
      (empty? (filter |(= name $0) names)))))
