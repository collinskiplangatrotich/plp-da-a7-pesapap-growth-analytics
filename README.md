# PesaPap Growth Analytics & Onboarding Experiment (`plp-da-a7-pesapap-growth-analytics`)

## Project Summary
This project analyses growth performance and an onboarding sign-up experiment for **PesaPap**, a Kenyan digital-payments start-up. Using `generate_data.py` (seed `77`), it generates synthetic user, transaction, and experiment datasets, loads them into a SQLite database (`pesapap.db`), executes validation and analytical SQL queries (`sql/queries.sql`), and produces a KPI scorecard, metric dictionary, RFM segmentation, cohort retention table, statistical experiment evaluation (`pesapap_analysis.ipynb`), and a one-page growth memo (`reports/growth_memo.md`).

---

## Tables, Primary Keys & Foreign Keys
* **`users`** (`users.csv` $\rightarrow$ `users` table): Stores `3,000` registered users (`user_id`, `signup_date`, `county`, `acquisition_channel`).
  * **Primary Key:** `user_id`
  * **Foreign Keys:** None
* **`transactions`** (`transactions.csv` $\rightarrow$ `transactions` table): Stores `12,000` payment transactions (`txn_id`, `user_id`, `txn_date`, `product`, `amount`) across `Airtime`, `Bill Pay`, `Send Money`, and `Merchant Pay`.
  * **Primary Key:** `txn_id`
  * **Foreign Keys:** `user_id` references `users(user_id)`
* **`experiment`** (`experiment.csv` $\rightarrow$ `experiment` table): Stores onboarding experiment assignments and conversion outcomes (`user_id`, `group`, `converted`) for `3,000` users across control (`A`) and simplified sign-up (`B`).
  * **Primary Key:** `user_id`
  * **Foreign Keys:** `user_id` references `users(user_id)`

---

## How to Run
1. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
