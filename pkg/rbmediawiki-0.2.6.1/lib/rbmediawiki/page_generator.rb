class Page_generator
    def initialize(site)
        @site = site
    end

    #gets pages alphabetically from a certain start point
    # * from: starting point (Default starts from the beginning)
    # * limit: pages to get per query (default: 500)
    # * prefix: Only list titles that start with this value
    # * namespace: The namespace to enumerate. By default, the main namespace will be enumerated
    # * How to filter redirects
    #   * all: List all pages regardless of their redirect flag (default)
    #   * redirects: Only list redirects
    #   * nonredirects: Don't list redirects
    # * minsize: Only list pages that are at least this many bytes in size
    # * maxsize: Only list pages that are at most this many bytes in size
    # * prtype: Only list pages that have been protected from this type of action
    #   * edit: Only list edit-protected pages
    #   * move: Only list move-protected pages
    # * prleve: Only list pages that have been protected at this level. Cannot be used without prtype
    #   * autoconfirmed: Only autoconfirmed users can edit/move/whatever
    #   * sysop: Only sysops can edit/move/whatever
    #   * Empty: Everyone can edit/move/whatever
    # * prfiltercascade: Filter protections based on cascadingness (ignored when apprtype isn't set) 
    #   * One value: cascading, noncascading, all
    #   * Default: all
    # *filterlanglinks: Filter based on whether a page has langlinks
    #   * One value: withlanglinks, withoutlanglinks, all
    #   * Default: all
    def all_pages(from = "!", limit = "500", prefix = nil, namespace = nil, filterredir = nil, minsize = nil, maxsize = nil, prtype = nil, prlevel = nil, prfiltercascade = nil, filterlanglinks = nil)
        pages = Hash.new
        count = 0
        finish = false
        while !finish
            result = @site.query_list_allpages(nil, from, prefix, namespace, filterredir, minsize, maxsize, prtype, prlevel, prfiltercascade, limit, nil, filterlanglinks)
            result['query']['allpages']['p'].each {|page|
                yield Page.new(page['title'], @site)
            }
            if result.key?('query-continue') 
                from = result['query-continue']['allpages']['apfrom']
            else
                finish = true
            end
        end
    end

    def linksearch(euquery, eulimit = 500, eunamespace = 0)
        pages = Hash.new
        count = 0
        finish = false
        euoffset = nil
        while !finish
            result = @site.query_list_exturlusage(nil, nil, euoffset, nil, euquery, eunamespace, eulimit)
            result['query']['exturlusage']['eu'].each {|page|
                yield Page.new(page['title'], @site)
            }
            if result.key?('query-continue') 
                euoffset = result['query-continue']['exturlusage']['euoffset']
            else
                finish = true
            end
        end
    end

    #Returns pages where eititle is transcluded in.
    #eilimit is the max results for query (default: 500)
    #einamespace is the namespace to work in
    def templateusage(eititle, eilimit = 500, einamespace = nil)
        pages = Hash.new
        finish = false
        eioffset = nil
        while !finish
            result = @site.query_list_embeddedin(nil, eititle, eioffset, einamespace, nil, eilimit)
            result['query']['embeddedin']['ei'].each {|page|
                yield Page.new(page['title'], @site)
            }
            if result.key?('query-continue') 
                eioffset = result['query-continue']['embeddedin']['eicontinue']
            else
                finish = true
            end
        end
    end
    def alllinks(alprefix, allimit = 500, alnamespace = nil)
        pages = Hash.new
        finish = false
        aloffset = nil
        while !finish
            result = @site.query_list_alllinks(nil, aloffset, nil, alprefix, nil, nil, nil, alnamespace, allimit, nil, nil, true)
            result['query']['alllinks']['l'].each {|page|
                yield Page.new(page['title'], @site)
            }
            if result.key?('query-continue') 
                euoffset = result['query-continue']['alllinks']['alcontinue']
            else
                finish = true
            end
        end
    end
    def backlinks(bltitle, bllimit = 500, blnamespace = nil, blfilterredir = nil)
        pages = Hash.new
        finish = false
        bloffset = nil
        while !finish
            result = @site.query_list_backlinks(nil, bltitle, bloffset, blnamespace, blfilterredir, bllimit, true )
            result['query']['backlinks']['bl'].each {|page|
                #TODO:code for dealing with redirects
       #         if page.key?('redirlinks')
       #             #checking probable double redirect
       #             if page['redirlinks'].key?('bl')
       #                 puts page
       #                 page['redirlinks']['bl'].each {|page2|
       #                     puts page2
       #                     yield Page.new(page2['title'], @site)
       #                 }
       #             end
       #         else
                    yield Page.new(page['title'], @site)
       #         end
            }
            if result.key?('query-continue') 
                bloffset = result['query-continue']['backlinks']['blcontinue']
            else
                finish = true
            end
        end
     
    end

    #TODO
    #opensearch
    #prop links
    #prop langlinks?
    #prop images
    #prop templates
    #prop categories
    #prop extlinks
    #list allimages
    #list allcategories
    #list allusers
    #list blocks
    #list categorymembers
    #list deletedrevs
    #list imageusage
    #list logevents
    #list recentchanges
    #list search
    #list usercontribs
    #list watchlist
    #list exturlusage
    #list users
    #list random
    #list protectedtitles
    #list globalblocks
end
