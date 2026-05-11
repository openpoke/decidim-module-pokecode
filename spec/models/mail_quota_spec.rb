# frozen_string_literal: true

require "spec_helper"

module Decidim::Pokecode
  describe MailQuota do
    let(:redis) { instance_double(Redis) }
    let(:now) { Time.zone.local(2024, 6, 15, 12, 0, 0) }

    before do
      allow(Redis).to receive(:new).and_return(redis)
      allow(Time).to receive(:current).and_return(now)
    end

    describe "#daily_key" do
      it "returns a key scoped to the current date" do
        expect(subject.daily_key).to eq("decidim:pokecode:mail_quota:daily:2024-06-15")
      end
    end

    describe "#monthly_key" do
      it "returns a key scoped to the current year-month" do
        expect(subject.monthly_key).to eq("decidim:pokecode:mail_quota:monthly:2024-06")
      end
    end

    describe "#daily_count" do
      it "returns the integer value stored in Redis for the daily key" do
        allow(redis).to receive(:get).with(subject.daily_key).and_return("42")
        expect(subject.daily_count).to eq(42)
      end

      it "returns 0 when the key does not exist" do
        allow(redis).to receive(:get).with(subject.daily_key).and_return(nil)
        expect(subject.daily_count).to eq(0)
      end
    end

    describe "#monthly_count" do
      it "returns the integer value stored in Redis for the monthly key" do
        allow(redis).to receive(:get).with(subject.monthly_key).and_return("250")
        expect(subject.monthly_count).to eq(250)
      end

      it "returns 0 when the key does not exist" do
        allow(redis).to receive(:get).with(subject.monthly_key).and_return(nil)
        expect(subject.monthly_count).to eq(0)
      end
    end

    describe "#increment!" do
      let(:pipeline) { double("Redis::Pipeline") } # rubocop:disable RSpec/VerifiedDoubles

      before do
        allow(redis).to receive(:multi).and_yield(pipeline)
        allow(pipeline).to receive(:incr)
        allow(pipeline).to receive(:expireat)
      end

      it "increments the daily counter" do
        subject.increment!
        expect(pipeline).to have_received(:incr).with(subject.daily_key)
      end

      it "increments the monthly counter" do
        subject.increment!
        expect(pipeline).to have_received(:incr).with(subject.monthly_key)
      end

      it "sets the daily TTL to end of day" do
        subject.increment!
        expect(pipeline).to have_received(:expireat).with(subject.daily_key, now.end_of_day.to_i)
      end

      it "sets the monthly TTL to end of month" do
        subject.increment!
        expect(pipeline).to have_received(:expireat).with(subject.monthly_key, now.end_of_month.to_i)
      end
    end
  end
end
