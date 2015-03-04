module Curlybars
  module Node
    EachElse = Struct.new(:path, :each_template, :else_template, :position) do
      def compile
        <<-RUBY
          compiled_path = #{path.compile}.call
          return if compiled_path.nil?

          position = rendering.position(#{position.line_number}, #{position.line_offset})
          rendering.check_context_is_array_of_presenters(compiled_path, #{path.path.inspect}, position)

          if compiled_path.any?
            compiled_path.each do |presenter|
              contexts << presenter
              begin
                buffer.safe_concat(#{each_template.compile})
              ensure
                contexts.pop
              end
            end
          else
            buffer.safe_concat(#{else_template.compile})
          end
        RUBY
      end
    end
  end
end
