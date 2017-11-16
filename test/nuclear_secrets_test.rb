require "test_helper"

class NuclearSecrets::Test < ActiveSupport::TestCase
  test "throws error when required secrets are missing" do
    assert_raises(NuclearSecrets::SecretsMissingError) do
      NuclearSecrets.configure do |c|
        c.required_secrets = {
          one_fish: String,
          two_fish: Fixnum,
        }
      end

      NuclearSecrets.check_secrets({ one_fish: "Red Fish" })
    end
  end

  test "throws error when extra secrets are provided" do
    assert_raises(NuclearSecrets::ExtraSecretsError) do
      NuclearSecrets.configure do |c|
        c.required_secrets = {
          one_fish: String,
        }
      end
      NuclearSecrets.check_secrets(
        {
          one_fish: "Red Fish",
          two_fish: 2,
        },
      )
    end
  end

  test "throws error when no required list is passed" do
    assert_raises(NuclearSecrets::RequiredSecretsListMissing) do
      NuclearSecrets.configure do |c|
        c.required_secrets = nil
      end
      NuclearSecrets.check_secrets(
        {
          one_fish: "Red Fish",
          two_fish: 2,
        },
      )
    end
  end

  test "handles correct secrets" do
    assert_nothing_raised do
      NuclearSecrets.configure do |c|
        c.required_secrets = {
          one_fish: String,
          two_fish: Fixnum,
        }
      end
      NuclearSecrets.check_secrets(
        {
          one_fish: "Red Fish",
          two_fish: 2,
        },
      )
    end
  end

  test "handles class name as value" do
    assert_nothing_raised do
      NuclearSecrets.configure do |c|
        c.required_secrets = {
          one_fish: String,
          two_fish: Fixnum,
        }
      end
      NuclearSecrets.check_secrets(
        {
          one_fish: "Red Fish",
          two_fish: 2,
        },
      )
    end
  end

  test "handles proc as value" do
    assert_nothing_raised do
      NuclearSecrets.configure do |c|
        c.required_secrets = {
          one_fish: Proc.new { true },
          two_fish: Fixnum,
        }
      end
      NuclearSecrets.check_secrets(
        {
          one_fish: "Red Fish",
          two_fish: 2,
        },
      )
    end
  end

  test "raises invalid required value with invalid value" do
    assert_raises(NuclearSecrets::InvalidRequiredSecretValue) do
      NuclearSecrets.configure do |c|
        c.required_secrets = {
          one_fish: Proc.new { true },
          two_fish: nil,
        }
      end
      NuclearSecrets.check_secrets(
        {
          one_fish: "Red Fish",
          two_fish: 2,
        },
      )
    end
  end

  test "raises mismatched value error" do
    assert_raises(NuclearSecrets::MismatchedSecretType) do
      NuclearSecrets.configure do |c|
        c.required_secrets = {
          one_fish: Proc.new { true },
          two_fish: Fixnum,
        }
      end
      NuclearSecrets.check_secrets(
        {
          one_fish: "Red Fish",
          two_fish: "2",
        },
      )
    end
  end
end
