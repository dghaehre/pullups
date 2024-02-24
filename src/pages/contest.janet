(use joy)
(use utils)
(use ../utils)
(import ../storage :as st)
(import ../service/session :as s)
(import ../chart :as chart)

# Views

(defn- list-users
  [users]
  (defn list [{:name name}]
    [:li name])
  [:ul (map list users)])

(defn- overview
  [contest-name users]
  [:table {:style "display: inline-table; margin: 0;" :class "contest-table"}
   [:thead
    [:tr
     [:th "Name"]
     [:th "Today"]
     [:th "Topscore"]
     [:th "Month"] # TODO: name of month?
     [:th "Year"]]]
   [:tbody
    (flip map users (fn [{:id id :name name :total total :today today :topscore topscore :month month}]
                     [:tr
                      [:td
                       [:a {:href (string "/" (cname contest-name) "/" id) } name]]
                      [:td today]
                      [:td topscore]
                      [:td month]
                      [:td total]]))]])

(defn- new-user-form
  [contest]
  [:details {:class "new-user-form"}
   [:summary "Add user"]
   [:form {:method "post" :action "/create-user"}
    [:input {:type "text" :placeholder "Name" :name "name"}]
    [:input {:type "hidden" :name "contest-id" :value (get contest :id)}]
    [:input {:type "hidden" :name "contest-name" :value (get contest :name)}]
    [:button {:type "submit" :style "width: 100%"} "Add user"]]])

(defn- main/content [contest err]
  (let [id          (get contest :id)
        name        (get contest :name)
        users       (st/contents-stats id)] # TODO
    [:main
     (overview (get contest :name) users)
     (new-user-form contest)
     (if-not (nil? err) (display-error err))
     (chart/loader name)]))

# Routes

(route :get "/:contest" :contest/index)
(route :get "/:contest/get-chart" :contest/get-chart)

(defn contest/index
  [req]
  (let [name               (get-in req [:params :contest])
        err                (get-in req [:query-string :error])
        contest            (st/get-contest name)
        logged-in-userid?  (s/user-id-from-session req)]
    (if (nil? contest)
      (redirect-to :home/index)
      [[:script {:src "/xxx.chart.js"}]
       (header (get contest :name) logged-in-userid?)
       (main/content contest err)
       (footer req (get contest :id))])))

(defn contest/get-chart [req]
  ```
  Return the chart stuff (html)
  ```
  (def name (get-in req [:params :contest]))
  (def contest (st/get-contest name))
  (if (nil? contest)
    (redirect-to :home/index)
    (let [id (get contest :id)
          general-chart-data (st/get-chart-data id)
          month-chart-data (st/get-chart-data-month id)]
      (chart/overview general-chart-data month-chart-data))))
