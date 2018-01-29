module Deposits
  class Renminbi < ::Deposit
    include ::AasmAbsolutely
    include ::Deposits::Bankable

    def charge!(txid)
      with_lock do
        submit!
        accept!
        touch(:done_at)
        update_attribute(:txid, txid)
      end
    end

  end
end
