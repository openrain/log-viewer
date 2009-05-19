#! /usr/bin/env ruby
#
# A simple sinatra application for benchmarking 
# web applications with bong: http://github.com/topfunky/bong
#
require 'rubygems'
require 'sinatra'

helpers do

  def benchmark_link name
    "<a href='/benchmarks/#{name}' title='#{name}'>#{name}</a><a href='/benchmarks/delete/#{name}' class='delete'>(delete)</a>"
  end

  def google_chart names, benchmarks
    url = "http://chart.apis.google.com/chart?cht=lc&chs=500x300&chtt=Benchmark+Results"
    url << "&chdl=#{ names.join('|') }&chdlp=b&chd=t:"

    max = 0

    paths = benchmarks[names.first]['localhost'].keys.sort
    names.each do |name|
      url << '|' unless name == names.first
      url << paths.map {|path|
        avg = benchmarks[name]['localhost'][path]['avg']
        max = avg.to_i unless max > avg.to_i
        avg
      }.join(',')
    end

    # give the chart a decent range
    url << "&chds=0,#{ max + 1 }"

    # generate random colors for each line
    url << '&chco='
    hex_values = "0123456789ABCDEF"
    names.each do |name|
      url << ',' unless name == names.first
      hex = ''
      3.times do
        hex << hex_values[( rand * hex_values.length ), 1] * 2
      end
      url << hex
    end

    html = "<div id='google'>"
    html << "<img src='#{ url }' />"
    html << "</div>"
    html
  end

  def gruff_chart names, benchmarks
    begin
      require 'gruff'
      require 'fileutils'

      # create chart
      g = Gruff::Line.new
      g.title = "Benchmark Results"
      paths = benchmarks[names.first]['localhost'].keys.sort
      names.each do |name|
        g.data name, paths.map {|path| benchmarks[name]['localhost'][path]['avg'] }
      end
      name = "benchmark_" + Time.now.strftime('%Y%m%d_%H%M%S') + '.png'
      path = options.public + '/' + name
      FileUtils.mkdir_p File.dirname(path)
      g.write path

      html = "<div id='gruff'>"
      html << "<img src='/#{ name }' />"
      html << "</div>"
      html

    rescue LoadError => ex
      "Problem building gruff chart.  Gruff/RMagick gems installed?"
    end
  end

end

get '/' do
  @benchmarks      = {}
  begin
    @benchmarks    = YAML.load_file 'log/httperf-report.yml'
  rescue Exception
  end 
  @benchmark_names = @benchmarks.keys.sort unless @benchmarks.empty?
  haml :index
end

get '/report' do
  @benchmark_names = params.select {|key,value| value == 'on' }.map {|key,value| key }.sort
  @benchmarks      = YAML.load_file 'log/httperf-report.yml'
  @paths           = []
  @benchmark_names.map {|name| @benchmarks[name]['localhost'].keys.sort.each { |path| 
    @paths << path unless @paths.include?(path)                     
  }}
  haml :report
end

get '/config' do
  @name   = 'bong Configuration'
  @output = File.read 'config/httperf.yml'
  haml :pre
end

get '/benchmarks/:name' do
  @name   = params['name']
  @output = `bong '#{ @name }' -r log/httperf-report.yml`
  haml :pre
end

get '/benchmarks/delete/:name' do
  name   = params['name']
  output = YAML.load_file 'log/httperf-report.yml'
  output.delete name
  File.open('log/httperf-report.yml', 'w'){|f| f << output.to_yaml }
  redirect '/'
end

get '/style.css' do
  headers['Content-Type'] = 'text/css'
  %[
    body {
      background-color: #ddd;
    }
    h2 {
      font-size: 1.0em;
    }
    #container {
      background-color: white;
      border: 1px solid black;
      border-width: 1px 2px 2px 1px;
      padding: 1em;
      margin: 1em;
    }
    a {
      text-decoration: none;
    }
    a:hover {
      text-decoration: underline;
    }
    a.delete {
      margin-left: 0.8em;
      font-size: 0.8em;
    }

    #nav {
      float: right;
    }
    #nav ul {
      margin: 0;
      padding: 0;
    }
    #nav li {
      display: inline;
    }

    ul {
      list-style-type: none;
    }
    #content li {
      margin-bottom: 0.5em;
    }

    #gruff, #google {
      margin: 1em;
    }
    #gruff img, #google img {
      max-width: 500px;
    }

    #google {
      float: right;
      position: relative;
      top: 50px;;
      right: 50px;
    }

    table {
       border: 1px solid #ccc;
    }
    th {
      font-size: 0.8em;
      border-bottom: 1px solid #ccc;
      padding-right: 1em;
    }
    td {
      border-right: 1px solid #ccc;
      margin: 0;
      padding: 0;
      padding-right: 0.3em;
      padding-left: 0.3em;
    }

    p.info {
      font-size: 0.8em;
    }
  ]
end

__END__

@@ index
%h1 Benchmarks
- if @benchmarks.empty?
  %p No benchmarks created yet, try running `rake benchmark`
-else
  %form{ :action => '/report', :method => 'get' }
    %ul
      - for name in @benchmark_names
        %li
          %input{ :type => 'checkbox', :name => name }
          = benchmark_link(name)
    %input{ :type => 'submit', :value => 'Compare Selected' }

@@ pre
%h1= @name
%pre= @output

@@ report
%h1 Report
%h2== Comparing: #{ @benchmark_names.join(', ') }
%p.info Numbers are the average reqs/second for a given path
%table

  %tr
    %th path
    - @benchmark_names.each do |name|
      %th= name

  - @paths.each do |path|
    %tr
      %td= path
      - @benchmark_names.each do |name|
        %td= @benchmarks[name]['localhost'][path]['avg']

= google_chart @benchmark_names, @benchmarks
= gruff_chart  @benchmark_names, @benchmarks

@@ layout
!!! XML
!!! Strict
%html
  %head
    %title== Benchmarking
    %link{ :rel => 'stylesheet', :type => 'text/css', :href => '/style.css' }
  %body
    #container
      #nav
        %ul
          %li
            %a{ :href => '/' } home
          %li
            %a{ :href => '/config' } config
      #content= yield
