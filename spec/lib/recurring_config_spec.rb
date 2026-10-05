# frozen_string_literal: true

require "spec_helper"
require "fugit"

module Decidim
  describe Pokecode do
    let(:tasks) { ActiveSupport::ConfigurationFile.parse(described_class::Engine.root.join("files/config/recurring.yml")).fetch("production") }
    let(:rake_tasks) { tasks.values.select { |options| options["class"] == "InvokeRakeTaskJob" }.map { |options| options["args"].first["task"] } }
    let(:sidekiq_tasks) { ActiveSupport::ConfigurationFile.parse(described_class::Engine.root.join("files/config/schedule.yml")) }
    let(:sidekiq_rake_tasks) { sidekiq_tasks.values.map { |options| options["args"]["task"] } }

    # Loading the job also loads the rake tasks
    before { InvokeRakeTaskJob.name }

    it "defines a valid schedule for every recurring task" do
      tasks.each do |key, options|
        expect(Fugit.parse(options["schedule"])).to be_a(Fugit::Cron), "#{key} has no valid schedule"
      end
    end

    it "defines a job class or a command for every recurring task" do
      tasks.each do |key, options|
        expect(options["class"] || options["command"]).to be_present, "#{key} has nothing to run"
      end
    end

    it "only invokes existing rake tasks" do
      expect(rake_tasks).not_to be_empty
      rake_tasks.each do |name|
        expect(Rake::Task.task_defined?(name)).to be(true), "#{name} is not defined"
      end
    end

    it "schedules the same rake tasks for Sidekiq and Solid Queue" do
      expect(sidekiq_rake_tasks).to match_array(rake_tasks)
    end

    it "can disable a recurring task with an ENV var" do
      allow(ENV).to receive(:fetch).and_call_original
      allow(ENV).to receive(:fetch).with("EXPORT_OPEN_DATA", "enabled").and_return("disabled")
      expect(tasks.keys).not_to include("daily_open_data_job")
      expect(tasks.keys).to include("daily_reminders_job")
    end
  end
end
