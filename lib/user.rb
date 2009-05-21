require 'deep_merge'

require 'api'
require 'page'

class User
    attr_reader :name
    def initialize(name = nil, site = nil)
        @username = name.gsub(" ","_")
        @site = site
    end

    #blocks the user with the given reason
    #the params are the usual block options
    def block(expiry, reason, anononly = true, nocreate = true, autoblock = true, noemail = false, allowusertalk = true, reblock = false)
        #require login
        @site.login
        result = @site.query_prop_info(@username, nil, 'block') 
        token = result['query']['pages']['page']['blocktoken']
        result = @site.block(@username, token, nil, expiry, reason, anononly, nocreate, autoblock, noemail, nil, allowusertalk, reblock)
        if result.key?('error')
            raise RbykimediaError, "#{@username}: "+result['error']['code']
        else
            return true
        end
    end

    #unblocks the user
    def unblock(reason)
        #require login
        @site.login
        result = @site.query_prop_info(@username, nil, 'unblock') 
        token = result['query']['pages']['page']['unblocktoken']
        result = @site.unblock(nil, @username, token, nil, reason)
        if result.key?('error')
            raise RbykimediaError, "#{@username}: "+result['error']['code']
        else
            return true
        end
    end

    #write a message in the user's talk page
    def write_msg(msg, summary = nil)
        page = Page.new("User talk:"+@username, @site)
        return page.append(msg, summary, false)
    end

    #write an email to the user
    def write_email(subject, text, ccme = nil)
        #require login
        @site.login
        result = @site.query_prop_info(@username, nil, 'email') 
        puts result
        token = result['query']['pages']['page']['emailtoken']
        result = @site.emailuser(@username, subject, text, token, ccme) 
        if result.key?('error')
            raise RbykimediaError, "#{@username}: "+result['error']['code']
        else
            return true
        end
    end

    #info about the user
    def info
        result = @site.query_list_users(nil, "blockinfo|groups|editcount|registration|emailable", @username)
        if result.key?('error')
            raise RbykimediaError, "#{@username}: "+result['error']['code']
        else
            return result
        end
    end

    #get user contributions
    #returns false if there aren't any
    def get_usercontribs(uclimit = 500, ucstart = nil, ucnamespace = nil)
        uccontinue = nil
        ucs = Hash.new
        puts ucstart
        loop {
            result = @site.query_list_usercontribs(nil, uclimit, ucstart, nil, uccontinue, @username, nil, "newer", ucnamespace)
            ucs.deep_merge!(result['query'])
            if result.key?('query-continue')
                ucstart = result['query-continue']['usercontribs']['ucstart']
            else
                break
            end
        }
        if ucs['usercontribs'].key?('item')
            return ucs['usercontribs']['item']
        else 
            return false
        end
    end

    #rollbacks (reverts) all edits by the user since a given time.
    #"since" is a timestamp. Default will rollback everything.
    #"namespace", if set, restricts the rollback to the given namespace
    def rollback(since = nil, namespace = nil)
        contribs = get_usercontribs(nil, since, nil)
        array_c = Array.new
        puts array_c
        contribs.each{|c| array_c.push(c['title'])}
        array_c.uniq!
        puts array_c
        array_c.each{|p| 
            page = Page.new(p, @site)
            begin
            page.rollback(@username, "desde aquí", false)
            rescue RbykimediaError => error
                puts error
            end
        }
    end
end
