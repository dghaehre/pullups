(use joy)
# TODO: use 'use' instead of import
(import ../common :as common)
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
  (defn list [{:id id :name name :total total :today today }]
    [:tr
     [:td
      [:a {:href (string "/" contest-name "/" id) } name ] ]
     [:td today ]
     [:td total ]])
  [:table {:style "display: inline-table; margin: 0;" }
   [:thead
    [:tr
     [:th "Name" ]
     [:th "Today" ]
     [:th "This year" ]]]
   [:tbody
    (map list users )]])

(defn- record-form
  "Where you record your daily stuff..."
  [contest user-id current-amount]
  (def t (os/date (os/time) :local))
  (def tmin (string (get t :year) "-0" (+ 1 (get t :month)) "-0" (get t :month-day)))
  (def tmax (string (get t :year) "-0" (+ 1 (get t :month)) "-0" (+ (get t :month-day) 1)))
   [:form {:method "post" :action "/record" }
    [:p
      [:label [:p "Today"]]
      [:input {:type "text" :placeholder current-amount :name "amount"} ]]
    [:input {:type "hidden" :name "contest-id" :value (get contest :id) } ]
    [:input {:type "hidden" :name "contest-name" :value (get contest :name) } ]
    [:input {:type "hidden" :name "user-id" :value user-id } ]
    [:p 
      [:button {:type "submit"} "Record" ]]])


(defn- new-user-form
  [contest]
  [:details
   [:summary "Add user" ]
   [:form {:method "post" :action "/create-user" }
    [:input {:type "text" :placeholder "Name" :name "name"} ]
    [:input {:type "hidden" :name "contest-id" :value (get contest :id) } ]
    [:input {:type "hidden" :name "contest-name" :value (get contest :name) } ]
    [:button {:type "submit" :style "width: 100%"} "Add user" ]]])

(defn- main/content [contest]
  (let [id          (get contest :id)
        name        (get contest :name)
        users       (st/contents-stats id)] # TODO
    [:main
     (overview (get contest :name) users)
     (new-user-form contest)
     (chart/loader name)]))

(defn- main/user
  [user contest err]
  [:main
   [:h3 (get user :name) ]
   [:hr]
   (record-form contest (get user :id) (get user :today))
   (if-not (nil? err)
     [:p {:style "color: pink"} err])])

# Routes

(route :get "/:contest" :contest/index)
(route :get "/:contest/get-chart" :contest/get-chart)
(route :get "/:contest/:user-id" :contest/user)
(route :post "/create-user" :contest/create-user)
(route :post "/record" :contest/record)

(defn contest/index
  [req]
  (def name (get-in req [:params :contest]))
  (def contest (st/get-contest name))
  (if (nil? contest)
    (redirect-to :home/index)
    [[:script {:src "/xxx.chart.js"}]
     (common/header (get contest :name))
      (main/content contest)
      common/footer ]))

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
  (let [query-error   (get-in req [:query-string :error])
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
            [ (common/header contest-name)
              (main/user user contest query-error)
              common/footer ]))))))

(defn contest/create-user
  [req]
  (pp req)
  (def name (get-in req [:body :name]))
  (def contest-id (get-in req [:body :contest-id]))
  (def contest-name (get-in req [:body :contest-name]))
  (st/create-user name contest-id)
  (redirect-to :contest/index {:contest contest-name }))

(defn contest/record
  [req]
  (let [user-id (get-in req [:body :user-id])
        contest-id (get-in req [:body :contest-id])
        contest-name (get-in req [:body :contest-name])]
    (try
      (let [amount (common/with-err "Not a valid number" (int/to-number (int/u64 (get-in req [:body :amount]))))]
        (st/insert-recording amount user-id contest-id)
        (redirect-to :contest/index {:contest contest-name }))

      ([err fib]
        (redirect-to :contest/user { :contest contest-name
                                    :user-id user-id
                                    :? {:error err }})))))
