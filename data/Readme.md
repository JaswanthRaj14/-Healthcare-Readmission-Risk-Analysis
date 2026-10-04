# Dataset

## Dataset Name

**Diabetes 130-US Hospitals for Years 1999–2008**

## Dataset Description

This project uses the Diabetes 130-US Hospitals dataset containing **100,100 hospital encounters** collected from multiple U.S. hospitals between 1999 and 2008.

The dataset contains information about:

- Patient demographics
- Hospital admissions
- Previous healthcare utilization
- Diagnoses
- Diabetes medications
- Laboratory test results
- Hospital stay duration
- Discharge information
- 30-day readmission outcomes

## Dataset Usage

The dataset was used to investigate factors associated with **30-day hospital readmission** and to develop a transparent, rule-based analytical risk segmentation framework using SQL.

## Target Variable

The original `readmitted` variable contains three categories:

- `<30` — Readmitted within 30 days
- `>30` — Readmitted after 30 days
- `NO` — Not readmitted

For the analysis, an additional binary variable named `readmitted_30_day` was created:

- `1` → Readmitted within 30 days
- `0` → Not readmitted within 30 days

## Data Preparation

The project created a working table named `diabetic_copy` for analysis.

Major preparation steps included:

- Removing the `weight` field because approximately 96.94% of values were unknown.
- Replacing `?` placeholders with `Unknown` in selected categorical fields.
- Standardizing invalid gender values.
- Creating the binary 30-day readmission target.
- Creating analytical risk-score components for healthcare utilization, diagnosis count, and hospital stay.

## GitHub Data Policy

The original patient-level dataset is **not included in this repository**.

This repository contains the SQL analysis, documentation, and selected analytical results instead of redistributing the complete raw dataset.

Users who want to reproduce the analysis should obtain the dataset from its original public source and load it into their own local database.

## Analytical Disclaimer

The dataset represents historical healthcare encounters from 1999–2008. The analysis identifies **observed associations** within the data and should not be interpreted as establishing causal relationships or providing clinical recommendations.
