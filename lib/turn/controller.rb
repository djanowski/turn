require 'fileutils'

module Turn
  require 'turn/components/suite.rb'
  require 'turn/components/case.rb'
  require 'turn/components/method.rb'

  require 'turn/reporters/outline_reporter'
  require 'turn/reporters/marshal_reporter'
  require 'turn/reporters/progress_reporter'
  require 'turn/reporters/dot_reporter'

  require 'turn/runners/testrunner'
  require 'turn/runners/solorunner'
  require 'turn/runners/crossrunner'

  # = Controller
  #
  #--
  # TODO: Add support to test run loggging.
  #++
  class Controller

    # File glob pattern of tests to run.
    # Can be an array of files/globs.
    attr_accessor :tests

    # Files globs to specially exclude.
    attr_accessor :exclude

    # Add these folders to the $LOAD_PATH.
    attr_accessor :loadpath

    # Libs to require when running tests.
    attr_accessor :requires

    # Instance of Reporter.
    attr_accessor :reporter

    # Insatance of Runner.
    attr_accessor :runner

    # Test against live install (i.e. Don't use loadpath option)
    attr_accessor :live

    # Log results? May be true/false or log file name. (TODO)
    attr_accessor :log

    # Verbose output?
    attr_accessor :verbose

    def verbose? ; @verbose ; end
    def live?    ; @live    ; end

  private

    def initialize
      yield(self) if block_given?
      initialize_defaults
    end

    #
    def initialize_defaults
      @loadpath ||= ['lib']
      @tests    ||= "test/**/{test,}*{,test}"
      @exclude  ||= []
      @requires ||= []
      @live     ||= false
      @log      ||= true
      @reporter ||= OutlineReporter.new($stdout)
      @runner   ||= TestRunner.new
    end

    # Collect test configuation.
    #def test_configuration(options={})
    #  #options = configure_options(options, 'test')
    #  #options['loadpath'] ||= metadata.loadpath
    #  options['tests']    ||= self.tests
    #  options['loadpath'] ||= self.loadpath
    #  options['requires'] ||= self.requires
    #  options['live']     ||= self.live
    #  options['exclude']  ||= self.exclude
    #  #options['tests']    = list_option(options['tests'])
    #  options['loadpath'] = list_option(options['loadpath'])
    #  options['exclude']  = list_option(options['exclude'])
    #  options['require']  = list_option(options['require'])
    #  return options
    #end

    #
    def list_option(list)
      case list
      when nil
        []
      when Array
        list
      else
        list.split(/[:;]/)
      end
    end

  public

    def loadpath=(paths)
      @loadpath = list_option(paths)
    end

    def exclude=(paths)
      @exclude = list_option(paths)
    end

    def requires=(paths)
      @requires = list_option(paths)
    end

    def files
      @files ||= (
        fs = tests.map do |t|
          File.directory?(t) ? Dir[File.join(t, '**', '*')] : Dir[t]
        end
        fs = fs.flatten.reject{ |f| File.directory?(f) }
        ex = exclude.map do |x|
          File.directory?(x) ? Dir[File.join(x, '**', '*')] : Dir[x]
        end
        ex = ex.flatten.reject{ |f| File.directory?(f) }
        (fs - ex).uniq
      )
    end

    def start
      @files = nil  # reset files just in case

      if files.empty?
        $stderr.puts "No tests."
        return
      end

      testrun = runner.new(self)

      testrun.start
    end

  end

end

