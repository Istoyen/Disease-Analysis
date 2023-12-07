---1. Analysis of Diagnosis and Symptoms Correlation:
SELECT 
    A.ID, 
    A.SEX, 
    CONVERT(varchar, A.Birthday, 23) AS Birthday, 
    A.Description, 
    A.Diagnosis,
    CONVERT(varchar, B.[Examination Date], 23) AS [Examination Date], 
    B.Diagnosis AS B_Diagnosis,
    CONVERT(varchar, C.Date, 23) AS C_Date, 
    C.GOT, 
    C.GPT,
    DATEDIFF(YEAR, A.Birthday, B.[Examination Date]) AS Age_at_Examination,
    YEAR(B.[Examination Date]) AS Exam_Year,
    MONTH(B.[Examination Date]) AS Exam_Month,
    DAY(B.[Examination Date]) AS Exam_Day
FROM 
 TSUM_A AS A
LEFT JOIN 
    TSUM_B AS B ON A.ID = B.ID
LEFT JOIN 
  TSUM_C AS C ON A.ID = C.ID;


 
SELECT 
    B.ID,
    B.Diagnosis as Diagnosis_B,
    C.GOT, C.GPT, C.LDH, C.ALP, C.TP, C.ALB, C.UA, C.UN, C.CRE, 
    B.Symptoms,
    B.Thrombosis
FROM TSUM_B AS B
INNER JOIN TSUM_C AS C ON B.ID = C.ID 
ORDER BY B.ID;


WITH AgeData AS (
    SELECT 
        ID, 
        SEX, 
        DATEDIFF(YEAR, Birthday, GETDATE()) AS Age,
        Diagnosis
    FROM TSUM_A
)
SELECT * FROM AgeData;

SELECT 
    ID, 
    Date, 
    WBC, 
    RBC, 
    HGB
FROM 
    dbo.TSUM_C
WHERE 
    WBC IS NOT NULL 
    OR RBC IS NOT NULL 
    OR HGB IS NOT NULL
ORDER BY 
    ID, 
    Date;

---2.Impact of Demographic Factors on Diagnosis:
SELECT 
    ID, 
    Date, 
    WBC, 
    RBC, 
    HGB
FROM 
    dbo.TSUM_C
WHERE 
    WBC IS NOT NULL 
    OR RBC IS NOT NULL 
    OR HGB IS NOT NULL
ORDER BY 
    ID, 
    Date;

	
	
	WITH AgeData AS (
    SELECT 
        ID, 
        SEX,
        DATEDIFF(YEAR, Birthday, GETDATE()) AS Age,
        Diagnosis
    FROM [dbo].[TSUM_A]
)
SELECT 
    SEX, 
    CASE 
        WHEN Age < 20 THEN '0-19'
        WHEN Age BETWEEN 20 AND 39 THEN '20-39'
        WHEN Age BETWEEN 40 AND 59 THEN '40-59'
        ELSE '60+'
    END AS AgeGroup,
    Diagnosis,
    COUNT(*) AS Diagnosis_Count
FROM AgeData
GROUP BY 
    SEX, 
    CASE 
        WHEN Age < 20 THEN '0-19'
        WHEN Age BETWEEN 20 AND 39 THEN '20-39'
        WHEN Age BETWEEN 40 AND 59 THEN '40-59'
        ELSE '60+'
    END, 
    Diagnosis
ORDER BY 
    SEX, 
    AgeGroup, 
    Diagnosis_Count DESC;



WITH JoinedData AS (
    SELECT 
        A.ID, YEAR(CONVERT(datetime, A.Birthday, 101)) AS Year, A.Diagnosis,
        CAST(B.[aCL IgG] AS int) AS [aCL IgG], CAST(B.[aCL IgM] AS int) AS [aCL IgM], CAST(B.ANA AS int) AS ANA, 
        CAST(B.[aCL IgA] AS int) AS [aCL IgA], CAST(B.KCT AS int) AS KCT, CAST(B.RVVT AS int) AS RVVT, CAST(B.LAC AS int) AS LAC
    FROM 
        [dbo].[TSUM_A] AS A
    JOIN 
        [dbo].[TSUM_B] AS B ON A.ID = B.ID
), 
DiagnosisTrend AS (
    SELECT 
        Year, Diagnosis, COUNT(*) AS Diagnosis_Count
    FROM 
        JoinedData
    WHERE 
        Year IS NOT NULL
    GROUP BY 
        Year, Diagnosis
)
SELECT 
    JD.Year, JD.Diagnosis, DT.Diagnosis_Count,
    AVG(JD.[aCL IgG]) AS Avg_aCL_IgG, AVG(JD.[aCL IgM]) AS Avg_aCL_IgM, AVG(JD.ANA) AS Avg_ANA,
    AVG(COALESCE(JD.[aCL IgA], 0)) AS Avg_aCL_IgA, AVG(COALESCE(JD.KCT, 0)) AS Avg_KCT, 
    AVG(COALESCE(JD.RVVT, 0)) AS Avg_RVVT, AVG(COALESCE(JD.LAC, 0)) AS Avg_LAC
FROM 
    JoinedData JD
JOIN 
    DiagnosisTrend DT ON JD.Year = DT.Year AND JD.Diagnosis = DT.Diagnosis
GROUP BY 
    JD.Year, JD.Diagnosis, DT.Diagnosis_Count
ORDER BY 
    JD.Year, DT.Diagnosis_Count DESC;

SELECT 
    A.[ID], A.[SEX], A.[Birthday],
    A.[Description], A.[First Date], A.[Admission], A.[Diagnosis] AS [Diagnosis_A],
    B.[Examination Date], B.[aCL IgG], B.[aCL IgM], B.[ANA], B.[ANA Pattern], B.[aCL IgA], B.[Diagnosis] AS [Diagnosis_B],
    B.[KCT], B.[RVVT], B.[LAC], B.[Symptoms], B.[Thrombosis]
FROM 
    [dbo].[TSUM_A] AS A
JOIN 
    [dbo].[TSUM_B] AS B 
ON 
    A.[ID] = B.[ID];

---Analysis of Autoimmune Diseases
	SELECT 
    A.[ID], 
    A.[SEX], 
    A.[Birthday], 
    A.[Diagnosis] AS [Diagnosis_A],
    B.[Examination Date], 
    B.[aCL IgG], 
    B.[aCL IgM], 
    B.[ANA], 
    B.[ANA Pattern], 
    B.[aCL IgA], 
    B.[Diagnosis] AS [Diagnosis_B],
    B.[KCT], 
    B.[RVVT], 
    B.[LAC]  
FROM 
    [dbo].[TSUM_A] AS A
LEFT JOIN 
    [dbo].[TSUM_B] AS B ON A.[ID] = B.[ID]
LEFT JOIN 
    [dbo].[TSUM_C] AS C ON A.[ID] = C.[ID];
