(use joy)
(import json)
(import ./common :as common)
(import ./storage :as st)

(defn create-colors [id]
  @{:backgroundColor "rgb(255, 99, 131)"
    :borderColor "rgb(255, 99, 131)"})

# TODO: create dates
(defn create-labels [days-of-data]
  (range days-of-data))

(defn rec-stats [users-with-recs]
  (let [all-recs      (flatten (map |(get $0 :recs) users-with-recs))
        year-days     (map |(get $0 :year-day) all-recs)
        start-day     (min (splice year-days))
        end-day       (max (splice year-days))
        days-of-data  (if (or (nil? start-day) (nil? end-day)) 0
                        (+ 1 (- end-day start-day)))]
    @{:start-day (or start-day 0)
      :end-day (or end-day 0)
      :days-of-data days-of-data}))

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
        (array/push user-data (common/tail user-data 0))
        (array/push user-data (+ (common/tail user-data 0) (get rec :amount)))))
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
  (let [users-with-recs (reduce common/padd-users @[] chart-data)
        stats           (rec-stats users-with-recs)
        labels          (create-labels (get stats :days-of-data))
        data            (common/map-indexed (create-dataset stats) users-with-recs)]
    [:div {:class "big-element"}
      [:canvas {:id "chart-overview"}]
      (create-chart data labels)]))
