<h1>Purpose </h1>

Improving data sharing will enable timely access to data, enhance the quality of data, and create clear channels for better management decisions.  Healthy aquatic habitat is critical to fishes, aquatic species, and water quality. Across the country long term, large scale stream habitat monitoring programs collect data for their specific objectives and within their jurisdictional boundaries.  Streams cross jurisdictional boundaries and face unprecedented pressure from changing climate, multi-use public lands, and development. To meet these stressors, we need a way to ingratiate data from multiple sources to create indicators of stream conditions across jurisdictional boundaries. As a pilot, we will focus on integrating data from the EPA National Aquatic Resources Surveys (NARS); BLM Aquatic Assessment, Inventory, and Monitoring; and USFS Aquatic and Riparian Effective Monitoring Program (AREMP) and Pacfish/Infish Biological Opinion Effectiveness Monitoring Program (PIBO). We will build infrastructure to integrate a subset of metrics collected on public lands in the Western United States and document metadata in MonitoringResources.org.

This Aquatic Habitat Analysis package will integrate aquatic habitat data from multiple projects and provide access and analysis of aquatic habitat data status and trends across jurisdictional boundaries.  

As a proof of concept for this analysis package, we picked a subset of the higher than 300 methods calculated between four habitat monitoring programs. You can access the subset list on ScienceBase: https://www.sciencebase.gov/catalog/item/5e9f4a1882cefae35a128bd9

We will build this analysis packages in two-phase.  Phase one we will focus on the following: 
<ul>
<li>Documenting data from the four programs</li>
<li>Building an integrated dataset </li>
<li>Linking the data collection locations to the NHD+ </li>
<li>Linking data to machine-readable metadata documentation </li>
<li>In the Biogeography Map we will build resources to: </li>
	<li> calculate the status of a specific metric based on user-defined HUC, State, Forest, BLM Management unit, or Tribal boundaries. </li>
	<li> The distribution of a metric across the programs in relationship to stream power variables such as gradient, bank-full width, stream order </li>
	<li>Display metadata with data </li>
	</ul>
	

Following phase one, we will gather feedback before implement step two. Phase two will address user feedback and hopeful anaysis questions such as: 
<ul>
<li> Determine if aquatic systems are being degraded, maintained or restored, based on disturbance and determine the direction and rate of changes in riparian and aquatic habitat over time (Figure 1)   (CITE PIBO WEBPAGE) </li>
</ul>


Figure 1) Example of analysis for the trend of aquatic metric based on management type (CITE PIBO REPORT) 

*  The quality in-stream habitat will achieve or exceed federal, state, tribal threshold standards for water quality? (CITE BLM REPORT)(NEED TO LOOK UP THE STANDARDS) 
 
This analysis package will provide benefits to a variety of users types. 

<h2>Benefits for data users: </h2>
<ul>
<li>Summary analysis based on user-defined spatial and temporal extent to be used in products such as Forest Plans, Annual Reports, BLM Grazing permits </li>
<li>Access to organized aquatic habitat metrics and indicators and metadata. Potential users Including the National Fish Habitat Monitoring Partnership and Dreissenid Mussel Risk Assessments Working Group, BLM AIM, AREMP, State of Oregon. Example: What are the biological conditions of wadable streams across all public lands in Oregon? </li>
</ul>

<h2> Benefits for the data providers include: </h2>
<ul>
<li>Increase visibility and data reuse of long term, large spatial scale in-stream and upland riparian habitat monitoring data </li>
<li> Streamline data publishing and access to long term datasets, freeing up data manager’s time </li>
<li> Provide interactive summary analysis for spatial regions such as forests, BLM regions, states and tribal holdings answering basic management question, allowing project’s data analysts to focus on novel analysis </li>
<li> Benefits for National Biogeographic Map: </li>
<li> Leverage existing capacities to answer management questions for specific audiences, using resources such as BLM’s AIM database, EPA’s Water Quality Portal, USGS’ ScienceBase, StreamStats, Metadata Generator, and MonitoringResources.org. </li>
<li>Improve access to in-stream and riparian habitat data, analysis, and metadata. </li>
<li>Example of USGS leading efforts to share resources across agencies inside DOI (USGS and BLM) and outside the DOI (USFS)</li>
<li> Working across Mission Areas in the USGS to expand knowledge and produce FAIR data products </li>
</ul>

<h1>Inputs: </h1>
The base of this analysis is a unified stream habitat dataset comprised of data available on the internet from the BLM AIM, the EPA NARS, and the USFS AREMP.  The combined dataset, data inputs, data exchange schema, field cross-walks are all documented on ScienceBase.  We build this data set using R in a Juyper notebook based on the rules documented in the data exchange schema and is shared in XX repository.   The dataset is published on ScienceBase as item https://www.sciencebase.gov/catalog/item/5e3c5883e4b0edb47be0ef1c. 

The data collection locations are linked to the NHD+ layers SO ALL THAT INFORMATION IS INCLUDED AS IN INPUT. I STILL NEED TO FIGURE THIS OUT. 

In addition to the metric values, we will link specific data from field visits to the appropriate methodology documented in MonitoringResources.org and will use APIs to pull information from MonitoringResources.org into the USGS Biogeographic Map.  

The spatial extent is Alaska and the lower 48; we project the dataset in  WGS84. The temporal extent is from 2002-2018. Each data set has a different sampling interval and data update interval. This information is documented with the data in ScienceBase. 


<h1>Outputs: </h1>
Document all outputs. Again names, links, security constraints, spatial extent and resolution, temporal extent and resolution, example output code all help speed development and ensure repeatability. We’ll also need this for the review(s).


<h1>Constraints</h1>
The data represents a subset of the metrics each program produces for each location.  Each monitoring program calculates  List and adequately explain any analytical constraints. For example, is the analysis only appropriate at a certain scale? Are there temporal aspects that must be met for a valid analysis? What conditions need to be met before performing a given analysis?

<h1>Dependencies</h1>
List all dependencies. Are there specific software libraries, packages, or other BAPs that are required to do this analysis? If so, what are they called, where can they be found and what version did you use? All this will also be wrapped up in the provenance trace.

<h1>Code</h1>
Code written in R and shared in a Juyper notebook are published here in this GitLab repository. 


<h1>Tests</h1>
Tests for BAPs are both conceptual and technical. A core principle we are pursuing in the BAP quest is the idea of a logical test for the applicability of what the BAP does with an appropriate stakeholder. At this stage of our development, we need to make sure that the BAPs we are spending time on can be directly applied to resource management or policymaking decision analysis. A key element of documenting a BAP is figuring out what this use may be and designing an engagement plan for testing and incorporating results into future work.
Also consider baking technical tests into the code part of a BAP. This is really important when we toss things to the developers. We are the domain experts. And since we have captured the previous five things, we need to communicate what the answers are to the folks that grab our science code and make it live. While they have broad and diverse experience working in this area, they may not know what the “right” answer looks like. We need to give them examples to work with and build from.

<h1>Provenance</h1>
Provenance is required. This is built into the system. Several of the previous items feed into that integral subsystem, so this will not be a difficult requirement to meet. We follow W3C PROV closely.

<h1>Citations</h1>
We need them. Just as for your papers, citations provide the scholarly basis for your choice of methodology and implementation, and, given the reusable requirement, provide the background users need to understand and use your BAP for their own work.
All of this information will be made available for the review processes. There are at least three of them. Two of these, the daily ongoing and the internal, are informal and involve working with your branch and program colleagues. The two BAPs we talked about, the ones at https://maps.usgs.gov/biogeography, have gone through both of these informal reviews. The other BAPs currently in development are queueing up for the internal. Every BAP will go through the appropriate level of formal review before it is authorized for official release.
