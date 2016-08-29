Deploying Community Tracks on the Araport JBrowse using the CyVerse Discovery Environment
=========================================================================================

The following tutorial explains the steps to upload Genomic Data Format (GFF3, BED, VCF) files into the CyVerse Data Store and run an app in the CyVerse Discovery Environment to process and prepare them for visualization in the Araport genome browser (JBrowse) instance.

### Background Information

* [GFF3](http://www.sequenceontology.org/gff3.shtml): _Generic Feature Format Version 3_ is a 9-column TAB-delimited text file format used to represent genomic features, allowing for hierarchical grouping of features, with feature types based on a controlled vocabulary called [Sequence Ontology (SO)](http://www.sequenceontology.org/gff3.shtml). The coordinate system is [1-based](https://www.biostars.org/p/84686/).

* [BED](https://genome.ucsc.edu/FAQ/FAQformat.html#format1): _Browser Extensible Data_ format is a 12-column TAB-delimited text file format used to represent genomic features, developed by UCSC. The coordinate system is [0-based](https://www.biostars.org/p/84686/).

* [VCF](http://samtools.github.io/hts-specs/VCFv4.1.pdf): _Variant Call Format_ is a TAB-delimited text file format (most likely stored in a compressed manner), which contains meta-information lines, a header line, and then data lines each containing information about a position in the genome. The coordinate system is [1-based](https://www.biostars.org/p/84686/).

* [tabix](http://www.htslib.org/doc/tabix.html): _tabix_ is a generic indexing tool for TAB-delimited genomic feature files like GFF3, VCF, BED, etc.
    * Depends on the _bgzip_ Block compression/decompression utility

* [CyVerse](http://www.cyverse.org/): An NSF-funded, community-driven, cyber-infrastructure initiative providing access to powerful computational infrastructure to scientists in the form of high performance computing and storage systems. The _CyVerse Data Store_ is a cloud-based storage system that enables researchers to store and share data related to their research.

* [Araport](https://www.araport.org/): Araport is a one-stop-shop for _Arabidopsis thaliana_ genomics. Araport offers gene and protein reports with orthology, expression, interactions and the latest annotation, plus analysis tools, community apps, and web services. Araport is 100% free and open-source.

* [JBrowse](http://gmod.org/wiki/JBrowse): Fast, scalable, customizable, client-side genome browser with a fully dynamic AJAX interface.

### Step-by-step guide

1. Login to the CyVerse Discovery Environment at <https://de.iplantcollaborative.org/de/> with your CyVerse ID.

2. **Upload Genomic Data Format file (GFF3, BED, VCF):** In the DE, click on the _Data_ button in the upper left corner to open up the Data window. From there select the _Upload_ menu and then _Simple Upload from Desktop_.

    ![File upload 1](images/de_upload_file.png?raw=true)

3. In the Upload dialog box, click the _Browse_ button to locate the file on your system and then click the _Upload_ button.

    ![File upload 2](images/de_file_upload_2.png?raw=true)

4. Verify that the file has been uploaded successfully by checking the Data window (Hit the _Refresh_ button if needed).

    ![File uploaded](images/de_file_uploaded.png?raw=true)

5. **Run the Publish App:** Click the _Apps_ button in the upper left corner to open up the Apps window. Find the app called _"Publish Community Tracks to Araport JBrowse 1.0.0"_. The easiest way is to type "araport" into the _Search Apps_ box.

    ![Search Apps](images/de_search_apps.png?raw=true)

6. Click on the app to use it.

    ![Launch App](images/de_open_app.png?raw=true)

7. Change the output folder by clicking on the _Browse_ button and navigate to **Community Data -> araport -> community-tracks -> staging** (/iplant/home/shared/araport/community-tracks/staging) and then click on the _Inputs_ tab.

    ![Select input](images/de_select_input_file.png?raw=true)

8. Click the _Browse_ button to locate the file that was uploaded earlier and then click on the _Parameters_ tab.

    ![Enter description](images/de_enter_description.png?raw=true)

9. Enter a short description for the track that will appear in the JBrowse track selector and then click the _Launch Analysis_ button.

10. (Optional) Click the _Analyses_ button in the upper left corner to open up the Analyses window. From here the job status can be monitored.

    ![Monitor job](images/de_monitor_job.png?raw=true)

When the job completes, the output files will have been uploaded to Araport. At this point, the Araport administrators will review the track and ultimately point to it from the Araport JBrowse instance.

For any questions or comments, please email <araport@jcvi.org>.
