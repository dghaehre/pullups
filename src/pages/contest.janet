(use joy)
(use ../utils)
(import ../storage :as st)
(import ../chart :as chart)

# Views

(defn- list-users
  [users]
  (defn list [{:name name}]
    [:li name])
  [:ul (map list users) ])

(defn- overview
  [contest-name users]
  [:table {:style "display: inline-table; margin: 0;" :class "contest-table" }
   [:thead
    [:tr
     [:th "Name" ]
     [:th "Today" ]
     [:th "Topscore" ]
     [:th "This year" ]]]
   [:tbody
    (flip map users (fn [{:id id :name name :total total :today today :topscore topscore }]
      [:tr
       [:td
        [:a {:href (string "/" contest-name "/" id) } name ] ]
       [:td today ]
       [:td topscore ]
       [:td total ]]))]])

(defn- record-form
  "Where you record your daily stuff..."
  [contest user-id current-amount]
  (def {:year year :month m :month-day md} (os/date (os/time) :local))
   [:form {:method "post" :action "/record" }
    [:p
      [:label [:h4 "Total pullups today"]
              [:p {:style "color: grey; margin: 0px"} (string md "/" m "/" year)]]
      [:input {:type "text" :placeholder current-amount :name "amount"} ]]
    [:input {:type "hidden" :name "contest-id" :value (get contest :id) } ]
    [:input {:type "hidden" :name "contest-name" :value (get contest :name) } ]
    [:input {:type "hidden" :name "user-id" :value user-id } ]
    [:p 
      [:button {:type "submit"} "Update" ]]])


(defn- new-user-form
  [contest]
  [:details {:class "new-user-form" }
   [:summary "Add user" ]
   [:form {:method "post" :action "/create-user" }
    [:input {:type "text" :placeholder "Name" :name "name"} ]
    [:input {:type "hidden" :name "contest-id" :value (get contest :id) } ]
    [:input {:type "hidden" :name "contest-name" :value (get contest :name) } ]
    [:button {:type "submit" :style "width: 100%"} "Add user" ]]])

(defn- main/content [contest err]
  (let [id          (get contest :id)
        name        (get contest :name)
        users       (st/contents-stats id)] # TODO
    [:main
     (overview (get contest :name) users)
     (new-user-form contest)
     (if-not (nil? err) (display-error err))
     (chart/loader name)]))

(defn- main/user
  [user contest err]
  [:main
   [:h3 (get user :name) ]
   [:hr]
   (record-form contest (get user :id) (get user :today))
   (if-not (nil? err) (display-error err))])

# Routes

(route :get "/:contest" :contest/index)
(route :get "/:contest/get-chart" :contest/get-chart)
(route :get "/:contest/:user-id" :contest/user)
(route :post "/create-user" :contest/create-user)
(route :post "/record" :contest/record)

(defn contest/index
  [req]
  (let [name        (get-in req [:params :contest])
        err         (get-in req [:query-string :error])
        contest     (st/get-contest name)]
    (if (nil? contest)
      (redirect-to :home/index)
      [[:script {:src "/xxx.chart.js"}]
       (header (get contest :name))
        (main/content contest err)
        (footer req (get contest :id)) ])))

(defn contest/get-chart [req]
  ```
  Return the chart stuff (html)
  ```
  (def name (get-in req [:params :contest]))
  (def contest (st/get-contest name))
  (if (nil? contest)
    (redirect-to :home/index)
    (->> (get contest :id)
        (st/get-chart-data)
        (chart/overview))))

(defn contest/user
  [req]
  (let [err           (get-in req [:query-string :error])
        contest-name  (get-in req [:params :contest])
        user-id       (get-in req [:params :user-id])
        contest       (st/get-contest contest-name)]
    (if (nil? contest)
      (redirect-to :home/index)
      (let [user (st/get-user-from-contest (get contest :id) user-id)]
        (if (nil? user)
          (redirect-to :contest/index {:contest contest-name})
          (do
            (put user :today (st/get-today-amount user-id))
            [ (header contest-name)
              (main/user user contest err)
              (footer req (get contest :id)) ]))))))

(defn contest/create-user
  [req]
  (def name (get-in req [:body :name]))
  (def contest-id (get-in req [:body :contest-id]))
  (def contest-name (get-in req [:body :contest-name]))
  (pp name)
  (if (-> name (string/trim) (empty?))
    (redirect-to :contest/index {:contest contest-name
                                 :? {:error "empty user name" }})
    (do
      (st/create-user name contest-id)
      (redirect-to :contest/index {:contest contest-name }))))

(defn contest/record
  [req]
  (let [user-id (get-in req [:body :user-id])
        contest-id (get-in req [:body :contest-id])
        contest-name (get-in req [:body :contest-name])]
    (try
      (let [amount (with-err "Not a valid number" (int/to-number (int/u64 (get-in req [:body :amount]))))]
        (st/insert-recording amount user-id contest-id)
        (redirect-to :contest/index {:contest contest-name }))

      ([err fib]
        (redirect-to :contest/user { :contest contest-name
                                    :user-id user-id
                                    :? {:error err }})))))
