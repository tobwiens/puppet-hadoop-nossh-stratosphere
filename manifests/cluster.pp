# /etc/puppet/modules/hadoop/manifests/master.pp

class hadoop::cluster {
	# do nothing, magic lookup helper
}

class hadoop::cluster::master {

    require hadoop::params
    require hadoop

	
    exec { "Format namenode":
        command => "./hdfs namenode -format",
        user => "${hadoop::params::hadoop_user}",
        cwd => "${hadoop::params::hadoop_base}/hadoop-${hadoop::params::version}/bin",
        creates => "${hadoop::params::hadoop_tmp_path}/dfs/name/current/VERSION",
        alias => "format-hdfs",
        path    => ["/bin", "/usr/bin", "${hadoop::params::hadoop_base}/hadoop-${hadoop::params::version}/bin"],
        before => [Exec["start-namenode"], Exec["start-resourcemanager"],  Exec["start-historyserver"]],
        require => File["hadoop-master"],
    }

    exec { "Start namenode":
        command => "./hadoop-daemon.sh start namenode",
        cwd => "${hadoop::params::hadoop_base}/hadoop-${hadoop::params::version}/sbin",
        user => "${hadoop::params::hadoop_user}",
        alias => "start-namenode",
        path    => ["/bin", "/usr/bin", "${hadoop::params::hadoop_base}/hadoop-${hadoop::params::version}/sbin"],
        unless => "${java::params::java_base}/jdk${java::params::java_version}/bin/jps | grep  NameNode 2>/dev/null",
        before => [Exec["start-resourcemanager"],  Exec["start-historyserver"]],
    }

    ### Don't start it over SSH ####
    #exec { "Start datanodes":
    #    command => "./hadoop-daemons.sh start datanode",
    #    cwd => #"${hadoop::params::hadoop_base}/hadoop-${hadoop::params::version}/sbin",
    #   user => "${hadoop::params::hadoop_user}",
    #   alias => "start-datanodes",
    #   path    => ["/bin", "/usr/bin", #"${hadoop::params::hadoop_base}/hadoop-${hadoop::params::version}/sbin"],
    #    before => [Exec["start-resourcemanager"], #Exec["start-historyserver"]],
    # }
    exec { "Start resourcemanager":
        command => "./yarn-daemon.sh start resourcemanager",
        cwd => "${hadoop::params::hadoop_base}/hadoop-${hadoop::params::version}/sbin",
        user => "${hadoop::params::hadoop_user}",
        alias => "start-resourcemanager",
        path    => ["/bin", "/usr/bin", "${hadoop::params::hadoop_base}/hadoop-${hadoop::params::version}/sbin"],
        unless => "${java::params::java_base}/jdk${java::params::java_version}/bin/jps | grep ResourceManager 2>/dev/null",
        before => [ Exec["start-historyserver"]],
    }
### Don't do it via SSH ###
    #exec { "Start nodemanagers":
    #    command => "./yarn-daemons.sh start nodemanager",
    #    cwd => #"${hadoop::params::hadoop_base}/hadoop-${hadoop::params::version}/sbin",
    #    user => "${hadoop::params::hadoop_user}",
    #    alias => "start-nodemanager",
    #    path    => ["/bin", "/usr/bin", #"${hadoop::params::hadoop_base}/hadoop-${hadoop::params::version}/sbin"],
    #    before => Exec["start-historyserver"],
    #}

    exec { "Start historyserver":
        command => "./mr-jobhistory-daemon.sh start historyserver",
        cwd => "${hadoop::params::hadoop_base}/hadoop-${hadoop::params::version}/sbin",
        user => "${hadoop::params::hadoop_user}",
        alias => "start-historyserver",
        path    => ["/bin", "/usr/bin", "${hadoop::params::hadoop_base}/hadoop-${hadoop::params::version}/sbin"],
		unless => "${java::params::java_base}/jdk${java::params::java_version}/bin/jps | grep JobHistoryServer 2>/dev/null",
    }
 
}

class hadoop::cluster::slave {

    require hadoop::params
    require hadoop

exec { "Start slave nodemanager":
        command => "./yarn-daemon.sh start nodemanager",
        cwd => "${hadoop::params::hadoop_base}/hadoop-${hadoop::params::version}/sbin",
        user => "${hadoop::params::hadoop_user}",
        alias => "start-slave-nodemanager",
        path    => ["/bin", "/usr/bin", "${hadoop::params::hadoop_base}/hadoop-${hadoop::params::version}/sbin"],
unless => "/opt/java/jdk1.7.0_51/bin/jps | grep NodeManager 2>/dev/null",
    }

	exec { "Start slave datanode":
        command => "./hadoop-daemon.sh start datanode",
        cwd => "${hadoop::params::hadoop_base}/hadoop-${hadoop::params::version}/sbin",
        user => "${hadoop::params::hadoop_user}",
        alias => "start-slave-datanode",
        path    => ["/bin", "/usr/bin", "${hadoop::params::hadoop_base}/hadoop-${hadoop::params::version}/sbin"],
		unless => "${java::params::java_base}/jdk${java::params::java_version}/bin/jps | grep DataNode 2>/dev/null",
		refresh => "./hadoop-daemon.sh stop datanode;./hadoop-daemon.sh start datanode",
		subscribe => File["${hadoop::params::hadoop_base}/hadoop-${hadoop::params::version}/conf/core-site.xml"],
		logoutput => true,
    }

}
