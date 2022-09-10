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
    [:a {:href (string "/" name)
         :style "color: var(--text); text-decoration: none;" }
      [:h3 {:style "margin: 20px 0px -5px"} name ]]])

(def footer
  [:footer
   [:p {:style "text-align: center" }
    [:span "Made by " ]
    [:a {:href "https://dghaehre.com"} "Daniel"]
    [:span " using " ]
    [:a {:href "https://janet-lang.org"} "Janet"]]])

(defn display-error [err]
  (let [red {:style "color: #E24556"}
        grey {:style "color: #DDD9D4"}]
    [:h5
     [:span red "[error] "]
     [:span grey err]]))

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

# TODO: use dghaehre/janet-utils instead
(defn end [arr &opt none]
  `Take last element of list`
  (get arr (- (length arr) 1) none))

(defn map-indexed [f ds]
  ```
  A map that also provide an index
  (map-indexed (fn [i v] [i v] ) ["a" "b" "c" "d"])
  ```
  (map f (range 0 (length ds)) ds))

(defmacro flip [f & args]
  ```
  Flip argument for the given function.
  Last argument becomes the first.
  Second argument becomes second.
  Third becomes third etc.
  ```
  ~(,f ,(end args) ,;(drop 1 (reverse args))))
