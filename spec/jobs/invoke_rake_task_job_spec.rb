# frozen_string_literal: true

require "spec_helper"

describe InvokeRakeTaskJob do
  let!(:task) { Rake::Task.define_task("pokecode:probe") }

  before { allow(task).to receive(:invoke) }

  it "accepts string keys" do
    described_class.perform_now("task" => "pokecode:probe")
    expect(task).to have_received(:invoke)
  end

  it "accepts symbol keys" do
    described_class.perform_now(task: "pokecode:probe")
    expect(task).to have_received(:invoke)
  end

  it "passes the arguments to the task" do
    described_class.perform_now(task: "pokecode:probe", args: "12")
    expect(task).to have_received(:invoke).with("12")
  end
end
