<?php

    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'../lib');
    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'/usr/home/migurski/pear/lib');
    require_once 'init.php';
    require_once 'data.php';
    
    $print_id = $_GET['id'] ? $_GET['id'] : null;
    list($user_id) = read_userdata($_COOKIE['visitor']);

    /**** ... ****/
    
    $dbh =& get_db_connection();
    
    if($user_id)
        $user = get_user($dbh, $user_id);

    if($user)
        setcookie('visitor', write_userdata($user['id']), time() + 86400 * 31);
    
    $print = get_print($dbh, $print_id);
    
    $sm = get_smarty_instance();
    $sm->assign('print', $print);
    
    header("Content-Type: text/html; charset=UTF-8");
    print $sm->fetch("print.html.tpl");

?>
