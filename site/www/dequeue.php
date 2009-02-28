<?php

    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'../lib');
    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'/usr/home/migurski/pear/lib');
    require_once 'init.php';
    require_once 'data.php';
    
    $timeout = is_numeric($_POST['timeout']) ? $_POST['timeout'] : null;
    $message_id = is_numeric($_POST['id']) ? $_POST['id'] : null;
    
    /**** ... ****/
    
    $dbh =& get_db_connection();
    
    if($timeout)
    {
        if($message_id && $timeout) {
            $dbh->query('START TRANSACTION');
            postpone_message($dbh, $message_id, $timeout);
            $dbh->query('COMMIT');
        
            echo "OK\n";

        } else {
            $dbh->query('START TRANSACTION');
            $message = get_message($dbh, $timeout);
            $dbh->query('COMMIT');
            
            header('Content-Type: text/plain');
            
            if($message) {
                printf("%d %s\n", $message['id'], $message['content']);
            
            } else {
                echo "0\n";
            }
        }
    }

?>
