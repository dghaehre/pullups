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

(defn display-error [err]
  (let [red {:style "color: #E24556"}
        grey {:style "color: #DDD9D4"}]
    [:h5
     [:span red "[error] "]
     [:span grey err]]))

(defn display-success [msg]
  (let [grey {:style "color: #DDD9D4"}] #TODO
    [:h5 grey msg]))

(defn footer [req &opt contest-id]
  (let [success     (get-in req [:query-string :feedback-success])
        err         (get-in req [:query-string :feedback-error])]
    [:footer {:style "margin-top: 10rem"}
      (if-not (nil? success)
        (display-success success))
      (if-not (nil? err)
        (display-error err))
    [:p {:style "text-align: center" }
      [:span "Made by " ]
      [:a {:href "https://dghaehre.com"} "Daniel"]
      [:span " using " ]
      [:a {:href "https://janet-lang.org"} "Janet"]]
    [:p
      [:form {:method "post" :action "/feedback"}
      [:p "For feedback or requests:" ]
      (if-not (nil? contest-id)
        [:input {:type "hidden"
                 :name "contest"
                 :value contest-id}])
      [:p [:input {:type "text"
                   :name "message"
                   :placeholder ""}]]
      [:button {:style "margin: 0px; padding: 8px;"} "Send feedback"]]]]))

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

(defn time-by-change [change]
  (let [time (os/time)
        day (* 60 60 24)]
    (case change
      :yesterday (- time day)
      :tomorrow (+ time day)
      time)))
