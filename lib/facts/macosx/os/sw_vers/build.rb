# frozen_string_literal: true

module Facter
  module Macosx
    class OsMacosxBuild
      FACT_NAME = 'os.macosx.build'
      @aliases = []

      def initialize(*args)
        @args = args
        puts 'Dispatching to resolve: ' + args.inspect
      end

      def call_the_resolver!
        fact_value = SwVersResolver.resolve('BuildVersion')
        Fact.new(FACT_NAME, fact_value)
      end
    end
  end
end