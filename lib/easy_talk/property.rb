# frozen_string_literal: true

require 'json'
require_relative 'builders/integer_builder'
require_relative 'builders/number_builder'
require_relative 'builders/boolean_builder'
require_relative 'builders/null_builder'
require_relative 'builders/string_builder'
require_relative 'builders/date_builder'
require_relative 'builders/datetime_builder'
require_relative 'builders/time_builder'
require_relative 'builders/any_of_builder'
require_relative 'builders/all_of_builder'
require_relative 'builders/one_of_builder'
require_relative 'builders/typed_array_builder'
require_relative 'builders/union_builder'

# frozen_string_literal: true

module EasyTalk
  # Property class for building a JSON schema property.
  class Property
    extend T::Sig
    attr_reader :context, :name, :type, :constraints

    TYPE_TO_BUILDER = {
      'String' => Builders::StringBuilder,
      'Integer' => Builders::IntegerBuilder,
      'Float' => Builders::NumberBuilder,
      'BigDecimal' => Builders::NumberBuilder,
      'T::Boolean' => Builders::BooleanBuilder,
      'NilClass' => Builders::NullBuilder,
      'Date' => Builders::DateBuilder,
      'DateTime' => Builders::DatetimeBuilder,
      'Time' => Builders::TimeBuilder,
      'AnyOf' => Builders::AnyOfBuilder,
      'AllOf' => Builders::AllOfBuilder,
      'OneOf' => Builders::OneOfBuilder,
      'T::Types::TypedArray' => Builders::TypedArrayBuilder,
      'T::Types::Union' => Builders::UnionBuilder
    }.freeze

    # Initializes a new instance of the Property class.
    # @params context [Hash] The context of tree structure.
    # @param name [Symbol] The name of the property.
    # @param type [Object] The type of the property.
    # @param constraints [Hash] The property constraints.
    # @raise [ArgumentError] If the property type is missing.
    sig do
      params(context: T.untyped, name: Symbol, type: T.any(String, Object),
             constraints: T::Hash[Symbol, T.untyped]).void
    end
    def initialize(context, name, type = nil, constraints = {})
      @context = context
      @name = name
      @type = type
      @constraints = constraints
      raise ArgumentError, 'property type is missing' if type.blank?
    end

    def build
      return type.schema if type.respond_to?(:schema)

      if type.is_a?(T::Types::Simple)
        @type = type.raw_type
        return self
      end

      builder.new(context, name).build
    end

    def as_json(*_args)
      build.as_json
    end

    def builder
      TYPE_TO_BUILDER[type.class.name] || TYPE_TO_BUILDER[type.name]
    end
  end
end
