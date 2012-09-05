#
#  AppDelegate.rb
#  liblize
#
#  Created by 正栄 比嘉 on 12/09/05.
#  Copyright 2012年 __MyCompanyName__. All rights reserved.
#
require 'socket'

$kCGSessionEventTap = 1

class AppDelegate
    attr_accessor :window, :textField, :button, :log
    
    def applicationDidFinishLaunching(a_notification)
        # Insert code here to initialize your application
    end
    
    def startOrStop(sender)
        if button.title == "start"
            @run = true
            
            button.title = "stop"
            port = textField.stringValue.to_i
            
            @server = UDPSocket.new
            @server.bind(Socket::INADDR_ANY, port)
            
            @thread = Thread.start {
                begin
                    loop {
                        begin
                            isbn, sender = @server.recvfrom_nonblock(4096)
                            appendLog(isbn)
                            isbn.split('').each {|c|
                                keyPress c
                            }
                            puts "isbn: #{isbn}"
                        rescue => e
                        end
                        
                        break if @server.closed?
                    }
                ensure
                    button.title = "start"
                    appendLog("server stopped")
                end
            }
            
            appendLog("server start at #{port}")
        else
            @server.close
            Thread.kill(@thread) unless @thread.stop?
        end
    end
    
    private
    
    def appendLog(str)
        prev = log.string
        log.setString "#{str}\n#{prev}"
    end
    
    def keyCodeFromChar(char)
        {
            "0" => 29,
            "1" => 18,
            "2" => 19,
            "3" => 20,
            "4" => 21,
            "5" => 23,
            "6" => 22,
            "7" => 26,
            "8" => 28,
            "9" => 25,
        }[char]
    end
    
    def keyPress(char)
        puts "keyPress #{char}"
        keyCode = keyCodeFromChar(char) or return
        
        ev = CGEventCreateKeyboardEvent(nil, keyCode, true)
        CGEventPost $kCGSessionEventTap, ev
        CFRelease ev
        
        ev = CGEventCreateKeyboardEvent(nil, keyCode, false)
        CGEventPost $kCGSessionEventTap, ev
        CFRelease ev  
    end
end

