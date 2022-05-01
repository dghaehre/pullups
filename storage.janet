(use joy)

(defn contest-exist?
  "Check db if name already exist"
  [name]
  (not (empty? (db/from :contest :where {:name name} :limit 1))))

(defn create-contest
  [name]
  (db/insert {:db/table :contest :name name}))

(defn get-contest
  "Get contest. Returns nil if not found."
  [name]
  (def rows (db/from :contest :where {:name name}))
  (if (= 1 (length rows))
    (get rows 0)
    nil))

# (get-contest "testing")

(defn- get-all
  "Just a helper function used in development"
  []
  (db/from :contest))

# (get-all)

(defn- delete-contest
  "Just a helper function used in development"
  [id]
  (db/delete :contest id))

# (delete-contest 3)
