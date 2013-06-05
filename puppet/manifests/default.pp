Exec {
  path => ['/usr/sbin', '/usr/bin', '/sbin', '/bin']
}

# --- Preinstall Stage ---------------------------------------------------------

stage { 'preinstall':
  before => Stage['main']
}

class apt_get_update {
  exec { 'apt-get -y update':
    command => "sudo apt-get -y update"
  }
}
class { 'apt_get_update':
  stage => preinstall
}

class python {
  package {                    
    "build-essential": ensure => latest;        
    "python": ensure => latest;            
    "python-dev": ensure => latest;        
    "python-setuptools": ensure => "latest";          
  }   
  exec { "easy_install pip":                
    path => "/usr/local/bin:/usr/bin:/bin",          
    refreshonly => true,            
    require => Package["python-setuptools"],          
    subscribe => Package["python-setuptools"],        
  }            

  package { 'virtualenv':
    ensure => installed,
    provider => pip
  }
  package { 'virtualenvwrapper':
    ensure => installed,
    provider => pip
  }
  file { '/home/vagrant/.virtualenvs':
    ensure => directory,
    owner => vagrant,
    group => vagrant
  }            
  file { '/home/vagrant/media/':
    ensure => directory,
    owner => vagrant,
    group => vagrant
  }            

}                    
class { "python": stage => "preinstall" }

# --- SQLite -------------------------------------------------------------------

package { ['sqlite3', 'libsqlite3-dev']:
  ensure => installed;
}

# --- PostgreSQL ---------------------------------------------------------------

class install_postgres {
  class { 'postgresql': }

  class { 'postgresql::server': }

  pg_database { 'django':
    ensure   => present,
    encoding => 'UTF8',
    require  => Class['postgresql::server']
  }

  pg_user { 'django':
    ensure  => present,
    password => 'myawesomedjangopassword',
    require => Class['postgresql::server'] 
  }

  pg_user { 'vagrant':
    ensure    => present,
    superuser => true,
    require   => Class['postgresql::server']
  }

  package { 'libpq-dev':
    ensure => installed
  }

  package { 'python-psycopg2':
    ensure => installed
  }
}
class { 'install_postgres': }

# --- Memcached ----------------------------------------------------------------

class install_memcached {
  package { 'memcached':
    ensure => installed
  }
}
class { 'install_memcached': }

# --- Packages -----------------------------------------------------------------

package { 'curl':
  ensure => installed
}

package { 'git-core':
  ensure => installed
}
