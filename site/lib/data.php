<?php

    require_once 'JSON.php';
    require_once 'PEAR.php';
    require_once 'DB.php';
    require_once 'output.php';
    require_once 'Crypt/HMAC.php';
    
    function &get_db_connection()
    {
        return DB::connect(DB_DSN);
    }
    
    if(!function_exists('json_encode'))
    {
        function json_encode($value)
        {
            $json = new Services_JSON(SERVICES_JSON_LOOSE_TYPE);
            return $json->encode($value);
        }
    }
    
    function generate_id()
    {
        $chars = 'qwrtypsdfghjklzxcvbnm0123456789';
        $id = '';
        
        while(strlen($id) < 8)
            $id .= substr($chars, rand(0, strlen($chars) - 1), 1);

        return $id;
    }
    
    function create_scan(&$dbh)
    {
        while(true)
        {
            $scan_id = generate_id();
            
            $q = sprintf('INSERT INTO scans SET id=%s, last_step=0',
                         $dbh->quoteSmart($scan_id));

            $res = $dbh->query($q);
            
            if(PEAR::isError($res)) 
            {
                if($res->getCode() == DB_ERROR_ALREADY_EXISTS)
                    continue;
    
                die_with_code(500, "{$res->message}\n{$q}\n");
            }
            
            $q = sprintf('INSERT INTO steps SET scan_id=%s, number=0, description=%s',
                         $dbh->quoteSmart($scan_id),
                         $dbh->quoteSmart('Getting ready to upload'));

            $res = $dbh->query($q);
            
            if(PEAR::isError($res)) 
                die_with_code(500, "{$res->message}\n{$q}\n");
            
            return get_scan($dbh, $scan_id);
        }
    }
    
    function get_scan(&$dbh, $scan_id)
    {
        $q = sprintf('SELECT *
                      FROM scans
                      WHERE id = %s',
                     $dbh->quoteSmart($scan_id));
    
        $res = $dbh->query($q);
        
        if(PEAR::isError($res)) 
            die_with_code(500, "{$res->message}\n{$q}\n");

        return $res->fetchRow(DB_FETCHMODE_ASSOC);
    }

   /**
    * See: http://coreforge.org/snippet/detail.php?type=snippet&id=3
    */
    function uuid()
    {
        // Use the server name (if present) in the generation of UUID
        $base = strtoupper(
            md5(
                uniqid(
                    isset($_SERVER['HTTP_HOST']) 
                    ? $_SERVER['HTTP_HOST'] : '' . 
                    rand(), 
                true)
            )
        );

        // Mark as "random" UUID, set version
        $byte = hexdec(substr($base,12,2));
        $byte = $byte & hexdec('0f');
        $byte = $byte | hexdec('40');
        $base = substr_replace($base, strtoupper(dechex($byte)), 12, 2);

        // Set the variant
        $byte = hexdec(substr($base,16,2));
        $byte = $byte & hexdec('3f');
        $byte = $byte | hexdec('80');
        $base = substr_replace($base, strtoupper(dechex($byte)), 16, 2);

        // Format
        return join('-', array(substr($base, 0, 8),
                               substr($base, 8, 4),
                               substr($base, 12, 4),
                               substr($base, 16, 4),
                               substr($base, 20, 12)));
    }
    
   /**
    * Sign a string with the AWS secret key, return it raw.
    */
    function s3_sign_auth_string($string)
    {
        $crypt_hmac = new Crypt_HMAC(AWS_SECRET_KEY, 'sha1');
        $hashed = $crypt_hmac->hash($string);

        $signature = '';

        for($i = 0; $i < strlen($hashed); $i += 2)
            $signature .= chr(hexdec(substr($hashed, $i, 2)));

        return $signature;
    }
    
   /**
    * @param    int     $expires    Expiration timestamp
    * @param    string  $format     Response format for redirect URL
    * @return   array   Associative array with:
    *                   - "access": AWS access key
    *                   - "policy": base64-encoded policy
    *                   - "signature": base64-encoded, signed policy
    *                   - "acl": allowed ACL
    *                   - "key": upload key
    *                   - "bucket": bucket ID
    *                   - "redirect": URL
    */
    function s3_get_post_details($scan_id, $expires, $format=null)
    {
        $acl = 'public-read';
        $key = "{$scan_id}/\${filename}";
        $redirect = 'http://'.get_domain_name().get_base_href().'?scan='.rawurlencode($scan_id).(is_null($format) ? '' : "&format={$format}");
        $access = AWS_ACCESS_KEY;
        $bucket = S3_BUCKET_ID;
        
        $policy = array('expiration' => gmdate('Y-m-d', $expires).'T'.gmdate('H:i:s', $expires).'Z',
                        'conditions' => array(
                            array('bucket' => $bucket),
                            array('acl' => $acl),
                            array('starts-with', '$key', "{$scan_id}/"),
                            array('redirect' => $redirect)));

        $policy = base64_encode(json_encode($policy));
        $signature = base64_encode(s3_sign_auth_string($policy));

        return compact('access', 'policy', 'signature', 'acl', 'key', 'redirect', 'bucket');
    }

?>