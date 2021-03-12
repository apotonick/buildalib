module Auth
  module TokenUtils # stolen from Rodauth
    module_function

    private def split_token(token)
      token.split("_", 2)
    end

    # https://codahale.com/a-lesson-in-timing-attacks/
    private def timing_safe_eql?(provided, actual)
      provided = provided.to_s
      Rack::Utils.secure_compare(provided.ljust(actual.length), actual) && provided.length == actual.length
    end
  end
end
