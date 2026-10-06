# frozen_string_literal: true

require "rake"
Rails.application.load_tasks

class InvokeRakeTaskJob < ApplicationJob
  def perform(args)
    # Recurring tasks send symbol keys, perform_later with a plain hash sends strings
    args = args.with_indifferent_access
    Rake::Task[args[:task]].reenable
    Rake::Task[args[:task]].invoke(args[:args])
  end
end
