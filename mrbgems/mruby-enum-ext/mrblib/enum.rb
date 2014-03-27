##
# Enumerable
#
module Enumerable
  ##
  # call-seq:
  #    enum.drop(n)               -> array
  #
  # Drops first n elements from <i>enum</i>, and returns rest elements
  # in an array.
  #
  #    a = [1, 2, 3, 4, 5, 0]
  #    a.drop(3)             #=> [4, 5, 0]

  def drop(n)
    raise TypeError, "no implicit conversion of #{n.class} into Integer" unless n.respond_to?(:to_int)
    raise ArgumentError, "attempt to drop negative size" if n < 0

    n = n.to_int
    ary = []
    self.each {|*val| n == 0 ? ary << val.__svalue : n -= 1 }
    ary
  end

  ##
  # call-seq:
  #    enum.drop_while {|arr| block }   -> array
  #
  # Drops elements up to, but not including, the first element for
  # which the block returns +nil+ or +false+ and returns an array
  # containing the remaining elements.
  #
  #    a = [1, 2, 3, 4, 5, 0]
  #    a.drop_while {|i| i < 3 }   #=> [3, 4, 5, 0]

  def drop_while(&block)
    ary, state = [], false
    self.each do |*val|
      state = true if !state and !block.call(*val)
      ary << val.__svalue if state
    end
    ary
  end

  ##
  # call-seq:
  #    enum.take(n)               -> array
  #
  # Returns first n elements from <i>enum</i>.
  #
  #    a = [1, 2, 3, 4, 5, 0]
  #    a.take(3)             #=> [1, 2, 3]

  def take(n)
    raise TypeError, "no implicit conversion of #{n.class} into Integer" unless n.respond_to?(:to_int)
    raise ArgumentError, "attempt to take negative size" if n < 0

    n = n.to_int
    ary = []
    self.each do |*val|
      break if ary.size >= n
      ary << val.__svalue
    end
    ary
  end

  ##
  # call-seq:
  #    enum.take_while {|arr| block }   -> array
  #
  # Passes elements to the block until the block returns +nil+ or +false+,
  # then stops iterating and returns an array of all prior elements.
  #
  #
  #    a = [1, 2, 3, 4, 5, 0]
  #    a.take_while {|i| i < 3 }   #=> [1, 2]

  def take_while(&block)
    ary = []
    self.each do |*val|
      return ary unless block.call(*val)
      ary << val.__svalue
    end
    ary
  end
  
  ##
  # call-seq:
  #   enum.each_cons(n) {...}   ->  nil
  #
  # Iterates the given block for each array of consecutive <n>
  # elements.
  #
  # e.g.:
  #     (1..10).each_cons(3) {|a| p a}
  #     # outputs below
  #     [1, 2, 3]
  #     [2, 3, 4]
  #     [3, 4, 5]
  #     [4, 5, 6]
  #     [5, 6, 7]
  #     [6, 7, 8]
  #     [7, 8, 9]
  #     [8, 9, 10]

  def each_cons(n, &block)
    raise TypeError, "no implicit conversion of #{n.class} into Integer" unless n.respond_to?(:to_int)
    raise ArgumentError, "invalid size" if n <= 0

    ary = []
    n = n.to_int
    self.each do |*val|
      ary.shift if ary.size == n
      ary << val.__svalue
      block.call(ary.dup) if ary.size == n
    end
  end

  ##
  # call-seq:
  #   enum.each_slice(n) {...}  ->  nil
  #
  # Iterates the given block for each slice of <n> elements.
  #
  # e.g.:
  #     (1..10).each_slice(3) {|a| p a}
  #     # outputs below
  #     [1, 2, 3]
  #     [4, 5, 6]
  #     [7, 8, 9]
  #     [10]

  def each_slice(n, &block)
    raise TypeError, "no implicit conversion of #{n.class} into Integer" unless n.respond_to?(:to_int)
    raise ArgumentError, "invalid slice size" if n <= 0

    ary = []
    n = n.to_int
    self.each do |*val|
      ary << val.__svalue
      if ary.size == n
        block.call(ary)
        ary = []
      end
    end
    block.call(ary) unless ary.empty?
  end

  ##
  # call-seq:
  #    enum.group_by {| obj | block }  -> a_hash
  #
  # Returns a hash, which keys are evaluated result from the
  # block, and values are arrays of elements in <i>enum</i>
  # corresponding to the key.
  #
  #    (1..6).group_by {|i| i%3}   #=> {0=>[3, 6], 1=>[1, 4], 2=>[2, 5]}

  def group_by(&block)
    h = {}
    self.each do |*val|
      key = block.call(*val)
      sv = val.__svalue
      h.key?(key) ? (h[key] << sv) : (h[key] = [sv])
    end
    h
  end

  ##
  # call-seq:
  #    enum.sort_by { |obj| block }   -> array
  #
  # Sorts <i>enum</i> using a set of keys generated by mapping the
  # values in <i>enum</i> through the given block.
  def sort_by(&block)
    ary = []
    orig = [] 
    self.each_with_index{|e, i|
      orig.push(e)
      ary.push([block.call(e), i])
    }
    if ary.size > 1
      __sort_sub__(ary, ::Array.new(ary.size), 0, 0, ary.size - 1) do |a,b|
        a <=> b
      end
    end
    ary.collect{|e,i| orig[i]}
  end

  NONE = Object.new
  ##
  # call-seq:
  #    enum.first       ->  obj or nil
  #    enum.first(n)    ->  an_array
  #
  # Returns the first element, or the first +n+ elements, of the enumerable.
  # If the enumerable is empty, the first form returns <code>nil</code>, and the
  # second form returns an empty array.
  def first(n=NONE)
    if n == NONE
      self.each do |*val|
        return val.__svalue
      end
      return nil
    else
      a = []
      i = 0
      self.each do |*val|
        break if n<=i
        a.push val.__svalue
        i += 1
      end
      a
    end
  end

  ##
  # call-seq:
  #    enum.count                 -> int
  #    enum.count(item)           -> int
  #    enum.count { |obj| block } -> int
  #
  # Returns the number of items in +enum+ through enumeration.
  # If an argument is given, the number of items in +enum+ that
  # are equal to +item+ are counted.  If a block is given, it
  # counts the number of elements yielding a true value.
  def count(v=NONE, &block)
    count = 0
    if block
      self.each do |*val|
        count += 1 if block.call(*val)
      end
    else
      if v == NONE
        self.each { count += 1 }
      else
        self.each do |*val|
          count += 1 if val.__svalue == v 
        end
      end
    end
    count
  end

  ##
  # call-seq:
  #    enum.flat_map       { |obj| block } -> array
  #    enum.collect_concat { |obj| block } -> array
  #    enum.flat_map                       -> an_enumerator
  #    enum.collect_concat                 -> an_enumerator
  #
  # Returns a new array with the concatenated results of running
  # <em>block</em> once for every element in <i>enum</i>.
  #
  # If no block is given, an enumerator is returned instead.
  #
  #    [1, 2, 3, 4].flat_map { |e| [e, -e] } #=> [1, -1, 2, -2, 3, -3, 4, -4]
  #    [[1, 2], [3, 4]].flat_map { |e| e + [100] } #=> [1, 2, 100, 3, 4, 100]
  def flat_map(&block)
    return to_enum :flat_map unless block_given?

    ary = []
    self.each do |*e|
      e2 = block.call(*e)
      if e2.respond_to? :each
        e2.each {|e3| ary.push(e3) }
      else
        ary.push(e2)
      end
    end
    ary
  end
  alias collect_concat flat_map

  ##
  # call-seq:
  #    enum.max_by {|obj| block }      -> obj
  #    enum.max_by                     -> an_enumerator
  #
  # Returns the object in <i>enum</i> that gives the maximum
  # value from the given block.
  #
  # If no block is given, an enumerator is returned instead.
  #
  #    %w[albatross dog horse].max_by {|x| x.length }   #=> "albatross"

  def max_by(&block)
    return to_enum :max_by unless block_given?

    first = true
    max = nil
    max_cmp = nil

    self.each do |*val|
      if first
        max = val.__svalue
        max_cmp = block.call(*val)
        first = false
      else
        if (cmp = block.call(*val)) > max_cmp
          max = val.__svalue
          max_cmp = cmp
        end
      end
    end
    max
  end

  ##
  # call-seq:
  #    enum.min_by {|obj| block }      -> obj
  #    enum.min_by                     -> an_enumerator
  #
  # Returns the object in <i>enum</i> that gives the minimum
  # value from the given block.
  #
  # If no block is given, an enumerator is returned instead.
  #
  #    %w[albatross dog horse].min_by {|x| x.length }   #=> "dog"

  def min_by(&block)
    return to_enum :min_by unless block_given?

    first = true
    min = nil
    min_cmp = nil

    self.each do |*val|
      if first
        min = val.__svalue
        min_cmp = block.call(*val)
        first = false
      else
        if (cmp = block.call(*val)) < min_cmp
          min = val.__svalue
          min_cmp = cmp
        end
      end
    end
    min
  end

  ##
  #  call-seq:
  #     enum.minmax                  -> [min, max]
  #     enum.minmax { |a, b| block } -> [min, max]
  #
  #  Returns two elements array which contains the minimum and the
  #  maximum value in the enumerable.  The first form assumes all
  #  objects implement <code>Comparable</code>; the second uses the
  #  block to return <em>a <=> b</em>.
  #
  #     a = %w(albatross dog horse)
  #     a.minmax                                  #=> ["albatross", "horse"]
  #     a.minmax { |a, b| a.length <=> b.length } #=> ["dog", "albatross"]

  def minmax(&block)
    max = nil
    min = nil
    first = true

    self.each do |*val|
      if first
        val = val.__svalue
        max = val
        min = val
        first = false
      else
        if block
          max = val.__svalue if block.call(*val, max) > 0
          min = val.__svalue if block.call(*val, min) < 0
        else
          val = val.__svalue
          max = val if (val <=> max) > 0
          min = val if (val <=> min) < 0
        end
      end
    end
    [min, max]
  end

  ##
  #  call-seq:
  #     enum.minmax_by { |obj| block } -> [min, max]
  #     enum.minmax_by                 -> an_enumerator
  #
  #  Returns a two element array containing the objects in
  #  <i>enum</i> that correspond to the minimum and maximum values respectively
  #  from the given block.
  #
  #  If no block is given, an enumerator is returned instead.
  #
  #     %w(albatross dog horse).minmax_by { |x| x.length }   #=> ["dog", "albatross"]

  def minmax_by(&block)
    max = nil
    max_cmp = nil
    min = nil
    min_cmp = nil
    first = true

    self.each do |*val|
      if first
        max = min = val.__svalue
        max_cmp = min_cmp = block.call(*val)
        first = false
     else
        if (cmp = block.call(*val)) > max_cmp
          max = val.__svalue
          max_cmp = cmp
        end
        if (cmp = block.call(*val)) < min_cmp
          min = val.__svalue
          min_cmp = cmp
        end
      end
    end
    [min, max]
  end

  ##
  #  call-seq:
  #     enum.none? [{ |obj| block }]   -> true or false
  #
  #  Passes each element of the collection to the given block. The method
  #  returns <code>true</code> if the block never returns <code>true</code>
  #  for all elements. If the block is not given, <code>none?</code> will return
  #  <code>true</code> only if none of the collection members is true.
  #
  #     %w(ant bear cat).none? { |word| word.length == 5 } #=> true
  #     %w(ant bear cat).none? { |word| word.length >= 4 } #=> false
  #     [].none?                                           #=> true
  #     [nil, false].none?                                 #=> true
  #     [nil, true].none?                                  #=> false

  def none?(&block)
    if block
      self.each do |*val|
        return false if block.call(*val)
      end
    else
      self.each do |*val|
        return false if val.__svalue
      end
    end
    true
  end

  ##
  #  call-seq:
  #    enum.one? [{ |obj| block }]   -> true or false
  #
  # Passes each element of the collection to the given block. The method
  # returns <code>true</code> if the block returns <code>true</code>
  # exactly once. If the block is not given, <code>one?</code> will return
  # <code>true</code> only if exactly one of the collection members is
  # true.
  #
  #    %w(ant bear cat).one? { |word| word.length == 4 }  #=> true
  #    %w(ant bear cat).one? { |word| word.length > 4 }   #=> false
  #    %w(ant bear cat).one? { |word| word.length < 4 }   #=> false
  #    [nil, true, 99].one?                               #=> false
  #    [nil, true, false].one?                            #=> true
  #

  def one?(&block)
    count = 0
    if block
      self.each do |*val|
        count += 1 if block.call(*val)
        return false if count > 1
      end
    else
      self.each do |*val|
        count += 1 if val.__svalue
        return false if count > 1
      end
    end

    count == 1 ? true : false
  end

  ##
  #  call-seq:
  #    enum.each_with_object(obj) { |(*args), memo_obj| ... }  ->  obj
  #    enum.each_with_object(obj)                              ->  an_enumerator
  #
  #  Iterates the given block for each element with an arbitrary
  #  object given, and returns the initially given object.
  #
  #  If no block is given, returns an enumerator.
  #
  #     (1..10).each_with_object([]) { |i, a| a << i*2 }
  #     #=> [2, 4, 6, 8, 10, 12, 14, 16, 18, 20]
  #

  def each_with_object(obj=nil, &block)
    raise ArgumentError, "wrong number of arguments (0 for 1)" if obj == nil

    return to_enum :each_with_object unless block_given?

    self.each {|*val| block.call(val.__svalue, obj) }
    obj
  end

  ##
  #  call-seq:
  #     enum.reverse_each { |item| block } ->  enum
  #     enum.reverse_each                  ->  an_enumerator
  #
  #  Builds a temporary array and traverses that array in reverse order.
  #
  #  If no block is given, an enumerator is returned instead.
  #
  #      (1..3).reverse_each { |v| p v }
  #
  #    produces:
  #
  #      3
  #      2
  #      1
  #

  def reverse_each(&block)
    ary = self.to_a
    i = ary.size - 1
    while i>=0
      block.call(ary[i])
      i -= 1
    end
    self
  end

  ##
  #  call-seq:
  #     enum.cycle(n=nil) { |obj| block }  ->  nil
  #     enum.cycle(n=nil)                  ->  an_enumerator
  #
  #  Calls <i>block</i> for each element of <i>enum</i> repeatedly _n_
  #  times or forever if none or +nil+ is given.  If a non-positive
  #  number is given or the collection is empty, does nothing.  Returns
  #  +nil+ if the loop has finished without getting interrupted.
  #
  #  Enumerable#cycle saves elements in an internal array so changes
  #  to <i>enum</i> after the first pass have no effect.
  #
  #  If no block is given, an enumerator is returned instead.
  #
  #     a = ["a", "b", "c"]
  #     a.cycle { |x| puts x }  # print, a, b, c, a, b, c,.. forever.
  #     a.cycle(2) { |x| puts x }  # print, a, b, c, a, b, c.
  #

  def cycle(n=nil, &block)
    ary = []
    if n == nil
      self.each do|*val|
        ary.push val
        block.call(*val)
      end
      loop do
        ary.each do|e|
          block.call(*e)
        end
      end
    else
      raise TypeError, "no implicit conversion of #{n.class} into Integer" unless n.respond_to?(:to_int)

      n = n.to_int
      self.each do|*val|
        ary.push val
      end
      count = 0
      while count < n
        ary.each do|e|
          block.call(*e)
        end
        count += 1
      end
    end
  end

  ##
  #  call-seq:
  #     enum.find_index(value)          -> int or nil
  #     enum.find_index { |obj| block } -> int or nil
  #     enum.find_index                 -> an_enumerator
  #
  #  Compares each entry in <i>enum</i> with <em>value</em> or passes
  #  to <em>block</em>.  Returns the index for the first for which the
  #  evaluated value is non-false.  If no object matches, returns
  #  <code>nil</code>
  #
  #  If neither block nor argument is given, an enumerator is returned instead.
  #
  #     (1..10).find_index  { |i| i % 5 == 0 and i % 7 == 0 }  #=> nil
  #     (1..100).find_index { |i| i % 5 == 0 and i % 7 == 0 }  #=> 34
  #     (1..100).find_index(50)                                #=> 49
  #

  def find_index(val=NONE, &block)
    return to_enum :find_index if !block_given? && val == NONE

    idx = 0
    if block
      self.each do |*e|
        return idx if block.call(*e)
        idx += 1
      end
    else
      self.each do |*e|
        return idx if e.__svalue == val
        idx += 1
      end
    end
    nil
  end

  ##
  #  call-seq:
  #     enum.zip(arg, ...)                  -> an_array_of_array
  #
  #  Takes one element from <i>enum</i> and merges corresponding
  #  elements from each <i>args</i>.  This generates a sequence of
  #  <em>n</em>-element arrays, where <em>n</em> is one more than the
  #  count of arguments.  The length of the resulting sequence will be
  #  <code>enum#size</code>.  If the size of any argument is less than
  #  <code>enum#size</code>, <code>nil</code> values are supplied.
  #

  def zip(*arg)
    ary = []
    i = 0
    self.each do |val|
      a = []
      a.push(val)
      idx = 0
      while idx < arg.size
        a2 = arg[idx].to_a
        a.push(a2[i])
        idx += 1
      end
      ary.push(a)
      i += 1
    end
    ary
  end
end
