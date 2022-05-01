(use joy)

(defn common/name-to-path
  [name]
  name)

(defn valid-contest-name?
  "Is given name valid?"
  [name]
  (let [names @["admin" "blog" "about" "terms" "login"]]
    (and
      (< 2 (length name))
      (empty? (filter |(= name $0) names)))))

(defn unique-user-ids
  "Take in a list of recordings, and return a list of unique user ids."
  [recordings]
  (defn f [list rec]
    (def user-id (get rec :user-id))
    (if (empty? (filter |(= user-id $0) list))
      (array/concat list user-id)
      list))
  (reduce f @[] recordings))

(defn header
  [name]
  [:header
    [:h3 {:style "margin: 20px 0px -5px"} name ]])
