path = File.expand_path('lib', File.dirname(__FILE__))
require 'logger'
$LOAD_PATH.unshift(path) unless $LOAD_PATH.include?(path)

require 'member_services_pb'

module GRPC
  def self.logger
    Logger.new(STDOUT)
  end
end

class ServiceHandler < MemberService::Service
  def load_member(requests, _other = nil)
    Enumerator.new do |yielder|
      requests.each do |request|
        puts "Request received: id = #{request.id}"
        amount = rand(1..15)
        puts "Response with #{amount}"
        amount.times do |n|
          sleep(1)
          yielder << MemberReply.new(
            name: "Member #{n} of ##{request.id}",
            email: "test#{n}-#{request.id}@gmail.com"
          )
        end
      end
    end
  end
end

server = GRPC::RpcServer.new
server.add_http2_port("localhost:50052", :this_port_is_insecure)
server.handle(ServiceHandler.new)
server.run_till_terminated
