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
  [users]
  (defn list [{:name name :alltime alltime :today today }]
    [:tr
     [:td name ]
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

# (defn- new-user-form
#   [collapsed]
#   (if collapsed
#     [:button {:style "float: right" }
#      "Add new user" ]))

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
   (overview users)
   (new-user-form contest)])

# Routes

(route :get "/:contest" :contest/index)
(route :post "/create-user" :contest/create-user)

(defn contest/index
  [req]
  (def name (get-in req [:params :contest]))
  (def contest (st/get-contest name))
  (if (nil? contest)
    (redirect-to :home/index)
    [ (common/header (get contest :name))
      (main/content contest)
      common/footer ]))

(defn contest/create-user
  [req]
  (pp req)
  (def name (get-in req [:body :name]))
  (def contest-id (get-in req [:body :contest-id]))
  (def contest-name (get-in req [:body :contest-name]))
  (st/create-user name contest-id)
  (redirect-to :contest/index {:contest contest-name }))

