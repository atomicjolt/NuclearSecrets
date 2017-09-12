require "test_helper"

class NuclearSecrets::Test < ActiveSupport::TestCase

  test "throws error when required secrets are missing" do
    assert_raises(NuclearSecrets::SecretsMissingError) do
      NuclearSecrets::check_secrets(
        {
          required_secrets: {
            required_secrets: "Hash",
            one_fish: "String",
            two_fish: "Fixnum",
          },
          one_fish: "Red Fish",
        },
      )
    end
  end

  test "throws error when extra secrets are provided" do
    assert_raises(NuclearSecrets::ExtraSecretsError) do
      NuclearSecrets::check_secrets(
        {
          required_secrets: {
            required_secrets: "Hash",
            one_fish: "String",
          },
          one_fish: "Red Fish",
          two_fish: 2,
        },
      )
    end
  end

  test "throws error when no required list is passed" do
    assert_raises(NuclearSecrets::RequiredSecretsListMissing) do
      NuclearSecrets::check_secrets(
        {
          one_fish: "Red Fish",
          two_fish: 2,
        },
      )
    end
  end

  test "handles correct secrets" do
    assert_nothing_raised do
      NuclearSecrets::check_secrets(
        {
          required_secrets: {
            required_secrets: "Hash",
            one_fish: "String",
            two_fish: "Fixnum",
          },
          one_fish: "Red Fish",
          two_fish: 2,
        },
      )
    end
  end
end
