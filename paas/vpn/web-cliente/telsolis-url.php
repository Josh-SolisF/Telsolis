// Telsolis: WordPress responde en la LAN (web.telsolis.test) y en internet (telsolis.tech, vía el proxy de AWS).
// Va al inicio de /var/www/wordpress/wp-config.php (reemplaza el bloque de la Fase 2).
$telsolis_hosts = array( 'web.telsolis.test', 'telsolis.tech', 'www.telsolis.tech' );
$telsolis_host  = ( isset( $_SERVER['HTTP_HOST'] ) && in_array( $_SERVER['HTTP_HOST'], $telsolis_hosts, true ) )
    ? $_SERVER['HTTP_HOST'] : 'web.telsolis.test';
// El proxy de AWS (10.8.2.1, por el túnel) avisa si la visita original llegó por HTTPS.
if ( isset( $_SERVER['REMOTE_ADDR'], $_SERVER['HTTP_X_FORWARDED_PROTO'] )
     && $_SERVER['REMOTE_ADDR'] === '10.8.2.1' && $_SERVER['HTTP_X_FORWARDED_PROTO'] === 'https' ) {
    $_SERVER['HTTPS'] = 'on';
}
$telsolis_esquema = ( ! empty( $_SERVER['HTTPS'] ) && $_SERVER['HTTPS'] !== 'off' ) ? 'https' : 'http';
define( 'WP_HOME',    $telsolis_esquema . '://' . $telsolis_host );
define( 'WP_SITEURL', $telsolis_esquema . '://' . $telsolis_host );
