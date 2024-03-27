require_relative 'compositional_keyword'
module EasyTalk
  module Types
    class AllOf
      include CompositionalKeyword

      def initialize(*args)
        @types = args
        insert_schemas
      end

      def self.name
        'AllOf'
      end

      def name
        'AllOf'
      end
    end
  end
end

module T
  module AllOf
    def self.[](*args)
      EasyTalk::Types::AllOf.new(*args)
    end
  end
end
