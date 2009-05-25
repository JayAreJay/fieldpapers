<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="en">
<head>
	<meta http-equiv="content-type" content="text/html; charset=utf-8" />
	<title>Scanned Walking Papers</title>
	<link rel="stylesheet" href="{$base_dir}/style.css" type="text/css" />
	<link rel="stylesheet" href="{$base_dir}/scan.css" type="text/css" />
	{if $scan && $scan.last_step != 6 && $scan.last_step != $constants.STEP_FATAL_ERROR}
        <meta http-equiv="refresh" content="5" />
    {else}
        <script type="text/javascript" src="http://www.openstreetmap.org/javascripts/swfobject.js"></script>
        <script type="text/javascript" src="{$base_dir}/modestmaps.js"></script>
        <script type="text/javascript" src="{$base_dir}/scan.js"></script>
    {/if}
</head>
<body>

    <h1><a href="{$base_dir}/"><img src="{$base_dir}/icon.png" border="0" align="bottom" alt="" /> Walking Papers</a></h1>
    
    {if $scan}
        {if $scan.last_step == 6}
            <p>
                <a href="{$base_dir}/print.php?id={$scan.print_id|escape}">Download more PDFs of this area</a>.
            </p>
        
            {*
            <p>
                <a href="javascript:map.zoomIn()">zoom in</a> | <a href="javascript:map.zoomOut()">zoom out</a>
                <br>
                <a href="javascript:map.panLeft()">pan left</a> | <a href="javascript:map.panRight()">pan right</a> | <a href="javascript:map.panDown()">pan down</a> | <a href="javascript:map.panUp()">pan up</a>
            </p>

            <p id="map"></p>
            
            <script type="text/javascript">
            // <![CDATA[
        
                // "import" the namespace
                var mm = com.modestmaps;
            
                var provider = new mm.MapProvider(makeProviderFunction('{$constants.S3_BUCKET_ID|escape}', '{$scan.id|escape}'));
                var map_el = document.getElementById('map');
                var map = new mm.Map(map_el, provider, new mm.Point(408, 528));
                
                var northwest = provider.coordinateLocation(new mm.Coordinate({$scan.min_row}, {$scan.min_column}, {$scan.min_zoom}));
                var southeast = provider.coordinateLocation(new mm.Coordinate({$scan.max_row}, {$scan.max_column}, {$scan.max_zoom}));
                
                map_el.style.backgroundColor = '#ccc';
                map.setExtent([northwest, southeast]);
                
                map.draw();
        
            // ]]>
            </script>
            *}

            <div id="editor">
                <form onsubmit="return editInPotlatch(this.elements);">
                    <p>
                        You&rsquo;ll need to first log in to OpenStreetMap to do any editing,
                        log in below or
                        <a href="http://www.openstreetmap.org/user/new">create a new account</a>.
                        <strong><i>Walking Papers</i> will not see or keep your password</strong>,
                        it is passed directly to OpenStreetMap.
                    </p>
                    <p>
                        <label for="username">Email Address or Username</label>
                        <br />
                        <input id="username-textfield" name="username" type="text" size="30" />
                    </p>
                    <script type="text/javascript">
                    // <![CDATA[{literal}
                    
                        if(readCookie('openstreetmap-username') && document.getElementById('username-textfield'))
                            document.getElementById('username-textfield').value = readCookie('openstreetmap-username');
                    
                    // {/literal}]]>
                    </script>
                    <p>
                        <label for="password">Password</label>
                        <br />
                        <input name="password" type="password" size="30" />
                        <br />
                        (<a href="http://www.openstreetmap.org/user/forgot-password">Lost your password?</a>)
                    </p>
                    <p>
                        <input id="edit-button" name="action" type="submit" value="Edit" />
                        <input name="minrow" type="hidden" value="{$scan.min_row|escape}" />
                        <input name="mincolumn" type="hidden" value="{$scan.min_column|escape}" />
                        <input name="minzoom" type="hidden" value="{$scan.min_zoom|escape}" />
                        <input name="maxrow" type="hidden" value="{$scan.max_row|escape}" />
                        <input name="maxcolumn" type="hidden" value="{$scan.max_column|escape}" />
                        <input name="maxzoom" type="hidden" value="{$scan.max_zoom|escape}" />

                        <input name="bucket" type="hidden" value="{$constants.S3_BUCKET_ID|escape}" />
                        <input name="scan" type="hidden" value="{$scan.id|escape}" />
                    </p>
                </form>
            </div>
        {else}
            {if $step.number == $constants.STEP_FATAL_ERROR}
                <p>Giving up, {$step.number|step_description|lower|escape}.</p>
                
            {else}
                <p>Processing your scanned image.</p>
    
                <ol class="steps">
                    <li class="{if $step.number == 0}on{/if}">{0|step_description|escape}</li>
                    <li class="{if $step.number == 1}on{/if}">{1|step_description|escape}</li>
                    <li class="{if $step.number == 2}on{/if}">{2|step_description|escape}</li>
                    <li class="{if $step.number == 3}on{/if}">{3|step_description|escape}</li>
                    <li class="{if $step.number == 4}on{/if}">{4|step_description|escape}</li>
                    <li class="{if $step.number == 5}on{/if}">{5|step_description|escape}</li>
                    <li class="{if $step.number == 6}on{/if}">{6|step_description|escape}</li>
                </ol>
                
                {if $step.number >= 7}
                    <p>Please stand by, currently {$step.number|step_description|lower|escape}.</p>
                {/if}
            {/if}
        {/if}
    {/if}
    
    <p id="footer">
        &copy;2009 <a href="http://mike.teczno.com">Michal Migurski</a>, <a href="http://stamen.com">Stamen Design</a>
    </p>
    
</body>
</html>
