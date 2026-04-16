# Llm::AdapterBase
#
# Abstract interface. Concrete adapters must implement #complete(prompt).
# Returns a plain String response.

module Llm
  class AdapterBase
    def complete(prompt)
      raise NotImplementedError, "#{self.class}#complete must be implemented"
    end
  end
end
