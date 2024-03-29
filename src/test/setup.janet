(use joy)
(use judge)
(use sh)
(import cipher)

(defn random-number [&opt max]
  (default max 100000)
  (-> (math/random)
      (* max)
      (math/floor)))

(defn new-db-name []
  (string "/tmp/pullups-test-" (random-number) ".db"))

(defn setup-cipher []
  (def key (cipher/password-key))
  (setdyn :encryption-key key))

(defn setup-db []
  (let [db-name (new-db-name)]
    ($ rm -f ,db-name)
    (setdyn :out @"")
    # ^ Dont really know how this works...
    #   But this makes everything silent.
    #   Comment out for debugging
    (db/migrate db-name)
    (db/connect db-name)))

(deftest-type with-db
  :setup (fn []
            (setup-cipher)
            (setup-db))
  :reset (fn [conn]
           (setup-cipher)
           (setdyn :db/connection conn)
           (db/disconnect)
           (setup-db))
  :teardown (fn [conn]
              (setdyn :encryption-key nil)
              (setdyn :db/connection conn)
              (db/disconnect)))
