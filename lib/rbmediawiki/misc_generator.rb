#coding: utf-8

class Misc_generator
    def initialize(site)
        @site = site
    end

    #returns revisions of a page
    # * titles: the page
    # * rvlimit: how many revisions retrieve by query (default: 50, max: 50)
    # * rvprop: fields to retrieve (default: all)
    # * rvstartid: id of the revision to start
    # * rvendid: id of the revision to end 
    # * rvdir: older or newer. Defaulr: older.
    # * rvuser: only get revisions by user.
    # * diffto: Revision ID to diff each revision to.  Use "prev", "next" and "cur" for the previous, next and current revision respectively.


    def history( titles, rvlimit = 50, rvprop = "ids|timestamp|flags|comment|user|size|content", rvstartid = nil, rvendid = nil, rvdir = "older", rvuser = nil, diffto = "prev")
        pages = Hash.new
        finish = false
        while !finish
            result = @site.query_prop_revisions(titles, rvprop, rvlimit, rvstartid, rvendid, nil, nil, rvdir, rvuser, nil, nil, nil, nil, nil, nil, diffto )
            result['query']['pages']['page']['revisions']['rev'].each {|rv|
                puts rv
                yield rv
            }
            if result.key?('query-continue') 
                rvstartid = result['query-continue']['revisions']['rvstartid']
            else
                finish = true
            end
        end
    end
    
    def history_diff( titles, rvlimit = 30, rvprop = "timestamp|comment|user|size", rvstartid = nil, rvendid = nil, rvdir = "older", rvuser= nil, diffto = "prev")
        pages = Hash.new
        finish = false
        while !finish
            result = @site.query_prop_revisions("japonés", rvprop, rvlimit, rvstartid, rvendid, nil, nil, rvdir, rvuser, nil, nil, nil, nil, nil, nil, "prev")
            result['query']['pages']['page']['revisions'].each {|rv|
                yield rv
            }
            if result.key?('query-continue') 
                rvstartid = result['query-continue']['revisions']['rvstartid']
            else
                finish = true
            end
        end
    end
end 
