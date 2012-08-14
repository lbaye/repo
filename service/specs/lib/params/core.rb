module Util
  module Params
    def parse(str_params)
      params = str_params.split(/,\s*/)
      { }.tap do |_params|
        params.each do |_param|
          parts                = _param.to_s.split('=')
          _params[parts.first] = _parse_values(parts.last)
        end
      end
    end

    def _parse_values(str)
      str.tap do |s|
        s.scan(/\{(.*?)\}/).each do |match|
          match.first.tap do |code|
            return Functions.module_eval(code)
          end
        end
      end
    end

    module_function :parse, :_parse_values
  end
end