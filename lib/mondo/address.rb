module Mondo
  class Address < Resource
    FIELDS = %i(
      address
      city
      region
      country
      postcode
      latitude
      longitude
      short_formatted
      formatted
    ).freeze

    attr_accessor *FIELDS
  end
end
