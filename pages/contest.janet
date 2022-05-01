(use joy)
(import ../common :as common)
(import ../storage :as st)

(defn- header
  [contest]
  (def name (get contest :name))
  [:header
    [:h2 name ]])


# Routes

(route :get "/:contest" :contest/index)

(defn contest/index
  [req]
  (def name (get-in req [:params :contest]))
  (def contest (st/get-contest name))
  (if (nil? contest)
    (redirect-to :home/index)
    [ (header contest) ]))
