# Copyright, 2017, by Samuel G. D. Williams. <http://www.codeotaku.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require 'async/io/stream'

RSpec.describe Async::IO::Stream do
	let(:io) {StringIO.new}
	let(:stream) {Async::IO::Stream.new(io)}
	
	describe '#read' do
		it "should read everything" do
			io.puts "Hello World"
			io.seek(0)
			
			expect(stream.read).to be == "Hello World\n"
			expect(stream).to be_eof
		end
	end
	
	describe '#flush' do
		it "should not call write if write buffer is empty" do
			expect(io).to_not receive(:write)
			
			stream.flush
		end
		
		it "should flush underlying data when it exceeds block size" do
			expect(io).to receive(:write).and_call_original.once
			
			stream.block_size.times do
				stream.write("!")
			end
		end
	end
	
	describe '#read_partial' do
		it "should avoid calling read" do
			io.puts "Hello World" * 1024
			io.seek(0)
			
			expect(io).to receive(:read).and_call_original.once
			
			expect(stream.read_partial(11)).to be == "Hello World"
		end
	end
	
	describe '#write' do
		it "should read one line" do
			expect(io).to receive(:write).and_call_original.once
			
			stream.write "Hello World\n"
			stream.flush
			
			expect(io.string).to be == "Hello World\n"
		end
	end
end
