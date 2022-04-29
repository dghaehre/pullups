(use joy)


# Layout
(defn app-layout [{:body body :request request}]
  (text/html
    (doctype :html5)
    [:html {:lang "en"}
     [:head
      [:title "Pullups"]
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
    [:h2 "A pullups competition" ]
    [:h4 "See if you can beat your friends"]])

(def home/footer
  [:footer
   [:p {:style "text-align: center" }
    [:span "Made with love by " ]
    [:a {:href "https://dghaehre.com"} "Daniel"]]])

(defn home/submit
  "Create competition button"
  [disabled]
  (def attr @{:type "submit" })
  (if disabled
    (put attr :disabled "true"))
  [:button (table/to-struct attr)
    [ "Create competition" ]])

(def home/main
  [:main {:style "text-align: center"}
     [:h3 "Create a competition"]
     [:form
      [:p
        [:input {:type "text"
                 :name "name"
                 :hx-get "/check-name"
                 :hx-trigger "keyup changed delay:500ms"
                 :hx-target "#submit"
                 :placeholder "Some wierd name"}]]
      [:p {:id "submit" } (home/submit true)]]])

# Routes
(route :get "/" :home)

(route :get "/check-name" :checkname)

(defn checkname
  "Check if name is available"
  [request]
  (text/html (home/submit false)))


(defn home
  "Home screen
  Let user create a new 'contest'"
  [request]
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
  (let [port (get args 1 (env :PORT))
        host (get args 2 "localhost")]
    (print (string "serving at " host ":" port))
    (db/connect (env :database-url))
    (server app port host)
    (db/disconnect)))
