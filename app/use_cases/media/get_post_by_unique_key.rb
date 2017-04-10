 class Media::GetPostByUniqueKey < Mutations::Command

    required do
      string :unique_key
    end

    def execute
      Post.find_by_unique_key(inputs[:unique_key])
  end
end
