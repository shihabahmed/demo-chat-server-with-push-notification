fslib = require 'fs'

exports.generateCertificate = (ssl)->
  ca = []
  chain = fslib.readFileSync ssl.ca, 'utf8'
  chain = chain.split '\n'
  cert = []
  for line in chain when line.length isnt 0
    cert.push line
    if line.match /-END CERTIFICATE-/
      ca.push cert.join "\n"
      cert = []

  hskey = fslib.readFileSync ssl.key
  hscert = fslib.readFileSync ssl.cert
  options = 
    ca: ca
    key: hskey
    cert: hscert