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


# Routes
(route :get "/" :home)

(defn home [request]
  [:div {:class "tc"}
   [:h1 "You found joy!"]
   [:p {:class "code"}
    [:b "Joy Version:"]
    [:span (string " " version)]]
   [:p {:class "code"}
    [:b "Janet Version:"]
    [:span janet/version]]])


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
