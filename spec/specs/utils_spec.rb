describe "send" do

  let(:args) { { user_id: 1, target_id: 2, report_id: 3, block_list_id: 4 } }
  let(:callback) { JSON.load JSON.dump ['create', args] }
  let(:model) { Block }

  it "calls a method on a model with the given arguments" do
    expect(model).to receive(callback[0]).with(callback[1])
    Utils.send(model, callback)
  end

end
