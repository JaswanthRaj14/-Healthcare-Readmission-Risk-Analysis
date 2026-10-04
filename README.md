# 🏥 Healthcare Readmission Risk Analysis

> **SQL-based healthcare analytics project investigating factors associated with 30-day hospital readmission and developing a transparent rule-based risk segmentation framework.**

---

## 📌 Project Overview

Hospital readmissions are an important healthcare analytics problem because frequent readmissions can indicate higher patient complexity and create additional pressure on healthcare resources.

This project analyzes **100,100 hospital encounters** from the **Diabetes 130-US Hospitals for Years 1999–2008** dataset to identify patterns associated with 30-day readmission.

The analysis progresses from data quality validation and exploratory analysis to risk-factor comparison and a transparent rule-based risk segmentation framework.

> **Important:** This project identifies observational associations in historical data. The risk score is an analytical framework created for this project and is **not a clinically validated prediction model**.

---

## 🎯 Business Objective

The primary objective is to answer:

> **Which patient utilization, clinical, hospitalization, and treatment-related factors are associated with higher observed 30-day readmission rates?**

The project also investigates whether a simple, interpretable risk-scoring framework can separate encounters into groups with meaningfully different observed readmission rates.

---

## 🗂️ Dataset

**Dataset:** Diabetes 130-US Hospitals for Years 1999–2008

The dataset contains approximately **100,100 hospital encounters** involving patients with diabetes across multiple U.S. hospitals.

### Target Variable

The original `readmitted` field contains three outcomes:

- `<30` — readmitted within 30 days
- `>30` — readmitted after 30 days
- `NO` — not readmitted

For the analysis, a binary target was created:

```text
readmitted_30_day

1 → Readmitted within 30 days
0 → Not readmitted within 30 days
```

---

## 🛠️ Tools & Technologies

- **SQL**
- **MySQL**
- Data Cleaning
- Exploratory Data Analysis
- Aggregation & Conditional Logic
- Risk Segmentation
- Healthcare Analytics
- Git & GitHub

---

## 🔄 Analytical Workflow

```text
Raw Healthcare Data
        ↓
Data Quality Validation
        ↓
Data Cleaning & Preparation
        ↓
Target Variable Engineering
        ↓
Exploratory Analysis
        ↓
Risk Factor Analysis
        ↓
Risk Factor Ranking
        ↓
Rule-Based Risk Scoring
        ↓
Risk Segmentation
        ↓
Comparative Risk Analysis
        ↓
Business Recommendations
```

---

## 🧹 Data Preparation

Several data-quality issues were addressed before analysis.

### Key cleaning steps

- Validated the total number of encounters.
- Checked for duplicate `encounter_id` values.
- Identified patients with multiple encounters.
- Created a working analysis table named `diabetic_copy`.
- Removed the `weight` column because of its extremely high proportion of unknown values.
- Replaced `?` values with `Unknown` in selected categorical fields.
- Standardized invalid gender values.
- Created the binary `readmitted_30_day` target variable.

Repeated patient encounters were **not removed**, because historical utilization variables such as previous inpatient and emergency visits are important to the analysis.

---

## 📊 Baseline Readmission Analysis

Across the full dataset:

| Metric | Result |
|---|---:|
| Total encounters | **100,100** |
| 30-day readmissions | **11,086** |
| Overall readmission rate | **11.07%** |

The **11.07% baseline** was used as the reference point for later risk comparisons.

---

## 🔎 Key Analytical Findings

### 1. Previous Inpatient Utilization

Previous inpatient utilization produced the strongest observed difference among the factors analyzed.

| Previous inpatient visits | Readmission rate |
|---|---:|
| 0 | 8.43% |
| 1–2 | 14.14% |
| 3–4 | 21.03% |
| 5+ | **35.98%** |

The difference between 0 and 5+ previous inpatient visits was:

**27.55 percentage points**

---

### 2. Previous Emergency Utilization

A similar increasing pattern was observed for previous emergency visits.

| Previous emergency visits | Readmission rate |
|---|---:|
| 0 | 10.38% |
| 1–2 | 15.07% |
| 3–4 | 23.92% |
| 5+ | **27.00%** |

Difference between 0 and 5+:

**16.62 percentage points**

---

### 3. Patient Complexity

Patients with more recorded diagnoses showed higher observed readmission rates.

| Number of diagnoses | Readmission rate |
|---|---:|
| 1–2 | 6.07% |
| 3–4 | 7.84% |
| 5+ | **11.44%** |

---

### 4. Hospital Stay

Readmission rates increased across hospital-stay groups.

| Hospital stay | Readmission rate |
|---|---:|
| 1–2 days | 9.04% |
| 3–4 days | 11.05% |
| 5–7 days | 12.37% |
| 8+ days | **13.48%** |

---

### 5. Glucose & Insulin Patterns

Higher observed readmission rates were also seen across certain glucose and insulin categories.

Maximum glucose serum:

```text
None → 11.01%
Norm → 11.29%
>200 → 12.23%
>300 → 14.21%
```

Insulin:

```text
No → 9.93%
Steady → 11.06%
Up → 12.86%
Down → 13.84%
```

These patterns are treated as **associations**, not causal effects.

---

## 🏆 Risk Factor Ranking

The major factors were compared using the difference between their lowest and highest observed readmission rates.

| Rank | Factor | Difference |
|---:|---|---:|
| 1 | Previous inpatient visits | **27.55 pp** |
| 2 | Previous emergency visits | **16.62 pp** |
| 3 | Number of diagnoses | **5.37 pp** |
| 4 | Hospital stay | **4.44 pp** |
| 5 | Insulin | **3.91 pp** |
| 6 | Maximum glucose serum | **3.20 pp** |
| 7 | Diabetes medication | **2.02 pp** |
| 8 | Medication change | **1.24 pp** |

This analysis highlighted **previous inpatient and emergency utilization** as the strongest observed signals among the factors examined.

---

## 🧮 Rule-Based Risk Scoring

A transparent scoring framework was created using four strong analytical signals:

### Previous inpatient utilization

```text
0 visits       → 0 points
1–2 visits     → 1 point
3–4 visits     → 2 points
5+ visits      → 3 points
```

### Previous emergency utilization

```text
0 visits       → 0 points
1–2 visits     → 1 point
3–4 visits     → 2 points
5+ visits      → 3 points
```

### Number of diagnoses

```text
1–2 diagnoses  → 0 points
3–4 diagnoses  → 1 point
5+ diagnoses   → 2 points
```

### Hospital stay

```text
1–2 days       → 0 points
3–4 days       → 1 point
5–7 days       → 2 points
8+ days        → 3 points
```

**Maximum score: 11 points**

---

## 🚦 Risk Segmentation

The total score was divided into three analytical segments:

| Risk segment | Score |
|---|---:|
| Low Risk | 0–3 |
| Moderate Risk | 4–7 |
| High Risk | 8–11 |

### Results

| Risk segment | Encounters | 30-day readmissions | Readmission rate |
|---|---:|---:|---:|
| Low Risk | 49,612 | 3,913 | **7.89%** |
| Moderate Risk | 49,298 | 6,799 | **13.79%** |
| High Risk | 1,190 | 374 | **31.43%** |

---

## 📈 Risk Segmentation vs Baseline

Overall baseline:

**11.07%**

| Risk segment | Readmission rate | Difference vs baseline | Relative risk |
|---|---:|---:|---:|
| Low Risk | 7.89% | −3.18 pp | 0.71× |
| Moderate Risk | 13.79% | +2.72 pp | 1.25× |
| High Risk | **31.43%** | **+20.36 pp** | **2.84×** |

### Key Finding

The High Risk segment had an observed 30-day readmission rate of **31.43%**, approximately **2.84× the overall baseline rate**.

This demonstrates that the rule-based segmentation produced substantial differences in observed readmission rates across the three groups.

---

## 💡 Business Recommendations

Based on the observed patterns:

### 1. Prioritize high-utilization patients

Patients with frequent previous inpatient admissions showed substantially higher observed readmission rates.

Healthcare teams could consider additional discharge planning, follow-up coordination, and post-discharge support for patients with high prior utilization.

### 2. Monitor frequent emergency utilization

Repeated emergency visits were strongly associated with higher observed readmission rates.

Emergency utilization could therefore be considered as one analytical signal for identifying patients who may benefit from closer follow-up.

### 3. Consider overall patient complexity

Patients with multiple diagnoses showed higher observed readmission rates.

Additional care coordination may be particularly relevant for patients with greater clinical complexity.

### 4. Use risk segmentation as an analytical screening framework

The rule-based segmentation can help prioritize further analysis of patient groups with different observed readmission rates.

It should **not** be used as a standalone clinical decision-making tool.

---

## ⚠️ Limitations

### Historical dataset

The dataset covers **1999–2008**, so healthcare practices and patient populations may differ from current clinical environments.

### Observational analysis

The analysis identifies **associations, not causation**.

### Rule-based score

The risk score was manually designed using selected variables and weights. It has not been clinically validated.

### Repeated encounters

Some patients have multiple hospital encounters, meaning individual observations are not necessarily independent.

### Missing and unknown values

Several fields contain substantial unknown or missing-style categories.

### Small subgroups

Some admission and discharge categories contain very few encounters, making their observed rates unstable.

### No causal adjustment

The analysis does not use multivariable regression, propensity scoring, or other methods to control for potential confounding.

---

## 📁 Project Structure

```text
healthcare-readmission-risk-analysis/
│
├── README.md
├── healthcare_readmission_analysis.sql
│
├── data/
│   └── README.md
│
├── results/
│   ├── risk_segmentation.png
│   └── key_findings.png
│
└── docs/
    └── data_dictionary.md
```

---

## 📌 Key SQL Techniques Demonstrated

- `CASE WHEN`
- `GROUP BY`
- `ORDER BY`
- Conditional aggregation
- `COUNT()`
- `SUM()`
- Percentage calculations
- Subqueries
- Table creation
- `ALTER TABLE`
- `UPDATE`
- Data cleaning
- Feature engineering
- Risk scoring
- Risk segmentation
- Comparative analysis

---

## 🎯 Final Project Outcome

This project demonstrates an end-to-end healthcare analytics workflow using SQL:

> **Data Quality → Cleaning → Exploration → Risk Factor Analysis → Risk Scoring → Segmentation → Business Insights**

The analysis found that previous inpatient and emergency utilization were the strongest observed signals among the factors examined, while the rule-based risk segmentation produced substantially different observed 30-day readmission rates across Low, Moderate, and High Risk groups.

---

## ⚕️ Analytical Disclaimer

This project is intended for **educational and portfolio purposes**.

The findings represent associations observed in historical data and should not be interpreted as clinical guidelines, causal conclusions, or a clinically validated prediction model.
