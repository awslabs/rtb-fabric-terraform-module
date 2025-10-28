# **Instructions (follow or be auto-resolved):**
1. If you plan to release sample code for github.com/aws-samples, such as code for blog or workshop then please use this self-service process for sample code https://w.amazon.com/bin/view/Open_Source/Posting_Sample_Code/. 
2. Replace all `<PLACEHOLDER_VALUES>` with their `actual values` (e.g. `<PROJECT_NAME>` with `My Cool Project`).
3. Do **not** modify or delete any part of the template itself unless it's replacing placeholder values with their actual values.
4.	Run RepoLinter https://w.amazon.com/bin/view/Open_Source/Tools/Repolinter/ on your source code repository. 

---

## 1. Release date and business justification
>    Release date **should** be at least two weeks from now.
>    Date **must** be in `YYYY-MM-DD` format or `None` if no date.

10/27/2025

Service (RTB Fabric) is scheduled for GA on 10/20/2025. Due to inability to validate TF functionality of the service before GA, I need one more week to test it out, since the service introduced API changes that will only be visible at GA (not available in beta now). 
Customers requested terraform support. This activity is tracked as part of the launch tracking for the service. Contact trevdyck@ (PMT) or dandenea@ (Engineering leadership). 

---

## 2. Project name
>    Creative or unique names, while encouraged, may require separate trademark review. [1][2]

terraform-aws-rtb-fabric

---
## 3. Logos
>  Does your repository include any logos - if so, please provide a link to your review ticket [3] with the Open Source Strategy & Marketing (OSSM) team?

No

## 3. Which GitHub Organization account are you planning to publish to?
>    If it's unusual and you're not planning to publish to GitHub, please explain.

awslabs 

---

## 4. Project license
>    AWS samples and blogs are usually `MIT-0`, while anything else is usually `Apache-2.0`. Alexa releases are generally defaulted to Amazon Software License. [3]

MIT

---

## 5. Project type
>    You **must** answer `Sample`, `Blog`, `Workshop`, or `Other`.

Other

---

## 6. Project description and business value

Desciption:
The Terraform AWS RTB Fabric Module is an infrastructure-as-code solution that simplifies the deployment and management of AWS RTB (Real-Time Bidding) Fabric resources for programmatic advertising platforms. This module enables organizations to quickly provision RTB requester applications, responder applications with flexible endpoint management (EKS, Auto Scaling Groups, or basic configurations), and fabric links that connect bidding participants in a secure, scalable manner. 

Value:
By abstracting the complexity of AWS CloudFormation resources and providing automated EKS integration with RBAC configuration, the module accelerates time-to-market for ad tech companies building real-time bidding infrastructure while ensuring best practices for security, networking, and resource management across development, staging, and production environments.

---

### 7. New to open sourcing - does your team already own an open source repository?

Yes

---

## 8. Source code and code review
>    You **may** attach a ZIP file instead of providing a link to source code.
>    You **may** provide a list of logins who reviewed the code instead of providing a link to code review.
>    Upload RepoLinter results to the Ticket Correspondence

Added ZIP archive

CR not available yet

---

## 9. Third-party code
>    Third-party code included in your project **must** be listed, including each license. [5]
>    Any code or other intellectual property included in your project that comes from another Amazon team **must** be listed.

<NAME> - <LICENSE>

---

## 10. Similar projects
>    Are you aware of any existing open source projects which have similar functionality to this new project?

No
---

## Support Expectations

It is expected that you, and your team, will respond to all issues, contributions, and security issues in a timely manner. Failure to do so creates a bad customer experience and will result in archiving/removing of your project.

## Helpful links

1. https://w.amazon.com/?Trademarks
2. https://w.amazon.com/?Open_Source/NamingForGitHubProjects
3. https://issues.amazon.com/issues/create?template=498c89d4-f803-428c-92da-a66abd03e651
4. https://w.amazon.com/?Open_Source/LicensingForGitHubProjects
5. https://w.amazon.com/bin/view/AWS/Teams/SA/Customer_Engagements/workshops
6. https://inside.amazon.com/en/services/legal/us/OpenSource/Pages/BlessedOpenSourceLicenses.aspx
