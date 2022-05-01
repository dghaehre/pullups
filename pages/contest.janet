(use joy)
(import ../common :as common)
(import ../storage :as st)

(defn- list-users
  [users]
  (defn list [{:name name}]
    [:li name])
  [:ul (map list users) ])

(defn- main/content
  [contest]
  (def id (get contest :id))
  (def recordings (st/get-recordings id))
  (def user-ids (common/unique-user-ids recordings))
  (def users (st/get-users user-ids))
  [:main
   (list-users users) ])

# Routes

(route :get "/:contest" :contest/index)

(defn contest/index
  [req]
  (def name (get-in req [:params :contest]))
  (def contest (st/get-contest name))
  (if (nil? contest)
    (redirect-to :home/index)
    [ (common/header (get contest :name))
      (main/content contest) ]))
