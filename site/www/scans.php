<?php

    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'../lib');
    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'/usr/home/migurski/pear/lib');
    require_once 'init.php';
    require_once 'data.php';
    
    list($user_id) = read_userdata($_COOKIE['visitor']);

    /**** ... ****/
    
    $dbh =& get_db_connection();
    
    if($user_id)
        $user = get_user($dbh, $user_id);

    if($user)
        setcookie('visitor', write_userdata($user['id']), time() + 86400 * 31);
    
    $scans = get_scans($dbh, 50, false);

    $sm = get_smarty_instance();
    $sm->assign('scans', $scans);
    
    header("Content-Type: text/html; charset=UTF-8");
    print $sm->fetch("scans.html.tpl");

?>
