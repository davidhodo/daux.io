<?php
  $data = json_decode(file_get_contents('php://input'), true);

  function sh($cmd) {
    echo '> '.$cmd."\n";
    $result = `$cmd`;
    echo $result;
    echo "\n";
    return $result;
  }

  $name = $data["repository"]["name"];
  $homepage = $data["repository"]["homepage"];

  $dest = "/var/www/html/docs";
  $archiveSrc = "$homepage/-/archive/master/$name-master.tar.gz";
  $tmp = "$dest/master.tar.gz";


  $check = sh("test -e $dest/$name.repo.test && echo ok || (test -e $dest/*.repo.test && echo no) || echo ok");
  echo $check;

  if (strcmp($check, "ok")) {
    sh("rm -fr $dest && mkdir $dest");
    sh("ls -al $dest");
    sh("curl $archiveSrc --output $tmp");
    sh("ls -al $dest");
    sh("tar xvf $tmp -C $dest && cp -r $dest/$name-master/* $dest/ && rm -rf $dest/$name-master $tmp");
    sh("ls -al $dest");
    sh("touch $dest/$name.repo.test");
  } else {
    echo "Invalud repository $name";
  }
?>