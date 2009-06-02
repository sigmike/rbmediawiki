#TODO: rollback
#TODO: patrol

#This class represents a page. It gives methods for dealing with single
#pages: obtainig the content, putting it, appending content, deleting, etc.
class Page
    attr_reader :title
    def initialize(title = nil, site = nil)
        @site = site ? site : Api.new()
        @title = title
        @normtitle = title.gsub(" ","_")
    end

    #retrieves the content of the page
    def get()
        result = @site.query_prop_revisions(@normtitle, 'content')
        if result.key?('error')
            raise RbmediawikiError, "#{title}: "+result['error']['code']
        else
            return result['query']['pages']['page']['revisions']['rev']
        end
    end

    #returns false if it is not a redirect, the redirected title if it is
    def redirect?()
        txt = this.get
        if (txt =~ /#REDIRECT\s+\[\[(.*)\]\]/)
            return $1
        else
            return false
        end
    end

    #puts the text of a page.
    # * text: the new content of the page
    # * summary: editting summary
    # * minor: is a minor edit? default->true
    # * bot: is a bot flagged edit?
    def put(text, summary = nil, minor = true, bot = true, password = nil)
        #require login
        @site.login(password)
        result = @site.query_prop_info(@normtitle, nil, 'edit') 
        token = result['query']['pages']['page']['edittoken']
        result = @site.edit(@normtitle, nil, text, token, summary, minor, nil, bot)
        if result.key?('error')
            raise RbmediawikiError, "#{title}: "+result['error']['code']
        else
            return true
        end
        puts "content put"
    end

    #appends texto to a page
    #same as #put, but the text is appended and the previous content preserved
    def append(text, summary = nil, minor = true, bot = true)
        #require login
        @site.login
        puts text
        result = @site.query_prop_info(@normtitle, nil, 'edit')    
        token = result['query']['pages']['page']['edittoken']
        result = @site.edit(@normtitle, nil, text, token, summary, minor, nil, bot, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, text)
        if result.key?('error')
            raise RbmediawikiError, "#{title}: "+result['error']['code']
        else
            return true
        end
    end

    #prepends text to a page
    #same as #put, but the text is prepended and the previous content preserved
    def prepend(text, summary = nil, minor = true, bot = true)
        #require login
        @site.login
        result = @site.query_prop_info(@normtitle, nil, 'edit')    
        token = result['query']['pages']['page']['edittoken']
        result = @site.edit(@normtitle, nil, text, token, summary, minor, nil, bot, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, text)
        if result.key?('error')
            raise RbmediawikiError, "#{title}: "+result['error']['code']
        else
            return true
        end
    end

    #adds a section to a page
    #same as #append, but is a section what is appended. 
    #title is the title of the new section
    def addsection(text, title, minor = false, bot = true)
        #require login
        @site.login
        result = @site.query_prop_info(@normtitle, nil, 'edit')    
        token = result['query']['pages']['page']['edittoken']
        result = @site.edit(@normtitle, section, text, token, title, minor, nil, bot) 
        if result.key?('error')
            raise RbmediawikiError, "#{title}: "+result['error']['code']
        else
            return true
        end
    end

    #moves a page 
    # * reason: reason or summary
    # * movetalk: move talk pages too (default->true)
    # * noredirect: don't leave a redirect (default->nil)
    def move(to, reason = nil, movetalk = true, noredirect = nil) 
        #require login
        @site.login
        result = @site.query_prop_info(@normtitle, nil, 'move') 
        token = result['query']['pages']['page']['movetoken']
        result = @site.move(@normtitle, nil, to, token, reason, movetalk, nil, noredirect)
        if result.key?('error')
            raise RbmediawikiError, "#{title}: "+result['error']['code']
        else
            return true
        end
    end
    
    #protects a page.
    #reason is the reason for the protection
    #expiry is a timescamp (default is infinite).
    #protections is the action and group that can perform that action, separated
    #by pipes. Exapmple "edit=sysop|move=autoconfirmed".Default is edit=sysop|move=sysop
    def protect(reason = nil, expiry = 'infinite', protections = 'edit=sysop|move=sysop') 
        #require login
        @site.login
        result = @site.query_prop_info(@normtitle, nil, 'protect') 
        token = result['query']['pages']['page']['protecttoken']
        result = @site.protect(@normtitle, token, protections, expiry, reason)
        if result.key?('error')
            raise RbmediawikiError, "#{title}: "+result['error']['code']
        else
            return true
        end
    end
    
    #semipotects a page.
    #is the same as protect, but default for protections is "edit=autoconfirmed|move=autoconfirmed"
    def semiprotect(reason = nil, expiry = 'infinite') 
        protect(reason, expiry, 'edit=autoconfirmed|move=autoconfirmed')
        #possible errors: user doesn't have privileges
    end

    #delete the page.
    #reason : reason for deleting
    #returns true if success, raises NoPage if page doesn't exist
    def delete(reason="")
        @site.login
        result = @site.query_prop_info(@normtitle, nil, 'delete') 
        token = result['query']['pages']['page']['deletetoken']
        result = @site.delete(@normtitle, nil, token, reason)
        if result.key?('error')
            raise RbmediawikiError, "#{@title}: "+result['error']['code']
        else
            return true    
        end
    end

    #undeletes a page.
    #reason: reason for deleting
    #returns true if success, false if there aren't deleted revisions
    
    def undelete(reason="")
        @site.login
        result = @site.query_list_deletedrevs(@normtitle, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, 'token') 
        if result.key?('error')
            raise RbmediawikiError, "#{@title}: "+result['error']['code']
        end
        if !result.has_key?('deletedRevs')
            return false
        end
        token = result['query']['deletedrevs']['page']['token']
        result = @site.undelete(@normtitle, token, reason)
        return true    
    end
   
    #rollback (revert) editr by user. Summary can be given
    def rollback(user = nil, summary = nil, markbot = nil)
        @site.login
        result = @site.query_prop_revisions(@normtitle, nil, nil, nil, nil, nil, nil, nil, user, nil, nil, nil, nil, 'rollback') 
        #Page exists?
        if result['query']['pages']['page'].key?('missing')
            raise NoPage, "Page [[#{@title}]] does not exist"
        end
        #Has user edited this?
        if !result['query']['pages']['page'].key?('revisions')
            raise RbmediawikiError, "#{@title}: No edits by user #{user}"
        end

        #If the user made more than one contribs, this is an array
        #but the token is the same. We only want the token
        if result['query']['pages']['page']['revisions']['rev'].is_a? Array
            token = result['query']['pages']['page']['revisions']['rev'][0]['rollbacktoken']
        else
            token =  result['query']['pages']['page']['revisions']['rev']['rollbacktoken']
        end
        result = @site.rollback(@normtitle, user, token, summary, markbot)
        if result.key?('error')
            raise RbmediawikiError, "#{@title}: "+result['error']['code']
        else
            return true    
        end
    end

    #gets info about the protections of a page. Returns an array as for instance
    #{level => sysop,type => edit,expiry => infinity}
    #{level => sysop,type => move,expiry => infinity}
    def protected?()
        result = @site.query_prop_info(@normtitle, 'protection')
        if result.key?('error')
            raise RbmediawikiError, "#{@title}: "+result['error']['code']
        end
        if result['query']['pages']['page'].key?('missing')
            raise NoPage, "Page [[#{@title}]] does not exist"
 
        else
            return result['query']['pages']['page']['protection']['pr']
        end
    end


     #not working in r1.9
#    #get interwiki links
#    #min is the minimum number of elements to return, lllimit is the number of
#    #elements to request from the API in each iteration. The method will 
#    #request elements until it has at least min elements.
#    #returns false if there aren't any, and raises NoPage if page doesn't exist
#    def get_interwikis(min = nil, lllimit = 500)
#        llcontinue = nil
#        iws = Hash.new
#        count = 0
#        loop {
#            result = @site.query_prop_langlinks(@normtitle, lllimit, llcontinue)
#            iws.deep_merge!(result['query'])
#            if result.key?('query-continue') && min && count < min
#                count += lllimit
#                llcontinue = result['query-continue']['langlinks']['llcontinue']
#            else
#                break
#            end
#        }
#        if iws['pages']['page'].key?('missing')
#            raise NoPage.new(), "Page [[#{title}]] does not exist"
#        elsif iws['pages']['page'].key?('langlinks')
#            return iws['pages']['page']['langlinks']['ll']
#        else return false
#        end
#    end
#    
#    #gets image links of a page
#    #min is the minimum number of elements to return, imlimit is the number of
#    #elements to request from the API in each iteration. The method will 
#    #request elements until it has at least min elements.
#    #returns false if there aren't any, and raises NoPage if page doesn't exist
#    def get_images(min = nil, imlimit = 500)
#        imcontinue = nil
#        ims = Hash.new
#        count = 0
#        loop {
#            result = @site.query_prop_images(@normtitle, imlimit, imcontinue)
#            ims.deep_merge!(result['query'])
#            if result.key?('query-continue') && min && count < min
#                count += lllimit
#                imcontinue = result['query-continue']['images']['imcontinue']
#            else
#                break
#            end
#        }
#        if ims['pages']['page'].key?('missing')
#            raise NoPage.new(), "Page [[#{@title}]] does not exist"
#        elsif ims['pages']['page'].key?('images')
#            return ims['pages']['page']['images']['im']
#        else return false
#        end
#    end
#
#    #gets templates used in a page
#    #min is the minimum number of elements to return, tllimit is the number of
#    #elements to request from the API in each iteration. The method will 
#    #request elements until it has at least min elements.
#    #returns false if there aren't any, and raises NoPage if page doesn't exist
#    def get_templates(min = nil, tllimit = 500)
#        tlcontinue = nil
#        tls = Hash.new
#        count = 0
#        loop {
#            result = @site.query_prop_templates(@normtitle, nil, tllimit, tlcontinue)
#            tls.deep_merge!(result['query'])
#            if result.key?('query-continue')&& min && count < min
#                count += lllimit
#                tlcontinue = result['query-continue']['templates']['tlcontinue']
#            else
#                break
#            end
#        }
#        if tls['pages']['page'].key?('missing')
#            raise NoPage.new(), "Page [[#{@title}]] does not exist"
#        elsif tls['pages']['page'].key?('templates')
#            return tls['pages']['page']['templates']['tl']
#        else return false
#        end
#    end
#    
    #gets templates used in a page
    #min is the minimum number of elements to return, cllimit is the number of
    #elements to request from the API in each iteration. The method will 
    #request elements until it has at least min elements.
    #clshow can be "hidden" or "!hidden". Default shows both
    #if sortkey is true will return the sortkey. Default is true
    def get_categories(min = nil, cllimit = 500, clshow = nil, sortkey = true)
        clcontinue = nil
        cls = Array.new
        count = 0

        if sortkey 
            clprop = "sortkey"
        end

        loop {
            result = @site.query_prop_categories(@normtitle, clprop, clshow, cllimit, clcontinue)
            if result['query']['pages']['page'].key?('missing')
                raise NoPage.new(), "Page [[#{@title}]] does not exist"
            end
            page = result['query']['pages']['page']
            if page['categories']['cl'].is_a? Array
                cls = cls + page['categories']['cl']
            else
                cls.push(page['categories']['cl'])
            end

            if result.key?('query-continue')&& min && count < min
                count += lllimit
                clcontinue = result['query-continue']['categories']['clcontinue']
            else
                break
            end
        }
        return cls
    end
#
#    #gets external links used in a page
#    #min is the minimum number of elements to return, ellimit is the number of
#    #elements to request from the API in each iteration. The method will 
#    #request elements until it has at least min elements.
#    #returns false if there aren't any, and raises NoPage if page doesn't exist
#    def get_external_links(min = nil, ellimit = 500)
#        eloffset = nil
#        els = Hash.new
#        count = 0
#        loop {
#            result = @site.query_prop_extlinks(@normtitle, ellimit, eloffset)
#            els.deep_merge!(result['query'])
#            if result.key?('query-continue')&& min && count < min
#                count += lllimit
#                eloffset = result['query-continue']['extlinks']['elcontinue']
#            else
#                break
#            end
#        }
#        if els['pages']['page'].key?('missing')
#            raise NoPage.new(), "Page [[#{@title}]] does not exist"
#        elsif els['pages']['page'].key?('extlinks')
#            return els['pages']['page']['extlinks']['el']
#        else return false
#        end
#    end
#    
    #gets backlinks (what links here) used in a page
    #min is the minimum number of elements to return, bllimit is the number of
    #elements to request from the API in each iteration. The method will 
    #request elements until it has at least min elements.
    #returns false if there aren't any, and raises NoPage if page doesn't exist

    def get_backlinks(bllimit = 500, blnamespace = nil, blredirect = true)
        blcontinue = nil
        bls = Array.new
        loop {
            result = @site.query_list_backlinks(@normtitle, @normtitle, blcontinue, blnamespace, nil, bllimit, blredirect)
            if result['query']['pages']['page'].key?('missing')
                raise NoPage.new(), "Page [[#{@title}]] does not exist"
            end
            if result['query']['backlinks']['bl'].is_a? Array
                bls = bls + result['query']['backlinks']['bl']
            else
                bls.push(result['query']['backlinks']['bl'])
            end
            if result.key?('query-continue')
                blcontinue = result['query-continue']['backlinks']['blcontinue']
            else
                break
            end
        }
        return bls
    end


#    #gets deleted revisions of a page
#    #min is the minimum number of elements to return, drlimit is the number of
#    #elements to request from the API in each iteration. The method will 
#    #request elements until it has at least min elements.
#    #returns false if there aren't any
#    def get_deletedrevs(min = nil, drlimit = 500)
#        @site.login
#        drcontinue = nil
#        drs = Hash.new
#        count = 0
#        loop {
#            result = @site.query_list_deletedrevs(@normtitle, nil, nil, nil, nil, nil, nil, drcontinue, nil, nil, nil, nil, drlimit)
#            drs.deep_merge!(result['query'])
#            if result.key?('query-continue')&& min && count < min
#                count += lllimit
#                drcontinue = result['query-continue']['deletedrevs']['drstart']
#            else
#                break
#            end
#        }
#        if drs['deletedrevs'].key?('page')
#            return drs['deletedrevs']['page']['revisions']['rev']
#        else return false
#        end
#    end
#
#    #gets pages in which this page is embedded (or transcluded). Returns a list
#    #of Page elements
#    #min is the minimum number of elements to return, eilimit is the number of
#    #elements to request from the API in each iteration. The method will 
#    #request elements until it has at least min elements.
#    #returns false if there aren't any, and raises NoPage if page doesn't exist
#    def get_embeddedin(min = nil, eilimit = 500)
#        eicontinue = nil
#        eis = Hash.new
#        count = 0
#        loop {
#            result = @site.query_list_embeddedin(@normtitle, @normtitle, eicontinue, nil, nil, eilimit)
#            eis.deep_merge!(result['query'])
#            if result.key?('query-continue')&& min && count < min
#                count += lllimit
#                eicontinue = result['query-continue']['embeddedin']['eicontinue']
#            else
#                break
#            end
#        }
#        if eis['pages']['page'].key?('missing')
#            raise NoPage.new(), "Page [[#{@title}]] does not exist"
#        elsif eis['embeddedin'].key?('ei')
#            members = Array.new
#            eis['embeddedin']['ei'].each{|el| members.push(Page.new(el['title']))}
#            return members
#        else return false
#        end
#    end
#
#    #returns the size of the page content in bytes
#    #Raises NoPage if the page doesn't exist
#    def get_size
#        result = @site.query_prop_info(@normtitle)
#        if result['query']['pages']['page'].key?('missing')
#            raise NoPage.new(), "Page [[#{@normtitle}]] does not exist"
#        else
#            return result['query']['pages']['page']['length']
#        end
#    end

end

class NoPage < RuntimeError
end

class PageExists < RuntimeError
end

class RbmediawikiError < RuntimeError
end
