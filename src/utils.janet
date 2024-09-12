(use joy)
(use judge)

(def notice-error :p.notice.error.slide-in-animation)
(def notice :p.notice.slide-in-animation)

(defn unique-user-ids
  "Take in a list of recordings, and return a list of unique user ids."
  [recordings]
  (defn f [list rec]
    (def user-id (get rec :user-id))
    (if (empty? (filter |(= user-id $0) list))
      (array/concat list user-id)
      list))
  (reduce f @[] recordings))

(defn header-private
  [name]
  [:header
    [:div {:style "display: flex; justify-content: space-around;"}
      [:a {:style "width: 30px;"}]
      [:a {:href "/private/user"
           :style "color: var(--text); text-decoration: none;"}
        [:h3 {:style "margin: 20px 0px -5px"} name]]
      [:a {:class "logout" :style "width: 30px; padding-top: 20px;"
           :href "/logout"} "logout"]]])

(defn header-private-contest
  [contest-name]
  [:header
    [:div {:style "display: flex; justify-content: space-around;"}
      [:a {:style "width: 100px;"}]
      [:a {:href (string "/" contest-name)
           :style "color: var(--text); text-decoration: none;"}
        [:h3 {:style "margin: 20px 0px -5px"} contest-name]]
      [:a {:class "logout" :style "width: 100px; padding-top: 20px;"
           :href "/private/user"} "your page"]]])

(defn header
  [contest-name &opt logged-in?]
  (if logged-in?
    (header-private-contest contest-name)
    [:header
      [:a {:href (string "/" contest-name)
           :style "color: var(--text); text-decoration: none;"}
        [:h3 {:style "margin: 20px 0px -5px"} contest-name]]]))

(defn footer [req &opt contest-id]
  (let [success     (get-in req [:query-string :feedback-success])
        err         (get-in req [:query-string :feedback-error])]
    [:footer
      (if-not (nil? success)
        [notice success])
      (if-not (nil? err)
        [notice-error err])
     [:p {:style "text-align: center"}
       [:span "Made by "]
       [:a {:href "https://dghaehre.com"} "Daniel"]
       [:span " using "]
       [:a {:href "https://janet-lang.org"} "Janet"]]
     [:p
       [:form {:method "post" :action "/feedback"}
        [:p "For feedback or requests:"]
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
  has been padded to the existing user or has been added to
  a new user in the list.
  ```
  (var exist false)
  (loop [u :in users :when (= (get u :id) (get rec :id))]
    (do
      (put u :recs (array/concat (get u :recs) @{:amount (get rec :amount)
                                                 :year (get rec :year)
                                                 :created-at (get rec :created-at)
                                                 :year-day (get rec :year-day)}))
      (set exist true)))
  (if-not exist
    (array/concat users @{:id (get rec :id)
                          :name (get rec :name)
                          :recs @[@{:amount (get rec :amount)
                                    :year (get rec :year)
                                    :created-at (get rec :created-at)
                                    :year-day (get rec :year-day)}]}))
  users)

(defn time-by-change [change]
  (let [time (os/time)
        day (* 60 60 24)]
    (case change
      :yesterday (- time day)
      :tomorrow (+ time day)
      time)))

(defn cname [name]
  (assert (string? name) "Name must be a string")
  (string/replace-all " " "-" name))

(defn from-cname [name]
  (string/replace-all "-" " " name))

(defn to-beginning-of-month [time]
  (let [{:month-day md} (os/date time :local)
        day-in-seconds (* 60 60 24)
        start-of-month (- time (* day-in-seconds md))]
    start-of-month))

(defn htmx-redirect [path & otherstuff]
  "Adds a HX-Redirect header for it to work with client side redirect (htmx)"
  (let [location  (url-for path ;otherstuff)]
    @{:status 200
      :body " "
      :headers @{"Location" location
                 "HX-Redirect" location}}))

(defmacro silent [body]
  ~(try ,body ([_] nil)))

(defn display-ranking [rank p no-recordings]
  (assert (number? rank))
  (assert (number? p))
  (cond
     no-recordings
     "No recordings"

     (and (> p 2)
          (= rank p))
     "Last place"

     (and (> p 1)
          (= rank 1))
     "First place"

     (and (> p 2)
          (= rank 2))
     "Second place"

     (= p 1)
     "N/A"
                      
     (string rank " of " p)))

(test (display-ranking 1 10 false) "First place")
(test (display-ranking 2 10 false) "Second place")
(test (display-ranking 2 3 false) "Second place")
(test (display-ranking 3 3 false) "Last place")
(test (display-ranking 1 1 false) "N/A")

(defn name-of-month [&opt month]
  (default month (-> (os/time)
                     (os/date :local)
                     (get :month)
                     (+ 1)))
  (assert (and (number? month)
               (<= 1 month 12)) "invalid month")
  (case month
    1 "Jan"
    2 "Feb"
    3 "Mar"
    4 "Apr"
    5 "May"
    6 "Jun"
    7 "Jul"
    8 "Aug"
    9 "Sep"
    10 "Oct"
    11 "Nov"
    12 "Dec"
    (error "Invalid month")))

(test (name-of-month 1) "Jan")
(test (name-of-month 2) "Feb")
(test (name-of-month 12) "Dec")
(test (protect (name-of-month 0))
  [false "invalid month"])
