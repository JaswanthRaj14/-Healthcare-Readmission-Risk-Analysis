create database healthcare;

use healthcare;

-- ============================================================
-- HEALTHCARE READMISSION RISK ANALYSIS
-- ============================================================
-- Dataset: Diabetes 130-US Hospitals for Years 1999-2008
-- Objective: Analyze factors associated with 30-day readmission
--             and develop a rule-based readmission risk segmentation.
-- ============================================================


-- ============================================================
-- 1. DATABASE & TABLE VALIDATION
-- ============================================================

-- Check the structure of the main dataset
DESCRIBE diabetic_data;

-- Check the structure of the ID mapping table
DESCRIBE ids_mapping;

-- Total number of encounters
SELECT
    COUNT(*) AS total_encounters
FROM diabetic_data;

-- Total number of mapping records
SELECT
    COUNT(*) AS total_mapping_records
FROM ids_mapping;

-- ============================================================
-- 2. DATA QUALITY & CLEANING
-- ============================================================

-- Check the distribution of the target variable
SELECT
    readmitted,
    COUNT(*) AS total_encounters
FROM diabetic_data
GROUP BY readmitted
ORDER BY total_encounters DESC;


-- Check for duplicate encounter IDs
SELECT
    encounter_id,
    COUNT(*) AS total_count
FROM diabetic_data
GROUP BY encounter_id
HAVING COUNT(*) > 1;


-- Check patients with multiple hospital encounters
SELECT
    patient_nbr,
    COUNT(*) AS total_encounters
FROM diabetic_data
GROUP BY patient_nbr
HAVING COUNT(*) > 1
ORDER BY total_encounters DESC;


-- Create a working copy for analysis
CREATE TABLE diabetic_copy AS
SELECT *
FROM diabetic_data;


-- Remove the weight column because of its extremely high
-- proportion of unknown values
ALTER TABLE diabetic_copy
DROP COLUMN weight;


-- Replace '?' with 'Unknown' in categorical columns
UPDATE diabetic_copy
SET medical_specialty = 'Unknown'
WHERE medical_specialty = '?';

UPDATE diabetic_copy
SET payer_code = 'Unknown'
WHERE payer_code = '?';

UPDATE diabetic_copy
SET race = 'Unknown'
WHERE race = '?';

UPDATE diabetic_copy
SET diag_2 = 'Unknown'
WHERE diag_2 = '?';

UPDATE diabetic_copy
SET diag_3 = 'Unknown'
WHERE diag_3 = '?';


-- Standardize invalid gender values
UPDATE diabetic_copy
SET gender = 'Unknown'
WHERE gender = 'Unknown/Invalid';


-- Create a binary target variable for 30-day readmission
ALTER TABLE diabetic_copy
ADD COLUMN readmitted_30_day TINYINT;


UPDATE diabetic_copy
SET readmitted_30_day =
    CASE
        WHEN readmitted = '<30' THEN 1
        ELSE 0
    END;


-- Validate the new target variable
SELECT
    readmitted_30_day,
    COUNT(*) AS total_encounters
FROM diabetic_copy
GROUP BY readmitted_30_day
ORDER BY readmitted_30_day;

-- ============================================================
-- 3. TARGET VARIABLE & BASELINE ANALYSIS
-- ============================================================

-- Overall distribution of 30-day readmission
SELECT
    readmitted_30_day,
    COUNT(*) AS total_encounters,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM diabetic_copy),
        2
    ) AS percentage
FROM diabetic_copy
GROUP BY readmitted_30_day
ORDER BY readmitted_30_day;


-- Overall 30-day readmission rate
SELECT
    COUNT(*) AS total_encounters,

    SUM(
        CASE
            WHEN readmitted_30_day = 1 THEN 1
            ELSE 0
        END
    ) AS readmissions_30_day,

    ROUND(
        SUM(
            CASE
                WHEN readmitted_30_day = 1 THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS baseline_readmission_rate

FROM diabetic_copy;

-- ============================================================
-- 4. DEMOGRAPHIC ANALYSIS
-- ============================================================

-- 30-day readmission rate by age group
SELECT
    CASE
        WHEN age = '[0-10)' THEN '0-10'
        WHEN age = '[10-20)' THEN '10-20'
        WHEN age = '[20-30)' THEN '20-30'
        WHEN age = '[30-40)' THEN '30-40'
        WHEN age = '[40-50)' THEN '40-50'
        WHEN age = '[50-60)' THEN '50-60'
        WHEN age = '[60-70)' THEN '60-70'
        WHEN age = '[70-80)' THEN '70-80'
        WHEN age = '[80-90)' THEN '80-90'
        WHEN age = '[90-100)' THEN '90-100'
    END AS age_group,

    COUNT(*) AS total_encounters,

    SUM(
        CASE
            WHEN readmitted_30_day = 1 THEN 1
            ELSE 0
        END
    ) AS readmissions_30_day,

    ROUND(
        SUM(
            CASE
                WHEN readmitted_30_day = 1 THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS readmission_rate

FROM diabetic_copy

GROUP BY
    CASE
        WHEN age = '[0-10)' THEN '0-10'
        WHEN age = '[10-20)' THEN '10-20'
        WHEN age = '[20-30)' THEN '20-30'
        WHEN age = '[30-40)' THEN '30-40'
        WHEN age = '[40-50)' THEN '40-50'
        WHEN age = '[50-60)' THEN '50-60'
        WHEN age = '[60-70)' THEN '60-70'
        WHEN age = '[70-80)' THEN '70-80'
        WHEN age = '[80-90)' THEN '80-90'
        WHEN age = '[90-100)' THEN '90-100'
    END

ORDER BY age_group;


-- 30-day readmission rate by gender
SELECT
    gender,
    COUNT(*) AS total_encounters,

    SUM(
        CASE
            WHEN readmitted_30_day = 1 THEN 1
            ELSE 0
        END
    ) AS readmissions_30_day,

    ROUND(
        SUM(
            CASE
                WHEN readmitted_30_day = 1 THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS readmission_rate

FROM diabetic_copy

GROUP BY gender
ORDER BY readmission_rate DESC;


-- 30-day readmission rate by race
SELECT
    race,
    COUNT(*) AS total_encounters,

    SUM(
        CASE
            WHEN readmitted_30_day = 1 THEN 1
            ELSE 0
        END
    ) AS readmissions_30_day,

    ROUND(
        SUM(
            CASE
                WHEN readmitted_30_day = 1 THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS readmission_rate

FROM diabetic_copy

GROUP BY race
ORDER BY readmission_rate DESC;

-- ============================================================
-- 5. UTILIZATION ANALYSIS
-- ============================================================


-- 30-day readmission rate by previous inpatient utilization
SELECT
    CASE
        WHEN number_inpatient = 0 THEN '0'
        WHEN number_inpatient BETWEEN 1 AND 2 THEN '1-2'
        WHEN number_inpatient BETWEEN 3 AND 4 THEN '3-4'
        ELSE '5+'
    END AS inpatient_visits_group,

    COUNT(*) AS total_encounters,

    SUM(
        CASE
            WHEN readmitted_30_day = 1 THEN 1
            ELSE 0
        END
    ) AS readmissions_30_day,

    ROUND(
        SUM(
            CASE
                WHEN readmitted_30_day = 1 THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS readmission_rate

FROM diabetic_copy

GROUP BY
    CASE
        WHEN number_inpatient = 0 THEN '0'
        WHEN number_inpatient BETWEEN 1 AND 2 THEN '1-2'
        WHEN number_inpatient BETWEEN 3 AND 4 THEN '3-4'
        ELSE '5+'
    END

ORDER BY
    CASE inpatient_visits_group
        WHEN '0' THEN 1
        WHEN '1-2' THEN 2
        WHEN '3-4' THEN 3
        WHEN '5+' THEN 4
    END;


-- 30-day readmission rate by previous emergency utilization
SELECT
    CASE
        WHEN number_emergency = 0 THEN '0'
        WHEN number_emergency BETWEEN 1 AND 2 THEN '1-2'
        WHEN number_emergency BETWEEN 3 AND 4 THEN '3-4'
        ELSE '5+'
    END AS emergency_visits_group,

    COUNT(*) AS total_encounters,

    SUM(
        CASE
            WHEN readmitted_30_day = 1 THEN 1
            ELSE 0
        END
    ) AS readmissions_30_day,

    ROUND(
        SUM(
            CASE
                WHEN readmitted_30_day = 1 THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS readmission_rate

FROM diabetic_copy

GROUP BY
    CASE
        WHEN number_emergency = 0 THEN '0'
        WHEN number_emergency BETWEEN 1 AND 2 THEN '1-2'
        WHEN number_emergency BETWEEN 3 AND 4 THEN '3-4'
        ELSE '5+'
    END

ORDER BY
    CASE emergency_visits_group
        WHEN '0' THEN 1
        WHEN '1-2' THEN 2
        WHEN '3-4' THEN 3
        WHEN '5+' THEN 4
    END;


-- 30-day readmission rate by previous outpatient utilization
SELECT
    CASE
        WHEN number_outpatient = 0 THEN '0'
        WHEN number_outpatient BETWEEN 1 AND 2 THEN '1-2'
        WHEN number_outpatient BETWEEN 3 AND 4 THEN '3-4'
        ELSE '5+'
    END AS outpatient_visits_group,

    COUNT(*) AS total_encounters,

    SUM(
        CASE
            WHEN readmitted_30_day = 1 THEN 1
            ELSE 0
        END
    ) AS readmissions_30_day,

    ROUND(
        SUM(
            CASE
                WHEN readmitted_30_day = 1 THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS readmission_rate

FROM diabetic_copy

GROUP BY
    CASE
        WHEN number_outpatient = 0 THEN '0'
        WHEN number_outpatient BETWEEN 1 AND 2 THEN '1-2'
        WHEN number_outpatient BETWEEN 3 AND 4 THEN '3-4'
        ELSE '5+'
    END

ORDER BY
    CASE outpatient_visits_group
        WHEN '0' THEN 1
        WHEN '1-2' THEN 2
        WHEN '3-4' THEN 3
        WHEN '5+' THEN 4
    END;
    
-- ============================================================
-- 6. CLINICAL & HOSPITALIZATION ANALYSIS
-- ============================================================


-- 30-day readmission rate by number of diagnoses
SELECT
    CASE
        WHEN number_diagnoses BETWEEN 1 AND 2 THEN '1-2'
        WHEN number_diagnoses BETWEEN 3 AND 4 THEN '3-4'
        ELSE '5+'
    END AS diagnosis_count_group,

    COUNT(*) AS total_encounters,

    SUM(
        CASE
            WHEN readmitted_30_day = 1 THEN 1
            ELSE 0
        END
    ) AS readmissions_30_day,

    ROUND(
        SUM(
            CASE
                WHEN readmitted_30_day = 1 THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS readmission_rate

FROM diabetic_copy

GROUP BY
    CASE
        WHEN number_diagnoses BETWEEN 1 AND 2 THEN '1-2'
        WHEN number_diagnoses BETWEEN 3 AND 4 THEN '3-4'
        ELSE '5+'
    END

ORDER BY
    CASE diagnosis_count_group
        WHEN '1-2' THEN 1
        WHEN '3-4' THEN 2
        WHEN '5+' THEN 3
    END;


-- 30-day readmission rate by hospital stay duration
SELECT
    CASE
        WHEN time_in_hospital BETWEEN 1 AND 2 THEN '1-2 days'
        WHEN time_in_hospital BETWEEN 3 AND 4 THEN '3-4 days'
        WHEN time_in_hospital BETWEEN 5 AND 7 THEN '5-7 days'
        ELSE '8+ days'
    END AS hospital_stay_group,

    COUNT(*) AS total_encounters,

    SUM(
        CASE
            WHEN readmitted_30_day = 1 THEN 1
            ELSE 0
        END
    ) AS readmissions_30_day,

    ROUND(
        SUM(
            CASE
                WHEN readmitted_30_day = 1 THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS readmission_rate

FROM diabetic_copy

GROUP BY
    CASE
        WHEN time_in_hospital BETWEEN 1 AND 2 THEN '1-2 days'
        WHEN time_in_hospital BETWEEN 3 AND 4 THEN '3-4 days'
        WHEN time_in_hospital BETWEEN 5 AND 7 THEN '5-7 days'
        ELSE '8+ days'
    END

ORDER BY
    CASE hospital_stay_group
        WHEN '1-2 days' THEN 1
        WHEN '3-4 days' THEN 2
        WHEN '5-7 days' THEN 3
        WHEN '8+ days' THEN 4
    END;
    
-- ============================================================
-- 7. MEDICATION & GLUCOSE ANALYSIS
-- ============================================================


-- 30-day readmission rate by diabetes medication status
SELECT
    diabetesMed,
    COUNT(*) AS total_encounters,

    SUM(
        CASE
            WHEN readmitted_30_day = 1 THEN 1
            ELSE 0
        END
    ) AS readmissions_30_day,

    ROUND(
        SUM(
            CASE
                WHEN readmitted_30_day = 1 THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS readmission_rate

FROM diabetic_copy

GROUP BY diabetesMed
ORDER BY readmission_rate DESC;


-- 30-day readmission rate by medication change
SELECT
    `change`,
    COUNT(*) AS total_encounters,

    SUM(
        CASE
            WHEN readmitted_30_day = 1 THEN 1
            ELSE 0
        END
    ) AS readmissions_30_day,

    ROUND(
        SUM(
            CASE
                WHEN readmitted_30_day = 1 THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS readmission_rate

FROM diabetic_copy

GROUP BY `change`
ORDER BY readmission_rate DESC;


-- 30-day readmission rate by A1C result
SELECT
    A1Cresult,
    COUNT(*) AS total_encounters,

    SUM(
        CASE
            WHEN readmitted_30_day = 1 THEN 1
            ELSE 0
        END
    ) AS readmissions_30_day,

    ROUND(
        SUM(
            CASE
                WHEN readmitted_30_day = 1 THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS readmission_rate

FROM diabetic_copy

GROUP BY A1Cresult
ORDER BY readmission_rate DESC;


-- 30-day readmission rate by maximum glucose serum result
SELECT
    max_glu_serum,
    COUNT(*) AS total_encounters,

    SUM(
        CASE
            WHEN readmitted_30_day = 1 THEN 1
            ELSE 0
        END
    ) AS readmissions_30_day,

    ROUND(
        SUM(
            CASE
                WHEN readmitted_30_day = 1 THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS readmission_rate

FROM diabetic_copy

GROUP BY max_glu_serum
ORDER BY readmission_rate DESC;


-- 30-day readmission rate by insulin treatment trend
SELECT
    insulin,
    COUNT(*) AS total_encounters,

    SUM(
        CASE
            WHEN readmitted_30_day = 1 THEN 1
            ELSE 0
        END
    ) AS readmissions_30_day,

    ROUND(
        SUM(
            CASE
                WHEN readmitted_30_day = 1 THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS readmission_rate

FROM diabetic_copy

GROUP BY insulin
ORDER BY readmission_rate DESC;

-- ============================================================
-- 8. ADMISSION & DISCHARGE ANALYSIS
-- ============================================================


-- 30-day readmission rate by admission type
SELECT
    admission_type_id,
    COUNT(*) AS total_encounters,

    SUM(
        CASE
            WHEN readmitted_30_day = 1 THEN 1
            ELSE 0
        END
    ) AS readmissions_30_day,

    ROUND(
        SUM(
            CASE
                WHEN readmitted_30_day = 1 THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS readmission_rate

FROM diabetic_copy

GROUP BY admission_type_id
ORDER BY readmission_rate DESC;


-- 30-day readmission rate by admission source
SELECT
    admission_source_id,
    COUNT(*) AS total_encounters,

    SUM(
        CASE
            WHEN readmitted_30_day = 1 THEN 1
            ELSE 0
        END
    ) AS readmissions_30_day,

    ROUND(
        SUM(
            CASE
                WHEN readmitted_30_day = 1 THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS readmission_rate

FROM diabetic_copy

GROUP BY admission_source_id
ORDER BY readmission_rate DESC;


-- 30-day readmission rate by discharge disposition
SELECT
    discharge_disposition_id,
    COUNT(*) AS total_encounters,

    SUM(
        CASE
            WHEN readmitted_30_day = 1 THEN 1
            ELSE 0
        END
    ) AS readmissions_30_day,

    ROUND(
        SUM(
            CASE
                WHEN readmitted_30_day = 1 THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS readmission_rate

FROM diabetic_copy

GROUP BY discharge_disposition_id
ORDER BY readmission_rate DESC;

-- ============================================================
-- 9. RISK FACTOR RANKING
-- ============================================================

SELECT
    'Previous Inpatient Visits' AS risk_factor,
    '0 vs 5+' AS comparison,
    8.43 AS lowest_rate,
    35.98 AS highest_rate,
    ROUND(35.98 - 8.43, 2) AS difference_pp

UNION ALL

SELECT
    'Previous Emergency Visits',
    '0 vs 5+',
    10.38,
    27.00,
    ROUND(27.00 - 10.38, 2)

UNION ALL

SELECT
    'Number of Diagnoses',
    '1-2 vs 5+',
    6.07,
    11.44,
    ROUND(11.44 - 6.07, 2)

UNION ALL

SELECT
    'Hospital Stay',
    '1-2 days vs 8+ days',
    9.04,
    13.48,
    ROUND(13.48 - 9.04, 2)

UNION ALL

SELECT
    'Insulin',
    'No vs Down',
    9.93,
    13.84,
    ROUND(13.84 - 9.93, 2)

UNION ALL

SELECT
    'Max Glucose Serum',
    'None vs >300',
    11.01,
    14.21,
    ROUND(14.21 - 11.01, 2)

UNION ALL

SELECT
    'Diabetes Medication',
    'No vs Yes',
    9.52,
    11.54,
    ROUND(11.54 - 9.52, 2)

UNION ALL

SELECT
    'Medication Change',
    'No vs Ch',
    10.50,
    11.74,
    ROUND(11.74 - 10.50, 2)

ORDER BY difference_pp DESC;

-- ============================================================
-- 10. RULE-BASED RISK SCORING
-- ============================================================

SELECT
    encounter_id,
    patient_nbr,

    -- Previous inpatient utilization score
    CASE
        WHEN number_inpatient = 0 THEN 0
        WHEN number_inpatient BETWEEN 1 AND 2 THEN 1
        WHEN number_inpatient BETWEEN 3 AND 4 THEN 2
        ELSE 3
    END AS inpatient_score,

    -- Previous emergency utilization score
    CASE
        WHEN number_emergency = 0 THEN 0
        WHEN number_emergency BETWEEN 1 AND 2 THEN 1
        WHEN number_emergency BETWEEN 3 AND 4 THEN 2
        ELSE 3
    END AS emergency_score,

    -- Diagnosis complexity score
    CASE
        WHEN number_diagnoses BETWEEN 1 AND 2 THEN 0
        WHEN number_diagnoses BETWEEN 3 AND 4 THEN 1
        ELSE 2
    END AS diagnosis_score,

    -- Hospital stay score
    CASE
        WHEN time_in_hospital BETWEEN 1 AND 2 THEN 0
        WHEN time_in_hospital BETWEEN 3 AND 4 THEN 1
        WHEN time_in_hospital BETWEEN 5 AND 7 THEN 2
        ELSE 3
    END AS hospital_stay_score,

    -- Total risk score
    (
        CASE
            WHEN number_inpatient = 0 THEN 0
            WHEN number_inpatient BETWEEN 1 AND 2 THEN 1
            WHEN number_inpatient BETWEEN 3 AND 4 THEN 2
            ELSE 3
        END
        +
        CASE
            WHEN number_emergency = 0 THEN 0
            WHEN number_emergency BETWEEN 1 AND 2 THEN 1
            WHEN number_emergency BETWEEN 3 AND 4 THEN 2
            ELSE 3
        END
        +
        CASE
            WHEN number_diagnoses BETWEEN 1 AND 2 THEN 0
            WHEN number_diagnoses BETWEEN 3 AND 4 THEN 1
            ELSE 2
        END
        +
        CASE
            WHEN time_in_hospital BETWEEN 1 AND 2 THEN 0
            WHEN time_in_hospital BETWEEN 3 AND 4 THEN 1
            WHEN time_in_hospital BETWEEN 5 AND 7 THEN 2
            ELSE 3
        END
    ) AS total_risk_score

FROM diabetic_copy;

-- ============================================================
-- 11. RISK SEGMENTATION
-- ============================================================

SELECT
    risk_segment,

    COUNT(*) AS total_encounters,

    SUM(
        CASE
            WHEN readmitted_30_day = 1 THEN 1
            ELSE 0
        END
    ) AS readmissions_30_day,

    ROUND(
        SUM(
            CASE
                WHEN readmitted_30_day = 1 THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS readmission_rate

FROM (
    SELECT
        readmitted_30_day,

        CASE
            WHEN (
                CASE
                    WHEN number_inpatient = 0 THEN 0
                    WHEN number_inpatient BETWEEN 1 AND 2 THEN 1
                    WHEN number_inpatient BETWEEN 3 AND 4 THEN 2
                    ELSE 3
                END
                +
                CASE
                    WHEN number_emergency = 0 THEN 0
                    WHEN number_emergency BETWEEN 1 AND 2 THEN 1
                    WHEN number_emergency BETWEEN 3 AND 4 THEN 2
                    ELSE 3
                END
                +
                CASE
                    WHEN number_diagnoses BETWEEN 1 AND 2 THEN 0
                    WHEN number_diagnoses BETWEEN 3 AND 4 THEN 1
                    ELSE 2
                END
                +
                CASE
                    WHEN time_in_hospital BETWEEN 1 AND 2 THEN 0
                    WHEN time_in_hospital BETWEEN 3 AND 4 THEN 1
                    WHEN time_in_hospital BETWEEN 5 AND 7 THEN 2
                    ELSE 3
                END
            ) BETWEEN 0 AND 3
            THEN 'Low Risk'

            WHEN (
                CASE
                    WHEN number_inpatient = 0 THEN 0
                    WHEN number_inpatient BETWEEN 1 AND 2 THEN 1
                    WHEN number_inpatient BETWEEN 3 AND 4 THEN 2
                    ELSE 3
                END
                +
                CASE
                    WHEN number_emergency = 0 THEN 0
                    WHEN number_emergency BETWEEN 1 AND 2 THEN 1
                    WHEN number_emergency BETWEEN 3 AND 4 THEN 2
                    ELSE 3
                END
                +
                CASE
                    WHEN number_diagnoses BETWEEN 1 AND 2 THEN 0
                    WHEN number_diagnoses BETWEEN 3 AND 4 THEN 1
                    ELSE 2
                END
                +
                CASE
                    WHEN time_in_hospital BETWEEN 1 AND 2 THEN 0
                    WHEN time_in_hospital BETWEEN 3 AND 4 THEN 1
                    WHEN time_in_hospital BETWEEN 5 AND 7 THEN 2
                    ELSE 3
                END
            ) BETWEEN 4 AND 7
            THEN 'Moderate Risk'

            ELSE 'High Risk'
        END AS risk_segment

    FROM diabetic_copy
) AS risk_data

GROUP BY risk_segment

ORDER BY
    CASE risk_segment
        WHEN 'Low Risk' THEN 1
        WHEN 'Moderate Risk' THEN 2
        WHEN 'High Risk' THEN 3
    END;
    
-- ============================================================
-- 12. FINAL COMPARATIVE RISK ANALYSIS
-- ============================================================

SELECT
    risk_segment,

    COUNT(*) AS total_encounters,

    SUM(
        CASE
            WHEN readmitted_30_day = 1 THEN 1
            ELSE 0
        END
    ) AS readmissions_30_day,

    ROUND(
        SUM(
            CASE
                WHEN readmitted_30_day = 1 THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS readmission_rate,

    -- Difference from overall baseline of 11.07%
    ROUND(
        (
            SUM(
                CASE
                    WHEN readmitted_30_day = 1 THEN 1
                    ELSE 0
                END
            ) * 100.0 / COUNT(*)
        ) - 11.07,
        2
    ) AS difference_from_baseline_pp,

    -- Relative risk compared with overall baseline
    ROUND(
        (
            SUM(
                CASE
                    WHEN readmitted_30_day = 1 THEN 1
                    ELSE 0
                END
            ) * 1.0 / COUNT(*)
        ) / 0.1107,
        2
    ) AS relative_risk

FROM (
    SELECT
        readmitted_30_day,

        CASE
            WHEN (
                CASE
                    WHEN number_inpatient = 0 THEN 0
                    WHEN number_inpatient BETWEEN 1 AND 2 THEN 1
                    WHEN number_inpatient BETWEEN 3 AND 4 THEN 2
                    ELSE 3
                END
                +
                CASE
                    WHEN number_emergency = 0 THEN 0
                    WHEN number_emergency BETWEEN 1 AND 2 THEN 1
                    WHEN number_emergency BETWEEN 3 AND 4 THEN 2
                    ELSE 3
                END
                +
                CASE
                    WHEN number_diagnoses BETWEEN 1 AND 2 THEN 0
                    WHEN number_diagnoses BETWEEN 3 AND 4 THEN 1
                    ELSE 2
                END
                +
                CASE
                    WHEN time_in_hospital BETWEEN 1 AND 2 THEN 0
                    WHEN time_in_hospital BETWEEN 3 AND 4 THEN 1
                    WHEN time_in_hospital BETWEEN 5 AND 7 THEN 2
                    ELSE 3
                END
            ) BETWEEN 0 AND 3
            THEN 'Low Risk'

            WHEN (
                CASE
                    WHEN number_inpatient = 0 THEN 0
                    WHEN number_inpatient BETWEEN 1 AND 2 THEN 1
                    WHEN number_inpatient BETWEEN 3 AND 4 THEN 2
                    ELSE 3
                END
                +
                CASE
                    WHEN number_emergency = 0 THEN 0
                    WHEN number_emergency BETWEEN 1 AND 2 THEN 1
                    WHEN number_emergency BETWEEN 3 AND 4 THEN 2
                    ELSE 3
                END
                +
                CASE
                    WHEN number_diagnoses BETWEEN 1 AND 2 THEN 0
                    WHEN number_diagnoses BETWEEN 3 AND 4 THEN 1
                    ELSE 2
                END
                +
                CASE
                    WHEN time_in_hospital BETWEEN 1 AND 2 THEN 0
                    WHEN time_in_hospital BETWEEN 3 AND 4 THEN 1
                    WHEN time_in_hospital BETWEEN 5 AND 7 THEN 2
                    ELSE 3
                END
            ) BETWEEN 4 AND 7
            THEN 'Moderate Risk'

            ELSE 'High Risk'
        END AS risk_segment

    FROM diabetic_copy
) AS risk_data

GROUP BY risk_segment

ORDER BY
    CASE risk_segment
        WHEN 'Low Risk' THEN 1
        WHEN 'Moderate Risk' THEN 2
        WHEN 'High Risk' THEN 3
    END;