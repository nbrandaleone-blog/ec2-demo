# ec2-demo
## Code from my blog on Haskell and AWS.
## See:

$ stack build

$ stack exec ec2-demo-exe
[instance:i-01c05962b28857085] {
  public-dns = Just ec2-54-71-143-215.us-west-2.compute.amazonaws.com
  tags       = [Tag' {_tagKey = "costCenter", _tagValue = "testing"},Tag' {_tagKey = "Name", _tagValue = "development"}]
  state      = running
}
[instance:i-0502327be319b7d92] {
  public-dns = Just ec2-34-208-83-214.us-west-2.compute.amazonaws.com
  tags       = [Tag' {_tagKey = "owner", _tagValue = "Nick"}]
  state      = running
}

