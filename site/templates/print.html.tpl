<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="en">
<head>
	<meta http-equiv="content-type" content="text/html; charset=utf-8" />
	<title>Print Walking Papers</title>
	<link rel="stylesheet" href="{$base_dir}/style.css" type="text/css" />
    <script type="text/javascript" src="{$base_dir}/modestmaps.js"></script>
    <style type="text/css" title="text/css">
    /* <![CDATA[{literal} */
    
        form#age-warning
        {
            border: 1px solid black;
            padding: .2em 1em;
        }
    
    /* {/literal}]]> */
    </style>
</head>
<body>

    <span id="print-info" style="display: none;">
        <span class="print">{$print.id|escape}</span>
        <span class="north">{$print.north|escape}</span>
        <span class="south">{$print.south|escape}</span>
        <span class="east">{$print.east|escape}</span>
        <span class="west">{$print.west|escape}</span>
    </span>

    <h1><a href="{$base_dir}/"><img src="{$base_dir}/icon.png" border="0" align="bottom" alt="" /> Walking Papers</a></h1>
    
    <p>
        Print map of the area surrounding
        <a id="print-location" href="http://www.openstreetmap.org/?lat={$print.north/2+$print.south/2|escape}&amp;lon={$print.east/2+$print.west/2|escape}&amp;zoom=15&amp;layers=B000FTF">
            {$print.north/2+$print.south/2|nice_degree:"lat"|escape}, {$print.east/2+$print.west/2|nice_degree:"lon"|escape}</a>
        <br />
        Created {$print.age|nice_relativetime|escape}.
        <span class="date-created" style="display: none;">{$print.created|escape}</span>
    </p>
    
    <script type="text/javascript" language="javascript1.2">
    // <![CDATA[
    
        var flickr_key = '{$constants.FLICKR_KEY|escape}';
        var lat = {$print.north/2+$print.south/2|escape};
        var lon = {$print.east/2+$print.west/2|escape};
        
        // {literal}
        
        function onPlaces(res)
        {
            if(res['places'] && res['places']['place'] && res['places']['place'][0])
            {
                var place = res['places']['place'][0];
                var placeName = document.createTextNode(place['name']);
                var anchor = document.getElementById('print-location');
                anchor.parentNode.insertBefore(placeName, anchor.nextSibling);
                anchor.parentNode.insertBefore(document.createElement('br'), anchor.nextSibling);
            }
        }
        
        var script = document.createElement('script');
        script.type = 'text/javascript';
        script.src = 'http://api.flickr.com/services/rest/?method=flickr.places.findByLatLon&lat=' + escape(lat) + '&lon=' + escape(lon) + '&accuracy=12&format=json&jsoncallback=onPlaces&api_key=' + escape(flickr_key);
        document.body.appendChild(script);
        
        // {/literal}
    
    // ]]>
    </script>

    {if $print.age > 14*86400}
        <form id="age-warning" action="{$base_dir}/compose.php" method="post" name="bounds">
            <p>
                This print is more than two weeks old.
                You may want to make a fresh one that
                includes recent OpenStreetMap updates.
            </p>

            <p>
                <input name="north" type="hidden" value="{$print.north|escape}" />
                <input name="south" type="hidden" value="{$print.south|escape}" />
                <input name="east" type="hidden" value="{$print.east|escape}" />
                <input name="west" type="hidden" value="{$print.west|escape}" />
                <input name="zoom" type="hidden" value="{$print.zoom|escape}" />
        
                <input class="mac-button" type="submit" name="action" value="Print" />
            </p>
        </form>
    {/if}
    
    <p>
        <a href="{$print.pdf_url|escape}">Download a PDF</a> to get started mapping this area
        from street level. Add details like businesses, parks, schools, buildings, paths,
        post boxes, cash machines and other useful landmarks. When you’re finished,
        <a href="{$base_dir}/upload.php">post a scan</a> of your annotated map
        to trace your handwritten changes and notes directly into OpenStreetMap.
    </p>

    <div class="sheet">
        <img src="{$print.preview_url|escape}"/>
        <div class="dummy-qrcode"><img src="http://chart.apis.google.com/chart?chs=44x44&amp;cht=qr&amp;chld=L%7C0&amp;chl=example" alt="" border="0" /></div>
        <div class="dog-ear"> </div>
    </div>
    
    <p id="mini-map">
        <img class="doc" src="{$base_dir}/c-thru-doc.png" />
    </p>
    
    <script type="text/javascript">
    // <![CDATA[

        // "import" the namespace
        var mm = com.modestmaps;
        var cloudmade_key = '{$constants.CLOUDMADE_KEY|escape}';
    
        // {literal}
        var provider = new mm.MapProvider(function(c) { return 'http://tile.cloudmade.com/' + cloudmade_key + '/997/256/' + c.zoom +'/'+ c.column +'/'+ c.row + '.png'; });
        // {/literal}

        var center = new mm.Location(({$print.south|escape} + {$print.north|escape}) / 2, ({$print.east|escape} + {$print.west|escape}) / 2);
        var map = new mm.Map('mini-map', provider, new mm.Point(408, 252));
        
        map.setCenterZoom(center, 9);
        map.draw();
        
        // we're not actually looking for an interactive map
        mm.removeEvent(map.parent, 'dblclick', map.getDoubleClick());
        mm.removeEvent(map.parent, 'mousedown', map.getMouseDown());
        mm.removeEvent(map.parent, 'mousewheel', map.getMouseWheel());

    // ]]>
    </script>

    <p>
        If you don’t have a printer, send us a
        <b><a href="http://en.wikipedia.org/wiki/Self-addressed_stamped_envelope">self-addressed, stamped envelope</a>
        with the print ID, “{$print.id}”,</b> and we’ll mail you a printed copy of this map. If you don’t have a scanner,
        mail us your printed map and an <b>e-mail address</b> and we’ll scan it for
        you.
    </p>

    <blockquote>
        Walking Papers<br />
        c/o Stamen Design<br />
        3012 16th St. #200<br />
        San Francisco, CA 94103
    </blockquote>

    <p>
        Please allow a few weeks for scanning and printing.
    </p>

    <p id="footer">
        &#xA9;2009 <a href="http://mike.teczno.com">Michal Migurski</a>, <a href="http://stamen.com">Stamen Design</a>
    </p>
    
</body>
</html>
