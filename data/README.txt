Package documentation adapted for stats.camp.

README: Replicating Analyses from “Incentivized Resume
        Rating: Eliciting Employer Preferences without Deception”
                       Judd B. Kessler, Corinne Low, and Colin D. Sullivan∗

                                               May 29, 2019

      The Supplement directory contains this document (README.txt) and three directories: Code,
Data, and Tables and Figures.

      • Code contains KesslerLowSullivan-IRR-Analysis.do. This file creates cleaned data files with
        derived variables, and then generates all tables and figures in Kessler, Low, and Sullivan 2019.
        In stats.camp, set the working directory to data/ before executing the script.

      • Data contains two subdirectories, Data/Raw and Data/Clean.

          – Data/Raw contains IRRData_Penn.dta and IRRData_Pitt.dta, each with data from two
             IRR experimental rounds (two at the University of Pennsylvania, two at the University
             of Pittsburgh). Each observation in the dataset represents the evaluation of one hypo-
             thetical resume. Each variable has a descriptive label in the dataset. The Penn data file
             contains all variables necessary to reconstruct each hypothetical resume. The resume
             components at Pitt were collected under a different data agreement, so we have removed
             the bullet point descriptions and locations of experiences to protect the anonymity of
             the source resumes. Key variables in the datasets:
               ∗ rating_hire is the Likert-scale rating of Hiring Interest; rating_accept is the
                 Likert-scale rating of Likelihood of Acceptance.
               ∗ Variables that appear as text directly on resumes are prefixed with rand (with
                 the exception of rand_eth and randgender, which are randomized demographic
                 variables that are implied on the resume through name only). When these variables
                 are missing (as for some bullet points, or some second work experiences), no element
                 appeared in that position on the resume.
  ∗
   The Wharton School, University of Pennsylvania, 3620 Locust Walk, Steinberg Hall-Dietrich Hall, Philadelphia,
PA 19104 (email: judd.kessler@wharton.upenn.edu, corlow@wharton.upenn.edu, colins@wharton.upenn.edu).

         ∗ Human capital variables include randgpa (GPA), topemp (Top Internship), secondint
           Second Internship, wfm (Work for Money), and techskills (Technical Skills).
         ∗ Demographic variables are derived from rand_eth and randgender. We define
           the demographic variables whitefemale (Female, White); nonwhite_male (Male,
           Non-White); nonwhite_female (Female; Non-White); and not_a_whitemale (Not a
           White Male) in the .do script for use in regressions.
         ∗ The Pitt data includes an additional variable targetmajor indicating whether or
           not the resume major was on the list of majors targeted by the firm. We only
           collected this variable for the final experimental wave at Pitt.
    – Data/Clean is an empty directory. After executing KesslerLowSullivan-IRR-Analysis.do,
       it will contain new datasets with all derived variables used for analysis.

• Tables and Figures is an empty directory. LaTeX tables and PNG figures will output to this
  directory when the .do script is executed.
