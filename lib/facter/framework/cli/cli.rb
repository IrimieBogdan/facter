#!/usr/bin/env ruby
# frozen_string_literal: true

require 'thor'

module Facter
  class Cli < Thor
    class_option :color,
                 type: :boolean,
                 desc: 'Enable color output.'

    class_option :config,
                 aliases: '-c',
                 type: :string,
                 desc: 'The location of the config file.'

    class_option :custom_dir,
                 type: :string,
                 repeatable: true,
                 desc: 'A directory to use for custom facts.'

    class_option :debug,
                 aliases: '-d',
                 type: :boolean,
                 desc: 'Enable debug output.'

    class_option :external_dir,
                 type: :string,
                 repeatable: true,
                 desc: 'A directory to use for external facts.'

    class_option :help,
                 hide: true,
                 aliases: '-h',
                 type: :boolean,
                 desc: 'Print this help message.'

    class_option :man,
                 hide: true,
                 type: :boolean,
                 desc: 'Display manual.'

    class_option :hocon,
                 type: :boolean,
                 desc: 'Output in Hocon format.'

    class_option :json,
                 aliases: '-j',
                 type: :boolean,
                 desc: 'Output in JSON format.'

    class_option :list_block_groups,
                 type: :boolean,
                 desc: 'List the names of all blockable fact groups.'

    class_option :list_cache_groups,
                 type: :boolean,
                 desc: 'List the names of all cacheable fact groups.'

    class_option :log_level,
                 aliases: '-l',
                 type: :string,
                 desc: 'Set logging level. Supported levels are: none, trace, debug, info, warn, error, and fatal.'

    class_option :no_block,
                 type: :boolean,
                 desc: 'Disable fact blocking.'

    class_option :no_cache,
                 type: :boolean,
                 desc: 'Disable loading and refreshing facts from the cache'

    class_option :no_custom_facts,
                 type: :boolean,
                 desc: 'Disable custom facts.'

    class_option :'no-external_facts',
                 type: :boolean,
                 desc: 'Disable external facts.'

    class_option :no_ruby,
                 type: :boolean,
                 desc: 'Disable loading Ruby, facts requiring Ruby, and custom facts.'

    class_option :trace,
                 type: :boolean,
                 desc: 'Enable backtraces for custom facts.'

    class_option :verbose,
                 type: :boolean,
                 desc: 'Enable verbose (info) output.'

    class_option :puppet,
                 type: :boolean,
                 aliases: '-p',
                 desc: 'Load the Puppet libraries, thus allowing Facter to load Puppet-specific facts.'

    class_option :show_legacy,
                 type: :boolean,
                 desc: 'Show legacy facts when querying all facts.'

    class_option :version,
                 type: :string,
                 aliases: '-v',
                 desc: 'Print the version and exit.'

    class_option :yaml,
                 aliases: '-y',
                 type: :boolean,
                 desc: 'Output in YAML format.'

    class_option :strict,
                 type: :boolean,
                 desc: 'Enable more aggressive error reporting.'

    desc '--man', 'Manual', hide: true
    map ['--man'] => :man
    def man(*args)
      require 'erb'
      negate_options = %w[block cache custom_facts external_facts]

      template = File.join(File.dirname(__FILE__), '..', '..', 'templates', 'man.erb')
      erb = ERB.new(File.read(template), nil, '-')
      erb.filename = template
      puts erb.result(binding)
    end

    desc 'query', 'Default method', hide: true
    desc '[options] [query] [query] [...]', ''
    def query(*args)
      output, status = Facter.to_user_output(@options, *args)
      puts output

      status = 1 if Facter::Log.errors?
      exit status
    end

    desc 'arg_parser', 'Parse arguments', hide: true
    def arg_parser(*args)
      # ignore unknown options
      args.reject! { |arg| arg.start_with?('-') }

      output, _status = Facter.to_user_output(@options, *args)

      output
    end

    desc '--version, -v', 'Print the version', hide: true
    map ['--version', '-v'] => :version
    def version
      puts Facter::VERSION
    end

    desc '--list-block-groups', 'List block groups', hide: true
    map ['--list-block-groups'] => :list_block_groups
    def list_block_groups(*args)
      options = @options.map { |(k, v)| [k.to_sym, v] }.to_h
      Facter::Options.init_from_cli(options, args)

      block_groups = Facter::FactGroups.new.groups.to_yaml.lines[1..-1].join
      block_groups.gsub!(/:\s*\n/, "\n")

      puts block_groups
    end

    desc '--list-cache-groups', 'List cache groups', hide: true
    map ['--list-cache-groups'] => :list_cache_groups
    def list_cache_groups(*args)
      options = @options.map { |(k, v)| [k.to_sym, v] }.to_h
      Facter::Options.init_from_cli(options, args)

      cache_groups = Facter::FactGroups.new.groups.to_yaml.lines[1..-1].join
      cache_groups.gsub!(/:\s*\n/, "\n")

      puts cache_groups
    end

    desc 'help', 'Help for all arguments'
    def help(*args)
      help_string = +''
      help_string << help_header(args)
      help_string << help_options
    end

    no_commands do
      def help_header(args)
        path = File.join(File.dirname(__FILE__), '../../')

        if args.include?(:puppet)
          Util::FileHelper.safe_read("#{path}fixtures/puppet_help_header")
        else
          Util::FileHelper.safe_read("#{path}fixtures/facter_help_header")
        end
      end

      def help_options
        help_options = +''
        class_options = Cli.class_options
        class_options.each do |class_option|
          option = class_option[1]
          next if option.hide

          help_options << build_option(option)
        end

        help_options
      end

      def build_option(option)
        help_option = +''
        help_option << option.aliases.join(',').rjust(10)
        help_option << ' '
        help_option << "[--#{option.name}]".ljust(30)
        help_option << " #{option.description}"
        help_option << "\n"

        help_option
      end
    end

    def self.exit_on_failure?
      true
    end

    default_task :query
  end
end
