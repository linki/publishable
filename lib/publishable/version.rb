# encoding: utf-8

module Publishable

  # Defines the current version for this gem. Versions are specified as a dot-delimited string:
  #
  # major.minor.patch.prerelease+build
  #
  # When incrementing any field, all lower-rank fields should be reset to zero or nil.
  #
  # @author David Daniell / тιηуηυмвєяѕ <info@tinynumbers.com>
  module VERSION

    # The major version number, only incremented for a major overhaul.
    MAJOR = 1

    # The minor version number, incremented for significant releases of new features.
    MINOR = 0

    # The patch-level, incremented for minor bug fixes / patches.
    PATCH = 0

    # Prerelease specification for e.g. "alpha", "beta.1", etc
    PRERELEASE = nil

    # The build number; can be used for e.g. git version of current build, etc.
    BUILD = nil

    # Return the version as a dot-delimited string.
    # @return [String] the current gem version
    def self.to_s
      @version_string ||= begin
        v = "#{MAJOR}.#{MINOR}.#{PATCH}"
        v = PRERELEASE ? "#{v}.#{PRERELEASE}" : v
        BUILD ? "#{v}+#{BUILD}" : v
      end
    end

  end
end
