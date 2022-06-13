#!/usr/bin/env lua
--- Common tools for screen tests.

IMAGE_OUTPUT_DIR = "test/results/images/"

HTML_HEADER = [[
    <html>
    <head>
        <style>
            ul.gallery {
                list-style-type: none;
                padding: 0;
                margin: 5px;
                display: grid;
                grid-gap: 20px 5px;
                grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            }
            
            ul.gallery svg {
                width: 100%;
                height: 100%;
            }
        </style>
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Fira+Mono&display=swap" rel="stylesheet">
        <link href="https://fonts.googleapis.com/css2?family=Montserrat&display=swap" rel="stylesheet">
        <link href="https://fonts.googleapis.com/css2?family=Play&display=swap" rel="stylesheet">
        <link href="https://fonts.googleapis.com/css2?family=Roboto+Condensed&display=swap" rel="stylesheet">
        <link href="https://fonts.googleapis.com/css2?family=Roboto+Mono&display=swap" rel="stylesheet">
    </head>
    
    <body>
        <ul class="gallery">
]]
SVG_WRAPPER_TEMPLATE = [[<li><p>%s<br>%s</p></li>]]
HTML_FOOTER = [[
    </ul>
</body>
</html>
]]
