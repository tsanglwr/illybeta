#app/views/sitemaps/index.xml.builder
base_url = "http://#{request.host_with_port}"
xml.instruct! :xml, :version=>'1.0'
xml.tag! 'urlset', 'xmlns' => 'http://www.sitemaps.org/schemas/sitemap/0.9' do
  xml.url{
    xml.loc("https://www.30secondpitch.io")
    xml.changefreq("weekly")
    xml.priority(1.0)
  }
  xml.url{
    xml.loc("https://www.30secondpitch.io/terms-of-use")
    xml.changefreq("weekly")
    xml.priority(0.9)
  }
  xml.url{
    xml.loc("https://www.30secondpitch.io/privacy-policy")
    xml.changefreq("weekly")
    xml.priority(0.9)
  }
end