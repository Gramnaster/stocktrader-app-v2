require 'rails_helper'

RSpec.describe Receipt, type: :model do
  describe 'Stock Buying Process' do
    let(:country) { create(:country) }
    let(:user) { create(:user, country: country) }
    let(:stock) { create(:stock, ticker: 'AAPL', current_price: 150.00, country: country) }
    let!(:wallet) { create(:wallet, user: user, balance: 2000.00) }

    describe 'validations' do
      it 'validates presence of quantity' do
        receipt = build(:receipt, quantity: nil)
        expect(receipt).not_to be_valid
        expect(receipt.errors[:quantity]).to include("can't be blank")
      end

      it 'validates quantity is greater than 0' do
        receipt = build(:receipt, quantity: 0)
        expect(receipt).not_to be_valid
        expect(receipt.errors[:quantity]).to include("must be greater than 0")
      end

      it 'validates price_per_share is greater than or equal to 0' do
        receipt = build(:receipt, price_per_share: -1)
        expect(receipt).not_to be_valid
        expect(receipt.errors[:price_per_share]).to include("must be greater than or equal to 0")
      end

      it 'validates total_amount is greater than or equal to 0' do
        receipt = build(:receipt, total_amount: -1)
        expect(receipt).not_to be_valid
        expect(receipt.errors[:total_amount]).to include("must be greater than or equal to 0")
      end
    end

    describe 'associations' do
      it 'belongs to user' do
        expect(Receipt.reflect_on_association(:user).macro).to eq(:belongs_to)
      end

      it 'belongs to stock' do
        expect(Receipt.reflect_on_association(:stock).macro).to eq(:belongs_to)
      end
    end

    describe 'successful stock purchase' do
      context 'when user has sufficient funds and no existing portfolio' do
        it 'creates a receipt record' do
          expect {
            Receipt.create!(
              user: user,
              stock: stock,
              transaction_type: 'buy',
              quantity: 10,
              price_per_share: 150.00,
              total_amount: 1500.00
            )
          }.to change(Receipt, :count).by(1)
        end

        it 'reduces wallet balance correctly' do
          initial_balance = wallet.balance

          Receipt.create!(
            user: user,
            stock: stock,
            transaction_type: 'buy',
            quantity: 10,
            price_per_share: 150.00,
            total_amount: 1500.00
          )

          wallet.reload
          expect(wallet.balance).to eq(initial_balance - 1500.00)
        end

        it 'creates a new portfolio entry with correct quantity' do
          expect {
            Receipt.create!(
              user: user,
              stock: stock,
              transaction_type: 'buy',
              quantity: 10,
              price_per_share: 150.00,
              total_amount: 1500.00
            )
          }.to change(Portfolio, :count).by(1)

          portfolio = Portfolio.find_by(user: user, stock: stock)
          expect(portfolio.quantity).to eq(10.0)
        end

        it 'updates receipt with actual execution data' do
          receipt = Receipt.create!(
            user: user,
            stock: stock,
            transaction_type: 'buy',
            quantity: 10,
            price_per_share: 0, # Will be updated by execution
            total_amount: 0 # Will be updated by execution
          )

          receipt.reload
          expect(receipt.price_per_share).to eq(150.00)
          expect(receipt.total_amount).to eq(1500.00)
        end
      end

      context 'when user has existing portfolio for the same stock' do
        let!(:existing_portfolio) { create(:portfolio, user: user, stock: stock, quantity: 5) }

        it 'does not create a new portfolio entry' do
          expect {
            Receipt.create!(
              user: user,
              stock: stock,
              transaction_type: 'buy',
              quantity: 10,
              price_per_share: 150.00,
              total_amount: 1500.00
            )
          }.not_to change(Portfolio, :count)
        end

        it 'increases existing portfolio quantity' do
          Receipt.create!(
            user: user,
            stock: stock,
            transaction_type: 'buy',
            quantity: 10,
            price_per_share: 150.00,
            total_amount: 1500.00
          )

          existing_portfolio.reload
          expect(existing_portfolio.quantity).to eq(15.0) # 5 + 10
        end
      end
    end

    describe 'failed stock purchase' do
      context 'when user has insufficient funds' do
        let!(:low_balance_wallet) { create(:wallet, user: user, balance: 100.00) }

        it 'raises an error and does not create receipt' do
          expect {
            Receipt.create!(
              user: user,
              stock: stock,
              transaction_type: 'buy',
              quantity: 10,
              price_per_share: 150.00,
              total_amount: 1500.00
            )
          }.to raise_error(StandardError, /Insufficient funds/)
        end

        it 'does not change wallet balance' do
          initial_balance = low_balance_wallet.balance

          expect {
            Receipt.create!(
              user: user,
              stock: stock,
              transaction_type: 'buy',
              quantity: 10,
              price_per_share: 150.00,
              total_amount: 1500.00
            )
          }.to raise_error(StandardError)

          low_balance_wallet.reload
          expect(low_balance_wallet.balance).to eq(initial_balance)
        end

        it 'does not create portfolio entry' do
          expect {
            begin
              Receipt.create!(
                user: user,
                stock: stock,
                transaction_type: 'buy',
                quantity: 10,
                price_per_share: 150.00,
                total_amount: 1500.00
              )
            rescue StandardError
              # Ignore error for this test
            end
          }.not_to change(Portfolio, :count)
        end
      end

      context 'when stock does not exist' do
        it 'handles missing stock gracefully' do
          # Mock the stock lookup to return nil
          allow(Stock).to receive(:find_by).with(ticker: 'INVALID').and_return(nil)

          receipt = Receipt.new(
            user: user,
            stock: stock,
            transaction_type: 'buy',
            quantity: 10,
            price_per_share: 150.00,
            total_amount: 1500.00
          )

          # Mock the stock.ticker call in execute_transaction
          allow(receipt).to receive_message_chain(:stock, :ticker).and_return('INVALID')

          expect {
            receipt.save!
          }.to raise_error # Should fail due to buy method returning nil
        end
      end
    end

    describe 'portfolio uniqueness' do
      it 'ensures only one portfolio entry per user-stock combination' do
        # Create first portfolio
        Portfolio.create!(user: user, stock: stock, quantity: 5)

        # Attempt to create duplicate should fail
        expect {
          Portfolio.create!(user: user, stock: stock, quantity: 10)
        }.to raise_error(ActiveRecord::RecordInvalid, /can only have one portfolio entry per stock/)
      end
    end

    describe 'buy method' do
      it 'returns correct hash with purchase details' do
        receipt = Receipt.new(user: user, stock: stock, transaction_type: 'buy')
        result = receipt.buy(10, 'AAPL')

        expect(result).to be_a(Hash)
        expect(result[:price_per_share]).to eq(150.00)
        expect(result[:total_cost]).to eq(1500.00)
        expect(result[:new_balance]).to eq(500.00) # 2000 - 1500
        expect(result[:portfolio_id]).to be_present
      end
    end

    describe 'wallet helper method' do
      it 'returns user wallet' do
        receipt = Receipt.new(user: user, stock: stock)
        expect(receipt.wallet).to eq(user.wallet)
      end
    end

    describe 'transaction execution callback' do
      it 'executes transaction after receipt creation' do
        receipt = Receipt.new(
          user: user,
          stock: stock,
          transaction_type: 'buy',
          quantity: 10,
          price_per_share: 0,
          total_amount: 0
        )

        expect(receipt).to receive(:execute_transaction).and_call_original
        receipt.save!
      end
    end
  end
end
