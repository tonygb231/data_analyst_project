SELECT * FROM job_market_unemployment_trends
LIMIT 100

-- 1/ Tỷ lệ thất nghiệp, bài đăng việc làm trung bình từng năm

SELECT EXTRACT(YEAR FROM date) AS year,
	   ROUND(AVG(unemployment_rate)::numeric, 1) AS avg_unemployment_rate,
	   ROUND(AVG(job_postings)::numeric) AS avg_job_postings
FROM job_market_unemployment_trends
GROUP BY year
ORDER BY year ASC

-- 2/ Tỷ lệ thất nghiệp, bài đăng việc làm trung bình từng bang qua các năm

SELECT location, EXTRACT(YEAR FROM date) AS year,
				 ROUND(AVG(unemployment_rate)::numeric, 1) AS avg_unemployment_rate,
				 ROUND(AVG(job_postings)::numeric) AS avg_job_postings
FROM job_market_unemployment_trends
GROUP BY location, year
ORDER BY location, year ASC

-- 3/ Top 3 kỹ năng được yêu cầu nhiều nhất theo từng bang qua các năm

-- Bảng phụ chứa vị trí, năm và kỹ năng được tách ra
WITH exploded_skills AS (
SELECT location, EXTRACT(YEAR FROM date) AS year,
    			 TRIM(demand_skills) AS skill
FROM job_market_unemployment_trends, 
	UNNEST(string_to_array(in_demand_skills, ',')) AS demand_skills
),
-- SELECT * FROM exploded_skills;

-- Đếm số lần kỹ năng suất hiện trong năm
skill_counts AS (
SELECT location, year, skill, COUNT(*) AS frequency
FROM exploded_skills
GROUP BY location, year, skill
),
-- SELECT * FROM skill_counts

-- Sắp xếp số lần suất hiện của kỹ năng trong năm và chọn ra 3 vị trí đầu
ranked_skill AS (
SELECT *, ROW_NUMBER() OVER (PARTITION BY location, year ORDER BY frequency DESC) AS rank
FROM skill_counts
)
SELECT location, year, skill, frequency
FROM ranked_skill
WHERE rank <= 3
ORDER BY location, year, frequency DESC;

-- 4/ Độ tuổi và tỷ lệ bằng cấp thất nghiệp trung bình của từng năm
SELECT EXTRACT(YEAR FROM date) AS year,
	   ROUND(AVG(average_age)::numeric) AS average_unemploy_age,
	   ROUND(AVG(college_degree_percentage)::numeric, 1) AS average_unemploy_with_degree
FROM job_market_unemployment_trends
GROUP BY year
ORDER BY year

-- 5/ Độ tuổi và tỷ lệ bằng cấp thất nghiệp trung bình của các bang
SELECT location, EXTRACT(YEAR FROM date) AS year,
				 ROUND(AVG(average_age)::numeric) AS average_unemploy_age,
	   			 ROUND(AVG(college_degree_percentage)::numeric, 1) AS average_unemploy_with_degree
FROM job_market_unemployment_trends
GROUP BY location, year
ORDER BY location, year

