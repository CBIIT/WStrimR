# WStrimR
This script will take a table structured file and trim the white space on a data frame.

Run the following command in a terminal where R is installed for help.

```
Rscript --vanilla WStrimR.R -h
```

```
Usage: WStrimR.R [options]

WStrimR v2.0.0

Options:
	-f CHARACTER, --file=CHARACTER
		A validated dataset file (.xlsx, .tsv, .csv) based on the template CDS_submission_metadata_template.xlsx

	-s CHARACTER, --sheet=CHARACTER
		For xlsx files, a sheet name will need to be provided. It will default to 'Metadata', if none is given.

	-h, --help
		Show this help message and exit
```

There are three test files, in different formats, that all contain white space in the cell 'D5', "        tester3", and they can be run via:

```
Rscript --vanilla WStrimR.R -f Test_files/c_fail_missing_values-v1.3.1.tsv
```
