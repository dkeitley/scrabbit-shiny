

var options =
    {
        reference:
            {
                fastaURL: "https://content.cruk.cam.ac.uk/jmlab/RabbitGastrulation2022/Oryctolagus_cuniculus.OryCun2.0.dna.toplevel.fa",
                indexURL: "https://content.cruk.cam.ac.uk/jmlab/RabbitGastrulation2022/Oryctolagus_cuniculus.OryCun2.0.dna.toplevel.fa.fai",
                indexed:true
            },
        //locus:"17:72,718,677-72,725,889",
        locus:"4:14,204,089-14,206,762",
        tracks: [
            {
                "name": "SIGAC11",
                "url": "https://content.cruk.cam.ac.uk/jmlab/RabbitGastrulation2022/SIGAC11_coverage.tdf",
            },
            {
                "type": "annotation",
                "name": "UpdatedAnnotation",
                "url": "https://content.cruk.cam.ac.uk/jmlab/RabbitGastrulation2022/extension_plus_alignments.gtf.gz",
                "indexURL": "https://content.cruk.cam.ac.uk/jmlab/RabbitGastrulation2022/extension_plus_alignments.gtf.gz.tbi",
                "displayMode": "SQUISHED" 
            }

        ]
    };

var igvDiv = document.getElementById("igvDiv");

igv.createBrowser(igvDiv, options)
    .then(function (browser) {
        console.log("Created IGV browser");
    })
