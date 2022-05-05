(use joy)

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
    [:h3 {:style "margin: 20px 0px -5px"}
     [:a {:href (string "/" name)} name ]]])

(def footer
  [:footer
   [:p {:style "text-align: center" }
    [:span "Made with love by " ]
    [:a {:href "https://dghaehre.com"} "Daniel"]]])

# TODO
(defn populate-users
  "Merge recordings into users array"
  [users recordings]
  (defn f [user]
    (loop [r :in recordings :when (= (get user :id) (get r :user-id))]
      (do
        (def current-today (get user :today 0))
        (def current-alltime (get user :alltime 0))
        (put user :alltime (+ current-alltime (get r :amount)))
        (put user :today 0)
        ))
    user)
  (map f users))


