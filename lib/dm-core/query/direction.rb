module DataMapper
  class Query
    class Direction
      include Extlib::Assertions

      attr_reader :property
      attr_reader :direction

      def ==(other)
        return true if equal?(other)
        return false unless other.respond_to?(:property) && other.respond_to?(:direction)

        property == other.property && direction == other.direction
      end

      def eql?(other)
        return true if equal?(other)
        return false unless self.class.equal?(other.class)

        property.eql?(other.property) && direction.eql?(other.direction)
      end

      def reverse
        dup.reverse!
      end

      def reverse!
        @direction = @direction == :asc ? :desc : :asc
        self
      end

      def inspect
        "#<#{self.class.name} #{@property.inspect} #{@direction}>"
      end

      private

      def initialize(property, direction = :asc)
        assert_kind_of 'property',  property,  Property
        assert_kind_of 'direction', direction, Symbol

        @property  = property
        @direction = direction
      end
    end # class Direction
  end # class Query
end # module DataMapper