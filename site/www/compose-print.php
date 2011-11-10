<?php

    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.dirname(__FILE__).'/../lib');
    require_once 'init.php';
    require_once 'data.php';
    require_once 'output.php';

    require_once 'ModestMaps/ModestMaps.php';

    $json = json_decode(file_get_contents('php://input'), true);
    
    if(!is_array($json))
    {
        die_with_code(400, 'Bad JSON input');
    }

    if($json['type'] != 'FeatureCollection' || !is_array($json['features']))
    {
        die_with_code(400, 'Bad GeoJSON input');
    }
    
    $p = $json['properties'];

    $paper_size = (is_array($p) && isset($p['paper_size'])) ? $p['paper_size'] : 'letter';
    $orientation = (is_array($p) && isset($p['orientation'])) ? $p['orientation'] : 'portrait';
    
    switch("{$paper_size}, {$orientation}")
    {
        case ('letter, portrait'):
            $paper_aspect = PAPER_PORTRAIT_LTR_WIDTH / PAPER_PORTRAIT_LTR_HEIGHT;
            break;
        
        default:
            die_with_code(500, "I don't know how to do this yet, sorry.");
    }
    
    foreach($json['features'] as $feature)
    {
        //
        // Do some basic idiot-checks
        //
        
        if(!is_array($feature))
        {
            die_with_code(400, 'Bad JSON input');
        }
    
        if($feature['type'] != 'Feature' || !is_array($feature['geometry']))
        {
            die_with_code(400, 'Bad GeoJSON input');
        }
        
        $p = $feature['properties'];

        $provider = (is_array($p) && isset($p['provider']))
            ? new MMaps_Templated_Spherical_Mercator_Provider($p['provider'])
            : new MMaps_OpenStreetMap_Provider();
        
        $explicit_zoom = is_array($p) && is_numeric($p['zoom']);
        $zoom = $explicit_zoom ? intval($p['zoom']) : 16;
        
        $extent = null;
        
        switch($feature['geometry']['type'])
        {
            case 'Point':
                $coords = $feature['geometry']['coordinates'];
                $center = new MMaps_Location($coords[1], $coords[0]);
                $dimensions = new MMaps_Point(1200, 1200); // aims for between 150-200dpi
                
                if($paper_aspect >= 1) {
                    // paper is wide
                    $dimensions->x = floor($dimensions->x * $paper_aspect);
                
                } else {
                    // paper is tall
                    $dimensions->y = floor($dimensions->y / $paper_aspect);
                }

                // make a temporary map with the correct center and aspect ratio
                $_mmap = MMaps_mapByCenterZoom($provider, $center, $zoom, $dimensions);

                // make a new extent with the corners of the map above.
                $extent = array($_mmap->pointLocation(new MMaps_Point(0, 0)),
                                $_mmap->pointLocation($mmap->dimensions));
                
                break;
            
            case 'Polygon':
                $coords = $feature['geometry']['coordinates'][0];
                
                list($minlon, $minlat) = array($coords[0][0], $coords[0][1]);
                list($maxlon, $maxlat) = array($coords[0][0], $coords[0][1]);
                
                foreach($coords as $coord)
                {
                    $minlon = min($minlon, $coord[0]);
                    $minlat = min($minlat, $coord[1]);
                    $maxlon = max($maxlon, $coord[0]);
                    $maxlat = max($maxlat, $coord[1]);
                }
                
                $extent = array(new MMaps_Location($minlat, $minlon),
                                new MMaps_Location($maxlat, $maxlon));

                break;
            
            default:
                die_with_code(500, "I don't know how to do this yet, sorry.");
        }
        
        switch(true)
        {
            case (is_array($extent) && $explicit_zoom):
                $mmap = MMaps_mapByExtentZoom($provider, $extent[0], $extent[1], $zoom);
                break;
            
            default:
                die_with_code(500, "I don't know how to do this yet, sorry.");
        }
        
        print_r($mmap);
    }

?>