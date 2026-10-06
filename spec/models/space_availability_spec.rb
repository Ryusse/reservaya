require 'rails_helper'

RSpec.describe Space, type: :model do
  describe "#availability_blocks" do
    let(:space) { create(:space, start_time: "08:00", end_time: "18:00", capacity: 10, space_type: :shared_space) }
    let(:date) { Date.tomorrow }

    context "when no reservations exist" do
      it "returns a single free block for the whole day" do
        blocks = space.availability_blocks(date)
        expect(blocks.length).to eq(1)
        expect(blocks.first).to include(
          start_time: "08:00",
          end_time: "18:00",
          status: "free",
          seats_available: 10
        )
      end
    end

    context "with a reservation in the middle" do
      before do
        create(:reservation, space: space, date: date, start_time: "10:00", end_time: "12:00", seats_reserved: 4)
      end

      it "returns three blocks: free, partial, free" do
        blocks = space.availability_blocks(date)
        expect(blocks.length).to eq(3)
        
        expect(blocks[0]).to include(start_time: "08:00", end_time: "10:00", status: "free", seats_available: 10)
        expect(blocks[1]).to include(start_time: "10:00", end_time: "12:00", status: "partial", seats_available: 6)
        expect(blocks[2]).to include(start_time: "12:00", end_time: "18:00", status: "free", seats_available: 10)
      end
    end

    context "with overlapping reservations filling the space" do
      before do
        create(:reservation, space: space, date: date, start_time: "09:00", end_time: "11:00", seats_reserved: 6)
        create(:reservation, space: space, date: date, start_time: "10:00", end_time: "12:00", seats_reserved: 4)
      end

      it "calculates capacity correctly for the overlapping period" do
        blocks = space.availability_blocks(date)
        
        # 08:00-09:00 -> free (10)
        # 09:00-10:00 -> partial (4) [6 reserved]
        # 10:00-11:00 -> full (0) [10 reserved]
        # 11:00-12:00 -> partial (6) [4 reserved]
        # 12:00-18:00 -> free (10)
        
        expect(blocks.find { |b| b[:start_time] == "10:00" }).to include(
          end_time: "11:00", status: "full", seats_available: 0
        )
      end
    end
  end
end
