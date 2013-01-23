# fluent-plugin-vcap

Cloud Foundry logging plugin.

## Usage

### DEA_NG + Warden

Install this plugin in your cloudfoundry box so that your application logs are collected and transfered to anywhere by fluentd.

#### Install

Install td-agent on your warden container:

    $ container_root_fs=path/to/container_root_fs
    $ chroot $container_root_fs env -i $(cat $container_root_fs/etc/environment) /bin/bash <<-EOS
    echo "deb http://packages.treasure-data.com/precise/ precise contrib" > /etc/apt/sources.list.d/treasure -data.list
    apt-get update
    apt-get install -y --force-yes td-agent
    EOS

Configure td-agent.conf as follows:

    <source>
      type tail
      path /app/logs/stdout.log
      pos_file /app/logs/td-agent/tail.pos
      format /(?<message>.*)/
      tag td.vcap.stdout
    </source>

    ## Multiple output
    ## match tag=td.*.* and output to Treasure Data AND file
    <match td.*.*>
       type vcap_app_log
       <store>
       type file
       path /app/logs/td-agent/td-%Y-%m-%d/%H.log
       </store>
    </match>

Setup 'before_start' hook script(*1) as follows:

      mkdir -p /app/logs/td-agent/buffer/td
      NAME=td-agent
      PIDFILE=/app/td-agent.pid
      LOGFILE=/app/logs/td-agent.log
      DAEMON=/usr/lib/fluent/ruby/bin/ruby # Introduce the server's location here
      DAEMON_ARGS="/usr/lib/fluent/ruby/bin/fluentd --daemon $PIDFILE --log $LOGFILE"

      export GEM_HOME=/usr/lib/fluent/ruby/lib/ruby/gems/1.9.1/
      export GEM_PATH=/usr/lib/fluent/ruby/lib/ruby/gems/1.9.1/
      export FLUENT_CONF=/etc/td-agent/td-agent.conf
      export FLUENT_PLUGIN=/etc/td-agent/plugin
      export FLUENT_SOCKET=/app/td-agent.sock
      $DAEMON $DAEMON_ARGS

(*1) hook script is not merged into cloudfoundry itself. You can pick up the patch from https://github.com/yssk22/dea_ng/commit/7673ddb32b5848ac8b8fd91f8e08b47d4ec0ed30

fluentd will launched in your warden container, collect stdout.log and store it on /app/logs/td-agent/td-%Y-%m-%d/%H.log (in your container). You can modify the target log storage by configuring 'vcap_app_log' output, which is same matter as 'out_copy' plugin.

### Router_V2

TBD