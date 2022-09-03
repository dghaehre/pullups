(use joy)
(import json)
(use ./common)

(defn create-colors [id]
  (let [colors @[{:backgroundColor "rgb(255, 99, 131)"
                  :borderColor "rgb(255, 99, 131)"}
                 {:borderColor "rgb(250, 215, 173)"
                  :backgroundColor "rgb(185, 203, 217)"}
                 {:backgroundColor "rgb(74, 61, 105)"
                  :borderColor "rgb(185, 203, 217)"}
                 {:borderColor "rgb(92, 165, 160)"
                  :backgroundColor "rgb(188, 222, 175)"}
                 {:borderColor "rgb(231, 113, 88)"
                  :backgroundColor "rgb(236, 149, 125)"}
                 {:backgroundColor "rgb(124, 166, 221)"
                  :borderColor "rgb(185, 203, 217)"}]
        total   (length colors)
        i       (if (> id total) (mod id total) id)]
    (get colors i 0)))

# (create-labels 10)
(defn create-labels [n]
  ```
  Returns a list of all dates from today and back `n` days.
  ```
  (let [t (os/time)] # Now
    (flip map (reverse (range n)) (fn [i]
      (let [newtime (- t (* 60 60 24 i)) # minus one day times i
            {:year y :month m :month-day d} (os/date newtime)]
        (string (+ 1 d) "/" (+ 1 m) "/" y))))))

(defn rec-stats [users-with-recs]
  (let [all-recs      (flatten (map |(get $0 :recs) users-with-recs))
        year-days     (map |(get $0 :year-day) all-recs)
        start-day     (min (splice year-days))
        end-day       (get (os/date (os/time) :local) :year-day) # Today
        days-of-data  (if (or (nil? start-day) (nil? end-day)) 0
                        (+ 1 (- end-day start-day)))]
    @{:start-day (or start-day 0)
      :end-day (or end-day 0)
      :days-of-data days-of-data}))

# (let [chart-data      (get-chart-data 3)
#       users-with-recs (reduce padd-users @[] chart-data)
#       stats           (rec-stats users-with-recs)
#   (map-indexed (create-dataset stats) users-with-recs))
(defn create-dataset [stats]
  (fn [i user]
    ```
    Returns @{
      :label: 'My First dataset'
      :backgroundColor: 'rgb(255, 99, 132)'
      :borderColor: 'rgb(255, 99, 132)'
      :data: [0, 10, 5, 2, 20, 30, 45]
    }
  ```
    (var user-data @[])
    # Loop through start-day through end-day and populate user-data
    (loop [i :range [0 (get stats :days-of-data)]]
      # rec matching given year-day
      (def rec (get (filter |(= (get $0 :year-day) (+ i (get stats :start-day))) (get user :recs)) 0))
      (if (nil? rec)
        (array/push user-data (tail user-data 0))
        (array/push user-data (+ (tail user-data 0) (get rec :amount)))))
    (let [colors (create-colors i)]
      @{:label (get user :name)
        :backgroundColor (get colors :backgroundColor)
        :borderColor (get colors :borderColor)
        :data user-data})))

(defn- create-chart [data labels]
  [:script (raw (string "
const data = {
  labels: " (json/encode labels) ",
  datasets: " (json/encode data) "
};

const config = {
  type: 'line',
  data: data,
  options: {}
};

const myChart = new Chart(
  document.getElementById('chart-overview'),
  config
);"))])

(defn overview [chart-data]
  (let [users-with-recs (reduce padd-users @[] chart-data)
        stats           (rec-stats users-with-recs)
        labels          (create-labels (get stats :days-of-data))
        data            (map-indexed (create-dataset stats) users-with-recs)]
    [:div {:class "big-element"}
      [:canvas {:id "chart-overview"}]
      (create-chart data labels)]))
