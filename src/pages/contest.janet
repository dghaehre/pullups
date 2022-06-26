(use joy)
(import ../common :as common)
(import ../storage :as st)

# Views

(defn- list-users
  [users]
  (defn list [{:name name}]
    [:li name])
  [:ul (map list users) ])

(defn- overview
  [contest-name users]
  (defn list [{:id id :name name :alltime alltime :today today }]
    [:tr
     [:td
      [:a {:href (string "/" contest-name "/" id) } name ] ]
     [:td today ]
     [:td alltime ]])
  [:table {:style "display: inline-table; margin: 0;" }
   [:thead
    [:tr
     [:th "Name" ]
     [:th "Today" ]
     [:th "All time" ]]]
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

(defn- main/content
  [contest]
  (def id (get contest :id))
  (def recordings (st/get-recordings id))
  (def user-ids (common/unique-user-ids recordings))
  (def users (st/get-users user-ids))
  (def data (common/populate-users users recordings))
  (pp data)
  [:main
   (overview (get contest :name) users)
   (new-user-form contest)])

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
(route :get "/:contest/:user-id" :contest/user)
(route :post "/create-user" :contest/create-user)
(route :post "/record" :contest/record)

(defn contest/index
  [req]
  (def name (get-in req [:params :contest]))
  (def contest (st/get-contest name))
  (if (nil? contest)
    (redirect-to :home/index)
    [ (common/header (get contest :name))
      (main/content contest)
      common/footer ]))

(defn contest/user
  [req]
  (def query-error (get-in req [:query-string :error]))
  (def contest-name (get-in req [:params :contest]))
  (def user-id (get-in req [:params :user-id]))
  (def contest (st/get-contest contest-name))
  (if (nil? contest)
    (redirect-to :home/index))
  (def user (st/get-user user-id))
  (if (nil? user)
    (redirect-to :home/contest {:contest contest-name}))
  (put user :today (st/get-today-amount (get contest :id) user-id))
  [ (common/header (get contest :name))
    (main/user user contest query-error)
    common/footer ])

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
