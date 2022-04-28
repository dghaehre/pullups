(use joy)


# Layout
(defn app-layout [{:body body :request request}]
  (text/html
    (doctype :html5)
    [:html {:lang "en"}
     [:head
      [:title "Pushups"]
      [:meta {:charset "utf-8"}]
      [:meta {:name "viewport" :content "width=device-width, initial-scale=1"}]
      [:meta {:name "csrf-token" :content (csrf-token-value request)}]
      [:link {:href "https://cdn.simplecss.org/simple.min.css" :rel "stylesheet"}]
      [:script {:src "/htmx.min.js" :defer ""}]
      [:link {:href "/app.css" :rel "stylesheet"}]]
     [:body
       body]]))

(def home/header
  [:header
    [:h2 "A pushups competition" ]
    [:h4 "See if you can beat your friends"]])

(def home/footer
  [:footer
   [:p {:style "text-align: center" }
    [:span "Made with love by " ]
    [:a {:href "https://dghaehre.com"} "Daniel"]]])

(def home/main
  [:main {:style "text-align: center" }
     [:h3 "Create a competition"]
     [:form
      [:p
        [:input {:text "some input"
                 :name "name"
                 :placeholder "Some wierd name"}]]
      [:p
        [:button {:type "submit"} [ "Create" ]]]]])

# Routes
(route :get "/" :home)

(defn home [request]
  " Home screen
    Let user create a new 'contest'"
  [ home/header
   home/main
   home/footer ])


# Middleware
(def app (-> (handler)
             (layout app-layout)
             (with-csrf-token)
             (with-session)
             (extra-methods)
             (query-string)
             (body-parser)
             (json-body-parser)
             (server-error)
             (x-headers)
             (static-files)
             (not-found)
             (logger)))


# Server
(defn main [& args]
  (let [port (get args 1 (os/getenv "PORT" "9001"))
        host (get args 2 "localhost")]
    (print (string "serving at " host ":" port))
    (server app port host)))
