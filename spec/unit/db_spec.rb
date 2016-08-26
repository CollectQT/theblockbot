describe "the database" do

  it "allows loading the seeds file twice", :vcr do
    load "#{Rails.root}/db/seeds.rb"
    load "#{Rails.root}/db/seeds.rb"
  end

end

