# frozen_string_literal: true

module Facter
  class OptionStore
    # default options
    @debug = false
    @verbose = false
    # TODO: constant is not yet available when running puppet facts
    @log_level = :warn
    @show_legacy = true
    @block = true
    @custom_dir = []
    @config_file_custom_dir = []
    @custom_facts = true
    @external_dir = []
    @config_file_external_dir = []
    @default_external_dir = []
    @external_facts = true
    @ruby = true
    @cache = true
    @blocked_facts = []
    @user_query = []
    @block_list = {}
    @fact_groups = {}
    @color = true
    @timing = false
    @allow_external_loggers = true

    class << self
      attr_reader :debug, :verbose, :log_level, :show_legacy,
                  :custom_facts, :blocked_facts, :ruby, :external_facts

      attr_accessor :config, :user_query, :strict, :json, :haml,
                    :cache, :yaml, :puppet, :ttls, :block, :cli, :config_file_custom_dir,
                    :config_file_external_dir, :default_external_dir, :fact_groups,
                    :block_list, :color, :trace, :timing, :allow_external_loggers

      attr_writer :external_dir

      def all
        options = {}
        instance_variables.each do |iv|
          variable_name = iv.to_s.delete('@')
          options[variable_name.to_sym] = OptionStore.send(variable_name.to_sym)
        end
        options
      end

      def no_ruby=(bool)
        if bool
          @ruby = false
          @custom_facts = false
          @blocked_facts << 'ruby'
        else
          @ruby = true
        end
      end

      def no_block=(bool)
        @block = !bool
      end

      def no_cache=(bool)
        @cache = !bool
      end

      def no_color=(bool)
        @color = !bool
      end

      def external_dir
        return fallback_external_dir if @external_dir.empty? && @external_facts

        @external_dir
      end

      def blocked_facts=(*facts)
        @blocked_facts += [*facts]

        @blocked_facts.flatten!
      end

      def custom_dir
        return @config_file_custom_dir unless @custom_dir.any?

        @custom_dir
      end

      def custom_dir=(*dirs)
        @ruby = true

        @custom_dir = [*dirs]
        @custom_dir.flatten!
      end

      def debug=(bool)
        if bool == true
          self.log_level = :debug
        else
          @debug = false
          self.log_level = Facter::DEFAULT_LOG_LEVEL
        end
      end

      def verbose=(bool)
        if bool == true
          @verbose = true
          self.log_level = :info
        else
          @verbose = false
          self.log_level = Facter::DEFAULT_LOG_LEVEL
        end
      end

      def no_custom_facts=(bool)
        if bool == false
          @custom_facts = true
          @ruby = true
        else
          @custom_facts = false
        end
      end

      def no_external_facts=(bool)
        @external_facts = !bool
      end

      def log_level=(level)
        level = level.to_sym
        case level
        when :trace
          @log_level = :debug
        when :debug
          @log_level = :debug
          @debug = true
        else
          @log_level = level
        end

        Facter::Log.level = @log_level
      end

      def show_legacy=(bool)
        if bool == true
          @show_legacy = bool
          @ruby = true
        else
          @show_legacy = false
        end
      end

      def set(key, value)
        send("#{key}=".to_sym, value)
      end

      def reset
        @debug = false
        @verbose = false
        # TODO: constant is not yet available when running puppet facts
        @log_level = :warn
        @show_legacy = true
        @block = true
        @ruby = true
        @user_query = []
        @cli = nil
        @cache = true
        @trace = false
        reset_config
      end

      def reset_config
        @custom_dir = []
        @custom_facts = true
        @external_dir = []
        @default_external_dir = []
        @config_file_external_dir = []
        @external_facts = true
        @blocked_facts = []
        @fact_groups = {}
        @block_list = {}
        @timing = false
        @allow_external_loggers = true
      end

      def fallback_external_dir
        return @config_file_external_dir if @config_file_external_dir.any?

        @default_external_dir
      end
    end
  end
end
