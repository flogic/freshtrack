class Array
  def group_by(&block)
    raise ArgumentError unless block
    inject({}) do |hash, elem|
      key = block.call(elem)
      hash[key] ||= []
      hash[key].push(elem)
      hash
    end
  end
end
