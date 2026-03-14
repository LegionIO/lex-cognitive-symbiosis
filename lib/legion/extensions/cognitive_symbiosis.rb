# frozen_string_literal: true

require 'securerandom'

require 'legion/extensions/cognitive_symbiosis/version'
require 'legion/extensions/cognitive_symbiosis/helpers/constants'
require 'legion/extensions/cognitive_symbiosis/helpers/symbiotic_bond'
require 'legion/extensions/cognitive_symbiosis/helpers/ecosystem'
require 'legion/extensions/cognitive_symbiosis/helpers/symbiosis_engine'
require 'legion/extensions/cognitive_symbiosis/runners/cognitive_symbiosis'
require 'legion/extensions/cognitive_symbiosis/client'

module Legion
  module Extensions
    module CognitiveSymbiosis
      extend Legion::Extensions::Core if Legion::Extensions.const_defined? :Core
    end
  end
end
