

var options =
    {
        // Need to upload genomes to addressable location
        reference:
            {
                //fastaURL: "https://drive.google.com/file/d/1GoDCYkVgumf8R5LS_7lRtRkgW8LBMjUJ/view",
                //indexURL: "https://drive.google.com/file/d/1GsgdeAnxJuwqG0RA58MV5biJW1SdqbWP/view",
                fastaURL: "https://content.cruk.cam.ac.uk/jmlab/RabbitGastrulation2020/Oryctolagus_cuniculus.OryCun2.0.dna.toplevel.fa",
                indexURL: "https://content.cruk.cam.ac.uk/jmlab/RabbitGastrulation2020/Oryctolagus_cuniculus.OryCun2.0.dna.toplevel.fa.fai",
                indexed:true
            },
        locus:"17:72,718,677-72,725,889",
        tracks: [
            {
                "name": "SIGAC11",
                "url": "https://content.cruk.cam.ac.uk/jmlab/RabbitGastrulation2020/SIGAC11_coverage.tdf",
            },
            {
                "type": "annotation",
                "name": "UpdatedAnnotation",
                "url": "https://content.cruk.cam.ac.uk/jmlab/RabbitGastrulation2020/extension_plus_alignments.gtf.gz",
                "indexURL": "https://content.cruk.cam.ac.uk/jmlab/RabbitGastrulation2020/extension_plus_alignments.gtf.gz.tbi",
                "displayMode": "SQUISHED" 
            }

        ]
    };

var igvDiv = document.getElementById("igvDiv");

igv.createBrowser(igvDiv, options)
    .then(function (browser) {
        console.log("Created IGV browser");
    })
