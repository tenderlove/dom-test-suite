require 'test/unit'

def DOMTestCase(test_case_name)
  klass = test_case_name.capitalize
  raise "Already defined!" if Object.const_get(klass.to_sym)
end