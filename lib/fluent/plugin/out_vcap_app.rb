require 'json'
module Fluent
  module VCAP
    class AppOutput < CopyOutput
      Fluent::Plugin.register_output("vcap_app_log", self)

      def initialize
        @vcap_application = JSON.parse(ENV['VCAP_APPLICATION'].dup)
        super
      end

      def emit(tag, es, chain)
        es.each { |time, record|
          record[:vcap] = {
            :app      => @vcap_application["application_name"],
            :version  => @vcap_application["application_version"],
            :id       => @vcap_application["instance_id"],
            :index    => @vcap_application["instance_index"],
            :uris     => @vcap_application["uris"]
          }
        }
        super(tag, es, chain)
      end
    end
  end
end
