(use joy)

(defn valid-contest-name?
  "Is given name valid?"
  [name]
  (let [not-valid-names @["admin" "blog" "about" "terms" "login"]]
    (and
      (< 2 (length name))
      (empty? (filter |(= name $0) not-valid-names)))))

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
    [:a {:href "https://dghaehre.com"} "Daniel"]
    [:span " and " ]
    [:a {:href "https://janet-lang.org"} "Janet"]]])

(defmacro with-err
  "Map possible error"
  [err & body]
  ~(try ,;body ([_] (error ,err))))


(defn padd-users [users rec]
  ```
  Takes a list of users and one recording.
  Returns a new list of users where the recording either
  has been padded to the existing user or had been added to
  a new user in the list.
  ```
  (var exist false)
  (loop [u :in users :when (= (get u :id) (get rec :id))]
    (do
      (put u :recs (array/concat (get u :recs) @{:amount (get rec :amount)
                                              :year (get rec :year)
                                              :year-day (get rec :year-day)}))
      (set exist true)))
  (if-not exist
    (array/concat users @{:id (get rec :id)
                          :name (get rec :name)
                          :recs @[@{:amount (get rec :amount)
                                    :year (get rec :year)
                                    :year-day (get rec :year-day)}]}))
  users)

(defn tail [arr &opt none]
  `Take last element of list`
  (get arr (- (length arr) 1) none))

(defn map-indexed [f ds]
  ```
  A map that also provide an index
  (map-indexed (fn [i v] [i v] ) ["a" "b" "c" "d"])
  ```
  (map f (range 0 (length ds)) ds))
