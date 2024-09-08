(use joy)
(use ./pages/session)
(use ./pages/home)
(use ./pages/contest)
(use ./pages/user)
(use ./feedback)

# Layout
(defn app-layout [{:body body :request request}]
  (text/html
    (doctype :html5)
    [:html {:lang "en"}
     [:head
      [:title "Pullups"]
      [:meta {:charset "utf-8"}]
      [:meta {:name "viewport" :content "width=device-width, initial-scale=1"}]
      [:meta {:name "csrf-token" :content (csrf-token-value request)}] # Dont currently need that
      [:link {:href "/simple.min.css" :rel "stylesheet"}]
      [:script {:src "/htmx.min.js" :defer ""}]
      [:link {:href "/app.v2.css" :rel "stylesheet"}]]
     [:body {:hx-boost "true"}
       body]]))

# Middleware
(def app (-> (handler)
             (layout app-layout)
             (with-session {"Expires" "Thu, 01 Jan 2030 00:00:00 GMT"}) # Lasting a long time..
             (query-string)
             (body-parser)
             (server-error)
             (x-headers)
             (static-files)
             (not-found)
             (logger)))

# Server
(defn main [& args]
  (let [port (get args 1 (env :PORT))
        host (get args 2 "localhost")
        encryption-key (env :encryption-key)]
    (if (nil? encryption-key) (error "ENCRYPTION-KEY environment variable is not set")
      (setdyn :encryption-key encryption-key))
    (print (string "serving at " host ":" port))
    (db/connect (env :database-url))
    (server app port host)
    (db/disconnect)))
