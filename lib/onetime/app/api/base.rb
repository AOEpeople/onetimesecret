require 'onetime/app/helpers'

class Onetime::App
  class API
    module Base
      include Onetime::App::Helpers
      
      def publically
        carefully do 
          yield
        end
      end
      
      # curl -F 'ttl=7200' -u 'EMAIL:APIKEY' http://LOCALHOSTNAME:7143/api/v1/generate
      def authorized allow_anonymous=false
        carefully do 
          success = false
          req.env['otto.auth'] ||= Rack::Auth::Basic::Request.new(req.env)
          auth = req.env['otto.auth']
          #req.env['HTTP_X_ONETIME_CLIENT']
          if auth.provided?
            raise Unauthorized unless auth.basic?
            custid, apitoken = *(auth.credentials || [])
            raise Unauthorized if custid.to_s.empty? || apitoken.to_s.empty?
            possible = OT::Customer.load custid
            raise Unauthorized if possible.nil?
            @cust = possible if possible.apitoken?(apitoken)
            unless cust.nil? || @sess = cust.load_session 
              @sess = OT::Session.create req.client_ipaddress, cust.custid
            end
            sess.authenticated = true unless sess.nil?
          elsif req.cookie?(:sess) && OT::Session.exists?(req.cookie(:sess))
            #check_session!
            raise Unauthorized, "No session support"
          elsif !allow_anonymous
            raise Unauthorized, "No session or credentials"
          else
            @cust = OT::Customer.anonymous
            @sess = OT::Session.new req.client_ipaddress, cust.custid
          end
          if cust.nil? || sess.nil? #|| cust.anonymous? && !sess.authenticated?
            raise Unauthorized, "[bad-cust] '#{custid}' via #{req.client_ipaddress}"
          else
            cust.sessid = sess.sessid unless cust.anonymous?
            yield
          end
        end
      end
      
      def json hsh
        res.header['Content-Type'] = "application/json; charset=utf-8"
        res.body = hsh.to_json
      end
      
      def handle_form_error ex, redirect
        error_response ex.message
      end
      
      def secret_not_found_response
        not_found_response "Unknown secret", :secret_key => req.params[:key]
      end
      
      def not_found_response msg, hsh={}
        hsh[:message] = msg
        res.status = 404
        json hsh
      end
    
      def error_response msg, hsh={}
        hsh[:message] = msg
        res.status = 404
        json hsh
      end
      
    end
  end
end