# Data analysis and visualisation of autocycler sensor logs

## Takes in the sensor logs cleans the data and provides visualisation output

### Overview

This project aims to read the sensor logs of autocycler, perform data wrangling and renders an html document and a presentation with visualisation. This project predominantly uses regular expression for cleaning the data along with dplyr for data wrangling.

There are 2 .qmd files, **DataWrangling.qmd** and **DataVisualisation.qmd;** the first file can be used to generate a html document whose main purpose is to have a holistic idea on sensor performance, visualise and to make decision on certain aspects of statistics. The second file can be used to generate the presentation, more aimed towards visualisation.

### How to run the project...

#### Prerequisites, assumptions and considerations

-   This project is written on R and hence requires R compiler to be installed. You can [click this link](https://cran.r-project.org/bin/windows/base/) to download the compiler. Also yo can use python along with this, if you intend to use python code, python compiler is needed.

-   You don't need to install namespaces on your system.

-   Once you have downloaded all required files into your system (provided as zip folder in teams), it can be opened on any IDE (please check the requirements), recommended IDE is R studio you can [click this link](https://posit.co/download/rstudio-desktop/) to download. If using VS code you want to add **Quarto** extension to render the result.

-   If the presentation required needed to be rendered in pptx, MS PowerPoint need to be installed.

-   **Assumptions and considerations**

    -   This project assumes the log from the sensors 'vaisala_in' and 'vaisala_out' to be synchronised and have the same starting time.

    -   We cannot assume the output log from *temp, humidity, flow* and from *air and probe temperature* to run synchronously with any logs nor we we cannot assume anything about their run time info.

    -   Any data that doesn't match the standard sensor log line is not considered.

#### Note

*For all cases a data frame is created even though tibble is better to work with in R, this is done because python code can be implemented here which can take the data frame data type. Also ensure the code chunk `eval:` is set to false unless you want to render it.*

*There could be warnings in most cases it is about translation error and or embedded null just keep an eye on number of elements, the code does deal with strings that can't be translated, embedded nulls (lines with no entry) and incomplete lines meaning sensor failing to write the entire output.*

#### Once you have opened the project you can follow these steps,

1.  Create a folder inside the **data** folder with name in '**dd-mm-yy'** format of the day in which experiment is run.

2.  Copy all the sensor logs of that particular run into the above created folder.

3.  Initially it is advised to run **DataWrangling.qmd**,

    1.  Open the file and enter the date in `enter_Date` variable as string,

        ![](images/Screenshot%202024-05-30%20at%2021.54.50.png)

    2.  From this point, it is possible to run individual code chunks, if more insights into data is required or for debugging purposes (have seen some unexpected numeric values in log; most of which are taken care of in this code).

    3.  Or you can directly render the directly render the html by hitting the render button in R studio, if in VS code just run the qmd file.

    4.  An html document named **DataWrangling.html** would be populated (first run) or updated. It may open up in your browser or you can do it manually.

4.  Once you are satisfied with the results, you can open **DataVisualisation.qmd** file,

    1.  Enter the date in `enter_Date` variable as string as stated before.

    2.  Ensure the plotting function considers only the required data, at this point it would be easy to identify and remove any unwanted results.

    3.  Hit render button in R studio a html document named **DataVisualisation.html** would be populated, which is a presentation not a document.

    4.  If you want pptx format, under `format` in header YAML change `revealjs` to `pptx`.

        \
        ![](images/Screenshot%202024-05-30%20at%2022.28.12.png)

## Known details, bugs and under development,

-   The project currently uses more variables than it could be necessary which may increase memory consumption, this done so as to make debugging easier because it's still under development.

-   Misalignments are seen while rendering in pptx format which may require manual correction in MS PowerPoint =\> Looking into the issue...

-   The testing was done with data from 8 individual experiment runs manually selected based on bad sensor performance as seen in log.

-   Please refer to comment lines in script for more...

-   **Under development**

    -   Integration of calculating absorbed concentration of $CO_2$.
    -   Gather more sensor data to be tested.
    -   Improve the overall performance of run (memory usage and run time).
    -   Integrate development of processing result of multiple experiment runs simultaneously.
