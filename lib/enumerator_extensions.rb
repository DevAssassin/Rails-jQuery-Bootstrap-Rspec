module EnumeratorExtensions
  def lazy_map(&block)
    Enumerator.new do |yielder|
      each do |e|
        yielder << block.call(e)
      end
    end
  end
end
