module Pod
  class Installer
    class Analyzer
      # Caches podfile & target definition dependencies, so they do not need to be re-computed
      # from the internal hash on each access
      #
      class PodfileDependencyCache
        # @return [Array<Pod::Dependency>]
        #         All the dependencies in the podfile
        #
        attr_reader :podfile_dependencies

        # @param [Array<Pod::Dependency>] podfile_dependencies @see #podfile_dependencies
        #
        # @param [Hash{Pod::TargetDefinition => Array<Pod::Dependency>}] dependencies_by_target_definition
        #        dependencies keyed by their target definition
        #
        def initialize(podfile_dependencies, dependencies_by_target_definition)
          @podfile_dependencies = podfile_dependencies
          @dependencies_by_target_definition = dependencies_by_target_definition
        end

        # @return [Array<Pod::Dependency>] The dependencies for the given target definition
        #
        def target_definition_dependencies(target_definition)
          dependencies_by_target_definition[target_definition] ||
            raise(ArgumentError, "dependencies for #{target_definition.inspect} do not exist in the cache")
        end

        # @return [Array<Pod::TargetDefinition>] A list of all of the target definitions in the Podfile
        #
        def target_definition_list
          dependencies_by_target_definition.keys
        end

        # Creates a {PodfileDependencyCache} from the given {Podfile}
        #
        # @param [Podfile] podfile
        #        The {Podfile} from which dependencies should be cached
        #
        # @return [PodfileDependencyCache]
        #         A warmed, immutable cache of all the dependencies in the {Podfile}
        #
        def self.from_podfile(podfile)
          raise ArgumentError, 'Must be initialized with a podfile' unless podfile
          podfile_dependencies = []
          dependencies_by_target_definition = {}
          podfile.target_definition_list.each do |target_definition|
            deps = target_definition.dependencies.freeze
            podfile_dependencies.concat deps
            dependencies_by_target_definition[target_definition] = deps
          end
          podfile_dependencies.uniq!

          new(podfile_dependencies.freeze, dependencies_by_target_definition.freeze)
        end

        private

        # @return [Hash{TargetDefinition => Array<Pod::Dependency>}]
        #         dependencies keyed by their target definition
        #
        attr_reader :dependencies_by_target_definition
      end
    end
  end
end
