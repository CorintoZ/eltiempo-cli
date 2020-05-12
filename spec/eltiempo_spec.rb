RSpec.describe Eltiempo do
  it "Town is incorrect" do
    argv = ["-today","IncorrectTown"]
    expect(Eltiempo::WeatherCLI.start(argv)).to output("The town IncorrectTown is not available or doesn't exist").to_stdout
  end
end
