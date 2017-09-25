package MasterWebInterface;
our(%S, $ROOT);
our %S = (
  root => $ROOT,
  
  url         => 'http://simple.333networks.com',
  admin_email => 'info@333networks.com',
  
  site_title  => '333networks Masterserver WebInterface',
  site_name   => '333networks',
  
  style       => 'classic',
  img_path    => "$ROOT/s/img",

  map_url     => "/map",
  map_dir     => "$ROOT/s/map",
);

1;
