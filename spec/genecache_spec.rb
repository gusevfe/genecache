require 'spec_helper'

describe GeneCache do
  it "does the job" do 
    r = GeneCache.convert('hsa', 'ensg_id', 'omim_id', 'ENSG00000142192') # APP
    expect(r.sort).to eq(%w{104300 104760 605714}.sort)
  end
end
