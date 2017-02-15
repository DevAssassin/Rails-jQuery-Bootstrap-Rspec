shared_examples_for "hot date" do |method|
  it "handles dates of format 'Jan 1, 2010'" do
    dateable.send("#{method}=", "Jan 1, 2010")

    dateable.send(method).should == Date.civil(2010, 1, 1)
  end

  it "handles dates of format '1/2/2010'" do
    dateable.send("#{method}=", "1/2/2010")

    dateable.send(method).should == Date.civil(2010, 1, 2)
  end

  it "handles dates of format '10/09/83'" do
    dateable.send("#{method}=", "10/09/83")

    dateable.send(method).should == Date.civil(1983, 10, 9)
  end

end
