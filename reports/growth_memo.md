# PesaPap Growth & Onboarding Experiment Memo

## Result
Across **3,000** registered users and **12,000** transactions generated for PesaPap (`seed 77`), the platform shows active transaction volume across four products (**Send Money**, **Airtime**, **Bill Pay**, and **Merchant Pay**), five counties (**Nairobi**, **Mombasa**, **Kisumu**, **Nakuru**, and **Eldoret**), and four acquisition channels (**Referral**, **Social**, **Agent**, and **Search**). In the onboarding experiment, **Group B** (simplified sign-up screen) was designed with a higher conversion rate than **Group A** (control), with balanced group assignment across users, counties, and acquisition channels. Data validation also identified transactions where `txn_date < signup_date` because signup dates (`2026-01-01` to `2026-04-30`) and transaction dates (`2026-01-15` to `2026-06-13`) overlap across the observation window.

## Impact
A higher onboarding conversion rate increases the share of new sign-ups who complete conversion and enter active payment usage rather than dropping off during registration. Pairing conversion gains with RFM and cohort retention tracking helps separate one-off activity from repeat usage across core products like **Send Money** and high-volume counties/channels, while flagging pre-signup transactions prevents distorted cohort retention or post-signup engagement metrics.

## Recommendation
**Roll out the simplified sign-up screen (Group B) to 100% of new users**, subject to confirming statistical significance ($p < 0.05$) and positive lift in your executed `pesapap_analysis.ipynb` outputs. After rollout, track post-signup activation, repeat transaction frequency in RFM segments, and monthly cohort retention while investigating any `txn_date < signup_date` records in upstream event/signup logging.

## Caveats
* **Synthetic / Simulated Data:** The dataset is synthetically generated (`seed 77`), so exact counts, lift, and p-values reflect simulated behaviour rather than live production telemetry.
* **Pre-Signup Timestamp Anomalies:** Transactions dated before a user's `signup_date` (`txn_date < signup_date`) occur in the raw table and must be flagged/handled carefully when computing post-signup cohorts and retention.
* **Censored / Incomplete Cohort Periods:** Later signup cohorts have shorter observable follow-up windows before the end of the transaction period (`2026-06-13`), making trailing cohort retention cells incomplete.
* **Conversion vs. Long-Term Value:** Short-term onboarding conversion measures initial conversion rather than long-term net revenue, transaction margin, or multi-month retention.
