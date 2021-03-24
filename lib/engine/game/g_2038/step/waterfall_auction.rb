# frozen_string_literal: true

require_relative '../../../step/waterfall_auction'

module Engine
  module Game
    module G2038
      module Step
        class WaterfallAuction < Engine::Step::WaterfallAuction

          def may_purchase?(company)
            return false unless super
            return true if @purchasing_first_minor

            !is_minor?(company)
          end

          def min_bid(company)
            return unless company
            return company.min_bid if may_purchase?(company)

            high_bid = highest_bid(company)
            high_bid ? high_bid.price + min_increment : company.min_bid
          end

          def bid_str(company)
            !auctioning && company && is_minor?(company) && company == @companies.first ? 'Buy' : 'Place Bid'
          end

          def placement_bid(bid)
            @purchasing_first_minor = bid.company && bid.company == @companies.first
            super
            @purchasing_first_minor = false
          end

          def is_minor?(company)
            @game.minors.find { |m| m.id == company.id }
          end

          def resolve_bids
            super
            return if @unbid_companies.empty?
            @companies.concat(@unbid_companies)
            @unbid_companies = []
          end

          def all_passed!
            @companies, @unbid_companies = @companies.partition do |company|
              !@bids[company].empty?
            end

            resolve_bids

            @game.payout_companies
            @game.or_set_finished
        
            entities.each(&:unpass!)
          end
        end
      end
    end
  end
end
