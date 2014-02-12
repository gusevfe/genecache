require 'spec_helper'

describe GeneCache do
  it "does the job" do 
    r = GeneCache.convert('biodb:hsa', 'ensg_id', 'omim_id', 'ENSG00000142192') # APP
    expect(r.sort).to eq(%w{104300 104760 605714}.sort)
  end

  it "does the job with MGI" do 
    r = GeneCache.convert('mgi', 'mgi_accession', 'mgi_symbol', '87853') 
    expect(r.sort).to eq(%w{a}.sort)

    r = GeneCache.convert('mgi', 'mgi_accession', 'ensembl_id', '87853')
    expect(r.sort).to eq(%w{ENSMUSG00000027596}.sort)
  end
end
