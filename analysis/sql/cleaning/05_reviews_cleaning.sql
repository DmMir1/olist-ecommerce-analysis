/*
====================================================================
File: 05_reviews_cleaning.sql
====================================================================

Purpose
-------
Review and document missing values in the order_reviews table.

Cleaning tasks:
• Verify missing review comments
• Confirm that missing comments represent expected business behaviour

No updates are required for this table.

====================================================================
*/

------------------------------------------------------------
-- 1. Missing Review Titles
------------------------------------------------------------

SELECT
    COUNT(*) AS missing_review_titles
FROM order_reviews
WHERE review_comment_title IS NULL;

------------------------------------------------------------
-- 2. Missing Review Messages
------------------------------------------------------------

SELECT
    COUNT(*) AS missing_review_messages
FROM order_reviews
WHERE review_comment_message IS NULL;

------------------------------------------------------------
-- 3. Review Score Validation
------------------------------------------------------------

SELECT
    review_score,
    COUNT(*) AS reviews
FROM order_reviews
GROUP BY review_score
ORDER BY review_score;

/*
====================================================================
Cleaning Summary

• Review comments were intentionally left unchanged.
• Customers are not required to provide written feedback
  when submitting a review.
• Review scores were retained without modification.
• No cleaning actions were required for this table.

====================================================================
*/

/*
====================================================================
End of Script
====================================================================
*/
