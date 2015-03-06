module Curlybars
  module Node
    EachElse = Struct.new(:path, :each_template, :else_template, :position) do
      def compile
        <<-RUBY
          compiled_path = #{path.compile}.call

          if rendering.to_bool(compiled_path)
            position = rendering.position(#{position.line_number}, #{position.line_offset})
            rendering.check_context_is_array_of_presenters(compiled_path, #{path.path.inspect}, position)

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

      def validate(base_tree)
        resolved = path.resolve_and_check!(base_tree, check_type: :presenter_collection)
        sub_tree = resolved.first
        [
          each_template.validate(sub_tree),
          else_template.validate(base_tree)
        ]
      rescue Curlybars::Error::Validate => path_error
        path_error
      end
    end
  end
end
